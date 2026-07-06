import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/models/focus_session.dart';
import '../../domain/session_providers.dart';

Future<void> showSessionDetailSheet(BuildContext context, FocusSession session) {
  return showAppModalBottomSheet(
    context: context,
    builder: (context) => SessionDetailSheet(session: session),
  );
}

class SessionDetailSheet extends ConsumerWidget {
  const SessionDetailSheet({super.key, required this.session});

  final FocusSession session;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete session?'),
        content: const Text('This will permanently remove it from your history.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(sessionsProvider.notifier).deleteSession(session.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurfaceSolid : Colors.white;
    final dateLabel = DateFormat('EEEE, MMMM d, y').format(session.date);
    final timeRange =
        '${DateFormat('h:mm a').format(session.startTime)} – ${DateFormat('h:mm a').format(session.endTime)}';

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: session.type.color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(session.type.icon, color: session.type.color),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.label?.isNotEmpty == true ? session.label! : session.type.label,
                        style: AppTextStyles.h3(color: theme.textTheme.headlineMedium?.color),
                      ),
                      Text(dateLabel, style: AppTextStyles.bodySmall(color: theme.textTheme.bodyMedium?.color)),
                    ],
                  ),
                ),
                _StatusBadge(completed: session.completed),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(icon: Icons.schedule_rounded, label: 'Time', value: timeRange),
            _DetailRow(
              icon: Icons.timer_outlined,
              label: 'Planned duration',
              value: '${session.plannedDurationMinutes} min',
            ),
            _DetailRow(
              icon: Icons.check_circle_outline_rounded,
              label: 'Actual duration',
              value: '${session.actualDurationMinutes.round()} min',
            ),
            if (session.interruptionCount > 0)
              _DetailRow(
                icon: Icons.notifications_active_outlined,
                label: 'Interruptions',
                value: '${session.interruptionCount}',
              ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _delete(context, ref),
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                label: const Text('Delete session', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                ),
              ),
            ),
          ],
        ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.textTheme.bodyMedium?.color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label, style: AppTextStyles.bodyMedium(color: theme.textTheme.bodyMedium?.color)),
          ),
          Text(value, style: AppTextStyles.labelMedium(color: theme.textTheme.headlineMedium?.color)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.completed});
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final color = completed ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        completed ? 'Completed' : 'Interrupted',
        style: AppTextStyles.caption(color: color),
      ),
    );
  }
}
