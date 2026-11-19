// Intellectual property of Strauch Development. All rights reserved.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../models/word.dart';

/// Pushes the learner's word rotation to the home screen widget.
abstract interface class WidgetSyncService {
  /// @precondition: [pool] is non-empty and [today] is in [pool].
  Future<void> sync({required List<Word> pool, required Word today});
}

/// Writes the full rotation to the App Group so the iOS widget can work out
/// each day's word on its own, without the app needing to be opened.
///
/// @invariant: Keys and [_iOSWidgetKind] match `WordOfTheDayWidget.swift`.
class HomeWidgetSyncService implements WidgetSyncService {
  static const String _iOSWidgetKind = 'WordOfTheDayWidget';
  static const String _poolKey = 'word_pool';
  static const String _wordKey = 'daily_word';
  static const String _definitionKey = 'daily_def';

  @override
  Future<void> sync({required List<Word> pool, required Word today}) async {
    if (pool.isEmpty) {
      throw ArgumentError.value(pool, 'pool', 'Must not be empty.');
    }

    final results = await Future.wait<bool?>([
      HomeWidget.saveWidgetData<String>(
        _poolKey,
        jsonEncode([for (final w in pool) w.toWidgetJson()]),
      ),
      // Fallback keys used if the pool can't be decoded.
      HomeWidget.saveWidgetData<String>(_wordKey, today.word),
      HomeWidget.saveWidgetData<String>(_definitionKey, today.definition),
    ]);
    if (results.any((ok) => ok != true)) {
      throw StateError('Failed to save the word rotation for the widget.');
    }

    // Only iOS has a widget extension in this project.
    if (defaultTargetPlatform != TargetPlatform.iOS) return;

    final updated = await HomeWidget.updateWidget(iOSName: _iOSWidgetKind);
    if (updated == false) {
      throw StateError('Failed to reload the $_iOSWidgetKind widget.');
    }
  }
}
