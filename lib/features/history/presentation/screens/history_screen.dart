import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/history_filter_providers.dart';
import '../widgets/history_filter_chips.dart';
import '../widgets/history_search_field.dart';
import '../widgets/history_session_tile.dart';
import '../widgets/session_detail_sheet.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(historyFilterProvider).query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _dayHeaderLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == today) return 'Today';
    if (day == yesterday) return 'Yesterday';
    final sameYear = day.year == now.year;
    return DateFormat(sameYear ? 'EEEE, MMMM d' : 'MMMM d, y').format(day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = ref.watch(historyFilterProvider);
    final filterNotifier = ref.read(historyFilterProvider.notifier);
    final filtered = ref.watch(filteredSessionsProvider);
    final grouped = groupSessionsByDay(filtered);
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            child: HistorySearchField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {}); // refresh suffix (clear) icon state
                filterNotifier.setQuery(value);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          HistoryFilterChips(
            selectedType: filter.type,
            selectedStatus: filter.status,
            onTypeChanged: filterNotifier.setType,
            onStatusChanged: filterNotifier.setStatus,
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(hasActiveFilter: !filter.isDefault)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      AppSpacing.xxl + 68,
                    ),
                    itemCount: days.length,
                    itemBuilder: (context, dayIndex) {
                      final day = days[dayIndex];
                      final sessionsForDay = grouped[day]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: dayIndex == 0 ? 0 : AppSpacing.md,
                              bottom: AppSpacing.sm,
                            ),
                            child: Text(
                              _dayHeaderLabel(day),
                              style: AppTextStyles.overline(
                                color: theme.brightness == Brightness.dark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.lightTextTertiary,
                              ),
                            ),
                          ),
                          ...sessionsForDay.map(
                            (session) => HistorySessionTile(
                              session: session,
                              onTap: () => showSessionDetailSheet(context, session),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: (40 * dayIndex).ms, duration: 220.ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasActiveFilter});
  final bool hasActiveFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasActiveFilter ? Icons.search_off_rounded : Icons.history_rounded,
              size: 40,
              color: theme.textTheme.bodyMedium?.color,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasActiveFilter ? 'No matching sessions' : 'No sessions yet',
              style: AppTextStyles.h3(color: theme.textTheme.headlineMedium?.color),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasActiveFilter
                  ? 'Try a different search term or filter.'
                  : 'Your completed and interrupted sessions\nwill show up here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(color: theme.textTheme.bodyMedium?.color),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 240.ms);
  }
}
