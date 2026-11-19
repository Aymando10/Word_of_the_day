import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_of_the_day/app_controller.dart';
import 'package:word_of_the_day/models/word.dart';
import 'package:word_of_the_day/services/notification_service.dart';
import 'package:word_of_the_day/services/storage.dart';
import 'package:word_of_the_day/services/widget_sync_service.dart';
import 'package:word_of_the_day/services/word_selector.dart';

class FakeWidgetSync implements WidgetSyncService {
  final List<(List<Word>, Word)> calls = [];
  bool fail = false;

  @override
  Future<void> sync({required List<Word> pool, required Word today}) async {
    if (fail) throw StateError('boom');
    calls.add((pool, today));
  }
}

class FakeNotifications implements NotificationService {
  bool grant = true;
  List<ScheduledReminder>? scheduled;
  int cancels = 0;

  @override
  Future<bool> requestPermission() async => grant;

  @override
  Future<void> schedule(List<ScheduledReminder> reminders) async =>
      scheduled = reminders;

  @override
  Future<void> cancelAll() async {
    cancels++;
    scheduled = null;
  }
}

void main() {
  late InMemoryStore store;
  late FakeWidgetSync widgetSync;
  late FakeNotifications notifications;
  late DateTime now;

  AppController build() => AppController(
    store: store,
    widgetSync: widgetSync,
    notifications: notifications,
    clock: () => now,
  );

  setUp(() {
    store = InMemoryStore();
    widgetSync = FakeWidgetSync();
    notifications = FakeNotifications();
    now = DateTime(2026, 11, 19, 8, 30);
  });

  test('initializes with every category and difficulty and syncs the widget', () async {
    final c = build();
    await c.initialize();

    expect(c.isReady, isTrue);
    expect(c.categories, WordCategory.values.toSet());
    expect(c.difficulties, Difficulty.values.toSet());
    expect(c.pool.length, c.totalWords);
    expect(widgetSync.calls.single.$2, c.today);
    expect(c.syncStatus, SyncStatus.synced);
    expect(c.history.single.word, c.today);
  });

  test('cannot deselect the last category or difficulty', () async {
    final c = build();
    await c.initialize();

    for (final cat in WordCategory.values.skip(1)) {
      expect(await c.toggleCategory(cat), isTrue);
    }
    expect(await c.toggleCategory(WordCategory.values.first), isFalse);
    expect(c.categories, {WordCategory.values.first});

    expect(await c.toggleDifficulty(Difficulty.practical), isTrue);
    expect(await c.toggleDifficulty(Difficulty.intermediate), isTrue);
    expect(await c.toggleDifficulty(Difficulty.niche), isFalse);
  });

  test('changing selections filters the pool, resyncs and persists', () async {
    final c = build();
    await c.initialize();

    for (final cat in WordCategory.values) {
      if (cat != WordCategory.arts) await c.toggleCategory(cat);
    }
    await c.toggleDifficulty(Difficulty.practical);
    await c.toggleDifficulty(Difficulty.intermediate);

    expect(
      c.pool.every(
        (w) => w.category == WordCategory.arts && w.difficulty == Difficulty.niche,
      ),
      isTrue,
    );
    expect(c.today.category, WordCategory.arts);
    expect(widgetSync.calls.last.$1, c.pool);

    // A fresh controller restores the same selection from storage.
    final restored = build();
    await restored.initialize();
    expect(restored.categories, {WordCategory.arts});
    expect(restored.difficulties, {Difficulty.niche});
    expect(restored.today, c.today);
  });

  test('favorites toggle and persist, newest first', () async {
    final c = build();
    await c.initialize();
    final a = c.pool[0];
    final b = c.pool[1];

    await c.toggleFavorite(a);
    await c.toggleFavorite(b);
    expect(c.favorites, [b, a]);

    await c.toggleFavorite(a);
    expect(c.favorites, [b]);

    final restored = build();
    await restored.initialize();
    expect(restored.favorites, [b]);
  });

  test('backfills missed days and refreshes on a new day', () async {
    final c = build();
    await c.initialize();

    now = DateTime(2026, 11, 22, 7);
    await c.refreshIfNewDay();

    final dates = c.history.map((e) => dateKey(e.date)).toList();
    expect(dates, ['2026-11-22', '2026-11-21', '2026-11-20', '2026-11-19']);
    expect(c.today, wordForDate(c.pool, now));
    expect(widgetSync.calls.length, 2);
  });

  test('onboarding is shown once and remembered', () async {
    final c = build();
    await c.initialize();
    expect(c.hasSeenOnboarding, isFalse);

    await c.completeOnboarding();
    expect(c.hasSeenOnboarding, isTrue);

    final restored = build();
    await restored.initialize();
    expect(restored.hasSeenOnboarding, isTrue);
  });

  test('ignores corrupt stored data', () async {
    store.values['pref_categories'] = '{not json';
    store.values['history'] = jsonEncode(['wrong', 'shape']);
    final c = build();
    await c.initialize();
    expect(c.categories, WordCategory.values.toSet());
    expect(c.history, hasLength(1));
  });

  test('reports a failed widget sync', () async {
    widgetSync.fail = true;
    final c = build();
    await c.initialize();
    expect(c.syncStatus, SyncStatus.failed);
  });

  group('reminders', () {
    test('schedules upcoming days with the right words', () async {
      final c = build();
      await c.initialize();

      expect(await c.setRemindersEnabled(true), ReminderResult.enabled);
      final reminders = notifications.scheduled!;

      // 9:00 today is still ahead of 8:30, so today is included.
      expect(reminders, hasLength(AppController.reminderDays));
      expect(reminders.first.date, DateTime(2026, 11, 19));
      expect(reminders.first.title, contains(c.today.word));
      expect(
        reminders[1].title,
        contains(wordForDate(c.pool, DateTime(2026, 11, 20)).word),
      );
    });

    test('skips today once the reminder time has passed', () async {
      final c = build();
      await c.initialize();
      await c.setRemindersEnabled(true);
      await c.setReminderTime(const TimeOfDay(hour: 7, minute: 0));

      expect(notifications.scheduled!.first.date, DateTime(2026, 11, 20));
      expect(notifications.scheduled!.first.hour, 7);
    });

    test('stays off when permission is denied', () async {
      notifications.grant = false;
      final c = build();
      await c.initialize();

      expect(await c.setRemindersEnabled(true), ReminderResult.permissionDenied);
      expect(c.remindersEnabled, isFalse);
    });

    test('turning off cancels reminders', () async {
      final c = build();
      await c.initialize();
      await c.setRemindersEnabled(true);
      await c.setRemindersEnabled(false);
      expect(notifications.scheduled, isNull);
    });
  });
}
