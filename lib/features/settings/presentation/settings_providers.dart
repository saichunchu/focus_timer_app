import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/settings_repository.dart';
import '../../../core/services/haptic_service.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// The resolved [ThemeMode] the app should render with.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._repo)
      : super(_parse(_repo.getThemeMode()));

  final SettingsRepository _repo;

  static ThemeMode _parse(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final str = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _repo.setThemeMode(str);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(settingsRepositoryProvider));
});

/// Simple boolean preference notifier reused for notifications/sound/haptics.
class BoolPrefNotifier extends StateNotifier<bool> {
  BoolPrefNotifier(this._initial, this._onChanged) : super(_initial);
  final bool _initial;
  final Future<void> Function(bool) _onChanged;

  Future<void> toggle() async {
    state = !state;
    await _onChanged(state);
  }

  Future<void> set(bool value) async {
    state = value;
    await _onChanged(value);
  }
}

final notificationsEnabledProvider =
    StateNotifierProvider<BoolPrefNotifier, bool>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return BoolPrefNotifier(repo.getNotificationsEnabled(), repo.setNotificationsEnabled);
});

final soundEnabledProvider = StateNotifierProvider<BoolPrefNotifier, bool>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return BoolPrefNotifier(repo.getSoundEnabled(), repo.setSoundEnabled);
});

final hapticEnabledProvider = StateNotifierProvider<BoolPrefNotifier, bool>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  final notifier = BoolPrefNotifier(repo.getHapticEnabled(), (value) async {
    HapticService.instance.enabled = value;
    await repo.setHapticEnabled(value);
  });
  HapticService.instance.enabled = repo.getHapticEnabled();
  return notifier;
});

final strictModeEnabledProvider = StateNotifierProvider<BoolPrefNotifier, bool>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return BoolPrefNotifier(repo.getStrictModeEnabled(), repo.setStrictModeEnabled);
});

final strictModeFailOnExitProvider = StateNotifierProvider<BoolPrefNotifier, bool>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return BoolPrefNotifier(repo.getStrictModeFailOnExit(), repo.setStrictModeFailOnExit);
});

// final strictModeFailOnExitProvider = StateNotifierProvider<BoolPrefNotifier, bool>((ref) {
//   final repo = ref.watch(settingsRepositoryProvider);
//   return BoolPrefNotifier(repo.getStrictModeFailOnExit(), repo.setStrictModeFailOnExit);
// });

class DailyGoalNotifier extends StateNotifier<int> {
  DailyGoalNotifier(this._repo) : super(_repo.getDailyGoalMinutes());
  final SettingsRepository _repo;

  Future<void> setGoal(int minutes) async {
    state = minutes;
    await _repo.setDailyGoalMinutes(minutes);
  }
}

final dailyGoalProvider = StateNotifierProvider<DailyGoalNotifier, int>((ref) {
  return DailyGoalNotifier(ref.watch(settingsRepositoryProvider));
});
