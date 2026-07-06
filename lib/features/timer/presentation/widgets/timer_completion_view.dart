import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/models/session_type.dart';

class TimerCompletionView extends StatelessWidget {
  const TimerCompletionView({
    super.key,
    required this.confettiController,
    required this.completedType,
    required this.completedMinutes,
    required this.onStartShortBreak,
    required this.onStartLongBreak,
    required this.onDone,
  });

  final ConfettiController confettiController;
  final SessionType completedType;
  final int completedMinutes;
  final VoidCallback onStartShortBreak;
  final VoidCallback onStartLongBreak;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFocus = completedType == SessionType.focus;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 24,
            maxBlastForce: 18,
            minBlastForce: 8,
            gravity: 0.25,
            colors: const [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.success,
              AppColors.warning,
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.primaryGradient),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
              ).animate().scale(
                    duration: 420.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0.4, 0.4),
                    end: const Offset(1, 1),
                  ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                isFocus ? 'Session complete!' : 'Break complete!',
                style: AppTextStyles.h1(color: theme.textTheme.headlineMedium?.color),
              ).animate().fadeIn(delay: 120.ms),
              const SizedBox(height: AppSpacing.sm),
              Text(
                isFocus
                    ? "You focused for $completedMinutes minutes. Nice work."
                    : 'Hope that helped you recharge.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge(color: theme.textTheme.bodyMedium?.color),
              ).animate().fadeIn(delay: 180.ms),
              const SizedBox(height: AppSpacing.xl),
              if (isFocus) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onStartShortBreak,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                        ),
                        child: const Text('Short break'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onStartLongBreak,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                        ),
                        child: const Text('Long break'),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: AppSpacing.sm),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDone,
                  child: const Text('Done'),
                ),
              ).animate().fadeIn(delay: 280.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ],
    );
  }
}
