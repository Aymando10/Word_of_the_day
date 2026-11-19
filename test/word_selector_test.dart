import 'package:flutter_test/flutter_test.dart';
import 'package:word_of_the_day/data/word_bank.dart';
import 'package:word_of_the_day/models/word.dart';
import 'package:word_of_the_day/services/word_selector.dart';

void main() {
  group('word bank', () {
    test('ids are unique', () {
      final ids = wordBank.map((w) => w.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every category and difficulty pair has words', () {
      for (final c in WordCategory.values) {
        for (final d in Difficulty.values) {
          expect(
            wordBank.where((w) => w.category == c && w.difficulty == d),
            isNotEmpty,
            reason: '${c.name}/${d.name} is empty',
          );
        }
      }
    });

    test('entries have every field filled in', () {
      for (final w in wordBank) {
        for (final field in [
          w.word,
          w.pronunciation,
          w.partOfSpeech,
          w.definition,
          w.example,
        ]) {
          expect(field.trim(), isNotEmpty, reason: w.word);
        }
      }
    });
  });

  group('dayIndex', () {
    test('epoch is day zero', () {
      expect(dayIndex(DateTime(2020, 1, 1)), 0);
      expect(dayIndex(DateTime(2020, 1, 2, 23, 59)), 1);
    });

    test('ignores time of day and DST changes', () {
      // Consecutive days across a DST transition differ by exactly one.
      expect(
        dayIndex(DateTime(2026, 3, 30)) - dayIndex(DateTime(2026, 3, 29)),
        1,
      );
      expect(dayIndex(DateTime(2026, 11, 19, 0, 1)),
          dayIndex(DateTime(2026, 11, 19, 23, 59)));
    });
  });

  group('buildPool', () {
    test('only includes selected categories and difficulties', () {
      final pool = buildPool(
        wordBank,
        categories: {WordCategory.science},
        difficulties: {Difficulty.niche},
      );
      expect(pool, isNotEmpty);
      expect(
        pool.every(
          (w) =>
              w.category == WordCategory.science &&
              w.difficulty == Difficulty.niche,
        ),
        isTrue,
      );
    });

    test('order is deterministic regardless of input order', () {
      final selection = (
        categories: WordCategory.values.toSet(),
        difficulties: Difficulty.values.toSet(),
      );
      final a = buildPool(
        wordBank,
        categories: selection.categories,
        difficulties: selection.difficulties,
      );
      final b = buildPool(
        wordBank.reversed,
        categories: selection.categories,
        difficulties: selection.difficulties,
      );
      expect(a.map((w) => w.id), b.map((w) => w.id));
    });
  });

  group('wordForDate', () {
    final pool = buildPool(
      wordBank,
      categories: WordCategory.values.toSet(),
      difficulties: Difficulty.values.toSet(),
    );

    test('same word all day', () {
      expect(
        wordForDate(pool, DateTime(2026, 5, 1, 0, 0)),
        wordForDate(pool, DateTime(2026, 5, 1, 23, 59)),
      );
    });

    test('no repeats until the pool is exhausted', () {
      final start = DateTime(2026, 1, 1);
      final seen = {
        for (var i = 0; i < pool.length; i++)
          wordForDate(pool, DateTime(start.year, start.month, start.day + i)).id,
      };
      expect(seen.length, pool.length);
    });

    test('throws on an empty pool', () {
      expect(() => wordForDate(const [], DateTime(2026)), throwsStateError);
    });
  });

  test('dateKey round-trips', () {
    final date = DateTime(2026, 3, 7);
    expect(dateKey(date), '2026-03-07');
    expect(parseDateKey(dateKey(date)), date);
    expect(parseDateKey('nonsense'), isNull);
  });
}
