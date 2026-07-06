import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/session_stats.dart';
import '../../history/domain/session_providers.dart';

enum StatsRange { week, month, sixMonths }

extension StatsRangeLabel on StatsRange {
  String get label => switch (this) {
        StatsRange.week => 'Week',
        StatsRange.month => 'Month',
        StatsRange.sixMonths => '6 Months',
      };
}

final selectedStatsRangeProvider = StateProvider<StatsRange>((ref) => StatsRange.week);

/// Chart-ready `(bucketStart, minutes)` pairs for the currently selected
/// range — daily buckets for Week, weekly buckets for Month, monthly
/// buckets for 6 Months.
final chartBucketsProvider = Provider<List<(DateTime, double)>>((ref) {
  final sessions = ref.watch(sessionsProvider);
  final range = ref.watch(selectedStatsRangeProvider);

  return switch (range) {
    StatsRange.week => SessionStats.lastNDaysTotals(sessions, 7),
    StatsRange.month => SessionStats.lastNWeeksTotals(sessions, 5),
    StatsRange.sixMonths => SessionStats.lastNMonthsTotals(sessions, 6),
  };
});

class StatsSummary {
  const StatsSummary({
    required this.totalHours,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageSessionMinutes,
    required this.completionRate,
    required this.todayMinutes,
    required this.weekMinutes,
    required this.monthMinutes,
  });

  final double totalHours;
  final int currentStreak;
  final int longestStreak;
  final double averageSessionMinutes;
  final double completionRate;
  final double todayMinutes;
  final double weekMinutes;
  final double monthMinutes;
}

final statsSummaryProvider = Provider<StatsSummary>((ref) {
  final sessions = ref.watch(sessionsProvider);
  return StatsSummary(
    totalHours: SessionStats.totalFocusHours(sessions),
    currentStreak: SessionStats.currentStreak(sessions),
    longestStreak: SessionStats.longestStreak(sessions),
    averageSessionMinutes: SessionStats.averageSessionMinutes(sessions),
    completionRate: SessionStats.completionRate(sessions),
    todayMinutes: SessionStats.focusMinutesOn(sessions),
    weekMinutes: SessionStats.focusMinutesInLastDays(sessions, 7),
    monthMinutes: SessionStats.focusMinutesInLastDays(sessions, 30),
  );
});
