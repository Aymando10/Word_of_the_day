// Intellectual property of Strauch Development. All rights reserved.
import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../app_scope.dart';
import '../theme.dart';
import '../widgets/word_card.dart';

const _weekdays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];
const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December',
];

String formatLongDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

String formatShortDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1].substring(0, 3)}';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final word = controller.today;

    return RefreshIndicator(
      color: AppColors.sage,
      backgroundColor: AppColors.surfaceRaised,
      onRefresh: controller.syncNow,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            formatLongDate(controller.todayDate).toUpperCase(),
            style: eyebrow(AppColors.muted),
          ),
          const SizedBox(height: 6),
          Text(
            'Word of the Day',
            style: serif.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 24),
          WordCard(
            word: word,
            isFavorite: controller.isFavorite(word),
            onFavoriteToggled: () => controller.toggleFavorite(word),
          ),
          const SizedBox(height: 22),
          _SyncStatusRow(
            status: controller.syncStatus,
            onRetry: controller.syncNow,
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.tune, size: 18),
              label: Text(
                '${controller.pool.length} words in your rotation',
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncStatusRow extends StatelessWidget {
  const _SyncStatusRow({required this.status, required this.onRetry});

  final SyncStatus status;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String label, Color color) = switch (status) {
      SyncStatus.idle || SyncStatus.syncing => (
        Icons.sync,
        'Updating your widget…',
        AppColors.muted,
      ),
      SyncStatus.synced => (
        Icons.check_circle_outline,
        'Widget up to date · updates itself daily',
        AppColors.sage,
      ),
      SyncStatus.failed => (
        Icons.error_outline,
        'Couldn\'t update the widget',
        AppColors.error,
      ),
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Text(label, style: TextStyle(color: color, fontSize: 13)),
        ),
        if (status == SyncStatus.failed)
          TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
