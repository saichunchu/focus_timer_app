import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../history/domain/models/focus_session.dart';

class RecentSessionsSection extends StatelessWidget {
  const RecentSessionsSection({super.key, required this.sessions});

  final List<FocusSession> sessions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent sessions',
                  style: AppTextStyles.h3(color: theme.textTheme.headlineMedium?.color),
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.history),
                child: Text('See all', style: AppTextStyles.labelMedium(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (sessions.isEmpty)
            _EmptyState(theme: theme)
          else
            ...List.generate(sessions.length, (index) {
              final session = sessions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _SessionTile(session: session)
                    .animate()
                    .fadeIn(delay: (60 * index).ms, duration: 260.ms)
                    .slideX(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
              );
            }),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
      child: Column(
        children: [
          Icon(Icons.spa_outlined, size: 28, color: theme.textTheme.bodyMedium?.color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No sessions yet',
            style: AppTextStyles.labelMedium(color: theme.textTheme.headlineMedium?.color),
          ),
          const SizedBox(height: 2),
          Text(
            'Start a quick timer above to begin your streak',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(color: theme.textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final FocusSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeLabel = DateFormat('h:mm a').format(session.startTime);
    final minutes = session.actualDurationMinutes.round();

    return SoftCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: session.type.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(session.type.icon, size: 18, color: session.type.color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.label?.isNotEmpty == true ? session.label! : session.type.label,
                  style: AppTextStyles.bodyLarge(color: theme.textTheme.headlineMedium?.color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(timeLabel, style: AppTextStyles.bodySmall(color: theme.textTheme.bodyMedium?.color)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${minutes}m', style: AppTextStyles.labelMedium(color: theme.textTheme.headlineMedium?.color)),
              const SizedBox(height: 2),
              Icon(
                session.completed ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
                size: 14,
                color: session.completed ? AppColors.success : AppColors.lightTextTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
