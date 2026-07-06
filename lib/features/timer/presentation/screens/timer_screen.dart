import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../settings/presentation/settings_providers.dart';
import '../../domain/models/session_type.dart';
import '../../domain/models/timer_launch_args.dart';
import '../../domain/models/timer_run_state.dart';
import '../../domain/providers/timer_controller.dart';
import '../widgets/active_timer_view.dart';
import '../widgets/strict_mode_exit_dialog.dart';
import '../widgets/timer_completion_view.dart';
import '../widgets/timer_picker_view.dart';

/// The Timer tab. Renders one of three states driven by [TimerController]:
/// an idle preset picker, the live countdown, or a completion celebration.
///
/// When navigated to with [launchArgs] (e.g. from a Home preset tap), the
/// session is configured and started automatically.
///
/// Also enforces Strict Focus Mode: intercepts the hardware back
/// button/gesture while a session is active, and detects when the app is
/// backgrounded to record (and optionally fail) the session.
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key, this.launchArgs});

  final TimerLaunchArgs? launchArgs;

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> with WidgetsBindingObserver {
  late final ConfettiController _confettiController;
  TimerLaunchArgs? _lastHandledArgs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeHandleLaunchArgs(widget.launchArgs);
    });
  }

  @override
  void didUpdateWidget(covariant TimerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.launchArgs, oldWidget.launchArgs)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeHandleLaunchArgs(widget.launchArgs);
      });
    }
  }

  /// Consumes a launch-args instance exactly once (guarded by reference
  /// identity, since each navigation constructs a fresh object).
  ///
  /// If a session is already running or paused, new launch args are
  /// ignored rather than silently discarding it — this also prevents an
  /// easy Strict Mode bypass (e.g. tapping another preset on Home while
  /// a strict session is active).
  void _maybeHandleLaunchArgs(TimerLaunchArgs? args) {
    if (args == null || identical(args, _lastHandledArgs)) return;
    _lastHandledArgs = args;

    final controller = ref.read(timerControllerProvider.notifier);
    final currentState = ref.read(timerControllerProvider);

    if (currentState.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish or stop your current session first')),
      );
      return;
    }

    controller.configure(
      minutes: args.minutes,
      type: args.type,
      label: args.label,
      presetId: args.presetId,
    );
    if (args.autoStart) controller.start();
  }

  void _startBreak(SessionType type, int minutes) {
    final controller = ref.read(timerControllerProvider.notifier);
    controller.configure(minutes: minutes, type: type);
    controller.start();
  }

  /// Strict Mode: the app was backgrounded mid-session.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.paused) return;

    final strictEnabled = ref.read(strictModeEnabledProvider);
    final timerState = ref.read(timerControllerProvider);
    if (!strictEnabled || timerState.status != TimerStatus.running) return;

    final controller = ref.read(timerControllerProvider.notifier);
    controller.registerInterruption();

    final failOnExit = ref.read(strictModeFailOnExitProvider);
    if (failOnExit) {
      controller.stop();
    }
  }

  /// Strict Mode: the user tried to Stop a running/paused session.
  Future<void> _handleStopPressed(TimerRunState state) async {
    final strictEnabled = ref.read(strictModeEnabledProvider);
    if (strictEnabled) {
      final confirmed = await confirmLeaveStrictSession(context);
      if (!confirmed) return;
    }
    await ref.read(timerControllerProvider.notifier).stop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timerControllerProvider);
    final controller = ref.read(timerControllerProvider.notifier);
    final strictModeEnabled = ref.watch(strictModeEnabledProvider);
    final strictSessionActive = strictModeEnabled && state.isActive;

    ref.listen<TimerRunState>(timerControllerProvider, (previous, next) {
      final justCompleted = previous?.status != TimerStatus.completed &&
          next.status == TimerStatus.completed;
      if (justCompleted) {
        _confettiController.play();
      }
    });

    return PopScope(
      canPop: !strictSessionActive,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirmed = await confirmLeaveStrictSession(context);
        if (confirmed) {
          await controller.stop();
          if (context.mounted) Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        body: switch (state.status) {
          TimerStatus.idle => TimerPickerView(
              onSelectFocus: (minutes, {label, presetId}) {
                controller.configure(minutes: minutes, label: label, presetId: presetId);
                controller.start();
              },
              onSelectBreak: _startBreak,
            ),
          TimerStatus.running || TimerStatus.paused => ActiveTimerView(
              state: state,
              strictModeEnabled: strictModeEnabled,
              onStop: () => _handleStopPressed(state),
              onPauseResume: () {
                if (state.isRunning) {
                  controller.pause();
                } else {
                  controller.resume();
                }
              },
            ),
          TimerStatus.completed => TimerCompletionView(
              confettiController: _confettiController,
              completedType: state.type,
              completedMinutes: state.totalSeconds ~/ 60,
              onStartShortBreak: () =>
                  _startBreak(SessionType.shortBreak, AppDefaults.shortBreakMinutes),
              onStartLongBreak: () =>
                  _startBreak(SessionType.longBreak, AppDefaults.longBreakMinutes),
              onDone: controller.reset,
            ),
        },
      ),
    );
  }
}