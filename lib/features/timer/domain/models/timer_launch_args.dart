import 'session_type.dart';

/// Configuration passed from Home (or Custom Timers) to the Timer tab when
/// starting a specific preset. When `null` is passed as `extra`, the Timer
/// screen falls back to showing its own preset picker.
class TimerLaunchArgs {
  const TimerLaunchArgs({
    required this.minutes,
    this.type = SessionType.focus,
    this.label,
    this.presetId,
    this.autoStart = true,
  });

  final int minutes;
  final SessionType type;
  final String? label;
  final String? presetId;
  final bool autoStart;
}
