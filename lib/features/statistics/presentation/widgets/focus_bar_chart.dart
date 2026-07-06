import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/statistics_providers.dart';

class FocusBarChart extends StatelessWidget {
  const FocusBarChart({super.key, required this.buckets, required this.range});

  /// `(bucketStart, minutes)` pairs, oldest first.
  final List<(DateTime, double)> buckets;
  final StatsRange range;

  String _labelFor(DateTime date) {
    switch (range) {
      case StatsRange.week:
        return DateFormat.E().format(date).substring(0, 1);
      case StatsRange.month:
        return 'W${_isoWeekOfYear(date)}';
      case StatsRange.sixMonths:
        return DateFormat.MMM().format(date).substring(0, 1);
    }
  }

  int _isoWeekOfYear(DateTime date) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final maxMinutes = buckets.map((b) => b.$2).fold<double>(0, (a, b) => a > b ? a : b);
    // Give the chart a little headroom above the tallest bar.
    final maxY = maxMinutes <= 0 ? 60.0 : maxMinutes * 1.25;
    final gridColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final labelColor = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 3,
            getDrawingHorizontalLine: (value) => FlLine(color: gridColor, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= buckets.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _labelFor(buckets[index].$1),
                      style: AppTextStyles.caption(color: labelColor),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => isDark ? AppColors.darkCard : AppColors.lightTextPrimary,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final minutes = rod.toY.round();
                return BarTooltipItem(
                  '${minutes}m',
                  AppTextStyles.labelMedium(color: Colors.white),
                );
              },
            ),
          ),
          barGroups: List.generate(buckets.length, (i) {
            final minutes = buckets[i].$2;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: minutes,
                  width: range == StatsRange.week ? 20 : 14,
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: gridColor.withValues(alpha: 0.4),
                  ),
                ),
              ],
            );
          }),
        ),
        swapAnimationDuration: const Duration(milliseconds: 500),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }
}
