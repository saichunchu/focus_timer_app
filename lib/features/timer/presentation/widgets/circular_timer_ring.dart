import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/session_type.dart';

/// A large circular progress ring with the remaining time centered inside
/// a soft, elevated disc — smoothly animates between ticks instead of
/// jumping once per second.
class CircularTimerRing extends StatelessWidget {
  const CircularTimerRing({
    super.key,
    required this.progress,
    required this.timeLabel,
    required this.subtitle,
    required this.type,
    this.size = 280,
  });

  /// 0.0 (just started) -> 1.0 (finished).
  final double progress;
  final String timeLabel;
  final String subtitle;
  final SessionType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trackColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final discColor = isDark ? AppColors.darkSurfaceSolid : Colors.white;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation(trackColor),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 220),
            curve: Curves.linear,
            builder: (context, value, _) {
              return SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  valueColor: AlwaysStoppedAnimation(type.color),
                ),
              );
            },
          ),
          Container(
            width: size - 48,
            height: size - 48,
            decoration: BoxDecoration(
              color: discColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeLabel,
                  style: AppTextStyles.displayTimer(
                    color: theme.textTheme.headlineMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium(
                    color: theme.textTheme.bodyMedium?.color,
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
