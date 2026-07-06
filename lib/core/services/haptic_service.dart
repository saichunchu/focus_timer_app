import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Centralizes haptic feedback so every interaction in the app feels
/// consistent. Respects the user's haptic-enabled setting.
class HapticService {
  HapticService._();
  static final HapticService instance = HapticService._();

  bool enabled = true;

  Future<void> light() async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> medium() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavy() async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> selection() async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// A distinct celebratory pulse used when a session completes.
  Future<void> success() async {
    if (!enabled) return;
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      Vibration.vibrate(pattern: [0, 60, 80, 60, 80, 120]);
    } else {
      await HapticFeedback.mediumImpact();
    }
  }
}
