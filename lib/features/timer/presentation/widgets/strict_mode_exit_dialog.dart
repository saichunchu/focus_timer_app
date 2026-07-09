import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Shown whenever the user tries to leave an active session while Strict
/// Focus Mode is on — via the hardware back button/gesture or by tapping
/// away to another tab. Returns `true` if the user confirms leaving.
Future<bool> confirmLeaveStrictSession(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      icon: const Icon(Icons.shield_outlined, color: AppColors.primary),
      title: const Text('Leave focus session?'),
      content: const Text(
        "Strict Mode is on. Leaving now will end your session early and it'll be recorded as interrupted. "
        'This includes switching tabs, pressing back, or leaving the app.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Stay focused'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Leave anyway', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );
  return result ?? false;
}
