import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/custom_timer_providers.dart';
import '../../domain/models/custom_timer_preset.dart';
import '../widgets/preset_editor_sheet.dart';
import '../widgets/preset_list_tile.dart';

class CustomTimersScreen extends ConsumerWidget {
  const CustomTimersScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, CustomTimerPreset preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete timer?'),
        content: Text('"${preset.label}" will be removed from your quick start list.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(customTimerPresetsProvider.notifier).delete(preset.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${preset.label}" deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(customTimerPresetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Timers'),
        centerTitle: false,
      ),
      body: presets.isEmpty
          ? _EmptyState(onCreate: () => showPresetEditorSheet(context))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              itemCount: presets.length,
              itemBuilder: (context, index) {
                final preset = presets[index];
                return PresetListTile(
                  preset: preset,
                  onTap: () => showPresetEditorSheet(context, preset: preset),
                  onDelete: () => _confirmDelete(context, ref, preset),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showPresetEditorSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New timer'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Icon(Icons.timer_outlined, size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No custom timers yet',
              style: AppTextStyles.h3(color: theme.textTheme.headlineMedium?.color),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create named presets like "Deep Work" or "Reading"\nfor sessions you start often.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(color: theme.textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: onCreate, child: const Text('Create your first timer')),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 260.ms);
  }
}
