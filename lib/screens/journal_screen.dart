// Intellectual property of Strauch Development. All rights reserved.
import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/word.dart';
import '../theme.dart';
import '../widgets/word_card.dart';
import 'today_screen.dart';

enum _JournalView { history, saved }

/// Past words and saved favorites.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  _JournalView _view = _JournalView.history;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    final List<(String?, Word)> rows = switch (_view) {
      _JournalView.history => [
        for (final entry in controller.history)
          (formatShortDate(entry.date), entry.word),
      ],
      _JournalView.saved => [
        for (final word in controller.favorites) (null, word),
      ],
    };

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR WORDS', style: eyebrow(AppColors.muted)),
                const SizedBox(height: 6),
                Text(
                  'Journal',
                  style: serif.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<_JournalView>(
                    showSelectedIcon: false,
                    segments: [
                      const ButtonSegment(
                        value: _JournalView.history,
                        label: Text('History'),
                        icon: Icon(Icons.history),
                      ),
                      ButtonSegment(
                        value: _JournalView.saved,
                        label: Text('Saved (${controller.favorites.length})'),
                        icon: const Icon(Icons.bookmark_border),
                      ),
                    ],
                    selected: {_view},
                    onSelectionChanged: (s) => setState(() => _view = s.first),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (rows.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(view: _view),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList.separated(
              itemCount: rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final (date, word) = rows[index];
                return _JournalTile(
                  date: date,
                  word: word,
                  isFavorite: controller.isFavorite(word),
                  onTap: () => showWordSheet(
                    context,
                    word: word,
                    isFavorite: () => controller.isFavorite(word),
                    onFavoriteToggled: () => controller.toggleFavorite(word),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _JournalTile extends StatelessWidget {
  const _JournalTile({
    required this.date,
    required this.word,
    required this.isFavorite,
    required this.onTap,
  });

  final String? date;
  final Word word;
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          child: Row(
            children: [
              if (date != null) ...[
                SizedBox(
                  width: 52,
                  child: Text(
                    date!.toUpperCase(),
                    style: eyebrow(AppColors.gold).copyWith(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.word,
                      style: serif.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      word.definition,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (isFavorite)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.bookmark, size: 18, color: AppColors.gold),
                ),
              const Icon(Icons.chevron_right, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.view});

  final _JournalView view;

  @override
  Widget build(BuildContext context) {
    final (icon, title, body) = switch (view) {
      _JournalView.history => (
        Icons.auto_stories_outlined,
        'No words yet',
        'Each day\'s word will appear here.',
      ),
      _JournalView.saved => (
        Icons.bookmark_border,
        'Nothing saved yet',
        'Tap the bookmark on any word to keep it here.',
      ),
    };

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 44, color: AppColors.outline),
          const SizedBox(height: 16),
          Text(
            title,
            style: serif.copyWith(fontSize: 20, color: AppColors.cream),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
