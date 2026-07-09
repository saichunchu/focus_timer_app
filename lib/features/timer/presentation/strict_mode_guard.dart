import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/presentation/settings_providers.dart';
import '../domain/providers/timer_controller.dart';
import 'widgets/strict_mode_exit_dialog.dart';

/// Index of the Timer tab inside [StatefulNavigationShell].
const kTimerTabIndex = 2;

/// Whether strict mode is on and a session is currently running or paused.
bool isStrictSessionLocked(WidgetRef ref) {
  final strictEnabled = ref.watch(strictModeEnabledProvider);
  final timerState = ref.watch(timerControllerProvider);
  return strictEnabled && timerState.isActive;
}

bool isStrictSessionLockedRead(WidgetRef ref) {
  final strictEnabled = ref.read(strictModeEnabledProvider);
  final timerState = ref.read(timerControllerProvider);
  return strictEnabled && timerState.isActive;
}

/// Prompts the user before leaving an active strict session.
/// Stops the session when the user confirms. Returns `true` when navigation
/// may proceed.
Future<bool> tryLeaveStrictSession(BuildContext context, WidgetRef ref) async {
  if (!isStrictSessionLockedRead(ref)) return true;

  final confirmed = await confirmLeaveStrictSession(context);
  if (!confirmed) return false;

  await ref.read(timerControllerProvider.notifier).stop();
  return true;
}
