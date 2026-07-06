import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/custom_timer_providers.dart';
import '../../domain/models/custom_timer_preset.dart';

/// A curated palette the user can tag a preset with — kept small and
/// on-brand rather than a full color wheel.
const List<Color> kPresetColorPalette = [
  AppColors.primary,
  Color(0xFF3FC17F),
  Color(0xFFF5A623),
  Color(0xFF4EA1F7),
  Color(0xFFEF5A6F),
  Color(0xFF2FBFB0),
];

/// Opens the create/edit sheet. Pass an existing [preset] to edit it,
/// or leave it null to create a new one.
Future<void> showPresetEditorSheet(BuildContext context, {CustomTimerPreset? preset}) {
  return showAppModalBottomSheet(
    context: context,
    accountForNavBar: false,
    builder: (context) => PresetEditorSheet(preset: preset),
  );
}

class PresetEditorSheet extends ConsumerStatefulWidget {
  const PresetEditorSheet({super.key, this.preset});

  final CustomTimerPreset? preset;

  @override
  ConsumerState<PresetEditorSheet> createState() => _PresetEditorSheetState();
}

class _PresetEditorSheetState extends ConsumerState<PresetEditorSheet> {
  late final TextEditingController _labelController;
  late int _minutes;
  late Color _color;
  String? _error;

  bool get _isEditing => widget.preset != null;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.preset?.label ?? '');
    _minutes = widget.preset?.minutes ?? 50;
    _color = widget.preset?.colorValue != null
        ? Color(widget.preset!.colorValue!)
        : kPresetColorPalette.first;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _adjustMinutes(int delta) {
    HapticService.instance.selection();
    setState(() => _minutes = (_minutes + delta).clamp(1, 240));
  }

  Future<void> _save() async {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      setState(() => _error = 'Give your timer a name');
      return;
    }

    final notifier = ref.read(customTimerPresetsProvider.notifier);
    if (_isEditing) {
      await notifier.update(
        widget.preset!.copyWith(label: label, minutes: _minutes, colorValue: _color.toARGB32()),
      );
    } else {
      await notifier.add(label: label, minutes: _minutes, colorValue: _color.toARGB32());
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurfaceSolid : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            Text(
              _isEditing ? 'Edit timer' : 'New custom timer',
              style: AppTextStyles.h2(color: theme.textTheme.headlineMedium?.color),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _labelController,
              textCapitalization: TextCapitalization.words,
              maxLength: 24,
              style: AppTextStyles.bodyLarge(color: theme.textTheme.headlineMedium?.color),
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Deep Work',
                errorText: _error,
                counterText: '',
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Duration', style: AppTextStyles.labelMedium(color: theme.textTheme.headlineMedium?.color)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepperButton(icon: Icons.remove_rounded, onTap: () => _adjustMinutes(-5)),
                SizedBox(
                  width: 120,
                  child: Column(
                    children: [
                      Text('$_minutes', style: AppTextStyles.h1(color: theme.textTheme.headlineMedium?.color)),
                      Text('minutes', style: AppTextStyles.bodySmall(color: theme.textTheme.bodyMedium?.color)),
                    ],
                  ),
                ),
                _StepperButton(icon: Icons.add_rounded, onTap: () => _adjustMinutes(5)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Color', style: AppTextStyles.labelMedium(color: theme.textTheme.headlineMedium?.color)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: kPresetColorPalette.map((color) {
                final selected = color.toARGB32() == _color.toARGB32();
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () {
                      HapticService.instance.selection();
                      setState(() => _color = color);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: theme.textTheme.headlineMedium!.color!, width: 2.5)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: selected
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Save changes' : 'Create timer'),
              ),
            ),
          ],
        ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
