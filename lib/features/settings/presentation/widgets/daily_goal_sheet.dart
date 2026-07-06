import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../settings_providers.dart';

Future<void> showDailyGoalSheet(BuildContext context) {
  return showAppModalBottomSheet(
    context: context,
    builder: (context) => const _DailyGoalSheet(),
  );
}

class _DailyGoalSheet extends ConsumerStatefulWidget {
  const _DailyGoalSheet();

  @override
  ConsumerState<_DailyGoalSheet> createState() => _DailyGoalSheetState();
}

class _DailyGoalSheetState extends ConsumerState<_DailyGoalSheet> {
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _minutes = ref.read(dailyGoalProvider);
  }

  void _adjust(int delta) {
    HapticService.instance.selection();
    setState(() => _minutes = (_minutes + delta).clamp(15, 720));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurfaceSolid : Colors.white;
    final hours = (_minutes / 60).toStringAsFixed(1);

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
            Text('Daily focus goal', style: AppTextStyles.h2(color: theme.textTheme.headlineMedium?.color)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepperButton(icon: Icons.remove_rounded, onTap: () => _adjust(-15)),
                SizedBox(
                  width: 140,
                  child: Column(
                    children: [
                      Text(
                        '$_minutes',
                        style: AppTextStyles.displayTimer(color: theme.textTheme.headlineMedium?.color),
                      ),
                      Text(
                        'minutes ($hours h)',
                        style: AppTextStyles.bodySmall(color: theme.textTheme.bodyMedium?.color),
                      ),
                    ],
                  ),
                ),
                _StepperButton(icon: Icons.add_rounded, onTap: () => _adjust(15)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Slider(
              value: _minutes.toDouble(),
              min: 15,
              max: 720,
              divisions: 47,
              activeColor: AppColors.primary,
              inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              onChanged: (v) => setState(() => _minutes = v.round()),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(dailyGoalProvider.notifier).setGoal(_minutes);
                  Navigator.of(context).pop();
                },
                child: const Text('Save goal'),
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
