import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/models/timer_run_state.dart';
import 'circular_timer_ring.dart';
import 'timer_controls.dart';

class ActiveTimerView extends StatelessWidget {
  const ActiveTimerView({
    super.key,
    required this.state,
    required this.onStop,
    required this.onPauseResume,
    this.strictModeEnabled = false,
  });

  final TimerRunState state;
  final VoidCallback onStop;
  final VoidCallback onPauseResume;
  final bool strictModeEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = state.label?.isNotEmpty == true ? state.label! : 'just ${state.type.label.toLowerCase()}';

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(
            state.type.label.toUpperCase(),
            style: AppTextStyles.overline(color: state.type.color),
          ).animate().fadeIn(duration: 260.ms),
          const SizedBox(height: AppSpacing.xs),
          if (state.isPaused)
            Text(
              'Paused',
              style: AppTextStyles.bodyMedium(color: theme.textTheme.bodyMedium?.color),
            ).animate().fadeIn(duration: 200.ms),
          if (strictModeEnabled)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_rounded, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Strict Mode', style: AppTextStyles.caption(color: AppColors.primary)),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 220.ms),
          const Spacer(),
          CircularTimerRing(
            progress: state.progress,
            timeLabel: state.remainingLabel,
            subtitle: subtitle,
            type: state.type,
          ).animate().fadeIn(duration: 380.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          const Spacer(),
          TimerControls(
            isRunning: state.isRunning,
            onStop: onStop,
            onPauseResume: onPauseResume,
          ).animate().fadeIn(delay: 160.ms, duration: 300.ms).slideY(begin: 0.15, end: 0),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
