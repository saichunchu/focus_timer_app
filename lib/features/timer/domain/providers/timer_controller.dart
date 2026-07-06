import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../history/domain/session_providers.dart';
import '../../../settings/presentation/settings_providers.dart';
import '../models/session_type.dart';
import '../models/timer_run_state.dart';

/// Owns the live countdown for a single timer session: configuration,
/// start/pause/resume/stop, and persisting the resulting [FocusSession]
/// once the session ends (naturally or by user interruption).
class TimerController extends StateNotifier<TimerRunState> {
  TimerController(this._ref) : super(TimerRunState.idle());

  final Ref _ref;
  Timer? _ticker;
  DateTime? _phaseStartedAt;
  int _elapsedBeforePauseMs = 0;

  static const _tickInterval = Duration(milliseconds: 200);

  /// Loads a new session configuration. Safe to call while idle only —
  /// callers should [reset] first if a session is already active.
  void configure({
    required int minutes,
    SessionType type = SessionType.focus,
    String? label,
    String? presetId,
  }) {
    _stopTicker();
    _elapsedBeforePauseMs = 0;
    _phaseStartedAt = null;
    state = TimerRunState(
      status: TimerStatus.idle,
      totalSeconds: minutes * 60,
      remainingMs: minutes * 60 * 1000,
      type: type,
      label: label,
      presetId: presetId,
    );
  }

  void start() {
    if (!state.isConfigured || state.status == TimerStatus.running) return;
    _phaseStartedAt = DateTime.now();
    state = state.copyWith(
      status: TimerStatus.running,
      startedAt: state.startedAt ?? DateTime.now(),
    );
    _ticker = Timer.periodic(_tickInterval, (_) => _tick());
    HapticService.instance.medium();
  }

  void pause() {
    if (state.status != TimerStatus.running) return;
    _accumulateElapsed();
    _stopTicker();
    state = state.copyWith(status: TimerStatus.paused);
    HapticService.instance.light();
  }

  void resume() {
    if (state.status != TimerStatus.paused) return;
    _phaseStartedAt = DateTime.now();
    state = state.copyWith(status: TimerStatus.running);
    _ticker = Timer.periodic(_tickInterval, (_) => _tick());
    HapticService.instance.medium();
  }

  /// Registers a background/foreground interruption (used by Strict Mode).
  void registerInterruption() {
    if (!state.isActive) return;
    state = state.copyWith(interruptionCount: state.interruptionCount + 1);
  }

  void _tick() {
    if (_phaseStartedAt == null) return;
    final elapsedSincePhaseStart =
        DateTime.now().difference(_phaseStartedAt!).inMilliseconds;
    final totalElapsedMs = _elapsedBeforePauseMs + elapsedSincePhaseStart;
    final remaining = (state.totalSeconds * 1000) - totalElapsedMs;

    if (remaining <= 0) {
      _finish(completed: true);
    } else {
      state = state.copyWith(remainingMs: remaining);
    }
  }

  void _accumulateElapsed() {
    if (_phaseStartedAt == null) return;
    _elapsedBeforePauseMs +=
        DateTime.now().difference(_phaseStartedAt!).inMilliseconds;
    _phaseStartedAt = null;
  }

  /// Stops the session early (user pressed Stop). Persists it as
  /// interrupted as long as some time had actually elapsed.
  Future<void> stop() => _finish(completed: false);

  Future<void> _finish({required bool completed}) async {
    if (!state.isActive) return;

    if (state.status == TimerStatus.running) {
      _accumulateElapsed();
    }
    _stopTicker();

    final actualSeconds = completed
        ? state.totalSeconds
        : (_elapsedBeforePauseMs / 1000).round();
    final start = state.startedAt ?? DateTime.now();

    if (actualSeconds > 0) {
      await _ref.read(sessionsProvider.notifier).addSession(
            startTime: start,
            endTime: DateTime.now(),
            plannedDurationMinutes: state.totalSeconds ~/ 60,
            actualDurationSeconds: actualSeconds,
            type: state.type,
            completed: completed,
            interrupted: !completed,
            interruptionCount: state.interruptionCount,
            label: state.label,
          );
    }

    state = state.copyWith(
      status: completed ? TimerStatus.completed : TimerStatus.idle,
      remainingMs: completed ? 0 : state.remainingMs,
    );

    if (completed) {
      await _onSessionCompleted();
    }
  }

  Future<void> _onSessionCompleted() async {
    await HapticService.instance.success();

    final notificationsEnabled = _ref.read(notificationsEnabledProvider);
    if (notificationsEnabled) {
      final isFocus = state.type == SessionType.focus;
      await NotificationService.instance.showSessionComplete(
        title: isFocus ? 'Focus session complete 🎉' : 'Break\'s over',
        body: isFocus
            ? "Nice work — you focused for ${state.totalSeconds ~/ 60} minutes."
            : 'Ready to get back to it?',
      );
    }
  }

  /// Returns to the idle/unconfigured picker state.
  void reset() {
    _stopTicker();
    _elapsedBeforePauseMs = 0;
    _phaseStartedAt = null;
    state = TimerRunState.idle();
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}

final timerControllerProvider =
    StateNotifierProvider.autoDispose<TimerController, TimerRunState>((ref) {
  return TimerController(ref);
});
