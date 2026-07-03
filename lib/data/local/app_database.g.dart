// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CourseNoteCoursesTable extends CourseNoteCourses
    with TableInfo<$CourseNoteCoursesTable, CourseNoteCourse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseNoteCoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _courseKeyMeta = const VerificationMeta(
    'courseKey',
  );
  @override
  late final GeneratedColumn<String> courseKey = GeneratedColumn<String>(
    'course_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseNameMeta = const VerificationMeta(
    'courseName',
  );
  @override
  late final GeneratedColumn<String> courseName = GeneratedColumn<String>(
    'course_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherNameMeta = const VerificationMeta(
    'teacherName',
  );
  @override
  late final GeneratedColumn<String> teacherName = GeneratedColumn<String>(
    'teacher_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _classroomMeta = const VerificationMeta(
    'classroom',
  );
  @override
  late final GeneratedColumn<String> classroom = GeneratedColumn<String>(
    'classroom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _semesterMeta = const VerificationMeta(
    'semester',
  );
  @override
  late final GeneratedColumn<String> semester = GeneratedColumn<String>(
    'semester',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _rawCourseIdMeta = const VerificationMeta(
    'rawCourseId',
  );
  @override
  late final GeneratedColumn<String> rawCourseId = GeneratedColumn<String>(
    'raw_course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    courseKey,
    courseName,
    teacherName,
    classroom,
    semester,
    rawCourseId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_note_courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseNoteCourse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('course_key')) {
      context.handle(
        _courseKeyMeta,
        courseKey.isAcceptableOrUnknown(data['course_key']!, _courseKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_courseKeyMeta);
    }
    if (data.containsKey('course_name')) {
      context.handle(
        _courseNameMeta,
        courseName.isAcceptableOrUnknown(data['course_name']!, _courseNameMeta),
      );
    } else if (isInserting) {
      context.missing(_courseNameMeta);
    }
    if (data.containsKey('teacher_name')) {
      context.handle(
        _teacherNameMeta,
        teacherName.isAcceptableOrUnknown(
          data['teacher_name']!,
          _teacherNameMeta,
        ),
      );
    }
    if (data.containsKey('classroom')) {
      context.handle(
        _classroomMeta,
        classroom.isAcceptableOrUnknown(data['classroom']!, _classroomMeta),
      );
    }
    if (data.containsKey('semester')) {
      context.handle(
        _semesterMeta,
        semester.isAcceptableOrUnknown(data['semester']!, _semesterMeta),
      );
    }
    if (data.containsKey('raw_course_id')) {
      context.handle(
        _rawCourseIdMeta,
        rawCourseId.isAcceptableOrUnknown(
          data['raw_course_id']!,
          _rawCourseIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {courseKey};
  @override
  CourseNoteCourse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseNoteCourse(
      courseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_key'],
      )!,
      courseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_name'],
      )!,
      teacherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_name'],
      )!,
      classroom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classroom'],
      )!,
      semester: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}semester'],
      )!,
      rawCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_course_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CourseNoteCoursesTable createAlias(String alias) {
    return $CourseNoteCoursesTable(attachedDatabase, alias);
  }
}

class CourseNoteCourse extends DataClass
    implements Insertable<CourseNoteCourse> {
  final String courseKey;
  final String courseName;
  final String teacherName;
  final String classroom;
  final String semester;
  final String rawCourseId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CourseNoteCourse({
    required this.courseKey,
    required this.courseName,
    required this.teacherName,
    required this.classroom,
    required this.semester,
    required this.rawCourseId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['course_key'] = Variable<String>(courseKey);
    map['course_name'] = Variable<String>(courseName);
    map['teacher_name'] = Variable<String>(teacherName);
    map['classroom'] = Variable<String>(classroom);
    map['semester'] = Variable<String>(semester);
    map['raw_course_id'] = Variable<String>(rawCourseId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CourseNoteCoursesCompanion toCompanion(bool nullToAbsent) {
    return CourseNoteCoursesCompanion(
      courseKey: Value(courseKey),
      courseName: Value(courseName),
      teacherName: Value(teacherName),
      classroom: Value(classroom),
      semester: Value(semester),
      rawCourseId: Value(rawCourseId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CourseNoteCourse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseNoteCourse(
      courseKey: serializer.fromJson<String>(json['courseKey']),
      courseName: serializer.fromJson<String>(json['courseName']),
      teacherName: serializer.fromJson<String>(json['teacherName']),
      classroom: serializer.fromJson<String>(json['classroom']),
      semester: serializer.fromJson<String>(json['semester']),
      rawCourseId: serializer.fromJson<String>(json['rawCourseId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'courseKey': serializer.toJson<String>(courseKey),
      'courseName': serializer.toJson<String>(courseName),
      'teacherName': serializer.toJson<String>(teacherName),
      'classroom': serializer.toJson<String>(classroom),
      'semester': serializer.toJson<String>(semester),
      'rawCourseId': serializer.toJson<String>(rawCourseId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CourseNoteCourse copyWith({
    String? courseKey,
    String? courseName,
    String? teacherName,
    String? classroom,
    String? semester,
    String? rawCourseId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CourseNoteCourse(
    courseKey: courseKey ?? this.courseKey,
    courseName: courseName ?? this.courseName,
    teacherName: teacherName ?? this.teacherName,
    classroom: classroom ?? this.classroom,
    semester: semester ?? this.semester,
    rawCourseId: rawCourseId ?? this.rawCourseId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CourseNoteCourse copyWithCompanion(CourseNoteCoursesCompanion data) {
    return CourseNoteCourse(
      courseKey: data.courseKey.present ? data.courseKey.value : this.courseKey,
      courseName: data.courseName.present
          ? data.courseName.value
          : this.courseName,
      teacherName: data.teacherName.present
          ? data.teacherName.value
          : this.teacherName,
      classroom: data.classroom.present ? data.classroom.value : this.classroom,
      semester: data.semester.present ? data.semester.value : this.semester,
      rawCourseId: data.rawCourseId.present
          ? data.rawCourseId.value
          : this.rawCourseId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseNoteCourse(')
          ..write('courseKey: $courseKey, ')
          ..write('courseName: $courseName, ')
          ..write('teacherName: $teacherName, ')
          ..write('classroom: $classroom, ')
          ..write('semester: $semester, ')
          ..write('rawCourseId: $rawCourseId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    courseKey,
    courseName,
    teacherName,
    classroom,
    semester,
    rawCourseId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseNoteCourse &&
          other.courseKey == this.courseKey &&
          other.courseName == this.courseName &&
          other.teacherName == this.teacherName &&
          other.classroom == this.classroom &&
          other.semester == this.semester &&
          other.rawCourseId == this.rawCourseId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CourseNoteCoursesCompanion extends UpdateCompanion<CourseNoteCourse> {
  final Value<String> courseKey;
  final Value<String> courseName;
  final Value<String> teacherName;
  final Value<String> classroom;
  final Value<String> semester;
  final Value<String> rawCourseId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CourseNoteCoursesCompanion({
    this.courseKey = const Value.absent(),
    this.courseName = const Value.absent(),
    this.teacherName = const Value.absent(),
    this.classroom = const Value.absent(),
    this.semester = const Value.absent(),
    this.rawCourseId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseNoteCoursesCompanion.insert({
    required String courseKey,
    required String courseName,
    this.teacherName = const Value.absent(),
    this.classroom = const Value.absent(),
    this.semester = const Value.absent(),
    this.rawCourseId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : courseKey = Value(courseKey),
       courseName = Value(courseName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CourseNoteCourse> custom({
    Expression<String>? courseKey,
    Expression<String>? courseName,
    Expression<String>? teacherName,
    Expression<String>? classroom,
    Expression<String>? semester,
    Expression<String>? rawCourseId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (courseKey != null) 'course_key': courseKey,
      if (courseName != null) 'course_name': courseName,
      if (teacherName != null) 'teacher_name': teacherName,
      if (classroom != null) 'classroom': classroom,
      if (semester != null) 'semester': semester,
      if (rawCourseId != null) 'raw_course_id': rawCourseId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseNoteCoursesCompanion copyWith({
    Value<String>? courseKey,
    Value<String>? courseName,
    Value<String>? teacherName,
    Value<String>? classroom,
    Value<String>? semester,
    Value<String>? rawCourseId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CourseNoteCoursesCompanion(
      courseKey: courseKey ?? this.courseKey,
      courseName: courseName ?? this.courseName,
      teacherName: teacherName ?? this.teacherName,
      classroom: classroom ?? this.classroom,
      semester: semester ?? this.semester,
      rawCourseId: rawCourseId ?? this.rawCourseId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (courseKey.present) {
      map['course_key'] = Variable<String>(courseKey.value);
    }
    if (courseName.present) {
      map['course_name'] = Variable<String>(courseName.value);
    }
    if (teacherName.present) {
      map['teacher_name'] = Variable<String>(teacherName.value);
    }
    if (classroom.present) {
      map['classroom'] = Variable<String>(classroom.value);
    }
    if (semester.present) {
      map['semester'] = Variable<String>(semester.value);
    }
    if (rawCourseId.present) {
      map['raw_course_id'] = Variable<String>(rawCourseId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseNoteCoursesCompanion(')
          ..write('courseKey: $courseKey, ')
          ..write('courseName: $courseName, ')
          ..write('teacherName: $teacherName, ')
          ..write('classroom: $classroom, ')
          ..write('semester: $semester, ')
          ..write('rawCourseId: $rawCourseId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CourseNotesTable extends CourseNotes
    with TableInfo<$CourseNotesTable, CourseNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _courseKeyMeta = const VerificationMeta(
    'courseKey',
  );
  @override
  late final GeneratedColumn<String> courseKey = GeneratedColumn<String>(
    'course_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('homework'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindAtMeta = const VerificationMeta(
    'remindAt',
  );
  @override
  late final GeneratedColumn<DateTime> remindAt = GeneratedColumn<DateTime>(
    'remind_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedClassDateMeta = const VerificationMeta(
    'linkedClassDate',
  );
  @override
  late final GeneratedColumn<DateTime> linkedClassDate =
      GeneratedColumn<DateTime>(
        'linked_class_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _calendarExportedMeta = const VerificationMeta(
    'calendarExported',
  );
  @override
  late final GeneratedColumn<bool> calendarExported = GeneratedColumn<bool>(
    'calendar_exported',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("calendar_exported" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    courseKey,
    type,
    title,
    content,
    dueAt,
    remindAt,
    linkedClassDate,
    isDone,
    calendarExported,
    notificationId,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('course_key')) {
      context.handle(
        _courseKeyMeta,
        courseKey.isAcceptableOrUnknown(data['course_key']!, _courseKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_courseKeyMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('remind_at')) {
      context.handle(
        _remindAtMeta,
        remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta),
      );
    }
    if (data.containsKey('linked_class_date')) {
      context.handle(
        _linkedClassDateMeta,
        linkedClassDate.isAcceptableOrUnknown(
          data['linked_class_date']!,
          _linkedClassDateMeta,
        ),
      );
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('calendar_exported')) {
      context.handle(
        _calendarExportedMeta,
        calendarExported.isAcceptableOrUnknown(
          data['calendar_exported']!,
          _calendarExportedMeta,
        ),
      );
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      courseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_key'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      remindAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remind_at'],
      ),
      linkedClassDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}linked_class_date'],
      ),
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
      calendarExported: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}calendar_exported'],
      )!,
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CourseNotesTable createAlias(String alias) {
    return $CourseNotesTable(attachedDatabase, alias);
  }
}

class CourseNote extends DataClass implements Insertable<CourseNote> {
  final int id;
  final String courseKey;
  final String type;
  final String title;
  final String content;
  final DateTime? dueAt;
  final DateTime? remindAt;
  final DateTime? linkedClassDate;
  final bool isDone;
  final bool calendarExported;
  final int? notificationId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const CourseNote({
    required this.id,
    required this.courseKey,
    required this.type,
    required this.title,
    required this.content,
    this.dueAt,
    this.remindAt,
    this.linkedClassDate,
    required this.isDone,
    required this.calendarExported,
    this.notificationId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['course_key'] = Variable<String>(courseKey);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    if (!nullToAbsent || remindAt != null) {
      map['remind_at'] = Variable<DateTime>(remindAt);
    }
    if (!nullToAbsent || linkedClassDate != null) {
      map['linked_class_date'] = Variable<DateTime>(linkedClassDate);
    }
    map['is_done'] = Variable<bool>(isDone);
    map['calendar_exported'] = Variable<bool>(calendarExported);
    if (!nullToAbsent || notificationId != null) {
      map['notification_id'] = Variable<int>(notificationId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CourseNotesCompanion toCompanion(bool nullToAbsent) {
    return CourseNotesCompanion(
      id: Value(id),
      courseKey: Value(courseKey),
      type: Value(type),
      title: Value(title),
      content: Value(content),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      remindAt: remindAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remindAt),
      linkedClassDate: linkedClassDate == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedClassDate),
      isDone: Value(isDone),
      calendarExported: Value(calendarExported),
      notificationId: notificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CourseNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseNote(
      id: serializer.fromJson<int>(json['id']),
      courseKey: serializer.fromJson<String>(json['courseKey']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      remindAt: serializer.fromJson<DateTime?>(json['remindAt']),
      linkedClassDate: serializer.fromJson<DateTime?>(json['linkedClassDate']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      calendarExported: serializer.fromJson<bool>(json['calendarExported']),
      notificationId: serializer.fromJson<int?>(json['notificationId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'courseKey': serializer.toJson<String>(courseKey),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'remindAt': serializer.toJson<DateTime?>(remindAt),
      'linkedClassDate': serializer.toJson<DateTime?>(linkedClassDate),
      'isDone': serializer.toJson<bool>(isDone),
      'calendarExported': serializer.toJson<bool>(calendarExported),
      'notificationId': serializer.toJson<int?>(notificationId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CourseNote copyWith({
    int? id,
    String? courseKey,
    String? type,
    String? title,
    String? content,
    Value<DateTime?> dueAt = const Value.absent(),
    Value<DateTime?> remindAt = const Value.absent(),
    Value<DateTime?> linkedClassDate = const Value.absent(),
    bool? isDone,
    bool? calendarExported,
    Value<int?> notificationId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CourseNote(
    id: id ?? this.id,
    courseKey: courseKey ?? this.courseKey,
    type: type ?? this.type,
    title: title ?? this.title,
    content: content ?? this.content,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    remindAt: remindAt.present ? remindAt.value : this.remindAt,
    linkedClassDate: linkedClassDate.present
        ? linkedClassDate.value
        : this.linkedClassDate,
    isDone: isDone ?? this.isDone,
    calendarExported: calendarExported ?? this.calendarExported,
    notificationId: notificationId.present
        ? notificationId.value
        : this.notificationId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CourseNote copyWithCompanion(CourseNotesCompanion data) {
    return CourseNote(
      id: data.id.present ? data.id.value : this.id,
      courseKey: data.courseKey.present ? data.courseKey.value : this.courseKey,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      remindAt: data.remindAt.present ? data.remindAt.value : this.remindAt,
      linkedClassDate: data.linkedClassDate.present
          ? data.linkedClassDate.value
          : this.linkedClassDate,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      calendarExported: data.calendarExported.present
          ? data.calendarExported.value
          : this.calendarExported,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseNote(')
          ..write('id: $id, ')
          ..write('courseKey: $courseKey, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('dueAt: $dueAt, ')
          ..write('remindAt: $remindAt, ')
          ..write('linkedClassDate: $linkedClassDate, ')
          ..write('isDone: $isDone, ')
          ..write('calendarExported: $calendarExported, ')
          ..write('notificationId: $notificationId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    courseKey,
    type,
    title,
    content,
    dueAt,
    remindAt,
    linkedClassDate,
    isDone,
    calendarExported,
    notificationId,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseNote &&
          other.id == this.id &&
          other.courseKey == this.courseKey &&
          other.type == this.type &&
          other.title == this.title &&
          other.content == this.content &&
          other.dueAt == this.dueAt &&
          other.remindAt == this.remindAt &&
          other.linkedClassDate == this.linkedClassDate &&
          other.isDone == this.isDone &&
          other.calendarExported == this.calendarExported &&
          other.notificationId == this.notificationId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CourseNotesCompanion extends UpdateCompanion<CourseNote> {
  final Value<int> id;
  final Value<String> courseKey;
  final Value<String> type;
  final Value<String> title;
  final Value<String> content;
  final Value<DateTime?> dueAt;
  final Value<DateTime?> remindAt;
  final Value<DateTime?> linkedClassDate;
  final Value<bool> isDone;
  final Value<bool> calendarExported;
  final Value<int?> notificationId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const CourseNotesCompanion({
    this.id = const Value.absent(),
    this.courseKey = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.linkedClassDate = const Value.absent(),
    this.isDone = const Value.absent(),
    this.calendarExported = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  CourseNotesCompanion.insert({
    this.id = const Value.absent(),
    required String courseKey,
    this.type = const Value.absent(),
    required String title,
    this.content = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.linkedClassDate = const Value.absent(),
    this.isDone = const Value.absent(),
    this.calendarExported = const Value.absent(),
    this.notificationId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : courseKey = Value(courseKey),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CourseNote> custom({
    Expression<int>? id,
    Expression<String>? courseKey,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? content,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? remindAt,
    Expression<DateTime>? linkedClassDate,
    Expression<bool>? isDone,
    Expression<bool>? calendarExported,
    Expression<int>? notificationId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseKey != null) 'course_key': courseKey,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (dueAt != null) 'due_at': dueAt,
      if (remindAt != null) 'remind_at': remindAt,
      if (linkedClassDate != null) 'linked_class_date': linkedClassDate,
      if (isDone != null) 'is_done': isDone,
      if (calendarExported != null) 'calendar_exported': calendarExported,
      if (notificationId != null) 'notification_id': notificationId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  CourseNotesCompanion copyWith({
    Value<int>? id,
    Value<String>? courseKey,
    Value<String>? type,
    Value<String>? title,
    Value<String>? content,
    Value<DateTime?>? dueAt,
    Value<DateTime?>? remindAt,
    Value<DateTime?>? linkedClassDate,
    Value<bool>? isDone,
    Value<bool>? calendarExported,
    Value<int?>? notificationId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return CourseNotesCompanion(
      id: id ?? this.id,
      courseKey: courseKey ?? this.courseKey,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      dueAt: dueAt ?? this.dueAt,
      remindAt: remindAt ?? this.remindAt,
      linkedClassDate: linkedClassDate ?? this.linkedClassDate,
      isDone: isDone ?? this.isDone,
      calendarExported: calendarExported ?? this.calendarExported,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (courseKey.present) {
      map['course_key'] = Variable<String>(courseKey.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<DateTime>(remindAt.value);
    }
    if (linkedClassDate.present) {
      map['linked_class_date'] = Variable<DateTime>(linkedClassDate.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (calendarExported.present) {
      map['calendar_exported'] = Variable<bool>(calendarExported.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseNotesCompanion(')
          ..write('id: $id, ')
          ..write('courseKey: $courseKey, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('dueAt: $dueAt, ')
          ..write('remindAt: $remindAt, ')
          ..write('linkedClassDate: $linkedClassDate, ')
          ..write('isDone: $isDone, ')
          ..write('calendarExported: $calendarExported, ')
          ..write('notificationId: $notificationId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $AttendanceGroupsTable extends AttendanceGroups
    with TableInfo<$AttendanceGroupsTable, AttendanceGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendanceGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AttendanceGroupsTable createAlias(String alias) {
    return $AttendanceGroupsTable(attachedDatabase, alias);
  }
}

class AttendanceGroup extends DataClass implements Insertable<AttendanceGroup> {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const AttendanceGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AttendanceGroupsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceGroupsCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AttendanceGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceGroup(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AttendanceGroup copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AttendanceGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AttendanceGroup copyWithCompanion(AttendanceGroupsCompanion data) {
    return AttendanceGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class AttendanceGroupsCompanion extends UpdateCompanion<AttendanceGroup> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const AttendanceGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  AttendanceGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AttendanceGroup> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  AttendanceGroupsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return AttendanceGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $AttendanceStudentsTable extends AttendanceStudents
    with TableInfo<$AttendanceStudentsTable, AttendanceStudent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceStudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attendance_groups (id)',
    ),
  );
  static const VerificationMeta _studentNoMeta = const VerificationMeta(
    'studentNo',
  );
  @override
  late final GeneratedColumn<String> studentNo = GeneratedColumn<String>(
    'student_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    studentNo,
    name,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_students';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceStudent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('student_no')) {
      context.handle(
        _studentNoMeta,
        studentNo.isAcceptableOrUnknown(data['student_no']!, _studentNoMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendanceStudent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceStudent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      )!,
      studentNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_no'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AttendanceStudentsTable createAlias(String alias) {
    return $AttendanceStudentsTable(attachedDatabase, alias);
  }
}

class AttendanceStudent extends DataClass
    implements Insertable<AttendanceStudent> {
  final int id;
  final int groupId;
  final String studentNo;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const AttendanceStudent({
    required this.id,
    required this.groupId,
    required this.studentNo,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_id'] = Variable<int>(groupId);
    map['student_no'] = Variable<String>(studentNo);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AttendanceStudentsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceStudentsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      studentNo: Value(studentNo),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AttendanceStudent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceStudent(
      id: serializer.fromJson<int>(json['id']),
      groupId: serializer.fromJson<int>(json['groupId']),
      studentNo: serializer.fromJson<String>(json['studentNo']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupId': serializer.toJson<int>(groupId),
      'studentNo': serializer.toJson<String>(studentNo),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AttendanceStudent copyWith({
    int? id,
    int? groupId,
    String? studentNo,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AttendanceStudent(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    studentNo: studentNo ?? this.studentNo,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AttendanceStudent copyWithCompanion(AttendanceStudentsCompanion data) {
    return AttendanceStudent(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      studentNo: data.studentNo.present ? data.studentNo.value : this.studentNo,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceStudent(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('studentNo: $studentNo, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    studentNo,
    name,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceStudent &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.studentNo == this.studentNo &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class AttendanceStudentsCompanion extends UpdateCompanion<AttendanceStudent> {
  final Value<int> id;
  final Value<int> groupId;
  final Value<String> studentNo;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const AttendanceStudentsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.studentNo = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  AttendanceStudentsCompanion.insert({
    this.id = const Value.absent(),
    required int groupId,
    this.studentNo = const Value.absent(),
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : groupId = Value(groupId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AttendanceStudent> custom({
    Expression<int>? id,
    Expression<int>? groupId,
    Expression<String>? studentNo,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (studentNo != null) 'student_no': studentNo,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  AttendanceStudentsCompanion copyWith({
    Value<int>? id,
    Value<int>? groupId,
    Value<String>? studentNo,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return AttendanceStudentsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      studentNo: studentNo ?? this.studentNo,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (studentNo.present) {
      map['student_no'] = Variable<String>(studentNo.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceStudentsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('studentNo: $studentNo, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $AttendanceSessionsTable extends AttendanceSessions
    with TableInfo<$AttendanceSessionsTable, AttendanceSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attendance_groups (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionDateMeta = const VerificationMeta(
    'sessionDate',
  );
  @override
  late final GeneratedColumn<DateTime> sessionDate = GeneratedColumn<DateTime>(
    'session_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    title,
    sessionDate,
    remark,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('session_date')) {
      context.handle(
        _sessionDateMeta,
        sessionDate.isAcceptableOrUnknown(
          data['session_date']!,
          _sessionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionDateMeta);
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendanceSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sessionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}session_date'],
      )!,
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AttendanceSessionsTable createAlias(String alias) {
    return $AttendanceSessionsTable(attachedDatabase, alias);
  }
}

class AttendanceSession extends DataClass
    implements Insertable<AttendanceSession> {
  final int id;
  final int groupId;
  final String title;
  final DateTime sessionDate;
  final String remark;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const AttendanceSession({
    required this.id,
    required this.groupId,
    required this.title,
    required this.sessionDate,
    required this.remark,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_id'] = Variable<int>(groupId);
    map['title'] = Variable<String>(title);
    map['session_date'] = Variable<DateTime>(sessionDate);
    map['remark'] = Variable<String>(remark);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AttendanceSessionsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceSessionsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      title: Value(title),
      sessionDate: Value(sessionDate),
      remark: Value(remark),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AttendanceSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceSession(
      id: serializer.fromJson<int>(json['id']),
      groupId: serializer.fromJson<int>(json['groupId']),
      title: serializer.fromJson<String>(json['title']),
      sessionDate: serializer.fromJson<DateTime>(json['sessionDate']),
      remark: serializer.fromJson<String>(json['remark']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupId': serializer.toJson<int>(groupId),
      'title': serializer.toJson<String>(title),
      'sessionDate': serializer.toJson<DateTime>(sessionDate),
      'remark': serializer.toJson<String>(remark),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AttendanceSession copyWith({
    int? id,
    int? groupId,
    String? title,
    DateTime? sessionDate,
    String? remark,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AttendanceSession(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    title: title ?? this.title,
    sessionDate: sessionDate ?? this.sessionDate,
    remark: remark ?? this.remark,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AttendanceSession copyWithCompanion(AttendanceSessionsCompanion data) {
    return AttendanceSession(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      title: data.title.present ? data.title.value : this.title,
      sessionDate: data.sessionDate.present
          ? data.sessionDate.value
          : this.sessionDate,
      remark: data.remark.present ? data.remark.value : this.remark,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceSession(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('title: $title, ')
          ..write('sessionDate: $sessionDate, ')
          ..write('remark: $remark, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    title,
    sessionDate,
    remark,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceSession &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.title == this.title &&
          other.sessionDate == this.sessionDate &&
          other.remark == this.remark &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class AttendanceSessionsCompanion extends UpdateCompanion<AttendanceSession> {
  final Value<int> id;
  final Value<int> groupId;
  final Value<String> title;
  final Value<DateTime> sessionDate;
  final Value<String> remark;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const AttendanceSessionsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.title = const Value.absent(),
    this.sessionDate = const Value.absent(),
    this.remark = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  AttendanceSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int groupId,
    required String title,
    required DateTime sessionDate,
    this.remark = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : groupId = Value(groupId),
       title = Value(title),
       sessionDate = Value(sessionDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AttendanceSession> custom({
    Expression<int>? id,
    Expression<int>? groupId,
    Expression<String>? title,
    Expression<DateTime>? sessionDate,
    Expression<String>? remark,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (title != null) 'title': title,
      if (sessionDate != null) 'session_date': sessionDate,
      if (remark != null) 'remark': remark,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  AttendanceSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? groupId,
    Value<String>? title,
    Value<DateTime>? sessionDate,
    Value<String>? remark,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return AttendanceSessionsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      sessionDate: sessionDate ?? this.sessionDate,
      remark: remark ?? this.remark,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sessionDate.present) {
      map['session_date'] = Variable<DateTime>(sessionDate.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceSessionsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('title: $title, ')
          ..write('sessionDate: $sessionDate, ')
          ..write('remark: $remark, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $AttendanceRecordsTable extends AttendanceRecords
    with TableInfo<$AttendanceRecordsTable, AttendanceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attendance_sessions (id)',
    ),
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attendance_students (id)',
    ),
  );
  static const VerificationMeta _presentMeta = const VerificationMeta(
    'present',
  );
  @override
  late final GeneratedColumn<bool> present = GeneratedColumn<bool>(
    'present',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("present" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    studentId,
    present,
    remark,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('present')) {
      context.handle(
        _presentMeta,
        present.isAcceptableOrUnknown(data['present']!, _presentMeta),
      );
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendanceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      present: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}present'],
      )!,
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AttendanceRecordsTable createAlias(String alias) {
    return $AttendanceRecordsTable(attachedDatabase, alias);
  }
}

class AttendanceRecord extends DataClass
    implements Insertable<AttendanceRecord> {
  final int id;
  final int sessionId;
  final int studentId;
  final bool present;
  final String remark;
  final DateTime updatedAt;
  const AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.present,
    required this.remark,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['student_id'] = Variable<int>(studentId);
    map['present'] = Variable<bool>(present);
    map['remark'] = Variable<String>(remark);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AttendanceRecordsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceRecordsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      studentId: Value(studentId),
      present: Value(present),
      remark: Value(remark),
      updatedAt: Value(updatedAt),
    );
  }

  factory AttendanceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceRecord(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      studentId: serializer.fromJson<int>(json['studentId']),
      present: serializer.fromJson<bool>(json['present']),
      remark: serializer.fromJson<String>(json['remark']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'studentId': serializer.toJson<int>(studentId),
      'present': serializer.toJson<bool>(present),
      'remark': serializer.toJson<String>(remark),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AttendanceRecord copyWith({
    int? id,
    int? sessionId,
    int? studentId,
    bool? present,
    String? remark,
    DateTime? updatedAt,
  }) => AttendanceRecord(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    studentId: studentId ?? this.studentId,
    present: present ?? this.present,
    remark: remark ?? this.remark,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AttendanceRecord copyWithCompanion(AttendanceRecordsCompanion data) {
    return AttendanceRecord(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      present: data.present.present ? data.present.value : this.present,
      remark: data.remark.present ? data.remark.value : this.remark,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRecord(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('studentId: $studentId, ')
          ..write('present: $present, ')
          ..write('remark: $remark, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, studentId, present, remark, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceRecord &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.studentId == this.studentId &&
          other.present == this.present &&
          other.remark == this.remark &&
          other.updatedAt == this.updatedAt);
}

class AttendanceRecordsCompanion extends UpdateCompanion<AttendanceRecord> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> studentId;
  final Value<bool> present;
  final Value<String> remark;
  final Value<DateTime> updatedAt;
  const AttendanceRecordsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.present = const Value.absent(),
    this.remark = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AttendanceRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int studentId,
    this.present = const Value.absent(),
    this.remark = const Value.absent(),
    required DateTime updatedAt,
  }) : sessionId = Value(sessionId),
       studentId = Value(studentId),
       updatedAt = Value(updatedAt);
  static Insertable<AttendanceRecord> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? studentId,
    Expression<bool>? present,
    Expression<String>? remark,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (studentId != null) 'student_id': studentId,
      if (present != null) 'present': present,
      if (remark != null) 'remark': remark,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AttendanceRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? studentId,
    Value<bool>? present,
    Value<String>? remark,
    Value<DateTime>? updatedAt,
  }) {
    return AttendanceRecordsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      present: present ?? this.present,
      remark: remark ?? this.remark,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (present.present) {
      map['present'] = Variable<bool>(present.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('studentId: $studentId, ')
          ..write('present: $present, ')
          ..write('remark: $remark, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CourseNoteCoursesTable courseNoteCourses =
      $CourseNoteCoursesTable(this);
  late final $CourseNotesTable courseNotes = $CourseNotesTable(this);
  late final $AttendanceGroupsTable attendanceGroups = $AttendanceGroupsTable(
    this,
  );
  late final $AttendanceStudentsTable attendanceStudents =
      $AttendanceStudentsTable(this);
  late final $AttendanceSessionsTable attendanceSessions =
      $AttendanceSessionsTable(this);
  late final $AttendanceRecordsTable attendanceRecords =
      $AttendanceRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    courseNoteCourses,
    courseNotes,
    attendanceGroups,
    attendanceStudents,
    attendanceSessions,
    attendanceRecords,
  ];
}

typedef $$CourseNoteCoursesTableCreateCompanionBuilder =
    CourseNoteCoursesCompanion Function({
      required String courseKey,
      required String courseName,
      Value<String> teacherName,
      Value<String> classroom,
      Value<String> semester,
      Value<String> rawCourseId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CourseNoteCoursesTableUpdateCompanionBuilder =
    CourseNoteCoursesCompanion Function({
      Value<String> courseKey,
      Value<String> courseName,
      Value<String> teacherName,
      Value<String> classroom,
      Value<String> semester,
      Value<String> rawCourseId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CourseNoteCoursesTableFilterComposer
    extends Composer<_$AppDatabase, $CourseNoteCoursesTable> {
  $$CourseNoteCoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get courseKey => $composableBuilder(
    column: $table.courseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classroom => $composableBuilder(
    column: $table.classroom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get semester => $composableBuilder(
    column: $table.semester,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawCourseId => $composableBuilder(
    column: $table.rawCourseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CourseNoteCoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseNoteCoursesTable> {
  $$CourseNoteCoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get courseKey => $composableBuilder(
    column: $table.courseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classroom => $composableBuilder(
    column: $table.classroom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get semester => $composableBuilder(
    column: $table.semester,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawCourseId => $composableBuilder(
    column: $table.rawCourseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CourseNoteCoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseNoteCoursesTable> {
  $$CourseNoteCoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get courseKey =>
      $composableBuilder(column: $table.courseKey, builder: (column) => column);

  GeneratedColumn<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get classroom =>
      $composableBuilder(column: $table.classroom, builder: (column) => column);

  GeneratedColumn<String> get semester =>
      $composableBuilder(column: $table.semester, builder: (column) => column);

  GeneratedColumn<String> get rawCourseId => $composableBuilder(
    column: $table.rawCourseId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CourseNoteCoursesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseNoteCoursesTable,
          CourseNoteCourse,
          $$CourseNoteCoursesTableFilterComposer,
          $$CourseNoteCoursesTableOrderingComposer,
          $$CourseNoteCoursesTableAnnotationComposer,
          $$CourseNoteCoursesTableCreateCompanionBuilder,
          $$CourseNoteCoursesTableUpdateCompanionBuilder,
          (
            CourseNoteCourse,
            BaseReferences<
              _$AppDatabase,
              $CourseNoteCoursesTable,
              CourseNoteCourse
            >,
          ),
          CourseNoteCourse,
          PrefetchHooks Function()
        > {
  $$CourseNoteCoursesTableTableManager(
    _$AppDatabase db,
    $CourseNoteCoursesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseNoteCoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseNoteCoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseNoteCoursesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> courseKey = const Value.absent(),
                Value<String> courseName = const Value.absent(),
                Value<String> teacherName = const Value.absent(),
                Value<String> classroom = const Value.absent(),
                Value<String> semester = const Value.absent(),
                Value<String> rawCourseId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseNoteCoursesCompanion(
                courseKey: courseKey,
                courseName: courseName,
                teacherName: teacherName,
                classroom: classroom,
                semester: semester,
                rawCourseId: rawCourseId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String courseKey,
                required String courseName,
                Value<String> teacherName = const Value.absent(),
                Value<String> classroom = const Value.absent(),
                Value<String> semester = const Value.absent(),
                Value<String> rawCourseId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CourseNoteCoursesCompanion.insert(
                courseKey: courseKey,
                courseName: courseName,
                teacherName: teacherName,
                classroom: classroom,
                semester: semester,
                rawCourseId: rawCourseId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CourseNoteCoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseNoteCoursesTable,
      CourseNoteCourse,
      $$CourseNoteCoursesTableFilterComposer,
      $$CourseNoteCoursesTableOrderingComposer,
      $$CourseNoteCoursesTableAnnotationComposer,
      $$CourseNoteCoursesTableCreateCompanionBuilder,
      $$CourseNoteCoursesTableUpdateCompanionBuilder,
      (
        CourseNoteCourse,
        BaseReferences<
          _$AppDatabase,
          $CourseNoteCoursesTable,
          CourseNoteCourse
        >,
      ),
      CourseNoteCourse,
      PrefetchHooks Function()
    >;
typedef $$CourseNotesTableCreateCompanionBuilder =
    CourseNotesCompanion Function({
      Value<int> id,
      required String courseKey,
      Value<String> type,
      required String title,
      Value<String> content,
      Value<DateTime?> dueAt,
      Value<DateTime?> remindAt,
      Value<DateTime?> linkedClassDate,
      Value<bool> isDone,
      Value<bool> calendarExported,
      Value<int?> notificationId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$CourseNotesTableUpdateCompanionBuilder =
    CourseNotesCompanion Function({
      Value<int> id,
      Value<String> courseKey,
      Value<String> type,
      Value<String> title,
      Value<String> content,
      Value<DateTime?> dueAt,
      Value<DateTime?> remindAt,
      Value<DateTime?> linkedClassDate,
      Value<bool> isDone,
      Value<bool> calendarExported,
      Value<int?> notificationId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

class $$CourseNotesTableFilterComposer
    extends Composer<_$AppDatabase, $CourseNotesTable> {
  $$CourseNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseKey => $composableBuilder(
    column: $table.courseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get linkedClassDate => $composableBuilder(
    column: $table.linkedClassDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get calendarExported => $composableBuilder(
    column: $table.calendarExported,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CourseNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseNotesTable> {
  $$CourseNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseKey => $composableBuilder(
    column: $table.courseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get linkedClassDate => $composableBuilder(
    column: $table.linkedClassDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get calendarExported => $composableBuilder(
    column: $table.calendarExported,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CourseNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseNotesTable> {
  $$CourseNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get courseKey =>
      $composableBuilder(column: $table.courseKey, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => column);

  GeneratedColumn<DateTime> get linkedClassDate => $composableBuilder(
    column: $table.linkedClassDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<bool> get calendarExported => $composableBuilder(
    column: $table.calendarExported,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$CourseNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseNotesTable,
          CourseNote,
          $$CourseNotesTableFilterComposer,
          $$CourseNotesTableOrderingComposer,
          $$CourseNotesTableAnnotationComposer,
          $$CourseNotesTableCreateCompanionBuilder,
          $$CourseNotesTableUpdateCompanionBuilder,
          (
            CourseNote,
            BaseReferences<_$AppDatabase, $CourseNotesTable, CourseNote>,
          ),
          CourseNote,
          PrefetchHooks Function()
        > {
  $$CourseNotesTableTableManager(_$AppDatabase db, $CourseNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> courseKey = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> remindAt = const Value.absent(),
                Value<DateTime?> linkedClassDate = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<bool> calendarExported = const Value.absent(),
                Value<int?> notificationId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => CourseNotesCompanion(
                id: id,
                courseKey: courseKey,
                type: type,
                title: title,
                content: content,
                dueAt: dueAt,
                remindAt: remindAt,
                linkedClassDate: linkedClassDate,
                isDone: isDone,
                calendarExported: calendarExported,
                notificationId: notificationId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String courseKey,
                Value<String> type = const Value.absent(),
                required String title,
                Value<String> content = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> remindAt = const Value.absent(),
                Value<DateTime?> linkedClassDate = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<bool> calendarExported = const Value.absent(),
                Value<int?> notificationId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => CourseNotesCompanion.insert(
                id: id,
                courseKey: courseKey,
                type: type,
                title: title,
                content: content,
                dueAt: dueAt,
                remindAt: remindAt,
                linkedClassDate: linkedClassDate,
                isDone: isDone,
                calendarExported: calendarExported,
                notificationId: notificationId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CourseNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseNotesTable,
      CourseNote,
      $$CourseNotesTableFilterComposer,
      $$CourseNotesTableOrderingComposer,
      $$CourseNotesTableAnnotationComposer,
      $$CourseNotesTableCreateCompanionBuilder,
      $$CourseNotesTableUpdateCompanionBuilder,
      (
        CourseNote,
        BaseReferences<_$AppDatabase, $CourseNotesTable, CourseNote>,
      ),
      CourseNote,
      PrefetchHooks Function()
    >;
typedef $$AttendanceGroupsTableCreateCompanionBuilder =
    AttendanceGroupsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> description,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$AttendanceGroupsTableUpdateCompanionBuilder =
    AttendanceGroupsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> description,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$AttendanceGroupsTableReferences
    extends
        BaseReferences<_$AppDatabase, $AttendanceGroupsTable, AttendanceGroup> {
  $$AttendanceGroupsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AttendanceStudentsTable, List<AttendanceStudent>>
  _attendanceStudentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attendanceStudents,
        aliasName: 'attendance_groups__id__attendance_students__group_id',
      );

  $$AttendanceStudentsTableProcessedTableManager get attendanceStudentsRefs {
    final manager = $$AttendanceStudentsTableTableManager(
      $_db,
      $_db.attendanceStudents,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attendanceStudentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttendanceSessionsTable, List<AttendanceSession>>
  _attendanceSessionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attendanceSessions,
        aliasName: 'attendance_groups__id__attendance_sessions__group_id',
      );

  $$AttendanceSessionsTableProcessedTableManager get attendanceSessionsRefs {
    final manager = $$AttendanceSessionsTableTableManager(
      $_db,
      $_db.attendanceSessions,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attendanceSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AttendanceGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceGroupsTable> {
  $$AttendanceGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> attendanceStudentsRefs(
    Expression<bool> Function($$AttendanceStudentsTableFilterComposer f) f,
  ) {
    final $$AttendanceStudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceStudents,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceStudentsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceStudents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attendanceSessionsRefs(
    Expression<bool> Function($$AttendanceSessionsTableFilterComposer f) f,
  ) {
    final $$AttendanceSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceSessions,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceSessionsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttendanceGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceGroupsTable> {
  $$AttendanceGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendanceGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceGroupsTable> {
  $$AttendanceGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> attendanceStudentsRefs<T extends Object>(
    Expression<T> Function($$AttendanceStudentsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceStudentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attendanceStudents,
          getReferencedColumn: (t) => t.groupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceStudentsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceStudents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> attendanceSessionsRefs<T extends Object>(
    Expression<T> Function($$AttendanceSessionsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attendanceSessions,
          getReferencedColumn: (t) => t.groupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AttendanceGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceGroupsTable,
          AttendanceGroup,
          $$AttendanceGroupsTableFilterComposer,
          $$AttendanceGroupsTableOrderingComposer,
          $$AttendanceGroupsTableAnnotationComposer,
          $$AttendanceGroupsTableCreateCompanionBuilder,
          $$AttendanceGroupsTableUpdateCompanionBuilder,
          (AttendanceGroup, $$AttendanceGroupsTableReferences),
          AttendanceGroup,
          PrefetchHooks Function({
            bool attendanceStudentsRefs,
            bool attendanceSessionsRefs,
          })
        > {
  $$AttendanceGroupsTableTableManager(
    _$AppDatabase db,
    $AttendanceGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => AttendanceGroupsCompanion(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> description = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => AttendanceGroupsCompanion.insert(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttendanceGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                attendanceStudentsRefs = false,
                attendanceSessionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attendanceStudentsRefs) db.attendanceStudents,
                    if (attendanceSessionsRefs) db.attendanceSessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attendanceStudentsRefs)
                        await $_getPrefetchedData<
                          AttendanceGroup,
                          $AttendanceGroupsTable,
                          AttendanceStudent
                        >(
                          currentTable: table,
                          referencedTable: $$AttendanceGroupsTableReferences
                              ._attendanceStudentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AttendanceGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceStudentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attendanceSessionsRefs)
                        await $_getPrefetchedData<
                          AttendanceGroup,
                          $AttendanceGroupsTable,
                          AttendanceSession
                        >(
                          currentTable: table,
                          referencedTable: $$AttendanceGroupsTableReferences
                              ._attendanceSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AttendanceGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AttendanceGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceGroupsTable,
      AttendanceGroup,
      $$AttendanceGroupsTableFilterComposer,
      $$AttendanceGroupsTableOrderingComposer,
      $$AttendanceGroupsTableAnnotationComposer,
      $$AttendanceGroupsTableCreateCompanionBuilder,
      $$AttendanceGroupsTableUpdateCompanionBuilder,
      (AttendanceGroup, $$AttendanceGroupsTableReferences),
      AttendanceGroup,
      PrefetchHooks Function({
        bool attendanceStudentsRefs,
        bool attendanceSessionsRefs,
      })
    >;
typedef $$AttendanceStudentsTableCreateCompanionBuilder =
    AttendanceStudentsCompanion Function({
      Value<int> id,
      required int groupId,
      Value<String> studentNo,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$AttendanceStudentsTableUpdateCompanionBuilder =
    AttendanceStudentsCompanion Function({
      Value<int> id,
      Value<int> groupId,
      Value<String> studentNo,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$AttendanceStudentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AttendanceStudentsTable,
          AttendanceStudent
        > {
  $$AttendanceStudentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AttendanceGroupsTable _groupIdTable(_$AppDatabase db) => db
      .attendanceGroups
      .createAlias('attendance_students__group_id__attendance_groups__id');

  $$AttendanceGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$AttendanceGroupsTableTableManager(
      $_db,
      $_db.attendanceGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttendanceRecordsTable, List<AttendanceRecord>>
  _attendanceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attendanceRecords,
        aliasName: 'attendance_students__id__attendance_records__student_id',
      );

  $$AttendanceRecordsTableProcessedTableManager get attendanceRecordsRefs {
    final manager = $$AttendanceRecordsTableTableManager(
      $_db,
      $_db.attendanceRecords,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attendanceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AttendanceStudentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceStudentsTable> {
  $$AttendanceStudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentNo => $composableBuilder(
    column: $table.studentNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AttendanceGroupsTableFilterComposer get groupId {
    final $$AttendanceGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.attendanceGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceGroupsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attendanceRecordsRefs(
    Expression<bool> Function($$AttendanceRecordsTableFilterComposer f) f,
  ) {
    final $$AttendanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceRecords,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttendanceStudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceStudentsTable> {
  $$AttendanceStudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentNo => $composableBuilder(
    column: $table.studentNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AttendanceGroupsTableOrderingComposer get groupId {
    final $$AttendanceGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.attendanceGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.attendanceGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceStudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceStudentsTable> {
  $$AttendanceStudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentNo =>
      $composableBuilder(column: $table.studentNo, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$AttendanceGroupsTableAnnotationComposer get groupId {
    final $$AttendanceGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.attendanceGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.attendanceGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attendanceRecordsRefs<T extends Object>(
    Expression<T> Function($$AttendanceRecordsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attendanceRecords,
          getReferencedColumn: (t) => t.studentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AttendanceStudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceStudentsTable,
          AttendanceStudent,
          $$AttendanceStudentsTableFilterComposer,
          $$AttendanceStudentsTableOrderingComposer,
          $$AttendanceStudentsTableAnnotationComposer,
          $$AttendanceStudentsTableCreateCompanionBuilder,
          $$AttendanceStudentsTableUpdateCompanionBuilder,
          (AttendanceStudent, $$AttendanceStudentsTableReferences),
          AttendanceStudent,
          PrefetchHooks Function({bool groupId, bool attendanceRecordsRefs})
        > {
  $$AttendanceStudentsTableTableManager(
    _$AppDatabase db,
    $AttendanceStudentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceStudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceStudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceStudentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> groupId = const Value.absent(),
                Value<String> studentNo = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => AttendanceStudentsCompanion(
                id: id,
                groupId: groupId,
                studentNo: studentNo,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int groupId,
                Value<String> studentNo = const Value.absent(),
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => AttendanceStudentsCompanion.insert(
                id: id,
                groupId: groupId,
                studentNo: studentNo,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttendanceStudentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({groupId = false, attendanceRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attendanceRecordsRefs) db.attendanceRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (groupId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.groupId,
                                    referencedTable:
                                        $$AttendanceStudentsTableReferences
                                            ._groupIdTable(db),
                                    referencedColumn:
                                        $$AttendanceStudentsTableReferences
                                            ._groupIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attendanceRecordsRefs)
                        await $_getPrefetchedData<
                          AttendanceStudent,
                          $AttendanceStudentsTable,
                          AttendanceRecord
                        >(
                          currentTable: table,
                          referencedTable: $$AttendanceStudentsTableReferences
                              ._attendanceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AttendanceStudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AttendanceStudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceStudentsTable,
      AttendanceStudent,
      $$AttendanceStudentsTableFilterComposer,
      $$AttendanceStudentsTableOrderingComposer,
      $$AttendanceStudentsTableAnnotationComposer,
      $$AttendanceStudentsTableCreateCompanionBuilder,
      $$AttendanceStudentsTableUpdateCompanionBuilder,
      (AttendanceStudent, $$AttendanceStudentsTableReferences),
      AttendanceStudent,
      PrefetchHooks Function({bool groupId, bool attendanceRecordsRefs})
    >;
typedef $$AttendanceSessionsTableCreateCompanionBuilder =
    AttendanceSessionsCompanion Function({
      Value<int> id,
      required int groupId,
      required String title,
      required DateTime sessionDate,
      Value<String> remark,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$AttendanceSessionsTableUpdateCompanionBuilder =
    AttendanceSessionsCompanion Function({
      Value<int> id,
      Value<int> groupId,
      Value<String> title,
      Value<DateTime> sessionDate,
      Value<String> remark,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$AttendanceSessionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AttendanceSessionsTable,
          AttendanceSession
        > {
  $$AttendanceSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AttendanceGroupsTable _groupIdTable(_$AppDatabase db) => db
      .attendanceGroups
      .createAlias('attendance_sessions__group_id__attendance_groups__id');

  $$AttendanceGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$AttendanceGroupsTableTableManager(
      $_db,
      $_db.attendanceGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttendanceRecordsTable, List<AttendanceRecord>>
  _attendanceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attendanceRecords,
        aliasName: 'attendance_sessions__id__attendance_records__session_id',
      );

  $$AttendanceRecordsTableProcessedTableManager get attendanceRecordsRefs {
    final manager = $$AttendanceRecordsTableTableManager(
      $_db,
      $_db.attendanceRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attendanceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AttendanceSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceSessionsTable> {
  $$AttendanceSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AttendanceGroupsTableFilterComposer get groupId {
    final $$AttendanceGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.attendanceGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceGroupsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attendanceRecordsRefs(
    Expression<bool> Function($$AttendanceRecordsTableFilterComposer f) f,
  ) {
    final $$AttendanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttendanceSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceSessionsTable> {
  $$AttendanceSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AttendanceGroupsTableOrderingComposer get groupId {
    final $$AttendanceGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.attendanceGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.attendanceGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceSessionsTable> {
  $$AttendanceSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$AttendanceGroupsTableAnnotationComposer get groupId {
    final $$AttendanceGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.attendanceGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.attendanceGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attendanceRecordsRefs<T extends Object>(
    Expression<T> Function($$AttendanceRecordsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attendanceRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AttendanceSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceSessionsTable,
          AttendanceSession,
          $$AttendanceSessionsTableFilterComposer,
          $$AttendanceSessionsTableOrderingComposer,
          $$AttendanceSessionsTableAnnotationComposer,
          $$AttendanceSessionsTableCreateCompanionBuilder,
          $$AttendanceSessionsTableUpdateCompanionBuilder,
          (AttendanceSession, $$AttendanceSessionsTableReferences),
          AttendanceSession,
          PrefetchHooks Function({bool groupId, bool attendanceRecordsRefs})
        > {
  $$AttendanceSessionsTableTableManager(
    _$AppDatabase db,
    $AttendanceSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> groupId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> sessionDate = const Value.absent(),
                Value<String> remark = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => AttendanceSessionsCompanion(
                id: id,
                groupId: groupId,
                title: title,
                sessionDate: sessionDate,
                remark: remark,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int groupId,
                required String title,
                required DateTime sessionDate,
                Value<String> remark = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => AttendanceSessionsCompanion.insert(
                id: id,
                groupId: groupId,
                title: title,
                sessionDate: sessionDate,
                remark: remark,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttendanceSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({groupId = false, attendanceRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attendanceRecordsRefs) db.attendanceRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (groupId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.groupId,
                                    referencedTable:
                                        $$AttendanceSessionsTableReferences
                                            ._groupIdTable(db),
                                    referencedColumn:
                                        $$AttendanceSessionsTableReferences
                                            ._groupIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attendanceRecordsRefs)
                        await $_getPrefetchedData<
                          AttendanceSession,
                          $AttendanceSessionsTable,
                          AttendanceRecord
                        >(
                          currentTable: table,
                          referencedTable: $$AttendanceSessionsTableReferences
                              ._attendanceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AttendanceSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AttendanceSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceSessionsTable,
      AttendanceSession,
      $$AttendanceSessionsTableFilterComposer,
      $$AttendanceSessionsTableOrderingComposer,
      $$AttendanceSessionsTableAnnotationComposer,
      $$AttendanceSessionsTableCreateCompanionBuilder,
      $$AttendanceSessionsTableUpdateCompanionBuilder,
      (AttendanceSession, $$AttendanceSessionsTableReferences),
      AttendanceSession,
      PrefetchHooks Function({bool groupId, bool attendanceRecordsRefs})
    >;
typedef $$AttendanceRecordsTableCreateCompanionBuilder =
    AttendanceRecordsCompanion Function({
      Value<int> id,
      required int sessionId,
      required int studentId,
      Value<bool> present,
      Value<String> remark,
      required DateTime updatedAt,
    });
typedef $$AttendanceRecordsTableUpdateCompanionBuilder =
    AttendanceRecordsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> studentId,
      Value<bool> present,
      Value<String> remark,
      Value<DateTime> updatedAt,
    });

final class $$AttendanceRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AttendanceRecordsTable,
          AttendanceRecord
        > {
  $$AttendanceRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AttendanceSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .attendanceSessions
      .createAlias('attendance_records__session_id__attendance_sessions__id');

  $$AttendanceSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$AttendanceSessionsTableTableManager(
      $_db,
      $_db.attendanceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AttendanceStudentsTable _studentIdTable(_$AppDatabase db) => db
      .attendanceStudents
      .createAlias('attendance_records__student_id__attendance_students__id');

  $$AttendanceStudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$AttendanceStudentsTableTableManager(
      $_db,
      $_db.attendanceStudents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttendanceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get present => $composableBuilder(
    column: $table.present,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AttendanceSessionsTableFilterComposer get sessionId {
    final $$AttendanceSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.attendanceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceSessionsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AttendanceStudentsTableFilterComposer get studentId {
    final $$AttendanceStudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.attendanceStudents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceStudentsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceStudents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get present => $composableBuilder(
    column: $table.present,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AttendanceSessionsTableOrderingComposer get sessionId {
    final $$AttendanceSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.attendanceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.attendanceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AttendanceStudentsTableOrderingComposer get studentId {
    final $$AttendanceStudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.attendanceStudents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceStudentsTableOrderingComposer(
            $db: $db,
            $table: $db.attendanceStudents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get present =>
      $composableBuilder(column: $table.present, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AttendanceSessionsTableAnnotationComposer get sessionId {
    final $$AttendanceSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.attendanceSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$AttendanceStudentsTableAnnotationComposer get studentId {
    final $$AttendanceStudentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.studentId,
          referencedTable: $db.attendanceStudents,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceStudentsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceStudents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AttendanceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceRecordsTable,
          AttendanceRecord,
          $$AttendanceRecordsTableFilterComposer,
          $$AttendanceRecordsTableOrderingComposer,
          $$AttendanceRecordsTableAnnotationComposer,
          $$AttendanceRecordsTableCreateCompanionBuilder,
          $$AttendanceRecordsTableUpdateCompanionBuilder,
          (AttendanceRecord, $$AttendanceRecordsTableReferences),
          AttendanceRecord,
          PrefetchHooks Function({bool sessionId, bool studentId})
        > {
  $$AttendanceRecordsTableTableManager(
    _$AppDatabase db,
    $AttendanceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<bool> present = const Value.absent(),
                Value<String> remark = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AttendanceRecordsCompanion(
                id: id,
                sessionId: sessionId,
                studentId: studentId,
                present: present,
                remark: remark,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int studentId,
                Value<bool> present = const Value.absent(),
                Value<String> remark = const Value.absent(),
                required DateTime updatedAt,
              }) => AttendanceRecordsCompanion.insert(
                id: id,
                sessionId: sessionId,
                studentId: studentId,
                present: present,
                remark: remark,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttendanceRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, studentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$AttendanceRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$AttendanceRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable:
                                    $$AttendanceRecordsTableReferences
                                        ._studentIdTable(db),
                                referencedColumn:
                                    $$AttendanceRecordsTableReferences
                                        ._studentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttendanceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceRecordsTable,
      AttendanceRecord,
      $$AttendanceRecordsTableFilterComposer,
      $$AttendanceRecordsTableOrderingComposer,
      $$AttendanceRecordsTableAnnotationComposer,
      $$AttendanceRecordsTableCreateCompanionBuilder,
      $$AttendanceRecordsTableUpdateCompanionBuilder,
      (AttendanceRecord, $$AttendanceRecordsTableReferences),
      AttendanceRecord,
      PrefetchHooks Function({bool sessionId, bool studentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CourseNoteCoursesTableTableManager get courseNoteCourses =>
      $$CourseNoteCoursesTableTableManager(_db, _db.courseNoteCourses);
  $$CourseNotesTableTableManager get courseNotes =>
      $$CourseNotesTableTableManager(_db, _db.courseNotes);
  $$AttendanceGroupsTableTableManager get attendanceGroups =>
      $$AttendanceGroupsTableTableManager(_db, _db.attendanceGroups);
  $$AttendanceStudentsTableTableManager get attendanceStudents =>
      $$AttendanceStudentsTableTableManager(_db, _db.attendanceStudents);
  $$AttendanceSessionsTableTableManager get attendanceSessions =>
      $$AttendanceSessionsTableTableManager(_db, _db.attendanceSessions);
  $$AttendanceRecordsTableTableManager get attendanceRecords =>
      $$AttendanceRecordsTableTableManager(_db, _db.attendanceRecords);
}
