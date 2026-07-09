import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/settings/presentation/settings_providers.dart';
import '../../features/timer/domain/models/timer_run_state.dart';
import '../../features/timer/domain/providers/timer_controller.dart';
import '../../features/timer/presentation/strict_mode_guard.dart';
import '../../features/timer/presentation/widgets/strict_mode_exit_dialog.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'bottom_nav_bar.dart';

/// Wraps every top-level tab with a shared [Scaffold] + [BottomNavBar],
/// driven by a [StatefulNavigationShell] from go_router.
///
/// Also enforces Strict Focus Mode app-wide: blocks tab switches, system
/// back, and records background exits while a session is active.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  bool _handledBackgroundExit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _handleNavTap(int index) async {
    if (index == widget.navigationShell.currentIndex) {
      widget.navigationShell.goBranch(index, initialLocation: true);
      return;
    }

    if (!await tryLeaveStrictSession(context, ref)) return;

    if (!mounted) return;
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handledBackgroundExit = false;
      return;
    }

    if (state != AppLifecycleState.paused) return;

    final strictEnabled = ref.read(strictModeEnabledProvider);
    final timerState = ref.read(timerControllerProvider);
    if (!strictEnabled || !timerState.isActive || _handledBackgroundExit) return;

    _handledBackgroundExit = true;
    final controller = ref.read(timerControllerProvider.notifier);
    controller.registerInterruption();

    final failOnExit = ref.read(strictModeFailOnExitProvider);
    if (failOnExit) {
      controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strictLocked = isStrictSessionLocked(ref);
    final controller = ref.read(timerControllerProvider.notifier);

    ref.listen<TimerRunState>(timerControllerProvider, (previous, next) {
      final strictEnabled = ref.read(strictModeEnabledProvider);
      final becameActive = previous?.isActive != true && next.isActive;
      if (!strictEnabled || !becameActive) return;

      if (widget.navigationShell.currentIndex != kTimerTabIndex) {
        widget.navigationShell.goBranch(kTimerTabIndex);
      }
    });

    return PopScope(
      canPop: !strictLocked,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final confirmed = await confirmLeaveStrictSession(context);
        if (!confirmed) return;

        await controller.stop();
      },
      child: Scaffold(
        extendBody: true,
        body: widget.navigationShell,
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: _handleNavTap,
        ),
      ),
    );
  }
}

/// Shared floating "+" action used from the bottom bar to quickly start a
/// custom timer / add a preset, depending on the active tab.
class AppFab extends StatelessWidget {
  const AppFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x407C6AF0),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
