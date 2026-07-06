import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../custom_timers/domain/custom_timer_providers.dart';
import '../widgets/custom_duration_sheet.dart';
import '../../domain/models/session_type.dart';

/// Shown when the Timer tab has no active session — lets the user pick a
/// quick preset, a custom duration, or jump straight into a break.
class TimerPickerView extends ConsumerWidget {
  const TimerPickerView({
    super.key,
    required this.onSelectFocus,
    required this.onSelectBreak,
  });

  final void Function(int minutes, {String? label, String? presetId}) onSelectFocus;
  final void Function(SessionType type, int minutes) onSelectBreak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final customPresets = ref.watch(customTimerPresetsProvider);
    final defaults = AppDefaults.defaultPresetsMinutes;
    final List<({int minutes, String? label, String? presetId})> allItems = [
      for (final m in defaults) (minutes: m, label: null, presetId: null),
      for (final p in customPresets) (minutes: p.minutes, label: p.label, presetId: p.id),
    ];

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'TRACK YOUR\nFOCUS TIME',
                style: AppTextStyles.h1(color: theme.textTheme.headlineMedium?.color),
              ).animate().fadeIn(duration: 280.ms).slideY(begin: -0.06, end: 0),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.35,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == allItems.length) {
                    return _AddCustomTile(onTap: () => showCustomDurationSheet(context))
                        .animate()
                        .fadeIn(delay: (40 * index).ms, duration: 220.ms)
                        .scale(begin: const Offset(0.94, 0.94));
                  }
                  final item = allItems[index];
                  return _DurationTile(
                    minutes: item.minutes,
                    label: item.label,
                    onTap: () => onSelectFocus(item.minutes, label: item.label, presetId: item.presetId),
                  ).animate().fadeIn(delay: (40 * index).ms, duration: 220.ms).scale(begin: const Offset(0.94, 0.94));
                },
                childCount: defaults.length + customPresets.length + 1,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Need a breather?',
                style: AppTextStyles.h3(color: theme.textTheme.headlineMedium?.color),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _BreakChip(
                      label: 'Short break',
                      minutes: AppDefaults.shortBreakMinutes,
                      color: AppColors.shortBreakColor,
                      onTap: () => onSelectBreak(SessionType.shortBreak, AppDefaults.shortBreakMinutes),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _BreakChip(
                      label: 'Long break',
                      minutes: AppDefaults.longBreakMinutes,
                      color: AppColors.longBreakColor,
                      onTap: () => onSelectBreak(SessionType.longBreak, AppDefaults.longBreakMinutes),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl + 68)),
        ],
      ),
    );
  }
}

class _DurationTile extends StatelessWidget {
  const _DurationTile({required this.minutes, required this.onTap, this.label});
  final int minutes;
  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCustom = label != null;
    return SoftCard(
      color: isCustom
          ? (theme.brightness == Brightness.dark ? AppColors.darkCard : AppColors.primarySoft)
          : null,
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$minutes', style: AppTextStyles.h1(color: theme.textTheme.headlineMedium?.color)),
            const SizedBox(height: 2),
            Text(
              isCustom ? label! : 'min',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(color: theme.textTheme.bodyMedium?.color),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCustomTile extends StatelessWidget {
  const _AddCustomTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.add_rounded,
              size: 28,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BreakChip extends StatelessWidget {
  const _BreakChip({
    required this.label,
    required this.minutes,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int minutes;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      color: color.withValues(alpha: 0.1),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            label == 'Short break' ? Icons.local_cafe_rounded : Icons.self_improvement_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelMedium(color: theme.textTheme.headlineMedium?.color)),
                Text('$minutes min', style: AppTextStyles.bodySmall(color: theme.textTheme.bodyMedium?.color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
