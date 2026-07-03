import 'package:class_tool/data/local/app_database.dart';
import 'package:flutter/foundation.dart';

@immutable
class AttendanceGroupSummary {
  const AttendanceGroupSummary({
    required this.group,
    required this.studentCount,
    required this.sessionCount,
  });

  final AttendanceGroup group;
  final int studentCount;
  final int sessionCount;
}

@immutable
class AttendanceSessionSummary {
  const AttendanceSessionSummary({
    required this.session,
    required this.group,
    required this.total,
    required this.present,
    required this.absent,
  });

  final AttendanceSession session;
  final AttendanceGroup group;
  final int total;
  final int present;
  final int absent;
}

@immutable
class AttendanceRecordEntry {
  const AttendanceRecordEntry({required this.record, required this.student});

  final AttendanceRecord record;
  final AttendanceStudent student;
}

@immutable
class AttendanceMatrix {
  const AttendanceMatrix({
    required this.group,
    required this.columns,
    required this.rows,
  });

  final AttendanceGroup group;
  final List<AttendanceMatrixColumn> columns;
  final List<AttendanceMatrixRow> rows;
}

@immutable
class AttendanceMatrixColumn {
  const AttendanceMatrixColumn({required this.session});

  final AttendanceSession session;
}

@immutable
class AttendanceMatrixRow {
  const AttendanceMatrixRow({required this.student, required this.cells});

  final AttendanceStudent student;
  final List<AttendanceMatrixCell> cells;
}

@immutable
class AttendanceMatrixCell {
  const AttendanceMatrixCell({required this.present, required this.remark});

  final bool? present;
  final String remark;
}
