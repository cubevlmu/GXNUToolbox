import 'package:class_tool/data/local/app_database.dart';
import 'package:class_tool/data/model/attendance.dart';
import 'package:drift/drift.dart';

class AttendanceRepo {
  AttendanceRepo({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  Stream<List<AttendanceGroupSummary>> watchGroups() {
    final query = _db.select(_db.attendanceGroups)
      ..where((item) => item.deletedAt.isNull())
      ..orderBy([(item) => OrderingTerm.desc(item.updatedAt)]);
    return query.watch().asyncMap(_attachGroupSummaries);
  }

  Stream<List<AttendanceSessionSummary>> watchSessions() {
    final query = _db.select(_db.attendanceSessions)
      ..where((item) => item.deletedAt.isNull())
      ..orderBy([(item) => OrderingTerm.desc(item.sessionDate)]);
    return query.watch().asyncMap(_attachSessionSummaries);
  }

  Stream<List<AttendanceRecordEntry>> watchRecords(int sessionId) {
    final query = _db.select(_db.attendanceRecords)
      ..where((item) => item.sessionId.equals(sessionId))
      ..orderBy([(item) => OrderingTerm.asc(item.id)]);
    return query.watch().asyncMap((records) async {
      if (records.isEmpty) return <AttendanceRecordEntry>[];
      final students =
          await (_db.select(_db.attendanceStudents)..where(
                (item) =>
                    item.id.isIn(records.map((record) => record.studentId)),
              ))
              .get();
      final studentMap = <int, AttendanceStudent>{
        for (final student in students) student.id: student,
      };
      return [
        for (final record in records)
          if (studentMap[record.studentId] != null)
            AttendanceRecordEntry(
              record: record,
              student: studentMap[record.studentId]!,
            ),
      ];
    });
  }

  Future<AttendanceSessionSummary?> getSessionSummary(int sessionId) async {
    final session = await (_db.select(
      _db.attendanceSessions,
    )..where((item) => item.id.equals(sessionId))).getSingleOrNull();
    if (session == null) return null;
    final group = await (_db.select(
      _db.attendanceGroups,
    )..where((item) => item.id.equals(session.groupId))).getSingle();
    final records = await (_db.select(
      _db.attendanceRecords,
    )..where((item) => item.sessionId.equals(sessionId))).get();
    final present = records.where((item) => item.present).length;
    return AttendanceSessionSummary(
      session: session,
      group: group,
      total: records.length,
      present: present,
      absent: records.length - present,
    );
  }

  Future<AttendanceMatrix> buildMatrix(
    int groupId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final group = await (_db.select(
      _db.attendanceGroups,
    )..where((item) => item.id.equals(groupId))).getSingle();
    final students =
        await (_db.select(_db.attendanceStudents)
              ..where(
                (item) =>
                    item.groupId.equals(groupId) & item.deletedAt.isNull(),
              )
              ..orderBy([(item) => OrderingTerm.asc(item.id)]))
            .get();
    final sessionQuery = _db.select(_db.attendanceSessions)
      ..where((item) => item.groupId.equals(groupId) & item.deletedAt.isNull())
      ..orderBy([(item) => OrderingTerm.asc(item.sessionDate)]);
    if (startDate != null) {
      sessionQuery.where(
        (item) => item.sessionDate.isBiggerOrEqualValue(startDate),
      );
    }
    if (endDate != null) {
      sessionQuery.where(
        (item) => item.sessionDate.isSmallerThanValue(endDate),
      );
    }
    final sessions = await sessionQuery.get();
    final records = sessions.isEmpty
        ? <AttendanceRecord>[]
        : await (_db.select(_db.attendanceRecords)..where(
                (item) => item.sessionId.isIn(sessions.map((item) => item.id)),
              ))
              .get();
    final recordMap = <String, AttendanceRecord>{
      for (final record in records)
        '${record.sessionId}:${record.studentId}': record,
    };
    return AttendanceMatrix(
      group: group,
      columns: [
        for (final session in sessions)
          AttendanceMatrixColumn(session: session),
      ],
      rows: [
        for (final student in students)
          AttendanceMatrixRow(
            student: student,
            cells: [
              for (final session in sessions)
                AttendanceMatrixCell(
                  present: recordMap['${session.id}:${student.id}']?.present,
                  remark:
                      recordMap['${session.id}:${student.id}']?.remark ?? '',
                ),
            ],
          ),
      ],
    );
  }

  Future<int> createGroup({
    required String name,
    required String rosterText,
    String description = '',
  }) async {
    final students = parseRoster(rosterText);
    if (name.trim().isEmpty) {
      throw StateError('请填写班级名称');
    }
    if (students.isEmpty) {
      throw StateError('请至少导入一名学生');
    }
    final now = DateTime.now();
    return _db.transaction(() async {
      final groupId = await _db
          .into(_db.attendanceGroups)
          .insert(
            AttendanceGroupsCompanion.insert(
              name: name.trim(),
              description: Value(description.trim()),
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (final student in students) {
        await _db
            .into(_db.attendanceStudents)
            .insert(
              AttendanceStudentsCompanion.insert(
                groupId: groupId,
                studentNo: Value(student.studentNo),
                name: student.name,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
      return groupId;
    });
  }

  Future<int> createSession({
    required int groupId,
    required String title,
    required DateTime sessionDate,
    String remark = '',
  }) async {
    final students =
        await (_db.select(_db.attendanceStudents)
              ..where(
                (item) =>
                    item.groupId.equals(groupId) & item.deletedAt.isNull(),
              )
              ..orderBy([(item) => OrderingTerm.asc(item.id)]))
            .get();
    if (students.isEmpty) {
      throw StateError('该班级没有学生名单');
    }
    final group = await (_db.select(
      _db.attendanceGroups,
    )..where((item) => item.id.equals(groupId))).getSingle();
    final now = DateTime.now();
    return _db.transaction(() async {
      final sessionId = await _db
          .into(_db.attendanceSessions)
          .insert(
            AttendanceSessionsCompanion.insert(
              groupId: groupId,
              title: title.trim().isEmpty ? '${group.name} 统计' : title.trim(),
              sessionDate: sessionDate,
              remark: Value(remark.trim()),
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (final student in students) {
        await _db
            .into(_db.attendanceRecords)
            .insert(
              AttendanceRecordsCompanion.insert(
                sessionId: sessionId,
                studentId: student.id,
                present: const Value(true),
                updatedAt: now,
              ),
            );
      }
      return sessionId;
    });
  }

  Future<void> updateRecord({
    required int recordId,
    required bool present,
    String? remark,
  }) async {
    await (_db.update(
      _db.attendanceRecords,
    )..where((item) => item.id.equals(recordId))).write(
      AttendanceRecordsCompanion(
        present: Value(present),
        remark: remark == null ? const Value.absent() : Value(remark.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteGroup(int groupId) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.attendanceGroups)
            ..where((item) => item.id.equals(groupId)))
          .write(AttendanceGroupsCompanion(deletedAt: Value(now)));
      await (_db.update(_db.attendanceStudents)
            ..where((item) => item.groupId.equals(groupId)))
          .write(AttendanceStudentsCompanion(deletedAt: Value(now)));
      await (_db.update(_db.attendanceSessions)
            ..where((item) => item.groupId.equals(groupId)))
          .write(AttendanceSessionsCompanion(deletedAt: Value(now)));
    });
  }

  Future<void> deleteSession(int sessionId) async {
    final now = DateTime.now();
    await (_db.update(_db.attendanceSessions)
          ..where((item) => item.id.equals(sessionId)))
        .write(AttendanceSessionsCompanion(deletedAt: Value(now)));
  }

  static List<AttendanceStudentDraft> parseRoster(String raw) {
    final result = <AttendanceStudentDraft>[];
    final seen = <String>{};
    for (final line in raw.split(RegExp(r'\r?\n'))) {
      final normalized = line.trim();
      if (normalized.isEmpty) continue;
      final parts = normalized
          .split(RegExp(r'[\s,，\t]+'))
          .where((item) => item.trim().isNotEmpty)
          .toList();
      final draft = parts.length >= 2
          ? AttendanceStudentDraft(
              studentNo: parts.first.trim(),
              name: parts.sublist(1).join(' ').trim(),
            )
          : AttendanceStudentDraft(studentNo: '', name: normalized);
      final key = '${draft.studentNo}|${draft.name}';
      if (draft.name.isNotEmpty && seen.add(key)) {
        result.add(draft);
      }
    }
    return result;
  }

  Future<List<AttendanceGroupSummary>> _attachGroupSummaries(
    List<AttendanceGroup> groups,
  ) async {
    if (groups.isEmpty) return <AttendanceGroupSummary>[];
    final groupIds = groups.map((item) => item.id).toList(growable: false);
    final students =
        await (_db.select(_db.attendanceStudents)..where(
              (item) => item.groupId.isIn(groupIds) & item.deletedAt.isNull(),
            ))
            .get();
    final sessions =
        await (_db.select(_db.attendanceSessions)..where(
              (item) => item.groupId.isIn(groupIds) & item.deletedAt.isNull(),
            ))
            .get();
    final studentCounts = <int, int>{};
    for (final student in students) {
      studentCounts[student.groupId] =
          (studentCounts[student.groupId] ?? 0) + 1;
    }
    final sessionCounts = <int, int>{};
    for (final session in sessions) {
      sessionCounts[session.groupId] =
          (sessionCounts[session.groupId] ?? 0) + 1;
    }
    return [
      for (final group in groups)
        AttendanceGroupSummary(
          group: group,
          studentCount: studentCounts[group.id] ?? 0,
          sessionCount: sessionCounts[group.id] ?? 0,
        ),
    ];
  }

  Future<List<AttendanceSessionSummary>> _attachSessionSummaries(
    List<AttendanceSession> sessions,
  ) async {
    if (sessions.isEmpty) return <AttendanceSessionSummary>[];
    final groupIds = sessions.map((item) => item.groupId).toSet();
    final sessionIds = sessions.map((item) => item.id).toList(growable: false);
    final groups = await (_db.select(
      _db.attendanceGroups,
    )..where((item) => item.id.isIn(groupIds))).get();
    final records = await (_db.select(
      _db.attendanceRecords,
    )..where((item) => item.sessionId.isIn(sessionIds))).get();
    final groupMap = <int, AttendanceGroup>{
      for (final group in groups) group.id: group,
    };
    final counts = <int, ({int total, int present})>{};
    for (final record in records) {
      final current = counts[record.sessionId] ?? (total: 0, present: 0);
      counts[record.sessionId] = (
        total: current.total + 1,
        present: current.present + (record.present ? 1 : 0),
      );
    }
    return [
      for (final session in sessions)
        if (groupMap[session.groupId] != null)
          AttendanceSessionSummary(
            session: session,
            group: groupMap[session.groupId]!,
            total: counts[session.id]?.total ?? 0,
            present: counts[session.id]?.present ?? 0,
            absent:
                (counts[session.id]?.total ?? 0) -
                (counts[session.id]?.present ?? 0),
          ),
    ];
  }
}

class AttendanceStudentDraft {
  const AttendanceStudentDraft({required this.studentNo, required this.name});

  final String studentNo;
  final String name;
}
