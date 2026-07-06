import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../domain/statistics_providers.dart';

class StatsSummaryGrid extends StatelessWidget {
  const StatsSummaryGrid({super.key, required this.summary});

  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCardData(
        icon: Icons.hourglass_bottom_rounded,
        color: AppColors.primary,
        bg: AppColors.primarySoft,
        value: '${summary.totalHours.toStringAsFixed(1)}h',
        label: 'Total focus time',
      ),
      _StatCardData(
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFF5A623),
        bg: const Color(0xFFFDF1DA),
        value: '${summary.currentStreak}',
        label: 'Current streak',
      ),
      _StatCardData(
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFF4EA1F7),
        bg: const Color(0xFFE4F1FD),
        value: '${summary.longestStreak}',
        label: 'Longest streak',
      ),
      _StatCardData(
        icon: Icons.task_alt_rounded,
        color: AppColors.success,
        bg: const Color(0xFFE3F6EC),
        value: '${summary.completionRate.round()}%',
        label: 'Completion rate',
      ),
      _StatCardData(
        icon: Icons.timer_outlined,
        color: const Color(0xFF2FBFB0),
        bg: const Color(0xFFDFF5F3),
        value: '${summary.averageSessionMinutes.round()}m',
        label: 'Avg. session',
      ),
      _StatCardData(
        icon: Icons.calendar_view_week_rounded,
        color: const Color(0xFFEF5A6F),
        bg: const Color(0xFFFCE6E9),
        value: '${(summary.weekMinutes / 60).toStringAsFixed(1)}h',
        label: 'This week',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm + 2,
        crossAxisSpacing: AppSpacing.sm + 2,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final data = cards[index];
        return _StatCard(data: data)
            .animate()
            .fadeIn(delay: (60 * index).ms, duration: 260.ms)
            .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _StatCardData {
  const _StatCardData({
    required this.icon,
    required this.color,
    required this.bg,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final Color bg;
  final String value;
  final String label;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});
  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: data.bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(data.icon, size: 16, color: data.color),
          ),
          const Spacer(),
          Text(data.value, style: AppTextStyles.statValue(color: theme.textTheme.headlineMedium?.color)),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: AppTextStyles.bodySmall(color: theme.textTheme.bodyMedium?.color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
