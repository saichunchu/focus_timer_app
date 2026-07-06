import '../../features/history/domain/models/focus_session.dart';
import '../../features/timer/domain/models/session_type.dart';

/// Pure calculation helpers over a list of [FocusSession]s. Kept
/// side-effect free and UI-agnostic so it can be reused by Home,
/// Statistics and the Heatmap features alike.
abstract class SessionStats {
  SessionStats._();

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _isFocus(FocusSession s) => s.type == SessionType.focus;

  /// Total focus minutes logged on [day] (defaults to today).
  static double focusMinutesOn(List<FocusSession> sessions, {DateTime? day}) {
    final target = _dateOnly(day ?? DateTime.now());
    return sessions
        .where((s) => _isFocus(s) && _dateOnly(s.date) == target)
        .fold<double>(0, (sum, s) => sum + s.actualDurationMinutes);
  }

  /// Total focus minutes within the last [days] days, inclusive of today.
  static double focusMinutesInLastDays(List<FocusSession> sessions, int days) {
    final today = _dateOnly(DateTime.now());
    final start = today.subtract(Duration(days: days - 1));
    return sessions
        .where((s) =>
            _isFocus(s) &&
            !_dateOnly(s.date).isBefore(start) &&
            !_dateOnly(s.date).isAfter(today))
        .fold<double>(0, (sum, s) => sum + s.actualDurationMinutes);
  }

  /// Map of calendar day -> total focus minutes, used to drive the heatmap.
  static Map<DateTime, double> dailyFocusTotals(List<FocusSession> sessions) {
    final map = <DateTime, double>{};
    for (final s in sessions.where(_isFocus)) {
      final day = _dateOnly(s.date);
      map[day] = (map[day] ?? 0) + s.actualDurationMinutes;
    }
    return map;
  }

  /// Current consecutive-day streak of >=1 completed focus session.
  /// A streak is considered "alive" if today OR yesterday has a session
  /// (so it doesn't reset to 0 right at midnight before today's first session).
  static int currentStreak(List<FocusSession> sessions) {
    final days = sessions
        .where((s) => _isFocus(s) && s.completed)
        .map((s) => _dateOnly(s.date))
        .toSet();
    if (days.isEmpty) return 0;

    final today = _dateOnly(DateTime.now());
    var cursor = today;
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }

    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Longest ever consecutive-day streak of completed focus sessions.
  static int longestStreak(List<FocusSession> sessions) {
    final days = sessions
        .where((s) => _isFocus(s) && s.completed)
        .map((s) => _dateOnly(s.date))
        .toSet()
        .toList()
      ..sort();
    if (days.isEmpty) return 0;

    var longest = 1;
    var current = 1;
    for (var i = 1; i < days.length; i++) {
      final diff = days[i].difference(days[i - 1]).inDays;
      if (diff == 1) {
        current++;
        longest = longest > current ? longest : current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return longest;
  }

  static double averageSessionMinutes(List<FocusSession> sessions) {
    final focusSessions = sessions.where(_isFocus).toList();
    if (focusSessions.isEmpty) return 0;
    final total =
        focusSessions.fold<double>(0, (sum, s) => sum + s.actualDurationMinutes);
    return total / focusSessions.length;
  }

  /// Percentage (0-100) of focus sessions that ran to completion.
  static double completionRate(List<FocusSession> sessions) {
    final focusSessions = sessions.where(_isFocus).toList();
    if (focusSessions.isEmpty) return 0;
    final completed = focusSessions.where((s) => s.completed).length;
    return (completed / focusSessions.length) * 100;
  }

  static List<FocusSession> recent(List<FocusSession> sessions, {int limit = 5}) {
    final sorted = [...sessions]..sort((a, b) => b.startTime.compareTo(a.startTime));
    return sorted.take(limit).toList();
  }

  static double totalFocusHours(List<FocusSession> sessions) {
    final totalMinutes =
        sessions.where(_isFocus).sumBy((s) => s.actualDurationMinutes);
    return totalMinutes / 60.0;
  }

  /// Daily focus minutes for the last [days] days, oldest first, ending
  /// today. Each entry is `(day, minutes)`.
  static List<(DateTime, double)> lastNDaysTotals(List<FocusSession> sessions, int days) {
    final totals = dailyFocusTotals(sessions);
    final today = _dateOnly(DateTime.now());
    return List.generate(days, (i) {
      final day = today.subtract(Duration(days: days - 1 - i));
      return (day, totals[day] ?? 0.0);
    });
  }

  /// Weekly focus minutes (Mon-Sun buckets) for the last [weeks] weeks,
  /// oldest first. Each entry is `(weekStart, minutes)`.
  static List<(DateTime, double)> lastNWeeksTotals(List<FocusSession> sessions, int weeks) {
    final totals = dailyFocusTotals(sessions);
    final today = _dateOnly(DateTime.now());
    final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));

    return List.generate(weeks, (i) {
      final weekStart = currentWeekStart.subtract(Duration(days: 7 * (weeks - 1 - i)));
      double sum = 0;
      for (int d = 0; d < 7; d++) {
        sum += totals[weekStart.add(Duration(days: d))] ?? 0.0;
      }
      return (weekStart, sum);
    });
  }

  /// Monthly focus minutes for the last [months] calendar months, oldest
  /// first. Each entry is `(monthStart, minutes)`.
  static List<(DateTime, double)> lastNMonthsTotals(List<FocusSession> sessions, int months) {
    final totals = dailyFocusTotals(sessions);
    final now = DateTime.now();

    return List.generate(months, (i) {
      final offset = months - 1 - i;
      final monthDate = DateTime(now.year, now.month - offset, 1);
      final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
      double sum = 0;
      for (int d = 0; d < daysInMonth; d++) {
        sum += totals[DateTime(monthDate.year, monthDate.month, d + 1)] ?? 0.0;
      }
      return (monthDate, sum);
    });
  }
}

extension _SumBy<T> on Iterable<T> {
  double sumBy(double Function(T) selector) =>
      fold<double>(0, (sum, item) => sum + selector(item));
}
