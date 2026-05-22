import 'dart:async';

import 'package:class_tool/data/model/class_meta.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:class_tool/data/model/class_table_context.dart';
import 'package:class_tool/data/model/class_table_course.dart';
import 'package:class_tool/data/model/today_course_snapshot.dart';
import 'package:class_tool/data/repo/bell_schedule_repo.dart';
import 'package:class_tool/data/repo/class_repo.dart';
import 'package:class_tool/data/repo/today_courses_widget_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/data/services/today_snapshot_cache.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@immutable
class ScheduleOption {
  const ScheduleOption({required this.label, this.extra = ''});

  final String label;
  final String extra;
}

@immutable
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

@immutable
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
  ClassesController({
    ClassRepo? classRepo,
    UserRepo? userRepo,
    TodayCoursesWidgetRepo? todayCoursesWidgetRepo,
    BellScheduleRepo? bellScheduleRepo,
  }) : _classRepo = classRepo ?? Get.find<ClassRepo>(),
       _userRepo = userRepo ?? Get.find<UserRepo>(),
       _todayCoursesWidgetRepo =
           todayCoursesWidgetRepo ?? Get.find<TodayCoursesWidgetRepo>(),
       _bellScheduleRepo = bellScheduleRepo ?? Get.find<BellScheduleRepo>();

  final ClassRepo _classRepo;
  final UserRepo _userRepo;
  final TodayCoursesWidgetRepo _todayCoursesWidgetRepo;
  final BellScheduleRepo _bellScheduleRepo;
  final EasyRefreshController easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
  );

  final RxBool _isLoading = false.obs;
  final RxString _scheduleError = ''.obs;
  final RxList<ScheduleOption> _semesters = <ScheduleOption>[].obs;
  final RxList<ScheduleOption> _weeks = <ScheduleOption>[].obs;
  final RxList<ScheduleDay> _days = <ScheduleDay>[].obs;
  final RxList<CourseBlock> _courseBlocks = <CourseBlock>[].obs;
  final RxInt _sectionCount = 12.obs;
  final RxString _monthLabel = ''.obs;
  final RxString _selectedSemester = ''.obs;
  final RxInt _selectedWeek = 0.obs;
  final Rx<ClassTableMeta?> _classTableMeta = Rx<ClassTableMeta?>(null);
  final RxList<ClassTableSemester> _rawSemesters = <ClassTableSemester>[].obs;
  final RxList<ClassMeta> _currentWeekMeta = <ClassMeta>[].obs;
  final RxList<ClassTableCourse> _currentWeekCourses = <ClassTableCourse>[].obs;
  final RxInt syncTick = 0.obs;
  final RxInt homeSyncTick = 0.obs;
  final Rx<TodayCourseSnapshot?> _homeSnapshot = Rx<TodayCourseSnapshot?>(null);
  int _requestVersion = 0;

  List<ScheduleOption> get semesters => _semesters;
  List<ScheduleOption> get weeks => _weeks;
  List<ScheduleDay> get days => _days;
  List<CourseBlock> get courseBlocks => _courseBlocks;
  List<CourseBlock> get visibleCourseBlocks => _courseBlocks;
  int get sectionCount => _sectionCount.value;
  String get monthLabel => _monthLabel.value.isEmpty ? '月' : _monthLabel.value;
  String get selectedSemester => _selectedSemester.value;
  int get selectedWeekNumber => _selectedWeek.value;
  String get selectedWeek =>
      _selectedWeek.value > 0 ? '第${_selectedWeek.value}周' : '';
  bool get isLoading => _isLoading.value;
  String get scheduleError => _scheduleError.value;
  bool get hasScheduleData =>
      _semesters.isNotEmpty ||
      _classTableMeta.value != null ||
      _currentWeekCourses.isNotEmpty;
  ClassTableMeta? get classTableMeta => _classTableMeta.value;
  List<ClassPeriodSetting> get effectivePeriodSettings {
    final bellSettings = _bellScheduleRepo.periodSettingsFor(
      _classRepo.currentCampusId,
    );
    if (bellSettings.isNotEmpty) {
      return bellSettings;
    }
    return classTableMeta?.periodSettings ?? const [];
  }
  List<ClassMeta> get currentWeekMeta => _currentWeekMeta;
  List<ClassTableCourse> get currentWeekCourses => _currentWeekCourses;
  TodayCourseSnapshot? get homeSnapshot => _homeSnapshot.value;

  @override
  void onInit() {
    super.onInit();
    if (_userRepo.isLogin && !_userRepo.isOfflineMode) {
      unawaited(syncScheduleOverview(syncExternalOutputs: true));
    }
  }

  Future<void> syncScheduleOverview({
    bool forceRefresh = false,
    bool syncExternalOutputs = false,
  }) async {
    if (!_userRepo.isLogin) {
      LogUtil.warn(
        '[ClassesController] skip schedule sync because user is not logged in',
      );
      return;
    }

    final version = ++_requestVersion;
    _isLoading.value = true;
    _scheduleError.value = '';
    syncTick.value++;
    update(<Object>['classes-header', 'schedule-table']);

    try {
      LogUtil.info('[ClassesController] syncScheduleOverview start');
      final requestedSemester = selectedSemester;
      final context = await _classRepo.syncBaseContext(
        semester: requestedSemester,
        forceRefresh: forceRefresh,
      );
      final bellScheduleTask = _loadBellScheduleQuietly();

      final effectiveSemester = requestedSemester.isNotEmpty
          ? requestedSemester
          : context.userContext.selectedSemester;

      final metaResponse = await _classRepo.fetchMeta(
        semester: effectiveSemester,
        forceRefresh: forceRefresh,
      );
      final meta = metaResponse.data;

      final resolvedWeek = meta.currentWeek > 0
          ? meta.currentWeek
          : (meta.weekRanges.isNotEmpty ? meta.weekRanges.first.week : 1);

      final weekMetaTask = _classRepo.fetchWeekMeta(
        resolvedWeek,
        semester: effectiveSemester,
        forceRefresh: forceRefresh,
      );
      final courseResponseTask = _classRepo.fetchCourses(
        resolvedWeek,
        semester: effectiveSemester,
        forceRefresh: forceRefresh,
      );
      final weekMeta = await weekMetaTask;
      final courseResponse = await courseResponseTask;
      await bellScheduleTask;
      final courses = courseResponse.data.courses;
      if (!_isActiveRequest(version)) {
        return;
      }

      _selectedSemester.value = effectiveSemester;
      _selectedWeek.value = resolvedWeek;
      _classTableMeta.value = meta;
      _rawSemesters.assignAll(context.semesters);
      _currentWeekMeta.assignAll(weekMeta);
      _currentWeekCourses.assignAll(courses);
      _scheduleError.value = '';
      _isLoading.value = false;

      _syncDerivedState(context.semesters);
      if (syncExternalOutputs) {
        final snapshot = buildTodayCourseSnapshot(
          semester: effectiveSemester,
          currentWeek: resolvedWeek,
          weekMeta: weekMeta,
          weekCourses: courses,
          meta: meta,
          periodSettings: effectivePeriodSettings,
        );
        _homeSnapshot.value = snapshot;
        homeSyncTick.value++;
        unawaited(TodaySnapshotCache.save(snapshot));
        unawaited(_todayCoursesWidgetRepo.updateFromSnapshot(snapshot));
      }

      syncTick.value++;
      update(<Object>['classes-header', 'schedule-table']);
      LogUtil.info(
        '[ClassesController] syncScheduleOverview success semester=$selectedSemester week=$selectedWeek courses=${currentWeekCourses.length}',
      );
    } catch (e, s) {
      if (!_isActiveRequest(version)) {
        return;
      }
      _isLoading.value = false;
      _scheduleError.value = e.toString();
      syncTick.value++;
      update(<Object>['classes-header', 'schedule-table']);
      LogUtil.errorE('[ClassesController] syncScheduleOverview failed', e, s);
    }
  }

  void _syncDerivedState(List<ClassTableSemester> rawSemesters) {
    _semesters.assignAll(
      rawSemesters
          .map((item) => ScheduleOption(label: item.value))
          .toList(growable: false),
    );

    final meta = classTableMeta;
    _weeks.assignAll(
      (meta?.weekRanges ?? const <ClassWeekRange>[])
          .map(
            (item) =>
                ScheduleOption(label: item.label, extra: item.dateRangeText),
          )
          .toList(growable: false),
    );

    _sectionCount.value = meta?.periodSettings.length ?? 12;
    _days.assignAll(_buildScheduleDays(currentWeekMeta));
    _monthLabel.value = _resolveMonthLabel(currentWeekMeta);
    _courseBlocks.assignAll(_buildCourseBlocks(currentWeekCourses));
  }

  Future<void> changeSemester(String value) async {
    if (value.isEmpty || value == selectedSemester) {
      return;
    }
    _selectedSemester.value = value;
    await syncScheduleOverview(forceRefresh: true, syncExternalOutputs: false);
  }

  Future<void> changeWeek(String value) async {
    final parsed = int.tryParse(
      value.replaceAll('第', '').replaceAll('周', '').trim(),
    );
    if (parsed == null || parsed <= 0 || parsed == _selectedWeek.value) {
      return;
    }
    if (!_userRepo.isLogin) {
      return;
    }

    final version = ++_requestVersion;
    _isLoading.value = true;
    _scheduleError.value = '';
    _selectedWeek.value = parsed;
    syncTick.value++;
    update(<Object>['classes-header', 'schedule-table']);

    try {
      LogUtil.info('[ClassesController] changeWeek start week=$parsed');
      final weekMetaTask = _classRepo.fetchWeekMeta(
        parsed,
        semester: selectedSemester,
        forceRefresh: false,
      );
      final courseResponseTask = _classRepo.fetchCourses(
        parsed,
        semester: selectedSemester,
        forceRefresh: false,
      );
      final weekMeta = await weekMetaTask;
      final courseResponse = await courseResponseTask;
      if (!_isActiveRequest(version)) {
        return;
      }

      _currentWeekMeta.assignAll(weekMeta);
      _currentWeekCourses.assignAll(courseResponse.data.courses);
      _isLoading.value = false;
      _scheduleError.value = '';
      _syncDerivedState(_rawSemesters);
      syncTick.value++;
      update(<Object>['classes-header', 'schedule-table']);
      LogUtil.info(
        '[ClassesController] changeWeek success week=$parsed courses=${currentWeekCourses.length}',
      );
    } catch (e, s) {
      if (!_isActiveRequest(version)) {
        return;
      }
      _isLoading.value = false;
      _scheduleError.value = e.toString();
      syncTick.value++;
      update(<Object>['classes-header', 'schedule-table']);
      LogUtil.errorE('[ClassesController] changeWeek failed', e, s);
    }
  }

  Future<void> refreshSchedule() async {
    try {
      await syncScheduleOverview(
        forceRefresh: true,
        syncExternalOutputs: false,
      );
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

  bool _isActiveRequest(int version) {
    return !isClosed && version == _requestVersion;
  }

  Future<void> _loadBellScheduleQuietly() async {
    try {
      await _bellScheduleRepo.ensureLoaded(forceRefresh: false);
    } catch (e, s) {
      LogUtil.warnE('[ClassesController] bell schedule preload failed', e, s);
    }
  }

  @override
  void onClose() {
    easyRefreshController.dispose();
    super.onClose();
  }
}
