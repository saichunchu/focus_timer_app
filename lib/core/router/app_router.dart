import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/timer/presentation/screens/timer_screen.dart';
import '../../features/timer/domain/models/timer_launch_args.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/custom_timers/presentation/screens/custom_timers_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

/// Route path constants — used across the app instead of magic strings.
abstract class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String home = '/home';
  static const String statistics = '/statistics';
  static const String timer = '/timer';
  static const String history = '/history';
  static const String settings = '/settings';

  static const String timerRun = 'run';
  static const String customTimers = '/custom-timers';
  static const String sessionDetail = 'session';
  static const String editGoal = 'goal';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.customTimers,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CustomTimersScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) =>
                    _fadeThrough(state, const HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.statistics,
                pageBuilder: (context, state) =>
                    _fadeThrough(state, const StatisticsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.timer,
                pageBuilder: (context, state) => _fadeThrough(
                  state,
                  TimerScreen(launchArgs: state.extra as TimerLaunchArgs?),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                pageBuilder: (context, state) =>
                    _fadeThrough(state, const HistoryScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (context, state) =>
                    _fadeThrough(state, const SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// A soft fade + slight-scale transition used for every top-level tab,
/// avoiding jarring platform-default slides between unrelated sections.
CustomTransitionPage _fadeThrough(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.98, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}
