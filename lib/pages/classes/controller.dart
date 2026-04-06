import 'dart:async';

import 'package:class_tool/data/model/class_meta.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:class_tool/data/model/class_table_course.dart';
import 'package:class_tool/pages/main/controller.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleOption {
  const ScheduleOption({required this.label, this.extra = ''});

  final String label;
  final String extra;
}

class ScheduleDay {
  const ScheduleDay({
    required this.dateText,
    required this.weekdayText,
    this.isToday = false,
  });

  final String dateText;
  final String weekdayText;
  final bool isToday;
}

class CourseBlock {
  const CourseBlock({
    required this.dayIndex,
    required this.startSection,
    required this.sectionSpan,
    required this.title,
    required this.teacher,
    required this.classroom,
    required this.weeks,
    required this.color,
  });

  final int dayIndex;
  final int startSection;
  final int sectionSpan;
  final String title;
  final String teacher;
  final String classroom;
  final String weeks;
  final Color color;
}

class ClassesController extends GetxController {
  ClassesController({MainController? mainController})
    : _mainController = mainController ?? Get.find<MainController>();

  final MainController _mainController;
  final EasyRefreshController easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
  );

  final RxList<ScheduleOption> _semesters = <ScheduleOption>[].obs;
  final RxList<ScheduleOption> _weeks = <ScheduleOption>[].obs;
  final RxList<ScheduleDay> _days = <ScheduleDay>[].obs;
  final RxList<CourseBlock> _courseBlocks = <CourseBlock>[].obs;
  final RxInt _sectionCount = 12.obs;
  final RxString _monthLabel = ''.obs;

  late final Worker _syncWorker;

  List<ScheduleOption> get semesters => _semesters;
  List<ScheduleOption> get weeks => _weeks;
  List<ScheduleDay> get days => _days;
  List<CourseBlock> get courseBlocks => _courseBlocks;
  List<CourseBlock> get visibleCourseBlocks => _courseBlocks;
  int get sectionCount => _sectionCount.value;
  String get monthLabel => _monthLabel.value.isEmpty ? '月' : _monthLabel.value;
  String get selectedSemester => _mainController.selectedSemester;
  String get selectedWeek => _mainController.selectedWeekLabel;
  bool get isLoading => _mainController.isScheduleLoading;
  String get scheduleError => _mainController.scheduleError;
  bool get hasScheduleData => _mainController.hasScheduleData;

  @override
  void onInit() {
    super.onInit();
    _syncFromMainController();
    _syncWorker = ever<int>(_mainController.scheduleSyncTick, (_) {
      _syncFromMainController();
    });
  }

  void _syncFromMainController() {
    _semesters.assignAll(
      _mainController.scheduleSemesters
          .map((item) => ScheduleOption(label: item.value))
          .toList(growable: false),
    );

    final meta = _mainController.classTableMeta;
    _weeks.assignAll(
      (meta?.weekRanges ?? const <ClassWeekRange>[])
          .map(
            (item) =>
                ScheduleOption(label: item.label, extra: item.dateRangeText),
          )
          .toList(growable: false),
    );

    _sectionCount.value = meta?.periodSettings.length ?? 12;
    _days.assignAll(_buildScheduleDays(_mainController.currentWeekMeta));
    _monthLabel.value = _resolveMonthLabel(_mainController.currentWeekMeta);
    _courseBlocks.assignAll(
      _buildCourseBlocks(_mainController.currentWeekCourses),
    );
    update(<Object>['classes-header', 'schedule-table']);
  }

  Future<void> changeSemester(String value) {
    return _mainController.changeScheduleSemester(value);
  }

  Future<void> changeWeek(String value) async {
    final parsed = int.tryParse(
      value.replaceAll('第', '').replaceAll('周', '').trim(),
    );
    if (parsed == null) {
      return;
    }
    await _mainController.changeScheduleWeek(parsed);
  }

  Future<void> refreshSchedule() async {
    try {
      await _mainController.syncScheduleOverview(forceRefresh: true);
    } finally {
      easyRefreshController.finishRefresh();
    }
  }

  List<ScheduleDay> _buildScheduleDays(List<ClassMeta> items) {
    final sorted = List<ClassMeta>.from(items)
      ..sort(
        (a, b) => _weekdayOrder(
          a.weekdayIndex,
        ).compareTo(_weekdayOrder(b.weekdayIndex)),
      );

    return sorted
        .map(
          (item) => ScheduleDay(
            dateText: item.dayText,
            weekdayText: _weekdayShortName(item.weekdayName),
            isToday: _isToday(item.dateTimeText),
          ),
        )
        .toList(growable: false);
  }

  String _resolveMonthLabel(List<ClassMeta> items) {
    if (items.isEmpty) {
      return '月';
    }
    final raw = items.first.dateTimeText;
    final date = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (date == null) {
      return '月';
    }
    return '${date.month.toString().padLeft(2, '0')}月';
  }

  List<CourseBlock> _buildCourseBlocks(List<ClassTableCourse> courses) {
    final sorted = List<ClassTableCourse>.from(courses)
      ..sort((a, b) {
        final dayCompare = a.weekday.compareTo(b.weekday);
        if (dayCompare != 0) {
          return dayCompare;
        }
        return a.section.compareTo(b.section);
      });

    final palette = <Color>[
      const Color(0xFFDAF3E4),
      const Color(0xFFE8F5D4),
      const Color(0xFFF8E5C0),
      const Color(0xFFDDECFD),
      const Color(0xFFE9E3FF),
      const Color(0xFFE0F2CB),
      const Color(0xFFFDE3E0),
      const Color(0xFFD9F0EB),
      const Color(0xFFE6EBFE),
      const Color(0xFFF9ECD2),
      const Color(0xFFF6DFEA),
      const Color(0xFFDDF4D9),
      const Color(0xFFEAF0FF),
      const Color(0xFFFBE8C8),
      const Color(0xFFFFE2D9),
    ];

    final merged = <CourseBlock>[];
    for (final course in sorted) {
      if (merged.isNotEmpty && _canMerge(merged.last, course)) {
        final previous = merged.removeLast();
        merged.add(
          CourseBlock(
            dayIndex: previous.dayIndex,
            startSection: previous.startSection,
            sectionSpan: previous.sectionSpan + 1,
            title: previous.title,
            teacher: previous.teacher,
            classroom: previous.classroom,
            weeks: previous.weeks,
            color: previous.color,
          ),
        );
        continue;
      }

      merged.add(
        CourseBlock(
          dayIndex: (course.weekday - 1).clamp(0, 6),
          startSection: course.section,
          sectionSpan: 1,
          title: course.courseName,
          teacher: course.teacherName,
          classroom: course.classroomName,
          weeks: _buildWeeksLabel(course),
          color:
              palette[course.teachingClassId.hashCode.abs() % palette.length],
        ),
      );
    }

    return merged;
  }

  bool _canMerge(CourseBlock previous, ClassTableCourse next) {
    final nextDayIndex = (next.weekday - 1).clamp(0, 6);
    return previous.dayIndex == nextDayIndex &&
        previous.startSection + previous.sectionSpan == next.section &&
        previous.title == next.courseName &&
        previous.classroom == next.classroomName &&
        previous.teacher == next.teacherName &&
        previous.weeks == _buildWeeksLabel(next);
  }

  String _buildWeeksLabel(ClassTableCourse course) {
    if (course.isOddWeekOnly) {
      return '${course.weekRangeText}(单周)';
    }
    if (course.isEvenWeekOnly) {
      return '${course.weekRangeText}(双周)';
    }
    return course.weekRangeText;
  }

  int _weekdayOrder(int value) {
    switch (value) {
      case 2:
        return 1;
      case 3:
        return 2;
      case 4:
        return 3;
      case 5:
        return 4;
      case 6:
        return 5;
      case 7:
        return 6;
      case 1:
        return 7;
      default:
        return value;
    }
  }

  String _weekdayShortName(String raw) {
    if (raw.startsWith('星期') && raw.length >= 3) {
      return raw.substring(2);
    }
    return raw;
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

  @override
  void onClose() {
    _syncWorker.dispose();
    easyRefreshController.dispose();
    super.onClose();
  }
}
