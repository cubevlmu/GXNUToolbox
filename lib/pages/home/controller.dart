import 'package:class_tool/data/model/today_course_snapshot.dart';
import 'package:class_tool/data/services/today_snapshot_cache.dart';
import 'package:class_tool/pages/classes/controller.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ClassesController _classesController = Get.find<ClassesController>();

  final RxString semesterText = '当前学期'.obs;
  final RxString currentWeekText = '--'.obs;
  final RxString todayWeekdayText = '今天'.obs;
  final RxInt todayCourseCount = 0.obs;
  final RxList<String> todayCourseSummaries = <String>[].obs;
  final RxBool _hasResolvedTodaySnapshot = false.obs;

  bool get isLoading => _classesController.isLoading;
  bool get hasScheduleData => _classesController.hasScheduleData;
  bool get showSkeleton => isLoading && !_hasResolvedTodaySnapshot.value;

  late final Worker _syncWorker;

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
    _hasResolvedTodaySnapshot.value = true;
  }

  @override
  void onClose() {
    _syncWorker.dispose();
    super.onClose();
  }
}
