import 'package:hive/hive.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/hive_service.dart';

/// Thin wrapper around the Hive settings box, providing typed getters
/// and setters for every user preference.
class SettingsRepository {
  Box get _box => HiveService.settingsBox;

  String getThemeMode() =>
      _box.get(SettingsKeys.themeMode, defaultValue: 'system') as String;
  Future<void> setThemeMode(String mode) =>
      _box.put(SettingsKeys.themeMode, mode);

  bool getNotificationsEnabled() =>
      _box.get(SettingsKeys.notificationsEnabled, defaultValue: true) as bool;
  Future<void> setNotificationsEnabled(bool value) =>
      _box.put(SettingsKeys.notificationsEnabled, value);

  bool getSoundEnabled() =>
      _box.get(SettingsKeys.soundEnabled, defaultValue: true) as bool;
  Future<void> setSoundEnabled(bool value) =>
      _box.put(SettingsKeys.soundEnabled, value);

  bool getHapticEnabled() =>
      _box.get(SettingsKeys.hapticEnabled, defaultValue: true) as bool;
  Future<void> setHapticEnabled(bool value) =>
      _box.put(SettingsKeys.hapticEnabled, value);

  int getDailyGoalMinutes() => _box.get(
        SettingsKeys.dailyGoalMinutes,
        defaultValue: AppDefaults.dailyGoalMinutes,
      ) as int;
  Future<void> setDailyGoalMinutes(int minutes) =>
      _box.put(SettingsKeys.dailyGoalMinutes, minutes);

  bool getStrictModeEnabled() =>
      _box.get(SettingsKeys.strictModeEnabled, defaultValue: false) as bool;
  Future<void> setStrictModeEnabled(bool value) =>
      _box.put(SettingsKeys.strictModeEnabled, value);

  bool getStrictModeFailOnExit() =>
      _box.get(SettingsKeys.strictModeFailOnExit, defaultValue: false) as bool;
  Future<void> setStrictModeFailOnExit(bool value) =>
      _box.put(SettingsKeys.strictModeFailOnExit, value);

  // bool getStrictModeFailOnExit() =>
  //     _box.get(SettingsKeys.strictModeFailOnExit, defaultValue: false) as bool;
  // Future<void> setStrictModeFailOnExit(bool value) =>
  //     _box.put(SettingsKeys.strictModeFailOnExit, value);

  String getUserName() =>
      _box.get(SettingsKeys.userName, defaultValue: 'there') as String;
  Future<void> setUserName(String name) =>
      _box.put(SettingsKeys.userName, name);
}
