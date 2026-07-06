import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/soft_card.dart';

class StatsOverviewRow extends StatelessWidget {
  const StatsOverviewRow({
    super.key,
    required this.todayMinutes,
    required this.currentStreak,
  });

  final double todayMinutes;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final hours = todayMinutes ~/ 60;
    final mins = (todayMinutes % 60).round();
    final timeLabel = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.bolt_rounded,
              iconColor: AppColors.primary,
              iconBg: AppColors.primarySoft,
              value: timeLabel,
              label: "Today's focus",
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _StatCard(
              icon: Icons.local_fire_department_rounded,
              iconColor: const Color(0xFFF5A623),
              iconBg: const Color(0xFFFDF1DA),
              value: '$currentStreak',
              label: currentStreak == 1 ? 'Day streak' : 'Day streak',
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 80.ms, duration: 320.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Text(value, style: AppTextStyles.statValue(color: theme.textTheme.headlineMedium?.color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall(color: theme.textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }
}
