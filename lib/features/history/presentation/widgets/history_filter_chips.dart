import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../timer/domain/models/session_type.dart';
import '../../domain/history_filter_providers.dart';

class HistoryFilterChips extends StatelessWidget {
  const HistoryFilterChips({
    super.key,
    required this.selectedType,
    required this.selectedStatus,
    required this.onTypeChanged,
    required this.onStatusChanged,
  });

  final SessionType? selectedType;
  final SessionStatusFilter selectedStatus;
  final ValueChanged<SessionType?> onTypeChanged;
  final ValueChanged<SessionStatusFilter> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _Chip(
            label: 'All',
            selected: selectedType == null,
            onTap: () => onTypeChanged(null),
          ),
          for (final type in SessionType.values)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: _Chip(
                label: type.label,
                selected: selectedType == type,
                color: type.color,
                onTap: () => onTypeChanged(type),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              width: 1,
              height: 20,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          _Chip(
            label: 'Completed',
            selected: selectedStatus == SessionStatusFilter.completed,
            color: AppColors.success,
            onTap: () => onStatusChanged(
              selectedStatus == SessionStatusFilter.completed
                  ? SessionStatusFilter.all
                  : SessionStatusFilter.completed,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: _Chip(
              label: 'Interrupted',
              selected: selectedStatus == SessionStatusFilter.interrupted,
              color: AppColors.error,
              onTap: () => onStatusChanged(
                selectedStatus == SessionStatusFilter.interrupted
                    ? SessionStatusFilter.all
                    : SessionStatusFilter.interrupted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final resolvedColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? resolvedColor : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium(
            color: selected ? Colors.white : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
