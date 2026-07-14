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
import 'package:class_tool/data/services/academic_term_service.dart';
import 'package:class_tool/utils/log_util.dart';
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
  final RxBool _isHoliday = false.obs;
  final Rx<ClassTableMeta?> _classTableMeta = Rx<ClassTableMeta?>(null);
  final RxList<ClassTableSemester> _rawSemesters = <ClassTableSemester>[].obs;
  final RxList<ClassMeta> _currentWeekMeta = <ClassMeta>[].obs;
  final RxList<ClassTableCourse> _currentWeekCourses = <ClassTableCourse>[].obs;
  final RxInt syncTick = 0.obs;
  final RxInt homeSyncTick = 0.obs;
  final Rx<TodayCourseSnapshot?> _homeSnapshot = Rx<TodayCourseSnapshot?>(null);
  int _requestVersion = 0;
  String _todaySemester = '';

  List<ScheduleOption> get semesters => _semesters;
  List<ScheduleOption> get weeks => _weeks;
  List<ScheduleDay> get days => _days;
  List<CourseBlock> get courseBlocks => _courseBlocks;
  List<CourseBlock> get visibleCourseBlocks => _courseBlocks;
  int get sectionCount => _sectionCount.value;
  String get monthLabel => _monthLabel.value.isEmpty ? '月' : _monthLabel.value;
  String get selectedSemester => _selectedSemester.value;
  int get selectedWeekNumber => _selectedWeek.value;
  String get selectedWeek => _isHoliday.value
      ? '假期'
      : (_selectedWeek.value > 0 ? '第${_selectedWeek.value}周' : '');
  bool get isHoliday => _isHoliday.value;
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
  int get currentMetaWeek => classTableMeta?.currentWeek ?? 0;
  int? get todayWeekNumber => _resolveTodayWeekNumber();
  bool get canReturnToday {
    if (_isViewingDifferentSemesterFromToday()) {
      return true;
    }
    final targetWeek = _resolveTodayWeekNumber(allowCurrentWeekFallback: false);
    return targetWeek != null && _selectedWeek.value != targetWeek;
  }

  int? get todayWeekday {
    for (final item in currentWeekMeta) {
      final date = _parseMetaDate(item.dateTimeText);
      if (date != null && _isSameDate(date, DateTime.now())) {
        return date.weekday;
      }
    }
    return null;
  }

  bool shouldShowReturnToday(int selectedWeekday) {
    if (isLoading) {
      return false;
    }
    if (_isViewingDifferentSemesterFromToday()) {
      return true;
    }
    final targetWeek = _resolveTodayWeekNumber(allowCurrentWeekFallback: false);
    if (targetWeek == null) {
      return false;
    }
    if (_selectedWeek.value != targetWeek) {
      return true;
    }
    final today = todayWeekday;
    return selectedWeekday != (today ?? DateTime.now().weekday);
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

      final termWeek = AcademicTermService.resolveWeek(meta);
      final resolvedWeek = termWeek.week;
      List<ClassMeta> weekMeta = const <ClassMeta>[];
      List<ClassTableCourse> courses = const <ClassTableCourse>[];
      if (!termWeek.isHoliday) {
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
        weekMeta = await weekMetaTask;
        courses = (await courseResponseTask).data.courses;
      }
      await bellScheduleTask;
      if (!_isActiveRequest(version)) {
        return;
      }

      _selectedSemester.value = effectiveSemester;
      _selectedWeek.value = resolvedWeek;
      _isHoliday.value = termWeek.isHoliday;
      _classTableMeta.value = meta;
      _rawSemesters.assignAll(context.semesters);
      _currentWeekMeta.assignAll(weekMeta);
      _currentWeekCourses.assignAll(courses);
      _scheduleError.value = '';
      _isLoading.value = false;

      _syncDerivedState(context.semesters);
      _rememberTodaySemesterIfApplicable(effectiveSemester);
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
    _isHoliday.value = false;
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

  Future<void> changeWeekByOffset(int offset) async {
    if (offset == 0 || isLoading) {
      return;
    }
    final weekOptions = weeks;
    if (weekOptions.isNotEmpty) {
      final currentIndex = weekOptions.indexWhere(
        (item) => _parseWeekLabel(item.label) == _selectedWeek.value,
      );
      if (currentIndex >= 0) {
        final nextIndex = currentIndex + offset;
        if (nextIndex < 0 || nextIndex >= weekOptions.length) {
          return;
        }
        await changeWeek(weekOptions[nextIndex].label);
        return;
      }
    }

    final nextWeek = _selectedWeek.value + offset;
    if (nextWeek <= 0) {
      return;
    }
    await changeWeek('第$nextWeek周');
  }

  Future<void> returnToToday({ValueChanged<int>? onWeekdayResolved}) async {
    final todaySemester = _resolveTodaySemesterValue();
    if (todaySemester.isNotEmpty && selectedSemester != todaySemester) {
      await changeSemester(todaySemester);
    }

    final targetWeek = _resolveTodayWeekNumber(allowCurrentWeekFallback: false);
    if (targetWeek == null || targetWeek <= 0) {
      final today = DateTime.now().weekday;
      onWeekdayResolved?.call(today);
      update(<Object>['classes-header', 'schedule-table']);
      return;
    }

    if (_selectedWeek.value != targetWeek) {
      await changeWeek('第$targetWeek周');
    }

    onWeekdayResolved?.call(todayWeekday ?? DateTime.now().weekday);
    update(<Object>['classes-header', 'schedule-table']);
  }

  Future<void> refreshSchedule() async {
    await syncScheduleOverview(forceRefresh: true, syncExternalOutputs: true);
  }

  int? _parseWeekLabel(String raw) {
    return int.tryParse(raw.replaceAll('第', '').replaceAll('周', '').trim());
  }

  List<ScheduleDay> _buildScheduleDays(List<ClassMeta> items) {
    final fallback = List<ScheduleDay>.generate(
      DateTime.daysPerWeek,
      (index) =>
          ScheduleDay(dateText: '', weekdayText: _weekdayShortLabel(index + 1)),
    );
    final days = List<ScheduleDay>.from(fallback);

    for (final item in items) {
      final weekday = _weekdayOrderForMeta(item);
      final index = weekday - 1;
      if (index < 0 || index >= days.length) {
        continue;
      }
      days[index] = ScheduleDay(
        dateText: item.dayText,
        weekdayText: _weekdayShortLabel(weekday),
        isToday: _isToday(item.dateTimeText),
      );
    }

    return days;
  }

  String _resolveMonthLabel(List<ClassMeta> items) {
    if (items.isEmpty) {
      return '月';
    }
    final dates =
        items
            .map((item) => _parseMetaDate(item.dateTimeText))
            .whereType<DateTime>()
            .toList(growable: false)
          ..sort();
    final date = dates.isEmpty ? null : dates.first;
    if (date == null) {
      return '月';
    }
    return '${date.month.toString().padLeft(2, '0')}月';
  }

  List<CourseBlock> _buildCourseBlocks(List<ClassTableCourse> courses) {
    final sorted = List<ClassTableCourse>.from(courses)
      ..sort((a, b) {
        final dayCompare = uiWeekdayFromSchoolWeekday(
          a.weekday,
        ).compareTo(uiWeekdayFromSchoolWeekday(b.weekday));
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
          dayIndex: uiWeekdayFromSchoolWeekday(course.weekday) - 1,
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
    final nextDayIndex = uiWeekdayFromSchoolWeekday(next.weekday) - 1;
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
    return uiWeekdayFromSchoolWeekday(value);
  }

  int _weekdayOrderForMeta(ClassMeta meta) {
    final date = _parseMetaDate(meta.dateTimeText);
    if (date != null) {
      return date.weekday;
    }
    return _weekdayFromName(meta.weekdayName) ??
        _weekdayOrder(meta.weekdayIndex);
  }

  static int uiWeekdayFromSchoolWeekday(int value) {
    return value >= DateTime.monday && value <= DateTime.sunday
        ? value
        : DateTime.monday;
  }

  int? _weekdayFromName(String raw) {
    if (raw.contains('一')) return DateTime.monday;
    if (raw.contains('二')) return DateTime.tuesday;
    if (raw.contains('三')) return DateTime.wednesday;
    if (raw.contains('四')) return DateTime.thursday;
    if (raw.contains('五')) return DateTime.friday;
    if (raw.contains('六')) return DateTime.saturday;
    if (raw.contains('日') || raw.contains('天')) return DateTime.sunday;
    return null;
  }

  String _weekdayShortLabel(int weekday) {
    const labels = ['一', '二', '三', '四', '五', '六', '日'];
    return labels[(weekday - 1).clamp(0, labels.length - 1)];
  }

  bool _isToday(String raw) {
    final date = _parseMetaDate(raw);
    if (date == null) {
      return false;
    }
    return _isSameDate(date, DateTime.now());
  }

  bool _isViewingDifferentSemesterFromToday() {
    final todaySemester = _resolveTodaySemesterValue();
    return todaySemester.isNotEmpty &&
        selectedSemester.isNotEmpty &&
        selectedSemester != todaySemester;
  }

  String _resolveTodaySemesterValue() {
    if (_todaySemester.isNotEmpty) {
      return _todaySemester;
    }

    final now = DateTime.now();
    for (final item in _rawSemesters) {
      if (_semesterLikelyContainsDate(item.value, now) ||
          _semesterLikelyContainsDate(item.label, now)) {
        return item.value;
      }
    }
    return '';
  }

  void _rememberTodaySemesterIfApplicable(String semester) {
    if (semester.isEmpty) {
      return;
    }
    if (_currentWeekMetaContainsToday() || _weekRangesContainToday()) {
      _todaySemester = semester;
    }
  }

  bool _currentWeekMetaContainsToday() {
    final now = DateTime.now();
    for (final item in currentWeekMeta) {
      final date = _parseMetaDate(item.dateTimeText);
      if (date != null && _isSameDate(date, now)) {
        return true;
      }
    }
    return false;
  }

  bool _weekRangesContainToday() {
    final ranges = classTableMeta?.weekRanges ?? const <ClassWeekRange>[];
    final now = DateTime.now();
    for (final item in ranges) {
      if (_dateRangeContains(item.dateRangeText, now)) {
        return true;
      }
    }
    return false;
  }

  int? _resolveTodayWeekNumber({bool allowCurrentWeekFallback = true}) {
    final now = DateTime.now();
    for (final item in currentWeekMeta) {
      final date = _parseMetaDate(item.dateTimeText);
      if (date != null && _isSameDate(date, now)) {
        return item.week > 0 ? item.week : _selectedWeek.value;
      }
    }

    final meta = classTableMeta;
    if (meta != null) {
      for (final item in meta.weekRanges) {
        if (item.week > 0 && _dateRangeContains(item.dateRangeText, now)) {
          return item.week;
        }
      }
    }

    if (allowCurrentWeekFallback && currentMetaWeek > 0) {
      return currentMetaWeek;
    }
    return null;
  }

  bool _dateRangeContains(String raw, DateTime date) {
    final range = _parseDateRange(raw);
    if (range != null) {
      return _isDateInRange(date, range.$1, range.$2);
    }

    final monthDays = _parseMonthDays(raw);
    if (monthDays.length < 2) {
      return false;
    }

    final startMonth = monthDays[0].$1;
    final startDay = monthDays[0].$2;
    final endMonth = monthDays[1].$1;
    final endDay = monthDays[1].$2;
    for (final year in _candidateYears()) {
      final start = _tryDate(year, startMonth, startDay);
      var end = _tryDate(year, endMonth, endDay);
      if (start == null || end == null) {
        continue;
      }
      if (end.isBefore(start)) {
        end = _tryDate(year + 1, endMonth, endDay);
      }
      if (end != null && _isDateInRange(date, start, end)) {
        return true;
      }
    }
    return false;
  }

  (DateTime start, DateTime end)? _parseDateRange(String raw) {
    final fullDates = _parseFullDates(raw);
    if (fullDates.length >= 2) {
      return (fullDates.first, fullDates[1]);
    }
    if (fullDates.length != 1) {
      return null;
    }

    final start = fullDates.first;
    final tail = raw.substring(raw.indexOf(RegExp(r'20\d{2}')) + 4);
    final monthDays = _parseMonthDays(tail);
    if (monthDays.isEmpty) {
      return null;
    }

    final endMonth = monthDays.last.$1;
    final endDay = monthDays.last.$2;
    var end = _tryDate(start.year, endMonth, endDay);
    if (end == null) {
      return null;
    }
    if (end.isBefore(start)) {
      end = _tryDate(start.year + 1, endMonth, endDay);
    }
    return end == null ? null : (start, end);
  }

  bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    return !normalizedDate.isBefore(normalizedStart) &&
        !normalizedDate.isAfter(normalizedEnd);
  }

  List<DateTime> _parseFullDates(String raw) {
    final matches = RegExp(
      r'(20\d{2})\D+(\d{1,2})\D+(\d{1,2})',
    ).allMatches(raw);
    return matches
        .map(
          (match) => _tryDate(
            int.parse(match.group(1)!),
            int.parse(match.group(2)!),
            int.parse(match.group(3)!),
          ),
        )
        .whereType<DateTime>()
        .toList(growable: false);
  }

  List<(int month, int day)> _parseMonthDays(String raw) {
    final matches = RegExp(r'(\d{1,2})[./月-](\d{1,2})').allMatches(raw);
    return matches
        .map((match) {
          final month = int.parse(match.group(1)!);
          final day = int.parse(match.group(2)!);
          if (month < 1 || month > 12 || day < 1 || day > 31) {
            return null;
          }
          return (month, day);
        })
        .whereType<(int, int)>()
        .toList(growable: false);
  }

  List<int> _candidateYears() {
    final years = RegExp(r'20\d{2}')
        .allMatches(selectedSemester)
        .map((match) => int.tryParse(match.group(0)!))
        .whereType<int>()
        .toList(growable: false);
    if (years.length < 2) {
      return years;
    }

    final term = _parseSemesterTerm(selectedSemester);
    if (term == 1) {
      return <int>[years.first, years[1]];
    }
    if (term == 2) {
      return <int>[years[1]];
    }
    return years;
  }

  bool _semesterLikelyContainsDate(String raw, DateTime date) {
    if (raw.isEmpty) {
      return false;
    }

    final yearMatches = RegExp(r'20\d{2}').allMatches(raw).toList();
    if (yearMatches.length < 2) {
      return false;
    }

    final startYear = int.tryParse(yearMatches[0].group(0)!);
    final endYear = int.tryParse(yearMatches[1].group(0)!);
    final term = _parseSemesterTerm(raw);
    if (startYear == null || endYear == null || term == null) {
      return false;
    }

    if (term == 1) {
      return (date.year == startYear && date.month >= 8) ||
          (date.year == endYear && date.month <= 1);
    }
    if (term == 2) {
      return date.year == endYear && date.month >= 2 && date.month <= 8;
    }
    return false;
  }

  int? _parseSemesterTerm(String raw) {
    final explicit = RegExp(r'第?\s*([12])\s*学期').firstMatch(raw);
    if (explicit != null) {
      return int.parse(explicit.group(1)!);
    }

    final trailing = RegExp(r'[-_ ]([12])(?:\D*)$').firstMatch(raw);
    if (trailing != null) {
      return int.parse(trailing.group(1)!);
    }
    return null;
  }

  DateTime? _tryDate(int year, int month, int day) {
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  DateTime? _parseMetaDate(String raw) {
    return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
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
}
