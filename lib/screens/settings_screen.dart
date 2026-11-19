// Intellectual property of Strauch Development. All rights reserved.
import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../app_scope.dart';
import '../models/word.dart';
import '../theme.dart';
import 'widget_guide_screen.dart';

/// Category, difficulty and reminder preferences.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        Text('PREFERENCES', style: eyebrow(AppColors.muted)),
        const SizedBox(height: 6),
        Text(
          'Settings',
          style: serif.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: AppColors.cream,
          ),
        ),
        const SizedBox(height: 28),
        const _SectionHeader(
          title: 'Categories',
          subtitle: 'Choose the subjects you want to learn.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: [
            for (final category in WordCategory.values)
              FilterChip(
                avatar: Icon(
                  category.icon,
                  size: 18,
                  color: controller.categories.contains(category)
                      ? AppColors.backgroundDeep
                      : AppColors.sage,
                ),
                showCheckmark: false,
                label: Text(category.label),
                selected: controller.categories.contains(category),
                onSelected: (_) async {
                  if (!await controller.toggleCategory(category) &&
                      context.mounted) {
                    _showMessage(context, 'Keep at least one category selected.');
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 32),
        const _SectionHeader(
          title: 'Difficulty',
          subtitle: 'From practical vocabulary to niche gems. Pick any mix.',
        ),
        const SizedBox(height: 14),
        for (final difficulty in Difficulty.values) ...[
          _DifficultyTile(
            difficulty: difficulty,
            selected: controller.difficulties.contains(difficulty),
            onTap: () async {
              if (!await controller.toggleDifficulty(difficulty) &&
                  context.mounted) {
                _showMessage(context, 'Keep at least one difficulty selected.');
              }
            },
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 4),
        Text(
          '${controller.pool.length} of ${controller.totalWords} words in your rotation',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 32),
        const _SectionHeader(
          title: 'Daily reminder',
          subtitle: 'A gentle nudge with each day\'s word.',
        ),
        const SizedBox(height: 14),
        _Panel(
          child: Column(
            children: [
              SwitchListTile(
                value: controller.remindersEnabled,
                title: const Text('Remind me'),
                secondary: const Icon(
                  Icons.notifications_none,
                  color: AppColors.sage,
                ),
                onChanged: (enabled) async {
                  final result = await controller.setRemindersEnabled(enabled);
                  if (result == ReminderResult.permissionDenied &&
                      context.mounted) {
                    _showMessage(
                      context,
                      'Notifications are off for this app. '
                      'Turn them on in the iOS Settings app.',
                    );
                  }
                },
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                enabled: controller.remindersEnabled,
                leading: const Icon(Icons.schedule, color: AppColors.sage),
                title: const Text('Time'),
                trailing: Text(
                  controller.reminderTime.format(context),
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: controller.reminderTime,
                  );
                  if (picked != null) await controller.setReminderTime(picked);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const _SectionHeader(title: 'Widget', subtitle: null),
        const SizedBox(height: 14),
        _Panel(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add_to_home_screen, color: AppColors.sage),
                title: const Text('How to add the widget'),
                subtitle: const Text(
                  'A quick step-by-step guide',
                  style: TextStyle(color: AppColors.muted),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (routeContext) => WidgetGuideScreen(
                      onFinished: () => Navigator.of(routeContext).pop(),
                    ),
                  ),
                ),
              ),
              const Divider(indent: 16, endIndent: 16),
              const Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.widgets_outlined, color: AppColors.sage),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Your home screen widget picks a new word at midnight '
                        'on its own, and follows any changes you make here '
                        'straight away.',
                        style: TextStyle(color: AppColors.muted, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: serif.copyWith(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            color: AppColors.cream,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: const TextStyle(color: AppColors.muted)),
        ],
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  const _DifficultyTile({
    required this.difficulty,
    required this.selected,
    required this.onTap,
  });

  final Difficulty difficulty;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dots = Difficulty.values.indexOf(difficulty) + 1;

    return Material(
      color: selected
          ? AppColors.sage.withValues(alpha: 0.12)
          : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? AppColors.sage : AppColors.outline,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
          child: Row(
            children: [
              Row(
                children: [
                  for (var i = 0; i < Difficulty.values.length; i++)
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < dots ? AppColors.gold : AppColors.outline,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficulty.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      difficulty.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  key: ValueKey(selected),
                  color: selected ? AppColors.sage : AppColors.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
