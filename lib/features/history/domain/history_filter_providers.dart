import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../timer/domain/models/session_type.dart';
import 'models/focus_session.dart';
import 'session_providers.dart';

enum SessionStatusFilter { all, completed, interrupted }

class HistoryFilterState {
  const HistoryFilterState({
    this.query = '',
    this.type,
    this.status = SessionStatusFilter.all,
  });

  final String query;

  /// `null` means "all types".
  final SessionType? type;
  final SessionStatusFilter status;

  bool get isDefault => query.isEmpty && type == null && status == SessionStatusFilter.all;

  HistoryFilterState copyWith({
    String? query,
    bool clearType = false,
    SessionType? type,
    SessionStatusFilter? status,
  }) {
    return HistoryFilterState(
      query: query ?? this.query,
      type: clearType ? null : (type ?? this.type),
      status: status ?? this.status,
    );
  }
}

class HistoryFilterNotifier extends StateNotifier<HistoryFilterState> {
  HistoryFilterNotifier() : super(const HistoryFilterState());

  void setQuery(String query) => state = state.copyWith(query: query);

  void setType(SessionType? type) {
    state = type == null ? state.copyWith(clearType: true) : state.copyWith(type: type);
  }

  void setStatus(SessionStatusFilter status) => state = state.copyWith(status: status);

  void clear() => state = const HistoryFilterState();
}

final historyFilterProvider =
    StateNotifierProvider<HistoryFilterNotifier, HistoryFilterState>((ref) {
  return HistoryFilterNotifier();
});

/// Sessions after search + type + status filters are applied, newest first.
final filteredSessionsProvider = Provider<List<FocusSession>>((ref) {
  final sessions = ref.watch(sessionsProvider);
  final filter = ref.watch(historyFilterProvider);

  return sessions.where((s) {
    if (filter.type != null && s.type != filter.type) return false;

    switch (filter.status) {
      case SessionStatusFilter.completed:
        if (!s.completed) return false;
        break;
      case SessionStatusFilter.interrupted:
        if (!s.interrupted) return false;
        break;
      case SessionStatusFilter.all:
        break;
    }

    if (filter.query.trim().isNotEmpty) {
      final q = filter.query.trim().toLowerCase();
      final haystack = '${s.label ?? ''} ${s.type.label}'.toLowerCase();
      if (!haystack.contains(q)) return false;
    }

    return true;
  }).toList();
});

/// Groups (already-filtered/sorted) sessions by calendar day for section
/// headers in the list, preserving newest-first order.
Map<DateTime, List<FocusSession>> groupSessionsByDay(List<FocusSession> sessions) {
  final map = <DateTime, List<FocusSession>>{};
  for (final s in sessions) {
    final day = DateTime(s.date.year, s.date.month, s.date.day);
    map.putIfAbsent(day, () => []).add(s);
  }
  return map;
}
