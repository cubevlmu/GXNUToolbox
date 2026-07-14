import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:class_tool/data/model/class_meta.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:class_tool/pages/classes/controller.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:flutter/services.dart';

class CalendarExportService {
  const CalendarExportService._();

  static const String _exportedCalendarEventSignaturesKey =
      'exported_calendar_event_signatures';
  static const MethodChannel _nativeChannel = MethodChannel(
    'me.cubevlmu.gxnutool/native',
  );

  static List<Event> buildEventsFromWeekSchedule({
    required String semester,
    required int selectedWeek,
    required List<ClassMeta> weekMeta,
    required List<CourseBlock> courseBlocks,
    required List<ClassPeriodSetting> periodSettings,
  }) {
    final datesByDayIndex = <int, DateTime>{};
    for (final meta in weekMeta) {
      final date = DateTime.tryParse(meta.dateTimeText.replaceFirst(' ', 'T'));
      if (date == null) {
        continue;
      }
      final dayIndex = date.weekday - 1;
      datesByDayIndex[dayIndex] = DateTime(date.year, date.month, date.day);
    }

    if (datesByDayIndex.isEmpty) {
      throw StateError('无法解析本周日期，暂不能导入日历');
    }

    final events = <Event>[];
    for (final course in courseBlocks) {
      final date = datesByDayIndex[course.dayIndex];
      if (date == null) {
        continue;
      }

      final startPeriod = _periodFor(periodSettings, course.startSection);
      final endPeriod = _periodFor(
        periodSettings,
        course.startSection + course.sectionSpan - 1,
      );
      if (startPeriod == null ||
          endPeriod == null ||
          startPeriod.startTime.isEmpty ||
          endPeriod.endTime.isEmpty) {
        throw StateError('缺少第${course.startSection}节的作息时间，无法生成日历事件');
      }

      final start = _combineDateAndTime(date, startPeriod.startTime);
      final end = _combineDateAndTime(date, endPeriod.endTime);
      events.add(
        Event(
          title: course.title.isEmpty ? '课程' : course.title,
          description: [
            if (course.teacher.isNotEmpty) '教师: ${course.teacher}',
            if (course.weeks.isNotEmpty) '周次: ${course.weeks}',
            '节次: 第${course.startSection}-${course.startSection + course.sectionSpan - 1}节',
            '来源: GXNU Class Tool',
            'class_tool_uid=$semester-$selectedWeek-${course.dayIndex}-${course.startSection}-${course.title.hashCode}',
          ].join('\n'),
          location: course.classroom,
          startDate: start,
          endDate: end.isAfter(start)
              ? end
              : start.add(const Duration(minutes: 45)),
          allDay: false,
        ),
      );
    }

    return events;
  }

  static Future<int> addEventsOneByOne(List<Event> events) async {
    final pending = _filterNewEvents(events);
    if (pending.isEmpty) {
      return 0;
    }
    if (Platform.isAndroid) {
      final added = await _nativeChannel.invokeMethod<int>(
        'addCalendarEvents',
        <String, Object>{
          'events': pending.map(_toNativeEvent).toList(growable: false),
        },
      );
      final count = added ?? 0;
      await _markEventsExported(pending);
      return count;
    }

    var added = 0;
    final addedEvents = <Event>[];
    for (final event in pending) {
      final success = await Add2Calendar.addEvent2Cal(event);
      if (success) {
        added += 1;
        addedEvents.add(event);
      }
    }
    await _markEventsExported(addedEvents);
    return added;
  }

  static List<Event> _filterNewEvents(List<Event> events) {
    final exported = _exportedSignatures();
    final seen = <String>{};
    final result = <Event>[];
    for (final event in events) {
      final signature = _eventSignature(event);
      if (exported.contains(signature) || !seen.add(signature)) {
        continue;
      }
      result.add(event);
    }
    return result;
  }

  static Set<String> _exportedSignatures() {
    final raw = StorageUtils.settings.get(_exportedCalendarEventSignaturesKey);
    if (raw is Iterable) {
      return raw.map((item) => item.toString()).toSet();
    }
    return <String>{};
  }

  static Future<void> _markEventsExported(Iterable<Event> events) async {
    final signatures = _exportedSignatures()
      ..addAll(events.map(_eventSignature));
    await StorageUtils.settings.put(
      _exportedCalendarEventSignaturesKey,
      signatures.toList(growable: false),
    );
  }

  static String _eventSignature(Event event) {
    final description = event.description ?? '';
    final marker = RegExp(
      r'class_tool_[A-Za-z0-9_\-]+=([^\s]+)',
    ).firstMatch(description);
    if (marker != null) {
      return marker.group(0)!;
    }
    return [
      event.title.trim(),
      (event.location ?? '').trim(),
      event.startDate.millisecondsSinceEpoch,
      event.endDate.millisecondsSinceEpoch,
    ].join('|');
  }

  static Map<String, Object?> _toNativeEvent(Event event) {
    return <String, Object?>{
      'title': event.title,
      'description': event.description,
      'location': event.location,
      'startMillis': event.startDate.millisecondsSinceEpoch,
      'endMillis': event.endDate.millisecondsSinceEpoch,
    };
  }

  static ClassPeriodSetting? _periodFor(
    List<ClassPeriodSetting> periods,
    int section,
  ) {
    for (final period in periods) {
      if (period.section == section) {
        return period;
      }
    }
    return null;
  }

  static DateTime _combineDateAndTime(DateTime date, String timeText) {
    final match = RegExp(r'(\d{1,2}):(\d{1,2})').firstMatch(timeText);
    if (match == null) {
      throw StateError('无法解析时间: $timeText');
    }
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
    );
  }
}
