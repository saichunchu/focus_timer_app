import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// The two primary controls shown while a session is running or paused:
/// a Stop button (ends early, saves as interrupted) and a Pause/Resume
/// toggle.
class TimerControls extends StatelessWidget {
  const TimerControls({
    super.key,
    required this.isRunning,
    required this.onStop,
    required this.onPauseResume,
  });

  final bool isRunning;
  final VoidCallback onStop;
  final VoidCallback onPauseResume;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: Icons.stop_rounded,
          background: isDark ? Colors.white10 : AppColors.lightTextPrimary,
          iconColor: isDark ? Colors.white : Colors.white,
          onTap: onStop,
        ),
        const SizedBox(width: 28),
        _ControlButton(
          icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          background: isDark ? AppColors.darkCard : Colors.white,
          iconColor: isDark ? Colors.white : AppColors.lightTextPrimary,
          elevated: true,
          onTap: onPauseResume,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onTap,
    this.elevated = false,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final bool elevated;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(icon, color: iconColor, size: 28),
        ),
      ),
    );
  }
}
