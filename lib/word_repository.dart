// Intellectual property of Strauch Development. All rights reserved.

/// Immutable value object representing a single daily vocabulary entry.
///
/// @invariant: [word] and [definition] are non-empty strings.
class WordOfTheDay {
  const WordOfTheDay({required this.word, required this.definition})
    : assert(word != '', 'Word must not be empty'),
      assert(definition != '', 'Definition must not be empty');

  final String word;
  final String definition;

  /// Runtime check that survives release-mode assertion stripping.
  ///
  /// @postcondition: Returns true if and only if both fields contain non-whitespace characters.
  bool get isValid => word.trim().isNotEmpty && definition.trim().isNotEmpty;

  /// Serializes this entry into a JSON-compatible map for the native bridge.
  ///
  /// @precondition: [isValid] is true.
  /// @postcondition: Returns a map containing non-empty 'word' and 'definition' keys.
  Map<String, String> toJson() => {
    'word': word,
    'definition': definition,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordOfTheDay &&
          runtimeType == other.runtimeType &&
          word == other.word &&
          definition == other.definition;

  @override
  int get hashCode => Object.hash(word, definition);
}

/// Contract for retrieving deterministic words assigned to calendar dates.
///
/// @invariant: Implementations are deterministic for any given calendar date.
abstract interface class WordRepository {
  /// @precondition: [date] is a valid [DateTime] instance.
  /// @postcondition: Completes with a valid [WordOfTheDay] where [WordOfTheDay.isValid] is true.
  Future<WordOfTheDay> getWordFor(DateTime date);

  /// Generates a map of ISO date strings (YYYY-MM-DD) to [WordOfTheDay] entries.
  ///
  /// @precondition: [days] is strictly greater than 0.
  /// @postcondition: Returns a map with exactly [days] entries starting from [startDate].
  Future<Map<String, WordOfTheDay>> getSchedule({
    required DateTime startDate,
    required int days,
  });
}

/// Deterministic in-memory repository backed by a curated static vocabulary list.
///
/// @invariant: [_words] is non-empty and all entries satisfy [WordOfTheDay.isValid].
class MockWordRepository implements WordRepository {
  static final DateTime _epoch = DateTime.utc(2020, 1, 1);

  static const List<WordOfTheDay> _words = [
    WordOfTheDay(
      word: 'Petrichor',
      definition:
          'The earthy scent that follows the first rain after a dry spell.',
    ),
    WordOfTheDay(
      word: 'Sonder',
      definition:
          'The realization that every passerby has a life as vivid as yours.',
    ),
    WordOfTheDay(
      word: 'Apricity',
      definition: 'The warmth of the sun in winter.',
    ),
    WordOfTheDay(
      word: 'Limerence',
      definition: 'An intense, involuntary longing for another person.',
    ),
    WordOfTheDay(
      word: 'Mellifluous',
      definition: 'Sweet or musical to hear.',
    ),
  ];

  /// Computes a timezone-agnostic day offset from [_epoch] to select a word.
  ///
  /// @precondition: [date] is a valid calendar date.
  /// @postcondition: Returns the same [WordOfTheDay] for any [DateTime] on the same calendar date.
  @override
  Future<WordOfTheDay> getWordFor(DateTime date) async {
    final normalizedDate = DateTime.utc(date.year, date.month, date.day);
    final dayOffset = normalizedDate.difference(_epoch).inDays;
    return _words[dayOffset % _words.length];
  }

  /// Builds a multi-day schedule using DST-safe calendar arithmetic.
  ///
  /// @precondition: [days] is greater than 0.
  /// @postcondition: Completes with [days] consecutive date-keyed vocabulary entries.
  @override
  Future<Map<String, WordOfTheDay>> getSchedule({
    required DateTime startDate,
    required int days,
  }) async {
    if (days <= 0) {
      throw ArgumentError.value(days, 'days', 'Must be greater than 0.');
    }

    final schedule = <String, WordOfTheDay>{};
    for (var offset = 0; offset < days; offset++) {
      // Calendar constructor arithmetic avoids 23/25-hour Daylight Saving Time drift.
      final targetDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day + offset,
      );
      final key = _formatDateKey(targetDate);
      schedule[key] = await getWordFor(targetDate);
    }
    return schedule;
  }

  /// Formats [date] as a zero-padded YYYY-MM-DD key matching the Swift parser.
  ///
  /// @postcondition: Returns a 10-character ISO-8601 calendar date string.
  static String _formatDateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}