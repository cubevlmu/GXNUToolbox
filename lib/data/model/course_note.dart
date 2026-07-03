/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:class_tool/data/local/app_database.dart';
import 'package:flutter/foundation.dart';

const String generalTaskCourseKey = '__general_tasks__';
const String generalTaskCourseName = '普通任务';

enum CourseNoteType {
  homework,
  note,
  exam,
  todo;

  String get label {
    switch (this) {
      case .homework:
        return '作业';
      case .note:
        return '备注';
      case .exam:
        return '考试';
      case .todo:
        return '待办';
    }
  }
}

CourseNoteType courseNoteTypeFromName(String value) {
  for (final type in CourseNoteType.values) {
    if (type.name == value) {
      return type;
    }
  }
  return .homework;
}

@immutable
class CourseNoteCourseDraft {
  const CourseNoteCourseDraft({
    required this.courseKey,
    required this.courseName,
    this.teacherName = '',
    this.classroom = '',
    this.semester = '',
    this.rawCourseId = '',
  });

  final String courseKey;
  final String courseName;
  final String teacherName;
  final String classroom;
  final String semester;
  final String rawCourseId;
}

@immutable
class CourseNoteDraft {
  const CourseNoteDraft({
    this.id,
    required this.course,
    required this.type,
    required this.title,
    this.content = '',
    this.dueAt,
    this.remindAt,
    this.linkedClassDate,
    this.exportCalendar = false,
  });

  final int? id;
  final CourseNoteCourseDraft course;
  final CourseNoteType type;
  final String title;
  final String content;
  final DateTime? dueAt;
  final DateTime? remindAt;
  final DateTime? linkedClassDate;
  final bool exportCalendar;
}

@immutable
class CourseNoteEntry {
  const CourseNoteEntry({required this.note, required this.course});

  final CourseNote note;
  final CourseNoteCourse course;

  CourseNoteType get type => courseNoteTypeFromName(note.type);
  bool get isExam => type == CourseNoteType.exam;
  bool get isGeneralTask => course.courseKey == generalTaskCourseKey;

  bool get isOverdue {
    final dueAt = note.dueAt;
    if (dueAt == null || note.isDone) {
      return false;
    }
    return dueAt.isBefore(DateTime.now());
  }
}
