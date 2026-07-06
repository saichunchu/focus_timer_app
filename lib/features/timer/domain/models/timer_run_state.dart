import 'session_type.dart';

enum TimerStatus { idle, running, paused, completed }

/// Immutable snapshot of the timer engine, held by [TimerController].
class TimerRunState {
  const TimerRunState({
    required this.status,
    required this.totalSeconds,
    required this.remainingMs,
    required this.type,
    this.label,
    this.presetId,
    this.startedAt,
    this.interruptionCount = 0,
  });

  factory TimerRunState.idle() => const TimerRunState(
        status: TimerStatus.idle,
        totalSeconds: 0,
        remainingMs: 0,
        type: SessionType.focus,
      );

  final TimerStatus status;

  /// The configured session length, in whole seconds.
  final int totalSeconds;

  /// Milliseconds left on the countdown (fine-grained so the ring animates
  /// smoothly instead of jumping once a second).
  final int remainingMs;

  final SessionType type;
  final String? label;
  final String? presetId;

  /// Wall-clock time the session first started running — used as the
  /// session's `startTime` when it's persisted.
  final DateTime? startedAt;

  final int interruptionCount;

  bool get isConfigured => totalSeconds > 0;
  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isCompleted => status == TimerStatus.completed;
  bool get isActive => status == TimerStatus.running || status == TimerStatus.paused;

  /// 0.0 -> 1.0, how much of the session has elapsed.
  double get progress =>
      totalSeconds == 0 ? 0 : 1 - (remainingMs / (totalSeconds * 1000));

  int get remainingSeconds => (remainingMs / 1000).ceil();

  String get remainingLabel {
    final total = remainingSeconds.clamp(0, 1 << 31);
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  TimerRunState copyWith({
    TimerStatus? status,
    int? totalSeconds,
    int? remainingMs,
    SessionType? type,
    String? label,
    String? presetId,
    DateTime? startedAt,
    int? interruptionCount,
  }) {
    return TimerRunState(
      status: status ?? this.status,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingMs: remainingMs ?? this.remainingMs,
      type: type ?? this.type,
      label: label ?? this.label,
      presetId: presetId ?? this.presetId,
      startedAt: startedAt ?? this.startedAt,
      interruptionCount: interruptionCount ?? this.interruptionCount,
    );
  }
}
