import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../history/domain/models/focus_session.dart';

/// Builds a CSV export of the full session history and opens the
/// platform share sheet so the user can save or send it anywhere.
class SessionExportService {
  const SessionExportService();

  static const _dateFmt = 'yyyy-MM-dd';
  static const _timeFmt = 'HH:mm:ss';

  String _toCsv(List<FocusSession> sessions) {
    final dateFormat = DateFormat(_dateFmt);
    final timeFormat = DateFormat(_timeFmt);

    final buffer = StringBuffer();
    buffer.writeln(
      'Date,Start Time,End Time,Type,Label,Planned (min),Actual (min),Completed,Interrupted,Interruptions',
    );

    final sorted = [...sessions]..sort((a, b) => a.startTime.compareTo(b.startTime));
    for (final s in sorted) {
      final row = [
        dateFormat.format(s.date),
        timeFormat.format(s.startTime),
        timeFormat.format(s.endTime),
        s.type.name,
        (s.label ?? '').replaceAll(',', ';'),
        s.plannedDurationMinutes.toString(),
        s.actualDurationMinutes.toStringAsFixed(1),
        s.completed.toString(),
        s.interrupted.toString(),
        s.interruptionCount.toString(),
      ];
      buffer.writeln(row.join(','));
    }
    return buffer.toString();
  }

  /// Writes a CSV file to a temp directory and opens the share sheet.
  /// Returns `false` if there was nothing to export.
  Future<bool> exportAndShare(List<FocusSession> sessions) async {
    if (sessions.isEmpty) return false;

    final csv = _toCsv(sessions);
    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/focus_sessions_$timestamp.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Focus Timer session history',
      text: 'Exported ${sessions.length} sessions from Focus Timer.',
    );
    return true;
  }
}
