import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/soft_card.dart';

class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({
    super.key,
    required this.todayMinutes,
    required this.goalMinutes,
  });

  final double todayMinutes;
  final int goalMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double progress = goalMinutes == 0
        ? 0.0
        : (todayMinutes / goalMinutes).clamp(0.0, 1.0).toDouble();
    final percent = (progress * 100).round();
    final remaining = (goalMinutes - todayMinutes).clamp(0, goalMinutes).round();
    final reached = todayMinutes >= goalMinutes && goalMinutes > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Daily goal',
                    style: AppTextStyles.h3(color: theme.textTheme.headlineMedium?.color),
                  ),
                ),
                Text(
                  reached ? 'Goal reached 🎉' : '$percent%',
                  style: AppTextStyles.labelMedium(
                    color: reached ? AppColors.success : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: SizedBox(
                height: 10,
                child: Stack(
                  children: [
                    Container(
                      color: theme.brightness == Brightness.dark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.primaryGradient,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              reached
                  ? "You've hit your ${goalMinutes}m goal today"
                  : '$remaining min left of your ${goalMinutes}m goal',
              style: AppTextStyles.bodySmall(color: theme.textTheme.bodyMedium?.color),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 140.ms, duration: 320.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}
