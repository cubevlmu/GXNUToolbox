import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:class_tool/data/model/course_note.dart';
import 'package:class_tool/data/services/calendar_export_service.dart';

class CourseNoteCalendarService {
  const CourseNoteCalendarService._();

  static Future<bool> exportEntry(CourseNoteEntry entry) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return false;
    }

    final start = entry.note.dueAt ?? entry.note.linkedClassDate;
    if (start == null) {
      throw StateError('需要先设置截止时间或绑定日期，才能导入系统日历');
    }

    final eventStart = start;
    final eventEnd = eventStart.add(const Duration(minutes: 30));
    final event = Event(
      title:
          '[${entry.type.label}] ${entry.course.courseName} - ${entry.note.title}',
      description: [
        if (entry.note.content.trim().isNotEmpty) entry.note.content.trim(),
        if (entry.course.teacherName.trim().isNotEmpty)
          '教师: ${entry.course.teacherName}',
        if (entry.course.semester.trim().isNotEmpty)
          '学期: ${entry.course.semester}',
        '来源: GXNU Class Tool',
        'class_tool_course_note_id=${entry.note.id}',
      ].join('\n'),
      location: entry.course.classroom,
      startDate: eventStart,
      endDate: eventEnd,
      allDay: false,
    );
    final added = await CalendarExportService.addEventsOneByOne([event]);
    return added > 0;
  }
}
