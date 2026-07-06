import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

/// A user-defined timer preset (e.g. "Deep Work" - 50 min).
///
/// Hive typeId: 1
class CustomTimerPreset extends HiveObject with EquatableMixin {
  CustomTimerPreset({
    required this.id,
    required this.label,
    required this.minutes,
    required this.createdAt,
    this.colorValue,
  });

  final String id;
  final String label;
  final int minutes;
  final DateTime createdAt;

  /// Optional ARGB color override for the preset card.
  final int? colorValue;

  CustomTimerPreset copyWith({String? label, int? minutes, int? colorValue}) {
    return CustomTimerPreset(
      id: id,
      label: label ?? this.label,
      minutes: minutes ?? this.minutes,
      createdAt: createdAt,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  @override
  List<Object?> get props => [id, label, minutes, createdAt, colorValue];
}

class CustomTimerPresetAdapter extends TypeAdapter<CustomTimerPreset> {
  @override
  final int typeId = 1;

  @override
  CustomTimerPreset read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return CustomTimerPreset(
      id: fields[0] as String,
      label: fields[1] as String,
      minutes: fields[2] as int,
      createdAt: fields[3] as DateTime,
      colorValue: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomTimerPreset obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.minutes)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.colorValue);
  }
}
