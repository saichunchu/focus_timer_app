import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../domain/models/focus_session.dart';

class HistorySessionTile extends StatelessWidget {
  const HistorySessionTile({super.key, required this.session, required this.onTap});

  final FocusSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeLabel =
        '${DateFormat('h:mm a').format(session.startTime)} · ${session.actualDurationMinutes.round()}m';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SoftCard(
        onTap: onTap,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge(color: theme.textTheme.headlineMedium?.color),
                  ),
                  const SizedBox(height: 2),
                  Text(timeLabel, style: AppTextStyles.bodySmall(color: theme.textTheme.bodyMedium?.color)),
                ],
              ),
            ),
            Icon(
              session.completed ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
              size: 18,
              color: session.completed ? AppColors.success : AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}
