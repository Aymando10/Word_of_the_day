// Intellectual property of Strauch Development. All rights reserved.
import 'package:flutter/material.dart';

import '../models/word.dart';
import '../theme.dart';

/// The hero presentation of a word: tag, word, pronunciation, definition and example.
class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.word,
    required this.isFavorite,
    required this.onFavoriteToggled,
  });

  final Word word;
  final bool isFavorite;
  final VoidCallback onFavoriteToggled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.outline),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceRaised, AppColors.surface],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(26, 18, 14, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(word.category.icon, size: 16, color: AppColors.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${word.category.label} · ${word.difficulty.label}'
                      .toUpperCase(),
                  style: eyebrow(AppColors.gold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: isFavorite ? 'Remove from saved' : 'Save word',
                onPressed: onFavoriteToggled,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    key: ValueKey(isFavorite),
                    color: isFavorite ? AppColors.gold : AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    word.word,
                    style: serif.copyWith(
                      fontSize: 46,
                      height: 1.05,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: word.pronunciation),
                      const TextSpan(text: '   '),
                      TextSpan(
                        text: word.partOfSpeech,
                        style: const TextStyle(color: AppColors.sage),
                      ),
                    ],
                  ),
                  style: serif.copyWith(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 22),
                Container(width: 44, height: 2, color: AppColors.gold),
                const SizedBox(height: 22),
                Text(
                  word.definition,
                  style: const TextStyle(
                    fontSize: 19,
                    height: 1.45,
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(left: 14),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppColors.sage, width: 2),
                    ),
                  ),
                  child: Text(
                    '“${word.example}”',
                    style: serif.copyWith(
                      fontSize: 16,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens [word] in a bottom sheet.
Future<void> showWordSheet(
  BuildContext context, {
  required Word word,
  required bool Function() isFavorite,
  required VoidCallback onFavoriteToggled,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: WordCard(
            word: word,
            isFavorite: isFavorite(),
            onFavoriteToggled: () {
              onFavoriteToggled();
              setState(() {});
            },
          ),
        ),
      ),
    ),
  );
}
