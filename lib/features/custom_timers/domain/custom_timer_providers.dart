import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/hive_service.dart';
import 'models/custom_timer_preset.dart';

const _uuid = Uuid();

/// Single source of truth for user-created [CustomTimerPreset]s.
class CustomTimerPresetsNotifier extends StateNotifier<List<CustomTimerPreset>> {
  CustomTimerPresetsNotifier(this._box) : super(_sorted(_box)) {
    _box.listenable().addListener(_onBoxChanged);
  }

  final Box<CustomTimerPreset> _box;

  static List<CustomTimerPreset> _sorted(Box<CustomTimerPreset> box) {
    final list = box.values.toList();
    list.sort((a, b) => a.minutes.compareTo(b.minutes));
    return list;
  }

  void _onBoxChanged() => state = _sorted(_box);

  Future<void> add({required String label, required int minutes, int? colorValue}) async {
    final id = _uuid.v4();
    final preset = CustomTimerPreset(
      id: id,
      label: label,
      minutes: minutes,
      createdAt: DateTime.now(),
      colorValue: colorValue,
    );
    await _box.put(id, preset);
  }

  Future<void> update(CustomTimerPreset preset) async {
    await _box.put(preset.id, preset);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  void dispose() {
    _box.listenable().removeListener(_onBoxChanged);
    super.dispose();
  }
}

final customTimerPresetsProvider =
    StateNotifierProvider<CustomTimerPresetsNotifier, List<CustomTimerPreset>>(
        (ref) {
  return CustomTimerPresetsNotifier(HiveService.customTimersBox);
});
