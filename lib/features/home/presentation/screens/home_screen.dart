import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/session_stats.dart';
import '../../../custom_timers/domain/custom_timer_providers.dart';
import '../../../history/domain/session_providers.dart';
import '../../../settings/presentation/settings_providers.dart';
import '../../../timer/presentation/strict_mode_guard.dart';
import '../../../timer/presentation/widgets/custom_duration_sheet.dart';
import '../widgets/goal_progress_card.dart';
import '../widgets/greeting_header.dart';
import '../widgets/mini_heatmap_preview.dart';
import '../widgets/recent_sessions_section.dart';
import '../widgets/stats_overview_row.dart';
import '../widgets/timer_presets_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final customPresets = ref.watch(customTimerPresetsProvider);
    final goalMinutes = ref.watch(dailyGoalProvider);
    final userName = ref.watch(settingsRepositoryProvider).getUserName();

    final todayMinutes = SessionStats.focusMinutesOn(sessions);
    final streak = SessionStats.currentStreak(sessions);
    final dailyTotals = SessionStats.dailyFocusTotals(sessions);
    final recent = SessionStats.recent(sessions, limit: 4);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: GreetingHeader(userName: userName)),
            SliverToBoxAdapter(
              child: StatsOverviewRow(todayMinutes: todayMinutes, currentStreak: streak),
            ),
            SliverToBoxAdapter(
              child: GoalProgressCard(todayMinutes: todayMinutes, goalMinutes: goalMinutes),
            ),
            SliverToBoxAdapter(
              child: TimerPresetsSection(
                defaultMinutes: AppDefaults.defaultPresetsMinutes,
                customPresets: customPresets,
                onAddCustom: () async {
                  if (!await tryLeaveStrictSession(context, ref)) return;
                  if (context.mounted) showCustomDurationSheet(context);
                },
                onManagePresets: () async {
                  if (!await tryLeaveStrictSession(context, ref)) return;
                  if (context.mounted) context.push(AppRoutes.customTimers);
                },
              ),
            ),
            SliverToBoxAdapter(child: MiniHeatmapPreview(dailyTotals: dailyTotals)),
            SliverToBoxAdapter(child: RecentSessionsSection(sessions: recent)),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl + 68)),
          ],
        ),
      ),
    );
  }
}
