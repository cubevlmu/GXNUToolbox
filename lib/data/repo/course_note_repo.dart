import 'package:class_tool/data/local/app_database.dart';
import 'package:class_tool/data/model/course_note.dart';
import 'package:class_tool/data/services/course_note_calendar_service.dart';
import 'package:class_tool/data/services/course_note_reminder_service.dart';
import 'package:drift/drift.dart';

class CourseNoteRepo {
  CourseNoteRepo({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  static CourseNoteCourseDraft courseDraftFromParts({
    required String semester,
    required String courseName,
    String teacherName = '',
    String classroom = '',
    String rawCourseId = '',
  }) {
    final keyParts = [
      semester.trim(),
      rawCourseId.trim(),
      courseName.trim(),
      teacherName.trim(),
      classroom.trim(),
    ].where((part) => part.isNotEmpty).join('|');
    return CourseNoteCourseDraft(
      courseKey: keyParts.isEmpty ? courseName.trim() : keyParts,
      courseName: courseName.trim().isEmpty ? '未命名课程' : courseName.trim(),
      teacherName: teacherName.trim(),
      classroom: classroom.trim(),
      semester: semester.trim(),
      rawCourseId: rawCourseId.trim(),
    );
  }

  static CourseNoteCourseDraft generalTaskCourseDraft() {
    return const CourseNoteCourseDraft(
      courseKey: generalTaskCourseKey,
      courseName: generalTaskCourseName,
    );
  }

  Stream<List<CourseNoteEntry>> watchUpcoming({
    required DateTime from,
    required DateTime to,
    int limit = 8,
  }) {
    final query = (_db.select(_db.courseNotes)
      ..where(
        (note) =>
            note.deletedAt.isNull() &
            note.isDone.equals(false) &
            note.dueAt.isNotNull() &
            note.dueAt.isBiggerOrEqualValue(from) &
            note.dueAt.isSmallerThanValue(to),
      )
      ..orderBy([
        (note) => OrderingTerm.asc(note.dueAt),
        (note) => OrderingTerm.asc(note.createdAt),
      ])
      ..limit(limit));
    return query.watch().asyncMap(_attachCourses);
  }

  Stream<List<CourseNoteEntry>> watchCourseNotes(String courseKey) {
    final query = (_db.select(_db.courseNotes)
      ..where(
        (note) => note.deletedAt.isNull() & note.courseKey.equals(courseKey),
      )
      ..orderBy([
        (note) => OrderingTerm.asc(note.isDone),
        (note) => OrderingTerm.asc(note.dueAt),
        (note) => OrderingTerm.desc(note.updatedAt),
      ]));
    return query.watch().asyncMap(_attachCourses);
  }

  Stream<List<CourseNoteEntry>> watchAllNotes({bool pendingOnly = false}) {
    final query = _db.select(_db.courseNotes)
      ..where((note) {
        final base = note.deletedAt.isNull();
        return pendingOnly ? base & note.isDone.equals(false) : base;
      })
      ..orderBy([
        (note) => OrderingTerm.asc(note.isDone),
        (note) => OrderingTerm.asc(note.dueAt),
        (note) => OrderingTerm.desc(note.updatedAt),
      ]);
    return query.watch().asyncMap(_attachCourses);
  }

  Stream<int> watchPendingCountForCourse(String courseKey) {
    return watchCourseNotes(
      courseKey,
    ).map((items) => items.where((item) => !item.note.isDone).length);
  }

  Future<int> save(CourseNoteDraft draft) async {
    final now = DateTime.now();
    await _upsertCourse(draft.course, now);
    final noteId = await _db.transaction(() async {
      if (draft.id != null) {
        await (_db.update(
          _db.courseNotes,
        )..where((note) => note.id.equals(draft.id!))).write(
          CourseNotesCompanion(
            courseKey: Value(draft.course.courseKey),
            type: Value(draft.type.name),
            title: Value(draft.title.trim()),
            content: Value(draft.content.trim()),
            dueAt: Value(draft.dueAt),
            remindAt: Value(draft.remindAt),
            linkedClassDate: Value(draft.linkedClassDate),
            updatedAt: Value(now),
          ),
        );
        return draft.id!;
      }
      return _db
          .into(_db.courseNotes)
          .insert(
            CourseNotesCompanion.insert(
              courseKey: draft.course.courseKey,
              type: Value(draft.type.name),
              title: draft.title.trim(),
              content: Value(draft.content.trim()),
              dueAt: Value(draft.dueAt),
              remindAt: Value(draft.remindAt),
              linkedClassDate: Value(draft.linkedClassDate),
              createdAt: now,
              updatedAt: now,
            ),
          );
    });

    final entry = await getEntry(noteId);
    if (entry != null) {
      await CourseNoteReminderService.schedule(entry);
      if (draft.exportCalendar) {
        final exported = await CourseNoteCalendarService.exportEntry(entry);
        if (exported) {
          await markCalendarExported(noteId);
        }
      }
    }
    return noteId;
  }

  Future<CourseNoteEntry?> getEntry(int noteId) async {
    final note = await (_db.select(
      _db.courseNotes,
    )..where((item) => item.id.equals(noteId))).getSingleOrNull();
    if (note == null) {
      return null;
    }
    final course = await _courseForKey(note.courseKey);
    return CourseNoteEntry(note: note, course: course);
  }

  Future<void> setDone(int noteId, bool isDone) async {
    await (_db.update(
      _db.courseNotes,
    )..where((note) => note.id.equals(noteId))).write(
      CourseNotesCompanion(
        isDone: Value(isDone),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (isDone) {
      await CourseNoteReminderService.cancel(noteId);
      return;
    }
    final entry = await getEntry(noteId);
    if (entry != null) {
      await CourseNoteReminderService.schedule(entry);
    }
  }

  Future<void> setDueAt(
    int noteId,
    DateTime dueAt, {
    bool markPending = false,
  }) async {
    final companion = CourseNotesCompanion(
      dueAt: Value(dueAt),
      isDone: markPending ? const Value(false) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );
    await (_db.update(
      _db.courseNotes,
    )..where((note) => note.id.equals(noteId))).write(companion);
    final entry = await getEntry(noteId);
    if (entry != null) {
      await CourseNoteReminderService.schedule(entry);
    }
  }

  Future<void> addToToday({
    required int noteId,
    required DateTime dueAt,
    required DateTime dayMarker,
  }) async {
    await (_db.update(
      _db.courseNotes,
    )..where((note) => note.id.equals(noteId))).write(
      CourseNotesCompanion(
        dueAt: Value(dueAt),
        linkedClassDate: Value(dayMarker),
        isDone: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final entry = await getEntry(noteId);
    if (entry != null) {
      await CourseNoteReminderService.schedule(entry);
    }
  }

  Future<void> removeFromToday(int noteId) async {
    await (_db.update(
      _db.courseNotes,
    )..where((note) => note.id.equals(noteId))).write(
      CourseNotesCompanion(
        dueAt: const Value<DateTime?>(null),
        linkedClassDate: const Value<DateTime?>(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final entry = await getEntry(noteId);
    if (entry != null) {
      await CourseNoteReminderService.schedule(entry);
    }
  }

  Future<void> delete(int noteId) async {
    await (_db.update(_db.courseNotes)..where((note) => note.id.equals(noteId)))
        .write(CourseNotesCompanion(deletedAt: Value(DateTime.now())));
    await CourseNoteReminderService.cancel(noteId);
  }

  Future<void> deleteMany(Iterable<int> noteIds) async {
    final ids = noteIds.toSet();
    if (ids.isEmpty) {
      return;
    }
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(
        _db.courseNotes,
      )..where((note) => note.id.isIn(ids))).write(
        CourseNotesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      for (final id in ids) {
        await CourseNoteReminderService.cancel(id);
      }
    });
  }

  Future<bool> exportToCalendar(int noteId) async {
    final entry = await getEntry(noteId);
    if (entry == null) {
      return false;
    }
    if (entry.note.calendarExported) {
      return false;
    }
    final exported = await CourseNoteCalendarService.exportEntry(entry);
    if (exported) {
      await markCalendarExported(noteId);
    }
    return exported;
  }

  Future<CourseNoteCalendarBatchResult> exportManyToCalendar(
    Iterable<int> noteIds,
  ) async {
    final ids = noteIds.toSet();
    if (ids.isEmpty) {
      return const CourseNoteCalendarBatchResult(total: 0);
    }
    var added = 0;
    var skipped = 0;
    var failed = 0;
    for (final id in ids) {
      final entry = await getEntry(id);
      if (entry == null) {
        failed += 1;
        continue;
      }
      if (entry.note.calendarExported) {
        skipped += 1;
        continue;
      }
      try {
        final exported = await CourseNoteCalendarService.exportEntry(entry);
        if (exported) {
          added += 1;
          await markCalendarExported(id);
        } else {
          skipped += 1;
        }
      } catch (_) {
        failed += 1;
      }
    }
    return CourseNoteCalendarBatchResult(
      total: ids.length,
      added: added,
      skipped: skipped,
      failed: failed,
    );
  }

  Future<void> markCalendarExported(int noteId) async {
    await (_db.update(
      _db.courseNotes,
    )..where((note) => note.id.equals(noteId))).write(
      CourseNotesCompanion(
        calendarExported: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _upsertCourse(CourseNoteCourseDraft course, DateTime now) async {
    await _db
        .into(_db.courseNoteCourses)
        .insertOnConflictUpdate(
          CourseNoteCoursesCompanion.insert(
            courseKey: course.courseKey,
            courseName: course.courseName,
            teacherName: Value(course.teacherName),
            classroom: Value(course.classroom),
            semester: Value(course.semester),
            rawCourseId: Value(course.rawCourseId),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<List<CourseNoteEntry>> _attachCourses(List<CourseNote> notes) async {
    final result = <CourseNoteEntry>[];
    for (final note in notes) {
      result.add(
        CourseNoteEntry(
          note: note,
          course: await _courseForKey(note.courseKey),
        ),
      );
    }
    return result;
  }

  Future<CourseNoteCourse> _courseForKey(String courseKey) async {
    final course = await (_db.select(
      _db.courseNoteCourses,
    )..where((item) => item.courseKey.equals(courseKey))).getSingleOrNull();
    if (course != null) {
      return course;
    }
    final now = DateTime.now();
    return CourseNoteCourse(
      courseKey: courseKey,
      courseName: '未命名课程',
      teacherName: '',
      classroom: '',
      semester: '',
      rawCourseId: '',
      createdAt: now,
      updatedAt: now,
    );
  }
}

class CourseNoteCalendarBatchResult {
  const CourseNoteCalendarBatchResult({
    required this.total,
    this.added = 0,
    this.skipped = 0,
    this.failed = 0,
  });

  final int total;
  final int added;
  final int skipped;
  final int failed;
}
