import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class CourseNoteCourses extends Table {
  TextColumn get courseKey => text()();
  TextColumn get courseName => text()();
  TextColumn get teacherName => text().withDefault(const Constant(''))();
  TextColumn get classroom => text().withDefault(const Constant(''))();
  TextColumn get semester => text().withDefault(const Constant(''))();
  TextColumn get rawCourseId => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {courseKey};
}

class CourseNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get courseKey => text()();
  TextColumn get type => text().withDefault(const Constant('homework'))();
  TextColumn get title => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get remindAt => dateTime().nullable()();
  DateTimeColumn get linkedClassDate => dateTime().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  BoolColumn get calendarExported =>
      boolean().withDefault(const Constant(false))();
  IntColumn get notificationId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class AttendanceGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class AttendanceStudents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer().references(AttendanceGroups, #id)();
  TextColumn get studentNo => text().withDefault(const Constant(''))();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class AttendanceSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer().references(AttendanceGroups, #id)();
  TextColumn get title => text()();
  DateTimeColumn get sessionDate => dateTime()();
  TextColumn get remark => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class AttendanceRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(AttendanceSessions, #id)();
  IntColumn get studentId => integer().references(AttendanceStudents, #id)();
  BoolColumn get present => boolean().withDefault(const Constant(true))();
  TextColumn get remark => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(
  tables: [
    CourseNoteCourses,
    CourseNotes,
    AttendanceGroups,
    AttendanceStudents,
    AttendanceSessions,
    AttendanceRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(attendanceGroups);
        await m.createTable(attendanceStudents);
        await m.createTable(attendanceSessions);
        await m.createTable(attendanceRecords);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final dbDir = Directory(p.join(dir.path, 'database'));
    if (!dbDir.existsSync()) {
      await dbDir.create(recursive: true);
    }
    return NativeDatabase(File(p.join(dbDir.path, 'class_tool.sqlite')));
  });
}
