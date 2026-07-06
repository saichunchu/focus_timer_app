import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();
  // await NotificationService.instance.init();

  runApp(const ProviderScope(child: FocusTimerApp()));
}

class FocusTimerApp extends ConsumerWidget {
  const FocusTimerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Ensure the haptic service reflects the saved preference on launch.
    ref.watch(hapticEnabledProvider);

    return MaterialApp.router(
      title: 'Focus Timer',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
