/// Global constants: Hive box names, notification channel ids, defaults.
abstract class HiveBoxes {
  HiveBoxes._();
  static const String sessions = 'sessions_box';
  static const String customTimers = 'custom_timers_box';
  static const String settings = 'settings_box';
}

abstract class SettingsKeys {
  SettingsKeys._();
  static const String themeMode = 'theme_mode'; // 'light' | 'dark' | 'system'
  static const String notificationsEnabled = 'notifications_enabled';
  static const String soundEnabled = 'sound_enabled';
  static const String hapticEnabled = 'haptic_enabled';
  static const String dailyGoalMinutes = 'daily_goal_minutes';
  static const String strictModeEnabled = 'strict_mode_enabled';
  static const String strictModeFailOnExit = 'strict_mode_fail_on_exit';
  // static const String strictModeFailOnExit = 'strict_mode_fail_on_exit';
  static const String userName = 'user_name';
}

abstract class AppDefaults {
  AppDefaults._();
  static const int dailyGoalMinutes = 120;
  static const List<int> defaultPresetsMinutes = [5, 10, 15, 20, 25, 30, 45];
  static const int shortBreakMinutes = 5;
  static const int longBreakMinutes = 15;
}

abstract class NotificationConstants {
  NotificationConstants._();
  static const String channelId = 'focus_timer_channel';
  static const String channelName = 'Focus Timer';
  static const String channelDescription =
      'Notifications for focus session completion and reminders';
  static const int sessionCompleteId = 1001;
}
