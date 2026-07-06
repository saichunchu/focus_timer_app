import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/soft_card.dart';

/// A compact, non-interactive preview of the last ~10 weeks of focus
/// consistency. The full interactive GitHub-style heatmap (tap-to-inspect)
/// lives in the Statistics tab.
class MiniHeatmapPreview extends StatelessWidget {
  const MiniHeatmapPreview({super.key, required this.dailyTotals});

  /// Map of day (midnight) -> total focus minutes.
  final Map<DateTime, double> dailyTotals;

  static const int _weeks = 10;

  int _levelFor(double minutes) {
    if (minutes <= 0) return 0;
    if (minutes < 15) return 1;
    if (minutes < 30) return 2;
    if (minutes < 60) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scale = isDark ? AppColors.heatmapScaleDark : AppColors.heatmapScaleLight;

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    // Align the grid to full Sun-Sat weeks, with the last column being the
    // week that contains today.
    final todaySundayIndex = todayMidnight.weekday % 7; // Mon=1..Sun=7 -> 0=Sun
    final weekEnd = todayMidnight.add(Duration(days: 6 - todaySundayIndex));
    final daysToShow = _weeks * 7;
    final start = weekEnd.subtract(Duration(days: daysToShow - 1));

    final columns = <List<DateTime>>[];
    for (int w = 0; w < _weeks; w++) {
      final col = <DateTime>[];
      for (int d = 0; d < 7; d++) {
        col.add(start.add(Duration(days: w * 7 + d)));
      }
      columns.add(col);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Consistency',
                    style: AppTextStyles.h3(color: theme.textTheme.headlineMedium?.color),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.statistics),
                  child: Text('See all', style: AppTextStyles.labelMedium(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 96,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: columns.map((col) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: col.map((day) {
                      final isFuture = day.isAfter(todayMidnight);
                      final minutes = dailyTotals[day] ?? 0;
                      final level = isFuture ? -1 : _levelFor(minutes);
                      return Container(
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: level < 0 ? Colors.transparent : scale[level],
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 260.ms, duration: 320.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}
