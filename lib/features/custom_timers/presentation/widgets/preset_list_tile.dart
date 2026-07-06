import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../domain/models/custom_timer_preset.dart';

class PresetListTile extends StatelessWidget {
  const PresetListTile({
    super.key,
    required this.preset,
    required this.onTap,
    required this.onDelete,
  });

  final CustomTimerPreset preset;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = preset.colorValue != null ? Color(preset.colorValue!) : AppColors.primary;

    return Dismissible(
      key: ValueKey(preset.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        // Deletion is handled through the provider (Hive listenable removes
        // the tile once the box changes) — tell Dismissible not to also
        // remove it itself, to avoid a duplicate/conflicting animation.
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: SoftCard(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  '${preset.minutes}',
                  style: AppTextStyles.labelMedium(color: color),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.label,
                      style: AppTextStyles.bodyLarge(color: theme.textTheme.headlineMedium?.color),
                    ),
                    Text(
                      '${preset.minutes} minutes',
                      style: AppTextStyles.bodySmall(color: theme.textTheme.bodyMedium?.color),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.textTheme.bodyMedium?.color),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 220.ms).slideX(begin: 0.03, end: 0);
  }
}
