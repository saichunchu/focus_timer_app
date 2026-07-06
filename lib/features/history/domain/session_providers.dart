import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/hive_service.dart';
import 'models/focus_session.dart';
import '../../timer/domain/models/session_type.dart';

const _uuid = Uuid();

/// Single source of truth for [FocusSession] data across the whole app.
/// Backed by Hive; automatically reflects changes made anywhere (including
/// directly on the box), sorted newest-first.
class SessionsNotifier extends StateNotifier<List<FocusSession>> {
  SessionsNotifier(this._box) : super(_sorted(_box)) {
    _box.listenable().addListener(_onBoxChanged);
  }

  final Box<FocusSession> _box;

  static List<FocusSession> _sorted(Box<FocusSession> box) {
    final list = box.values.toList();
    list.sort((a, b) => b.startTime.compareTo(a.startTime));
    return list;
  }

  void _onBoxChanged() {
    state = _sorted(_box);
  }

  /// Creates and persists a brand new session, returning its id.
  Future<String> addSession({
    required DateTime startTime,
    required DateTime endTime,
    required int plannedDurationMinutes,
    required int actualDurationSeconds,
    required SessionType type,
    required bool completed,
    required bool interrupted,
    int interruptionCount = 0,
    String? label,
  }) async {
    final id = _uuid.v4();
    final session = FocusSession(
      id: id,
      date: DateTime(startTime.year, startTime.month, startTime.day),
      startTime: startTime,
      endTime: endTime,
      plannedDurationMinutes: plannedDurationMinutes,
      actualDurationSeconds: actualDurationSeconds,
      type: type,
      completed: completed,
      interrupted: interrupted,
      interruptionCount: interruptionCount,
      label: label,
    );
    await _box.put(id, session);
    return id;
  }

  Future<void> updateSession(FocusSession session) async {
    await _box.put(session.id, session);
  }

  Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  @override
  void dispose() {
    _box.listenable().removeListener(_onBoxChanged);
    super.dispose();
  }
}

final sessionsProvider =
    StateNotifierProvider<SessionsNotifier, List<FocusSession>>((ref) {
  return SessionsNotifier(HiveService.sessionsBox);
});

/// Convenience derived provider: only completed/interrupted focus (not
/// break) sessions, newest first.
final focusSessionsProvider = Provider<List<FocusSession>>((ref) {
  final all = ref.watch(sessionsProvider);
  return all.where((s) => s.type == SessionType.focus).toList();
});
