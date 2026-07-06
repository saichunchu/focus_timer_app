import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../custom_timers/domain/models/custom_timer_preset.dart';
import '../../../timer/domain/models/timer_launch_args.dart';

class PresetItem {
  const PresetItem({required this.minutes, required this.label, this.presetId, this.isCustom = false});
  final int minutes;
  final String label;
  final String? presetId;
  final bool isCustom;
}

class TimerPresetsSection extends StatelessWidget {
  const TimerPresetsSection({
    super.key,
    required this.defaultMinutes,
    required this.customPresets,
    required this.onAddCustom,
    required this.onManagePresets,
  });

  final List<int> defaultMinutes;
  final List<CustomTimerPreset> customPresets;
  final VoidCallback onAddCustom;
  final VoidCallback onManagePresets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = <PresetItem>[
      ...defaultMinutes.map((m) => PresetItem(minutes: m, label: '$m')),
      ...customPresets.map((p) => PresetItem(
            minutes: p.minutes,
            label: '${p.minutes}',
            presetId: p.id,
            isCustom: true,
          )),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quick start',
                  style: AppTextStyles.h3(color: theme.textTheme.headlineMedium?.color),
                ),
              ),
              TextButton(
                onPressed: onManagePresets,
                child: Text('Manage', style: AppTextStyles.labelMedium(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.sm + 2,
              crossAxisSpacing: AppSpacing.sm + 2,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              if (index == items.length) {
                return _AddPresetTile(onTap: onAddCustom)
                    .animate()
                    .fadeIn(delay: (60 * index).ms, duration: 260.ms)
                    .scale(begin: const Offset(0.92, 0.92), end: const Offset(1, 1));
              }
              final item = items[index];
              return _PresetTile(item: item)
                  .animate()
                  .fadeIn(delay: (60 * index).ms, duration: 260.ms)
                  .scale(begin: const Offset(0.92, 0.92), end: const Offset(1, 1));
            },
          ),
        ],
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({required this.item});
  final PresetItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      color: item.isCustom
          ? (theme.brightness == Brightness.dark
              ? AppColors.darkCard
              : AppColors.primarySoft)
          : null,
      onTap: () {
        context.go(
          AppRoutes.timer,
          extra: TimerLaunchArgs(
            minutes: item.minutes,
            label: item.isCustom ? item.label : null,
            presetId: item.presetId,
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.label,
              style: AppTextStyles.h2(color: theme.textTheme.headlineMedium?.color),
            ),
            const SizedBox(height: 2),
            Text('min', style: AppTextStyles.caption(color: theme.textTheme.bodyMedium?.color)),
          ],
        ),
      ),
    );
  }
}

class _AddPresetTile extends StatelessWidget {
  const _AddPresetTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
