/// @invariant: The word and definition are non-empty display strings.
class WordOfTheDay {
  const WordOfTheDay({required this.word, required this.definition})
    : assert(word != ''),
      assert(definition != '');

  final String word;
  final String definition;
}

/// @invariant: Implementations return a complete word for the requested date.
abstract interface class WordRepository {
  /// @precondition: [date] is the date for which the word is requested.
  /// @postcondition: Completes with a non-empty word and definition.
  Future<WordOfTheDay> getWordFor(DateTime date);
}

/// @invariant: The fixed vocabulary is non-empty and provides a word per date.
class MockWordRepository implements WordRepository {
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
    WordOfTheDay(word: 'Mellifluous', definition: 'Sweet or musical to hear.'),
  ];

  /// @precondition: [date] is a valid calendar date.
  /// @postcondition: The same date always selects the same vocabulary entry.
  @override
  Future<WordOfTheDay> getWordFor(DateTime date) async {
    final day = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(2020)).inDays;
    return _words[day % _words.length];
  }
}
