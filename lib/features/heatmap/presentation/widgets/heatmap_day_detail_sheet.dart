import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../history/domain/models/focus_session.dart';
import '../../../history/presentation/widgets/history_session_tile.dart';
import '../../../history/presentation/widgets/session_detail_sheet.dart';

Future<void> showHeatmapDayDetailSheet(
  BuildContext context, {
  required DateTime day,
  required List<FocusSession> sessionsOnDay,
}) {
  return showAppModalBottomSheet(
    context: context,
    builder: (context) => HeatmapDayDetailSheet(day: day, sessionsOnDay: sessionsOnDay),
  );
}

class HeatmapDayDetailSheet extends StatelessWidget {
  const HeatmapDayDetailSheet({super.key, required this.day, required this.sessionsOnDay});

  final DateTime day;
  final List<FocusSession> sessionsOnDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurfaceSolid : Colors.white;
    final totalMinutes =
        sessionsOnDay.fold<double>(0, (sum, s) => sum + s.actualDurationMinutes).round();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              Text(
                DateFormat('EEEE, MMMM d').format(day),
                style: AppTextStyles.h2(color: theme.textTheme.headlineMedium?.color),
              ),
              const SizedBox(height: 4),
              Text(
                sessionsOnDay.isEmpty ? 'No sessions logged' : '$totalMinutes minutes focused',
                style: AppTextStyles.bodyMedium(color: theme.textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: sessionsOnDay.isEmpty
                    ? Center(
                        child: Text(
                          'A quiet day.',
                          style: AppTextStyles.bodyMedium(color: theme.textTheme.bodyMedium?.color),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: sessionsOnDay.length,
                        itemBuilder: (context, index) {
                          final session = sessionsOnDay[index];
                          return HistorySessionTile(
                            session: session,
                            onTap: () => showSessionDetailSheet(context, session),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
