import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../../features/history/domain/models/focus_session.dart';
import '../../features/custom_timers/domain/models/custom_timer_preset.dart';

/// Bootstraps Hive: registers all TypeAdapters and opens all boxes used by
/// the app. Call [HiveService.init] once, before [runApp].
class HiveService {
  HiveService._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FocusSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CustomTimerPresetAdapter());
    }

    await Future.wait([
      Hive.openBox<FocusSession>(HiveBoxes.sessions),
      Hive.openBox<CustomTimerPreset>(HiveBoxes.customTimers),
      Hive.openBox(HiveBoxes.settings),
    ]);

    _initialized = true;
  }

  static Box<FocusSession> get sessionsBox =>
      Hive.box<FocusSession>(HiveBoxes.sessions);

  static Box<CustomTimerPreset> get customTimersBox =>
      Hive.box<CustomTimerPreset>(HiveBoxes.customTimers);

  static Box get settingsBox => Hive.box(HiveBoxes.settings);
}
