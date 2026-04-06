import 'dart:async';

import 'package:class_tool/data/model/class_meta.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:class_tool/data/model/class_table_context.dart';
import 'package:class_tool/data/model/class_table_course.dart';
import 'package:class_tool/data/repo/class_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  MainController({ClassRepo? classRepo, UserRepo? userRepo})
    : _classRepo = classRepo ?? Get.find<ClassRepo>(),
      _userRepo = userRepo ?? Get.find<UserRepo>();

  final ClassRepo _classRepo;
  final UserRepo _userRepo;

  final RxInt selectedIndex = 0.obs;
  final Rx<_ScheduleState> _scheduleState = _ScheduleState.initial().obs;
  final Rx<_HomeScheduleState> _homeState = _HomeScheduleState.initial().obs;
  final RxInt scheduleSyncTick = 0.obs;
  final RxInt homeSyncTick = 0.obs;

  bool get isScheduleLoading => _scheduleState.value.isLoading;
  String get scheduleError => _scheduleState.value.error;
  String get selectedSemester => _scheduleState.value.selectedSemester;
  int get selectedWeek => _scheduleState.value.selectedWeek;
  List<ClassTableSemester> get scheduleSemesters =>
      _scheduleState.value.scheduleSemesters;
  List<ClassMeta> get currentWeekMeta => _scheduleState.value.currentWeekMeta;
  List<ClassTableCourse> get currentWeekCourses =>
      _scheduleState.value.currentWeekCourses;
  ClassTableMeta? get classTableMeta => _scheduleState.value.classTableMeta;

  int get homeWeek => _homeState.value.week;
  List<ClassMeta> get homeWeekMeta => _homeState.value.weekMeta;
  List<ClassTableCourse> get homeWeekCourses => _homeState.value.weekCourses;

  bool get hasScheduleData =>
      scheduleSemesters.isNotEmpty ||
      classTableMeta != null ||
      currentWeekCourses.isNotEmpty;

  String get selectedWeekLabel => selectedWeek > 0 ? '第$selectedWeek周' : '';

  @override
  void onInit() {
    super.onInit();
    if (_userRepo.isLogin && !_userRepo.isOfflineMode) {
      unawaited(syncScheduleOverview());
    }
  }

  void onDestinationSelected(int index) {
    selectedIndex.value = index;
  }

  Future<void> syncScheduleOverview({bool forceRefresh = false}) async {
    if (!_userRepo.isLogin) {
      LogUtil.warn(
        '[MainController] skip schedule sync because user is not logged in',
      );
      return;
    }

    _scheduleState.value = _scheduleState.value.copyWith(
      isLoading: true,
      error: '',
    );
    scheduleSyncTick.value++;

    try {
      LogUtil.info('[MainController] syncScheduleOverview start');
      final requestedSemester = selectedSemester;
      final context = await _classRepo.syncBaseContext(
        semester: requestedSemester,
        forceRefresh: forceRefresh,
      );

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

      final weekMeta = await _classRepo.fetchWeekMeta(
        resolvedWeek,
        semester: effectiveSemester,
        forceRefresh: forceRefresh,
      );

      final courseResponse = await _classRepo.fetchCourses(
        resolvedWeek,
        semester: effectiveSemester,
        forceRefresh: forceRefresh,
      );
      final courses = courseResponse.data.courses;

      _scheduleState.value = _scheduleState.value.copyWith(
        isLoading: false,
        error: '',
        selectedSemester: effectiveSemester,
        selectedWeek: resolvedWeek,
        scheduleSemesters: context.semesters,
        currentWeekMeta: weekMeta,
        currentWeekCourses: courses,
        classTableMeta: meta,
      );
      _homeState.value = _HomeScheduleState(
        week: resolvedWeek,
        weekMeta: weekMeta,
        weekCourses: courses,
      );

      scheduleSyncTick.value++;
      homeSyncTick.value++;
      LogUtil.info(
        '[MainController] syncScheduleOverview success semester=$selectedSemester week=$selectedWeek courses=${currentWeekCourses.length}',
      );
    } catch (e, s) {
      _scheduleState.value = _scheduleState.value.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      scheduleSyncTick.value++;
      LogUtil.errorE('[MainController] syncScheduleOverview failed', e, s);
    }
  }

  Future<void> changeScheduleSemester(String semester) async {
    if (semester.isEmpty || semester == selectedSemester) {
      return;
    }

    _scheduleState.value = _scheduleState.value.copyWith(
      selectedSemester: semester,
    );
    await syncScheduleOverview(forceRefresh: true);
  }

  Future<void> changeScheduleWeek(int week) async {
    if (week <= 0 || week == selectedWeek) {
      return;
    }

    if (!_userRepo.isLogin) {
      return;
    }

    _scheduleState.value = _scheduleState.value.copyWith(
      isLoading: true,
      error: '',
      selectedWeek: week,
    );
    scheduleSyncTick.value++;

    try {
      LogUtil.info('[MainController] changeScheduleWeek start week=$week');
      final weekMeta = await _classRepo.fetchWeekMeta(
        week,
        semester: selectedSemester,
        forceRefresh: false,
      );

      final courseResponse = await _classRepo.fetchCourses(
        week,
        semester: selectedSemester,
        forceRefresh: false,
      );

      _scheduleState.value = _scheduleState.value.copyWith(
        isLoading: false,
        error: '',
        currentWeekMeta: weekMeta,
        currentWeekCourses: courseResponse.data.courses,
      );
      scheduleSyncTick.value++;
      LogUtil.info(
        '[MainController] changeScheduleWeek success week=$week courses=${currentWeekCourses.length}',
      );
    } catch (e, s) {
      _scheduleState.value = _scheduleState.value.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      scheduleSyncTick.value++;
      LogUtil.errorE('[MainController] changeScheduleWeek failed', e, s);
    }
  }
}

class _ScheduleState {
  const _ScheduleState({
    required this.isLoading,
    required this.error,
    required this.selectedSemester,
    required this.selectedWeek,
    required this.scheduleSemesters,
    required this.currentWeekMeta,
    required this.currentWeekCourses,
    required this.classTableMeta,
  });

  factory _ScheduleState.initial() => const _ScheduleState(
    isLoading: false,
    error: '',
    selectedSemester: '',
    selectedWeek: 0,
    scheduleSemesters: <ClassTableSemester>[],
    currentWeekMeta: <ClassMeta>[],
    currentWeekCourses: <ClassTableCourse>[],
    classTableMeta: null,
  );

  final bool isLoading;
  final String error;
  final String selectedSemester;
  final int selectedWeek;
  final List<ClassTableSemester> scheduleSemesters;
  final List<ClassMeta> currentWeekMeta;
  final List<ClassTableCourse> currentWeekCourses;
  final ClassTableMeta? classTableMeta;

  _ScheduleState copyWith({
    bool? isLoading,
    String? error,
    String? selectedSemester,
    int? selectedWeek,
    List<ClassTableSemester>? scheduleSemesters,
    List<ClassMeta>? currentWeekMeta,
    List<ClassTableCourse>? currentWeekCourses,
    Object? classTableMeta = _sentinel,
  }) {
    return _ScheduleState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedSemester: selectedSemester ?? this.selectedSemester,
      selectedWeek: selectedWeek ?? this.selectedWeek,
      scheduleSemesters: scheduleSemesters ?? this.scheduleSemesters,
      currentWeekMeta: currentWeekMeta ?? this.currentWeekMeta,
      currentWeekCourses: currentWeekCourses ?? this.currentWeekCourses,
      classTableMeta: identical(classTableMeta, _sentinel)
          ? this.classTableMeta
          : classTableMeta as ClassTableMeta?,
    );
  }
}

class _HomeScheduleState {
  const _HomeScheduleState({
    required this.week,
    required this.weekMeta,
    required this.weekCourses,
  });

  factory _HomeScheduleState.initial() => const _HomeScheduleState(
    week: 0,
    weekMeta: <ClassMeta>[],
    weekCourses: <ClassTableCourse>[],
  );

  final int week;
  final List<ClassMeta> weekMeta;
  final List<ClassTableCourse> weekCourses;
}

const Object _sentinel = Object();
