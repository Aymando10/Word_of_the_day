// Intellectual property of Strauch Development. All rights reserved.
import 'dart:math';

import '../models/word.dart';

/// Day zero of the rotation. The Swift widget uses the same epoch, so both
/// sides pick the same word for any calendar date.
final DateTime rotationEpoch = DateTime.utc(2020, 1, 1);

/// Fixed seed so the shuffled pool order is identical on every launch.
const int _poolSeed = 0x5EED;

/// Whole calendar days between [rotationEpoch] and the local calendar date of [date].
///
/// Uses UTC calendar components so Daylight Saving Time never shifts the count.
int dayIndex(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day).difference(rotationEpoch).inDays;

/// Strips the time from [date], returning local midnight of the same calendar day.
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Zero-padded `YYYY-MM-DD` key for [date].
String dateKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Parses a key produced by [dateKey]; returns null if malformed.
DateTime? parseDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  return DateTime(y, m, d);
}

/// Builds the ordered rotation of words matching the learner's selections.
///
/// The order is a deterministic shuffle, so categories and difficulties are
/// mixed rather than clustered, and no word repeats until the pool is exhausted.
///
/// @postcondition: Returns an unmodifiable list; empty only if nothing matches.
List<Word> buildPool(
  Iterable<Word> bank, {
  required Set<WordCategory> categories,
  required Set<Difficulty> difficulties,
}) {
  final matches =
      bank
          .where(
            (w) =>
                categories.contains(w.category) &&
                difficulties.contains(w.difficulty),
          )
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id))
        ..shuffle(Random(_poolSeed));
  return List.unmodifiable(matches);
}

/// The word assigned to [date] within [pool].
///
/// @precondition: [pool] is non-empty.
Word wordForDate(List<Word> pool, DateTime date) {
  if (pool.isEmpty) {
    throw StateError('Cannot pick a word from an empty pool.');
  }
  return pool[dayIndex(date) % pool.length];
}
