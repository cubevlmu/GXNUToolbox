import 'package:class_tool/data/model/class_meta.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:class_tool/data/model/class_table_course.dart';

class TodayCourseSnapshot {
  const TodayCourseSnapshot({
    required this.semesterText,
    required this.currentWeekText,
    required this.headlineText,
    required this.items,
    this.nextItem,
  });

  factory TodayCourseSnapshot.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawNext = json['nextItem'];
    return TodayCourseSnapshot(
      semesterText: json['semesterText']?.toString() ?? '当前学期',
      currentWeekText: json['currentWeekText']?.toString() ?? '--',
      headlineText: json['headlineText']?.toString() ?? '今日课程',
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => TodayCourseItemSnapshot.fromJson(
                    item.cast<String, dynamic>(),
                  ),
                )
                .toList(growable: false)
          : const <TodayCourseItemSnapshot>[],
      nextItem: rawNext is Map
          ? TodayCourseItemSnapshot.fromJson(rawNext.cast<String, dynamic>())
          : null,
    );
  }

  final String semesterText;
  final String currentWeekText;
  final String headlineText;
  final List<TodayCourseItemSnapshot> items;
  final TodayCourseItemSnapshot? nextItem;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'semesterText': semesterText,
      'currentWeekText': currentWeekText,
      'headlineText': headlineText,
      'items': items.map((item) => item.toJson()).toList(growable: false),
      if (nextItem != null) 'nextItem': nextItem!.toJson(),
    };
  }
}

class TodayCourseItemSnapshot {
  const TodayCourseItemSnapshot({
    required this.timeText,
    required this.titleText,
    required this.roomText,
  });

  factory TodayCourseItemSnapshot.fromJson(Map<String, dynamic> json) {
    return TodayCourseItemSnapshot(
      timeText: json['timeText']?.toString() ?? '--:--',
      titleText: json['titleText']?.toString() ?? '课程待定',
      roomText: json['roomText']?.toString() ?? '教室待定',
    );
  }

  final String timeText;
  final String titleText;
  final String roomText;

  String get summary => '$timeText  $titleText  $roomText';

  Map<String, String> toJson() {
    return <String, String>{
      'timeText': timeText,
      'titleText': titleText,
      'roomText': roomText,
    };
  }
}

TodayCourseSnapshot buildTodayCourseSnapshot({
  required String semester,
  required int currentWeek,
  required List<ClassMeta> weekMeta,
  required List<ClassTableCourse> weekCourses,
  required ClassTableMeta? meta,
  List<ClassPeriodSetting>? periodSettings,
  DateTime? now,
}) {
  final todayMeta = _findTodayMeta(weekMeta);
  final todayCourses = _buildTodayCourses(weekCourses, todayMeta);
  final effectiveNow = now ?? DateTime.now();

  final nextCourse = _findNextUpcomingCourse(
    todayCourses: todayCourses,
    meta: meta,
    periodSettings: periodSettings,
    now: effectiveNow,
  );

  return TodayCourseSnapshot(
    semesterText: semester.isNotEmpty ? '$semester学期' : '当前学期',
    currentWeekText: currentWeek > 0 ? '第$currentWeek周' : '--',
    headlineText: _buildHeadline(currentWeek, todayMeta),
    items: todayCourses
        .map((course) => TodayCourseItemSnapshot(
              timeText: _findStartTime(course.section, meta, periodSettings),
              titleText: course.courseName.trim().isEmpty
                  ? '课程待定'
                  : course.courseName.trim(),
              roomText: course.classroomName.trim().isEmpty
                  ? '教室待定'
                  : course.classroomName.trim(),
            ))
        .toList(growable: false),
    nextItem: nextCourse == null
        ? null
        : TodayCourseItemSnapshot(
            timeText: _findStartTime(nextCourse.section, meta, periodSettings),
            titleText: nextCourse.courseName.trim().isEmpty
                ? '课程待定'
                : nextCourse.courseName.trim(),
            roomText: nextCourse.classroomName.trim().isEmpty
                ? '教室待定'
                : nextCourse.classroomName.trim(),
          ),
  );
}

ClassTableCourse? _findNextUpcomingCourse({
  required List<ClassTableCourse> todayCourses,
  required ClassTableMeta? meta,
  List<ClassPeriodSetting>? periodSettings,
  required DateTime now,
}) {
  final sorted = [...todayCourses]..sort((a, b) => a.section.compareTo(b.section));

  for (final course in sorted) {
    final start = _parseSectionDateTime(
      course.section,
      meta,
      periodSettings,
      now,
    );
    if (start == null) continue;
    if (start.isAfter(now)) return course;
  }

  return null;
}

DateTime? _parseSectionDateTime(
  int section,
  ClassTableMeta? meta,
  List<ClassPeriodSetting>? periodSettings,
  DateTime now,
) {
  final settings = periodSettings ?? meta?.periodSettings ?? const [];
  for (final item in settings) {
    if (item.section != section) continue;
    final raw = item.startTime.trim();
    if (raw.isEmpty) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
  return null;
}

ClassMeta? _findTodayMeta(List<ClassMeta> items) {
  for (final item in items) {
    if (_isToday(item.dateTimeText)) {
      return item;
    }
  }
  return null;
}

List<ClassTableCourse> _buildTodayCourses(
  List<ClassTableCourse> items,
  ClassMeta? todayMeta,
) {
  final todayWeekday = todayMeta != null
      ? _courseWeekdayFromName(todayMeta.weekdayName)
      : DateTime.now().weekday;
  final filtered =
      items
          .where((item) => item.weekday == todayWeekday)
          .toList(growable: false)
        ..sort((a, b) => a.section.compareTo(b.section));

  final seenCourseNames = <String>{};
  final unique = <ClassTableCourse>[];
  for (final course in filtered) {
    final key = course.courseName.trim();
    if (key.isEmpty || seenCourseNames.contains(key)) {
      continue;
    }
    seenCourseNames.add(key);
    unique.add(course);
  }
  return unique;
}

String _buildHeadline(int currentWeek, ClassMeta? todayMeta) {
  final weekText = currentWeek > 0 ? '第$currentWeek周' : '本周';
  if (todayMeta == null) {
    return '今天 · $weekText';
  }
  return '${todayMeta.weekdayName} · $weekText';
}

String _findStartTime(
  int section,
  ClassTableMeta? meta,
  List<ClassPeriodSetting>? periodSettings,
) {
  final settings = periodSettings ?? meta?.periodSettings ?? const [];
  for (final item in settings) {
    if (item.section == section && item.startTime.trim().isNotEmpty) {
      return item.startTime.trim();
    }
  }
  return '--:--';
}

bool _isToday(String raw) {
  final date = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  if (date == null) {
    return false;
  }
  final now = DateTime.now();
  return now.year == date.year &&
      now.month == date.month &&
      now.day == date.day;
}

int _courseWeekdayFromName(String raw) {
  switch (raw) {
    case '星期一':
      return 1;
    case '星期二':
      return 2;
    case '星期三':
      return 3;
    case '星期四':
      return 4;
    case '星期五':
      return 5;
    case '星期六':
      return 6;
    case '星期日':
    case '星期天':
      return 7;
  }
  return DateTime.now().weekday;
}
