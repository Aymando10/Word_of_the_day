// Intellectual property of Strauch Development. All rights reserved.
import 'dart:convert';

import 'package:flutter/material.dart';

import 'data/word_bank.dart';
import 'models/word.dart';
import 'services/notification_service.dart';
import 'services/storage.dart';
import 'services/widget_sync_service.dart';
import 'services/word_selector.dart';

/// A word shown on a particular day.
class HistoryEntry {
  const HistoryEntry(this.date, this.word);

  final DateTime date;
  final Word word;
}

enum SyncStatus { idle, syncing, synced, failed }

/// Result of trying to turn reminders on.
enum ReminderResult { enabled, disabled, permissionDenied }

/// Single source of truth for the app: preferences, today's word, history,
/// favorites, and keeping the widget and reminders in sync.
///
/// @invariant: Once [isReady], [categories] and [difficulties] are non-empty,
/// so [pool] is non-empty and [today] is defined.
class AppController extends ChangeNotifier {
  AppController({
    required KeyValueStore store,
    required WidgetSyncService widgetSync,
    required NotificationService notifications,
    List<Word>? bank,
    DateTime Function()? clock,
  }) : _store = store,
       _widgetSync = widgetSync,
       _notifications = notifications,
       _bank = bank ?? wordBank,
       _clock = clock ?? DateTime.now;

  static const int reminderDays = 30;
  static const int _historyBackfillDays = 30;
  static const int _historyLimit = 365;

  static const String _categoriesKey = 'pref_categories';
  static const String _difficultiesKey = 'pref_difficulties';
  static const String _favoritesKey = 'favorites';
  static const String _historyKey = 'history';
  static const String _reminderKey = 'reminder';

  final KeyValueStore _store;
  final WidgetSyncService _widgetSync;
  final NotificationService _notifications;
  final List<Word> _bank;
  final DateTime Function() _clock;

  late final Map<String, Word> _byId = {for (final w in _bank) w.id: w};

  Set<WordCategory> _categories = WordCategory.values.toSet();
  Set<Difficulty> _difficulties = Difficulty.values.toSet();
  List<String> _favoriteIds = [];
  Map<String, String> _history = {};
  bool _remindersEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  List<Word> _pool = const [];
  late DateTime _todayDate;
  late Word _today;
  bool _ready = false;
  SyncStatus _syncStatus = SyncStatus.idle;
  Future<void> _syncQueue = Future.value();

  // ---------------------------------------------------------------------------
  // Read-only state
  // ---------------------------------------------------------------------------

  bool get isReady => _ready;
  Word get today => _today;
  DateTime get todayDate => _todayDate;
  List<Word> get pool => _pool;
  int get totalWords => _bank.length;
  Set<WordCategory> get categories => Set.unmodifiable(_categories);
  Set<Difficulty> get difficulties => Set.unmodifiable(_difficulties);
  bool get remindersEnabled => _remindersEnabled;
  TimeOfDay get reminderTime => _reminderTime;
  SyncStatus get syncStatus => _syncStatus;

  bool isFavorite(Word word) => _favoriteIds.contains(word.id);

  List<Word> get favorites => [
    for (final id in _favoriteIds)
      if (_byId[id] case final word?) word,
  ];

  /// Words shown so far, newest first.
  List<HistoryEntry> get history {
    final entries = <HistoryEntry>[];
    for (final MapEntry(:key, :value) in _history.entries) {
      final date = parseDateKey(key);
      final word = _byId[value];
      if (date != null && word != null) entries.add(HistoryEntry(date, word));
    }
    return entries..sort((a, b) => b.date.compareTo(a.date));
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Loads saved preferences, works out today's word and syncs the widget.
  Future<void> initialize() async {
    await _loadPreferences();
    _rebuildToday();
    _ready = true;
    notifyListeners();
    await _save(_historyKey, jsonEncode(_history));
    await _syncAll();
  }

  /// Call when the app returns to the foreground; refreshes on a new day.
  Future<void> refreshIfNewDay() async {
    if (!_ready || dateOnly(_clock()) == _todayDate) return;
    _rebuildToday();
    notifyListeners();
    await _save(_historyKey, jsonEncode(_history));
    await _syncAll();
  }

  /// Re-pushes everything to the widget and reminder scheduler.
  Future<void> syncNow() => _syncAll();

  // ---------------------------------------------------------------------------
  // Preferences
  // ---------------------------------------------------------------------------

  /// Toggles [category]. Returns false if it is the last selected one.
  Future<bool> toggleCategory(WordCategory category) async {
    final next = {..._categories};
    if (!next.remove(category)) next.add(category);
    if (next.isEmpty) return false;
    _categories = next;
    await _selectionChanged(
      _categoriesKey,
      _categories.map((c) => c.name).toList(),
    );
    return true;
  }

  /// Toggles [difficulty]. Returns false if it is the last selected one.
  Future<bool> toggleDifficulty(Difficulty difficulty) async {
    final next = {..._difficulties};
    if (!next.remove(difficulty)) next.add(difficulty);
    if (next.isEmpty) return false;
    _difficulties = next;
    await _selectionChanged(
      _difficultiesKey,
      _difficulties.map((d) => d.name).toList(),
    );
    return true;
  }

  Future<void> toggleFavorite(Word word) async {
    if (!_favoriteIds.remove(word.id)) _favoriteIds.insert(0, word.id);
    notifyListeners();
    await _save(_favoritesKey, jsonEncode(_favoriteIds));
  }

  Future<ReminderResult> setRemindersEnabled(bool enabled) async {
    if (enabled && !await _notifications.requestPermission()) {
      return ReminderResult.permissionDenied;
    }
    _remindersEnabled = enabled;
    notifyListeners();
    await _saveReminder();
    await _enqueue(_syncReminders);
    return enabled ? ReminderResult.enabled : ReminderResult.disabled;
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    notifyListeners();
    await _saveReminder();
    await _enqueue(_syncReminders);
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<void> _selectionChanged(String key, List<String> names) async {
    _rebuildToday();
    notifyListeners();
    await _save(key, jsonEncode(names));
    await _save(_historyKey, jsonEncode(_history));
    await _syncAll();
  }

  /// Recomputes the pool and today's word, and records today in history.
  void _rebuildToday() {
    _todayDate = dateOnly(_clock());
    _pool = buildPool(
      _bank,
      categories: _categories,
      difficulties: _difficulties,
    );
    _today = wordForDate(_pool, _todayDate);
    _recordHistory();
  }

  /// Fills in days missed since the app was last opened (as the widget would
  /// have shown them), then records today's word.
  void _recordHistory() {
    final earlier = _history.keys
        .map(parseDateKey)
        .whereType<DateTime>()
        .where((d) => d.isBefore(_todayDate))
        .toList();

    if (earlier.isNotEmpty) {
      final last = earlier.reduce((a, b) => a.isAfter(b) ? a : b);
      final earliest = _addDays(_todayDate, -_historyBackfillDays);
      var cursor = _addDays(last, 1);
      if (cursor.isBefore(earliest)) cursor = earliest;
      while (cursor.isBefore(_todayDate)) {
        _history.putIfAbsent(dateKey(cursor), () => wordForDate(_pool, cursor).id);
        cursor = _addDays(cursor, 1);
      }
    }

    _history[dateKey(_todayDate)] = _today.id;

    if (_history.length > _historyLimit) {
      final keys = _history.keys.toList()..sort();
      for (final key in keys.take(_history.length - _historyLimit)) {
        _history.remove(key);
      }
    }
  }

  Future<void> _syncAll() => _enqueue(() async {
    _syncStatus = SyncStatus.syncing;
    notifyListeners();
    try {
      await _widgetSync.sync(pool: _pool, today: _today);
      await _syncReminders();
      _syncStatus = SyncStatus.synced;
    } catch (error, stackTrace) {
      debugPrint('Sync failed: $error\n$stackTrace');
      _syncStatus = SyncStatus.failed;
    }
    notifyListeners();
  });

  Future<void> _syncReminders() async {
    if (!_remindersEnabled) {
      await _notifications.cancelAll();
      return;
    }
    final now = _clock();
    final reminders = <ScheduledReminder>[];
    for (var offset = 0; offset < reminderDays; offset++) {
      final day = _addDays(_todayDate, offset);
      final fireAt = DateTime(
        day.year,
        day.month,
        day.day,
        _reminderTime.hour,
        _reminderTime.minute,
      );
      if (!fireAt.isAfter(now)) continue;
      final word = wordForDate(_pool, day);
      reminders.add(
        ScheduledReminder(
          date: day,
          hour: _reminderTime.hour,
          minute: _reminderTime.minute,
          title: 'Today\'s word: ${word.word}',
          body: '${word.partOfSpeech} · ${word.definition}',
        ),
      );
    }
    await _notifications.schedule(reminders);
  }

  /// Runs [task] after any in-flight sync, so rapid changes apply in order.
  Future<void> _enqueue(Future<void> Function() task) {
    final next = _syncQueue.then((_) => task()).catchError((Object error) {
      debugPrint('Background task failed: $error');
    });
    _syncQueue = next;
    return next;
  }

  Future<void> _loadPreferences() async {
    _categories = await _readEnumSet(
      _categoriesKey,
      WordCategory.values,
      (c) => c.name,
    );
    _difficulties = await _readEnumSet(
      _difficultiesKey,
      Difficulty.values,
      (d) => d.name,
    );
    _favoriteIds = await _readJson(_favoritesKey, (json) {
      return (json as List).whereType<String>().toList();
    }, []);
    _history = await _readJson(_historyKey, (json) {
      return (json as Map).map((k, v) => MapEntry(k as String, v as String));
    }, {});
    await _readJson<void>(_reminderKey, (json) {
      final map = json as Map;
      _remindersEnabled = map['enabled'] == true;
      final hour = map['hour'];
      final minute = map['minute'];
      if (hour is int && minute is int) {
        _reminderTime = TimeOfDay(hour: hour, minute: minute);
      }
    }, null);
  }

  /// Reads a saved set of enum names, falling back to all values if missing,
  /// unreadable or empty.
  Future<Set<T>> _readEnumSet<T>(
    String key,
    List<T> values,
    String Function(T) name,
  ) => _readJson(key, (json) {
    final names = (json as List).whereType<String>().toSet();
    final selected = values.where((v) => names.contains(name(v))).toSet();
    return selected.isEmpty ? values.toSet() : selected;
  }, values.toSet());

  Future<T> _readJson<T>(
    String key,
    T Function(Object? json) parse,
    T fallback,
  ) async {
    try {
      final raw = await _store.read(key);
      if (raw == null || raw.isEmpty) return fallback;
      return parse(jsonDecode(raw));
    } catch (error) {
      debugPrint('Ignoring unreadable "$key": $error');
      return fallback;
    }
  }

  Future<void> _saveReminder() => _save(
    _reminderKey,
    jsonEncode({
      'enabled': _remindersEnabled,
      'hour': _reminderTime.hour,
      'minute': _reminderTime.minute,
    }),
  );

  Future<void> _save(String key, String value) async {
    try {
      await _store.write(key, value);
    } catch (error) {
      debugPrint('Failed to save "$key": $error');
    }
  }

  static DateTime _addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);
}
