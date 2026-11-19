// Intellectual property of Strauch Development. All rights reserved.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import 'word_repository.dart';

/// @precondition: Flutter engine is ready to bind platform channels.
/// @postcondition: Initializes platform bindings and launches [WordApp].
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WordApp());
}

/// Root application widget configuring theme and navigation entry point.
///
/// @invariant: The app always starts at [WordOfTheDayPage].
class WordApp extends StatelessWidget {
  const WordApp({super.key});

  /// @postcondition: Returns the configured [MaterialApp].
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word of the Day',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315B52)),
        useMaterial3: true,
      ),
      home: const WordOfTheDayPage(),
    );
  }
}

/// Primary screen displaying the daily word and manual widget sync controls.
///
/// @invariant: Always presents a valid [WordOfTheDay] and reflects active sync status.
class WordOfTheDayPage extends StatefulWidget {
  const WordOfTheDayPage({super.key});

  /// @postcondition: Creates the mutable state managing word retrieval and widget synchronization.
  @override
  State<WordOfTheDayPage> createState() => _WordOfTheDayPageState();
}

/// Manages lifecycle events, daily word retrieval, and native multi-day widget syncing.
///
/// @invariant: [_word.isValid] is true, and [_isSyncing] blocks concurrent sync calls.
class _WordOfTheDayPageState extends State<WordOfTheDayPage>
    with WidgetsBindingObserver {
  static const int _lookaheadDays = 14;

  final WordRepository _repository = MockWordRepository();
  final WidgetSyncService _syncService = WidgetSyncService();

  WordOfTheDay _word = const WordOfTheDay(
    word: 'Word of the Day',
    definition: 'Sync today\'s word to see it here.',
  );
  DateTime? _lastSyncedDate;
  bool _isSyncing = false;
  String? _errorMessage;

  /// @postcondition: Registers lifecycle observer and triggers initial schedule sync.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  /// @postcondition: Unregisters the lifecycle observer to prevent memory leaks.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Automatically refreshes if the user returns to the app on a new calendar day.
  ///
  /// @precondition: Observer is registered with [WidgetsBinding].
  /// @postcondition: Triggers [_refresh] if [state] is resumed and the calendar day changed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (_lastSyncedDate != today) {
        _refresh();
      }
    }
  }

  /// Fetches a 14-day schedule, updates the UI with today's word, and syncs the native widget.
  ///
  /// @precondition: State is mounted and no sync operation is currently in progress.
  /// @postcondition: Updates [_word] and persists a [_lookaheadDays] schedule to WidgetKit.
  Future<void> _refresh() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
      _errorMessage = null;
    });

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final schedule = await _repository.getSchedule(
        startDate: today,
        days: _lookaheadDays,
      );
      final todayWord = schedule.values.first;

      if (!mounted) return;
      setState(() => _word = todayWord);

      await _syncService.syncSchedule(todayWord: todayWord, schedule: schedule);
      _lastSyncedDate = today;
    } catch (error, stackTrace) {
      debugPrint('Widget sync failed: $error\n$stackTrace');
      if (mounted) {
        setState(() => _errorMessage = 'Could not sync the widget. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  /// @postcondition: Renders the vocabulary card, sync button, and any active error banner.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Word of the Day')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _word.word,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _word.definition,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _isSyncing ? null : _refresh,
                    icon: _isSyncing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(_isSyncing ? 'Syncing...' : 'Sync widget'),
                  ),
                  if (_errorMessage case final message?) ...[
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Service bridging Flutter data to the native iOS WidgetKit extension via shared UserDefaults.
///
/// @invariant: [_appGroupId] and [_iOSWidgetKind] match the native Xcode target configuration.
class WidgetSyncService {
  // IMPORTANT: Ensure this matches the exact App Group checked in Xcode Signing & Capabilities.
  static const String _appGroupId = 'group.com.aymanstrauch.wordapp';
  static const String _iOSWidgetKind = 'WordOfTheDayWidget';

  static const String _wordKey = 'daily_word';
  static const String _definitionKey = 'daily_def';
  static const String _scheduleKey = 'word_schedule';

  bool _isGroupConfigured = false;

  /// Persists both the immediate fallback keys and the multi-day JSON schedule to shared storage.
  ///
  /// @precondition: [todayWord.isValid] is true and all values in [schedule] satisfy [WordOfTheDay.isValid].
  /// @postcondition: Shared UserDefaults contains the serialized schedule and WidgetKit reloads its timeline.
  Future<void> syncSchedule({
    required WordOfTheDay todayWord,
    required Map<String, WordOfTheDay> schedule,
  }) async {
    if (!todayWord.isValid ||
        schedule.isEmpty ||
        schedule.values.any((w) => !w.isValid)) {
      throw ArgumentError('Cannot sync an empty or invalid word schedule.');
    }

    if (!_isGroupConfigured) {
      final groupSet = await HomeWidget.setAppGroupId(_appGroupId);
      if (groupSet == false) {
        throw StateError('Failed to configure App Group: $_appGroupId');
      }
      _isGroupConfigured = true;
    }

    final serializedSchedule = jsonEncode(
      schedule.map((dateKey, entry) => MapEntry(dateKey, entry.toJson())),
    );

    final results = await Future.wait<bool?>([
      HomeWidget.saveWidgetData<String>(_wordKey, todayWord.word),
      HomeWidget.saveWidgetData<String>(_definitionKey, todayWord.definition),
      HomeWidget.saveWidgetData<String>(_scheduleKey, serializedSchedule),
    ]);

    if (results.any((succeeded) => succeeded != true)) {
      throw StateError('Failed to persist word schedule to shared UserDefaults.');
    }

    final updated = await HomeWidget.updateWidget(
      name: _iOSWidgetKind,
      iOSName: _iOSWidgetKind,
    );

    if (updated == false) {
      throw StateError('Failed to trigger WidgetKit reload for $_iOSWidgetKind.');
    }
  }
}