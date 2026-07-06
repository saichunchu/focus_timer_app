import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../history/domain/session_providers.dart';
import '../../domain/session_export_service.dart';
import '../settings_providers.dart';
import '../widgets/daily_goal_sheet.dart';
import '../widgets/settings_common.dart';
import '../widgets/theme_mode_selector.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _handleExport(BuildContext context, WidgetRef ref) async {
    final sessions = ref.read(sessionsProvider);
    final exported = await const SessionExportService().exportAndShare(sessions);
    if (!context.mounted) return;
    if (!exported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sessions to export yet')),
      );
    }
  }

  Future<void> _handleReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all statistics?'),
        content: const Text(
          "This permanently deletes every recorded session, including your streaks and history. This can't be undone.",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(sessionsProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All statistics have been reset')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);
    final hapticEnabled = ref.watch(hapticEnabledProvider);
    final strictModeEnabled = ref.watch(strictModeEnabledProvider);
    final strictModeFailOnExit = ref.watch(strictModeFailOnExitProvider);
    final dailyGoal = ref.watch(dailyGoalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl + 68),
        children: [
          SettingsSection(
            title: 'Appearance',
            children: [
              ThemeModeSelector(
                selected: themeMode,
                onChanged: (mode) => ref.read(themeModeProvider.notifier).setMode(mode),
              ),
            ],
          ).animate().fadeIn(duration: 240.ms),
          const SizedBox(height: AppSpacing.lg),
          SettingsSection(
            title: 'Preferences',
            children: [
              SettingsSwitchRow(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Alert me when a session ends',
                value: notificationsEnabled,
                onChanged: (_) => ref.read(notificationsEnabledProvider.notifier).toggle(),
              ),
              SettingsSwitchRow(
                icon: Icons.volume_up_outlined,
                title: 'Sounds',
                subtitle: 'Play a sound on completion',
                value: soundEnabled,
                onChanged: (_) => ref.read(soundEnabledProvider.notifier).toggle(),
              ),
              SettingsSwitchRow(
                icon: Icons.vibration_rounded,
                title: 'Haptic feedback',
                subtitle: 'Vibrate on taps and completion',
                value: hapticEnabled,
                onChanged: (_) => ref.read(hapticEnabledProvider.notifier).toggle(),
              ),
            ],
          ).animate().fadeIn(delay: 60.ms, duration: 240.ms),
          const SizedBox(height: AppSpacing.lg),
          SettingsSection(
            title: 'Focus',
            children: [
              SettingsNavRow(
                icon: Icons.flag_outlined,
                title: 'Daily goal',
                trailingText: '$dailyGoal min',
                onTap: () => showDailyGoalSheet(context),
              ),
              SettingsSwitchRow(
                icon: Icons.shield_outlined,
                title: 'Strict Mode',
                subtitle: 'Block accidental exits during a session',
                value: strictModeEnabled,
                onChanged: (_) => ref.read(strictModeEnabledProvider.notifier).toggle(),
              ),
              SettingsSwitchRow(
                icon: Icons.gpp_maybe_outlined,
                title: 'Fail on background exit',
                subtitle: 'End the session if you leave the app',
                value: strictModeFailOnExit,
                enabled: strictModeEnabled,
                onChanged: (_) => ref.read(strictModeFailOnExitProvider.notifier).toggle(),
              ),
            ],
          ).animate().fadeIn(delay: 120.ms, duration: 240.ms),
          const SizedBox(height: AppSpacing.lg),
          SettingsSection(
            title: 'Data',
            children: [
              SettingsNavRow(
                icon: Icons.ios_share_rounded,
                title: 'Export session history',
                onTap: () => _handleExport(context, ref),
              ),
              SettingsNavRow(
                icon: Icons.delete_outline_rounded,
                title: 'Reset all statistics',
                destructive: true,
                onTap: () => _handleReset(context, ref),
              ),
            ],
          ).animate().fadeIn(delay: 180.ms, duration: 240.ms),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              'Focus Timer · v1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
