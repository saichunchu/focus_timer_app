import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../../../timer/domain/models/session_type.dart';

/// A single completed or interrupted focus/break session, persisted in Hive.
///
/// Hive typeId: 0
class FocusSession extends HiveObject with EquatableMixin {
  FocusSession({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.plannedDurationMinutes,
    required this.actualDurationSeconds,
    required this.type,
    required this.completed,
    required this.interrupted,
    this.interruptionCount = 0,
    this.label,
  });

  final String id;

  /// Calendar date (midnight) this session belongs to — used for grouping,
  /// streaks and the heatmap.
  final DateTime date;

  final DateTime startTime;
  final DateTime endTime;

  /// The duration the user intended to focus for.
  final int plannedDurationMinutes;

  /// The actual number of seconds the timer ran before it stopped.
  final int actualDurationSeconds;

  final SessionType type;

  /// True if the countdown reached zero naturally.
  final bool completed;

  /// True if the user stopped it early / it failed strict mode.
  final bool interrupted;

  /// Number of times the app was backgrounded during this session
  /// (tracked by Strict Focus Mode).
  final int interruptionCount;

  /// Optional custom label, e.g. "English hometask".
  final String? label;

  double get actualDurationMinutes => actualDurationSeconds / 60.0;

  FocusSession copyWith({
    bool? completed,
    bool? interrupted,
    int? interruptionCount,
    DateTime? endTime,
    int? actualDurationSeconds,
  }) {
    return FocusSession(
      id: id,
      date: date,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      plannedDurationMinutes: plannedDurationMinutes,
      actualDurationSeconds: actualDurationSeconds ?? this.actualDurationSeconds,
      type: type,
      completed: completed ?? this.completed,
      interrupted: interrupted ?? this.interrupted,
      interruptionCount: interruptionCount ?? this.interruptionCount,
      label: label,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        startTime,
        endTime,
        plannedDurationMinutes,
        actualDurationSeconds,
        type,
        completed,
        interrupted,
        interruptionCount,
        label,
      ];
}

/// Manually written Hive TypeAdapter (avoids requiring build_runner codegen).
class FocusSessionAdapter extends TypeAdapter<FocusSession> {
  @override
  final int typeId = 0;

  @override
  FocusSession read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return FocusSession(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime,
      plannedDurationMinutes: fields[4] as int,
      actualDurationSeconds: fields[5] as int,
      type: SessionType.values[fields[6] as int],
      completed: fields[7] as bool,
      interrupted: fields[8] as bool,
      interruptionCount: fields[9] as int? ?? 0,
      label: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FocusSession obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.plannedDurationMinutes)
      ..writeByte(5)
      ..write(obj.actualDurationSeconds)
      ..writeByte(6)
      ..write(obj.type.index)
      ..writeByte(7)
      ..write(obj.completed)
      ..writeByte(8)
      ..write(obj.interrupted)
      ..writeByte(9)
      ..write(obj.interruptionCount)
      ..writeByte(10)
      ..write(obj.label);
  }
}
