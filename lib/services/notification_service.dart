// Intellectual property of Strauch Development. All rights reserved.
import 'package:flutter/services.dart';

/// A single reminder to deliver at a local date and time.
class ScheduledReminder {
  const ScheduledReminder({
    required this.date,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
  });

  final DateTime date;
  final int hour;
  final int minute;
  final String title;
  final String body;

  Map<String, Object> toMap() => {
    'year': date.year,
    'month': date.month,
    'day': date.day,
    'hour': hour,
    'minute': minute,
    'title': title,
    'body': body,
  };
}

/// Schedules the daily word reminders.
abstract interface class NotificationService {
  /// Asks the OS for permission; returns whether reminders may be shown.
  Future<bool> requestPermission();

  /// Replaces any previously scheduled reminders with [reminders].
  Future<void> schedule(List<ScheduledReminder> reminders);

  /// Removes all scheduled reminders.
  Future<void> cancelAll();
}

/// Talks to the native scheduler in `ios/Runner/AppDelegate.swift`.
///
/// On platforms without the native side, calls quietly do nothing.
class NativeNotificationService implements NotificationService {
  static const MethodChannel _channel = MethodChannel(
    'com.aymanstrauch.wordapp/notifications',
  );

  @override
  Future<bool> requestPermission() async {
    try {
      return await _channel.invokeMethod<bool>('requestPermission') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> schedule(List<ScheduledReminder> reminders) async {
    try {
      await _channel.invokeMethod<void>('schedule', {
        'items': [for (final r in reminders) r.toMap()],
      });
    } on MissingPluginException {
      // Not supported on this platform.
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _channel.invokeMethod<void>('cancelAll');
    } on MissingPluginException {
      // Not supported on this platform.
    }
  }
}
