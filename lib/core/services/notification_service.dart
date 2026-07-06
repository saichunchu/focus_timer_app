import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_constants.dart';

/// Wraps flutter_local_notifications to show session-completed and
/// reminder notifications.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationConstants.channelId,
        NotificationConstants.channelName,
        description: NotificationConstants.channelDescription,
        importance: Importance.high,
        playSound: true,
      ),
    );

    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showSessionComplete({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationConstants.channelId,
        NotificationConstants.channelName,
        channelDescription: NotificationConstants.channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(presentSound: true, presentAlert: true),
    );

    await _plugin.show(
      NotificationConstants.sessionCompleteId,
      title,
      body,
      details,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  /// Exposed for potential scheduled reminders in Settings.
  tz.TZDateTime nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
