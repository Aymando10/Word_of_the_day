import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import 'word_repository.dart';

/// @precondition: Flutter bindings can be initialized by the current runtime.
/// @postcondition: Launches the Word of the Day application.
void main() {
  runApp(const WordApp());
}

/// @invariant: The app always starts at the daily-word screen.
class WordApp extends StatelessWidget {
  const WordApp({super.key});

  /// @postcondition: Returns the single-screen daily-word application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word of the Day',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315B52)),
        useMaterial3: true,
      ),
      home: const WordOfTheDayPage(),
    );
  }
}

/// @invariant: The page presents a valid word and keeps sync state explicit.
class WordOfTheDayPage extends StatefulWidget {
  const WordOfTheDayPage({super.key});

  /// @postcondition: Creates the state that loads and syncs today's word.
  @override
  State<WordOfTheDayPage> createState() => _WordOfTheDayPageState();
}

/// @invariant: [_word] is always displayable and [_isSyncing] reflects active work.
class _WordOfTheDayPageState extends State<WordOfTheDayPage> {
  final WordRepository _repository = MockWordRepository();
  final WidgetSyncService _syncService = WidgetSyncService();
  WordOfTheDay _word = const WordOfTheDay(
    word: 'Word of the Day',
    definition: 'Sync today\'s word to see it here.',
  );
  bool _isSyncing = false;
  String? _errorMessage;

  /// @postcondition: Starts loading and sharing today's word with the widget.
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  /// @precondition: The state is mounted before UI updates are attempted.
  /// @postcondition: Shows today's word and requests a widget timeline refresh.
  Future<void> _refresh() async {
    setState(() {
      _isSyncing = true;
      _errorMessage = null;
    });

    try {
      final word = await _repository.getWordFor(DateTime.now());
      if (!mounted) return;
      setState(() => _word = word);
      await _syncService.sync(word);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not sync the widget. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  /// @postcondition: Renders today's word, definition, and a manual sync action.
  @override
  Widget build(BuildContext context) {
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
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _word.definition,
                    style: Theme.of(context).textTheme.titleMedium,
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
                    label: Text(_isSyncing ? 'Syncing' : 'Sync widget'),
                  ),
                  if (_errorMessage case final message?) ...[
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
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

/// @invariant: The bridge always writes both fields before refreshing the widget.
class WidgetSyncService {
  static const String _appGroupId = 'group.com.example.wordapp';

  /// @precondition: [word] contains a non-empty word and definition.
  /// @postcondition: Shared values are saved and the iOS widget is asked to reload.
  Future<void> sync(WordOfTheDay word) async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await HomeWidget.saveWidgetData<String>('daily_word', word.word);
    await HomeWidget.saveWidgetData<String>('daily_def', word.definition);
    await HomeWidget.updateWidget(iOSName: 'WordOfTheDayWidget');
  }
}
