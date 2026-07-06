import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../heatmap/presentation/widgets/interactive_heatmap.dart';
import '../../domain/statistics_providers.dart';
import '../widgets/focus_bar_chart.dart';
import '../widgets/stats_range_selector.dart';
import '../widgets/stats_summary_grid.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(statsSummaryProvider);
    final range = ref.watch(selectedStatsRangeProvider);
    final buckets = ref.watch(chartBucketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl + 68),
        children: [
          Text(
            'Focus over time',
            style: theme.textTheme.titleLarge,
          ).animate().fadeIn(duration: 260.ms),
          const SizedBox(height: AppSpacing.sm),
          StatsRangeSelector(
            selected: range,
            onChanged: (value) => ref.read(selectedStatsRangeProvider.notifier).state = value,
          ).animate().fadeIn(delay: 60.ms, duration: 260.ms),
          const SizedBox(height: AppSpacing.md),
          SoftCard(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: FocusBarChart(buckets: buckets, range: range),
          ).animate().fadeIn(delay: 120.ms, duration: 300.ms),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Consistency',
            style: theme.textTheme.titleLarge,
          ).animate().fadeIn(delay: 200.ms, duration: 260.ms),
          const SizedBox(height: AppSpacing.sm),
          SoftCard(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: const InteractiveHeatmap(),
          ).animate().fadeIn(delay: 240.ms, duration: 300.ms),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Overview',
            style: theme.textTheme.titleLarge,
          ).animate().fadeIn(delay: 300.ms, duration: 260.ms),
          const SizedBox(height: AppSpacing.sm),
          StatsSummaryGrid(summary: summary),
        ],
      ),
    );
  }
}
