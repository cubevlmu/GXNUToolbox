import 'dart:async';

import 'package:class_tool/data/model/course_note.dart';
import 'package:class_tool/data/model/today_course_snapshot.dart';
import 'package:class_tool/data/repo/course_note_repo.dart';
import 'package:class_tool/data/services/debug_time_service.dart';
import 'package:class_tool/data/services/today_snapshot_cache.dart';
import 'package:class_tool/pages/classes/controller.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ClassesController _classesController = Get.find<ClassesController>();
  final CourseNoteRepo _courseNoteRepo = Get.find<CourseNoteRepo>();
  final DebugTimeService _debugTimeService = Get.find<DebugTimeService>();

  final RxString semesterText = '当前学期'.obs;
  final RxString currentWeekText = '--'.obs;
  final RxString todayWeekdayText = '今天'.obs;
  final RxInt todayCourseCount = 0.obs;
  final RxList<String> todayCourseSummaries = <String>[].obs;
  final RxList<TodayCourseItemSnapshot> todayCourses =
      <TodayCourseItemSnapshot>[].obs;
  final Rx<TodayCourseItemSnapshot?> nextCourse = Rx<TodayCourseItemSnapshot?>(
    null,
  );
  final RxList<CourseNoteEntry> todayTasks = <CourseNoteEntry>[].obs;
  final RxList<CourseNoteEntry> upcomingTasks = <CourseNoteEntry>[].obs;
  final Rx<DateTime> _timelineNow = DateTime.now().obs;
  final RxBool _hasResolvedTodaySnapshot = false.obs;

  bool get isLoading => _classesController.isLoading;
  bool get hasScheduleData => _classesController.hasScheduleData;
  bool get showSkeleton => isLoading && !_hasResolvedTodaySnapshot.value;
  bool get initialLoadFailed =>
      !_hasResolvedTodaySnapshot.value &&
      !isLoading &&
      _classesController.scheduleError.isNotEmpty;
  String get initialLoadError => _classesController.scheduleError;
  DateTime get timelineNow => _timelineNow.value;
  int get pendingTaskCount => todayTasks.length + upcomingTasks.length;
  List<CourseNoteEntry> get weekTasks => [...todayTasks, ...upcomingTasks];

  late final Worker _syncWorker;
  late final Worker _debugTimeWorker;
  Timer? _timelineClock;
  StreamSubscription<List<CourseNoteEntry>>? _todayTaskSubscription;
  StreamSubscription<List<CourseNoteEntry>>? _upcomingTaskSubscription;

  @override
  void onInit() {
    super.onInit();
    _restoreTodayCache();
    if (_classesController.homeSnapshot != null) {
      _applySnapshot(_classesController.homeSnapshot!);
    }
    _syncWorker = ever<int>(_classesController.homeSyncTick, (_) {
      final snapshot = _classesController.homeSnapshot;
      if (snapshot != null) {
        _applySnapshot(snapshot);
      }
    });
    _debugTimeWorker = ever<DateTime?>(_debugTimeService.clientTimeOverride, (
      _,
    ) {
      _setTimelineNow(_debugTimeService.now, forceResubscribe: true);
    });
    _setTimelineNow(_debugTimeService.now, forceResubscribe: true);
    _timelineClock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_debugTimeService.hasOverride) {
        return;
      }
      _setTimelineNow(DateTime.now());
    });
  }

  void _restoreTodayCache() {
    final snapshot = TodaySnapshotCache.load();
    if (snapshot == null) {
      return;
    }
    _applySnapshot(snapshot);
  }

  void _applySnapshot(TodayCourseSnapshot snapshot) {
    semesterText.value = snapshot.semesterText;
    currentWeekText.value = snapshot.currentWeekText;
    todayWeekdayText.value = snapshot.headlineText;
    todayCourseCount.value = snapshot.items.length;
    todayCourseSummaries.assignAll(snapshot.items.map((item) => item.summary));
    todayCourses.assignAll(snapshot.items);
    nextCourse.value = snapshot.nextItem;
    _hasResolvedTodaySnapshot.value = true;
  }

  void _setTimelineNow(DateTime value, {bool forceResubscribe = false}) {
    final previous = _timelineNow.value;
    _timelineNow.value = value;
    if (forceResubscribe || !_isSameDay(previous, value)) {
      _subscribeTasks();
    }
  }

  void _subscribeTasks() {
    unawaited(_todayTaskSubscription?.cancel());
    unawaited(_upcomingTaskSubscription?.cancel());
    final now = _debugTimeService.now;
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    final upcomingEnd = todayStart.add(const Duration(days: 8));
    _todayTaskSubscription = _courseNoteRepo
        .watchUpcoming(from: todayStart, to: tomorrowStart, limit: 6)
        .listen((items) => todayTasks.assignAll(items));
    _upcomingTaskSubscription = _courseNoteRepo
        .watchUpcoming(from: tomorrowStart, to: upcomingEnd, limit: 6)
        .listen((items) => upcomingTasks.assignAll(items));
  }

  Future<void> setTaskDone(CourseNoteEntry entry, bool isDone) {
    return _courseNoteRepo.setDone(entry.note.id, isDone);
  }

  Future<void> deleteTask(CourseNoteEntry entry) {
    return _courseNoteRepo.delete(entry.note.id);
  }

  Future<bool> exportTaskToCalendar(CourseNoteEntry entry) {
    return _courseNoteRepo.exportToCalendar(entry.note.id);
  }

  @override
  void onClose() {
    _syncWorker.dispose();
    _debugTimeWorker.dispose();
    _timelineClock?.cancel();
    unawaited(_todayTaskSubscription?.cancel());
    unawaited(_upcomingTaskSubscription?.cancel());
    super.onClose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
