import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/models/timer_launch_args.dart';

/// Bottom sheet allowing the user to dial in an arbitrary focus duration
/// and jump straight into the timer with it.
Future<void> showCustomDurationSheet(BuildContext context) {
  return showAppModalBottomSheet(
    context: context,
    builder: (context) => const _CustomDurationSheet(),
  );
}

class _CustomDurationSheet extends StatefulWidget {
  const _CustomDurationSheet();

  @override
  State<_CustomDurationSheet> createState() => _CustomDurationSheetState();
}

class _CustomDurationSheetState extends State<_CustomDurationSheet> {
  int _minutes = 50;

  void _adjust(int delta) {
    HapticService.instance.selection();
    setState(() {
      _minutes = (_minutes + delta).clamp(1, 180);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurfaceSolid : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            Text('Custom timer', style: AppTextStyles.h2(color: theme.textTheme.headlineMedium?.color)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepperButton(icon: Icons.remove_rounded, onTap: () => _adjust(-5)),
                SizedBox(
                  width: 140,
                  child: Column(
                    children: [
                      Text(
                        '$_minutes',
                        style: AppTextStyles.displayTimer(color: theme.textTheme.headlineMedium?.color),
                      ),
                      Text('minutes', style: AppTextStyles.bodySmall(color: theme.textTheme.bodyMedium?.color)),
                    ],
                  ),
                ),
                _StepperButton(icon: Icons.add_rounded, onTap: () => _adjust(5)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Slider(
              value: _minutes.toDouble(),
              min: 1,
              max: 180,
              activeColor: AppColors.primary,
              inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _minutes = v.round());
              },
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  router.go(
                    AppRoutes.timer,
                    extra: TimerLaunchArgs(minutes: _minutes),
                  );
                },
                child: const Text('Start focus session'),
              ),
            ),
          ],
        ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
