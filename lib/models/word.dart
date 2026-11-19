// Intellectual property of Strauch Development. All rights reserved.
import 'package:flutter/material.dart';

/// Subject areas a learner can opt into.
enum WordCategory {
  everyday('Everyday Life', Icons.home_outlined),
  work('Business & Work', Icons.work_outline),
  academic('Academic & Ideas', Icons.school_outlined),
  science('Science & Nature', Icons.eco_outlined),
  arts('Arts & Literature', Icons.palette_outlined),
  emotion('Mind & Emotion', Icons.psychology_outlined),
  travel('Food & Travel', Icons.travel_explore);

  const WordCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// How common or specialised a word is, from practical to niche.
enum Difficulty {
  practical('Practical', 'Useful words for everyday conversation'),
  intermediate('Intermediate', 'Sharpen your writing and speech'),
  niche('Niche', 'Rare, beautiful and obscure words');

  const Difficulty(this.label, this.description);

  final String label;
  final String description;
}

/// Immutable vocabulary entry.
///
/// @invariant: [word], [definition] and [id] are non-empty; [id] is unique in the word bank.
class Word {
  const Word({
    required this.word,
    required this.pronunciation,
    required this.partOfSpeech,
    required this.definition,
    required this.example,
    required this.category,
    required this.difficulty,
  });

  final String word;
  final String pronunciation;
  final String partOfSpeech;
  final String definition;
  final String example;
  final WordCategory category;
  final Difficulty difficulty;

  /// Stable identifier used for favorites and history persistence.
  String get id => word.toLowerCase().replaceAll(' ', '-');

  /// Payload consumed by the native iOS widget.
  Map<String, String> toWidgetJson() => {
    'id': id,
    'word': word,
    'pronunciation': pronunciation,
    'partOfSpeech': partOfSpeech,
    'definition': definition,
  };

  @override
  bool operator ==(Object other) => other is Word && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Word($word)';
}
