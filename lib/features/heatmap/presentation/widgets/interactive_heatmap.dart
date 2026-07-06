import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/session_stats.dart';
import '../../../history/domain/models/focus_session.dart';
import '../../../history/domain/session_providers.dart';
import 'heatmap_day_detail_sheet.dart';

/// A full, scrollable, tap-to-inspect consistency heatmap covering the
/// last [weeksToShow] weeks — the GitHub-contributions-graph style view.
class InteractiveHeatmap extends ConsumerStatefulWidget {
  const InteractiveHeatmap({super.key, this.weeksToShow = 53});

  final int weeksToShow;

  @override
  ConsumerState<InteractiveHeatmap> createState() => _InteractiveHeatmapState();
}

class _InteractiveHeatmapState extends ConsumerState<InteractiveHeatmap> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
    final labelColor = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    final sessions = ref.watch(sessionsProvider);
    final dailyTotals = SessionStats.dailyFocusTotals(sessions);

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final todaySundayIndex = todayMidnight.weekday % 7; // 0 = Sunday
    final weekEnd = todayMidnight.add(Duration(days: 6 - todaySundayIndex));
    final daysToShow = widget.weeksToShow * 7;
    final start = weekEnd.subtract(Duration(days: daysToShow - 1));

    final columns = List.generate(widget.weeksToShow, (w) {
      return List.generate(7, (d) => start.add(Duration(days: w * 7 + d)));
    });

    const cellSize = 13.0;
    const cellGap = 3.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 128,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekday labels (Mon / Wed / Fri) aligned with rows 1, 3, 5.
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: [
                        const SizedBox(height: 20), // aligns with month label row
                        for (int row = 0; row < 7; row++)
                          SizedBox(
                            height: cellSize + cellGap,
                            child: (row == 1 || row == 3 || row == 5)
                                ? Text(
                                    DateFormat.E().format(DateTime(2024, 1, row)).substring(0, 1),
                                    style: AppTextStyles.caption(color: labelColor),
                                  )
                                : null,
                          ),
                      ],
                    ),
                  ),
                  ...List.generate(columns.length, (colIndex) {
                    final col = columns[colIndex];
                    final firstDayOfCol = col.first;
                    final prevCol = colIndex > 0 ? columns[colIndex - 1].first : null;
                    final showMonthLabel = prevCol == null || firstDayOfCol.month != prevCol.month;

                    return Padding(
                      padding: const EdgeInsets.only(right: cellGap),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                            child: showMonthLabel
                                ? Text(
                                    DateFormat.MMM().format(firstDayOfCol),
                                    style: AppTextStyles.caption(color: labelColor),
                                  )
                                : null,
                          ),
                          for (final day in col)
                            _HeatmapCell(
                              isFuture: day.isAfter(todayMidnight),
                              level: _levelFor(dailyTotals[day] ?? 0),
                              size: cellSize,
                              gap: cellGap,
                              scale: scale,
                              onTap: () => _handleDayTap(day, sessions),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Less', style: AppTextStyles.caption(color: labelColor)),
            const SizedBox(width: 6),
            for (int level = 0; level < scale.length; level++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: scale[level],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
            const SizedBox(width: 6),
            Text('More', style: AppTextStyles.caption(color: labelColor)),
          ],
        ),
      ],
    );
  }

  void _handleDayTap(DateTime day, List<FocusSession> allSessions) {
    final sessionsOnDay = allSessions.where((s) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      return d == day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    showHeatmapDayDetailSheet(context, day: day, sessionsOnDay: sessionsOnDay);
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.isFuture,
    required this.level,
    required this.size,
    required this.gap,
    required this.scale,
    required this.onTap,
  });

  final bool isFuture;
  final int level;
  final double size;
  final double gap;
  final List<Color> scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: GestureDetector(
        onTap: isFuture ? null : onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isFuture ? Colors.transparent : scale[level],
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
