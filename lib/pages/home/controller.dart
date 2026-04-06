import 'package:class_tool/pages/main/controller.dart';
import 'package:class_tool/data/model/class_meta.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:class_tool/data/model/class_table_course.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final MainController _mainController = Get.find<MainController>();

  final RxString semesterText = '当前学期'.obs;
  final RxString currentWeekText = '--'.obs;
  final RxString todayWeekdayText = '今天'.obs;
  final RxInt todayCourseCount = 0.obs;
  final RxList<String> todayCourseSummaries = <String>[].obs;

  bool get isLoading => _mainController.isScheduleLoading;
  bool get hasScheduleData => _mainController.hasScheduleData;
  bool get showSkeleton => isLoading && !hasScheduleData;

  late final Worker _syncWorker;

  @override
  void onInit() {
    super.onInit();
    _syncFromMainController();
    _syncWorker = ever<int>(_mainController.homeSyncTick, (_) {
      _syncFromMainController();
    });
  }

  void _syncFromMainController() {
    semesterText.value = _mainController.selectedSemester.isNotEmpty
        ? '${_mainController.selectedSemester}学期'
        : '当前学期';
    currentWeekText.value = _mainController.homeWeek > 0
        ? '第${_mainController.homeWeek}周'
        : '--';
    final todayMeta = _findTodayMeta(_mainController.homeWeekMeta);
    final todayCourses = _buildTodayCourses(
      _mainController.homeWeekCourses,
      todayMeta,
      _mainController.classTableMeta,
    );
    todayWeekdayText.value = todayMeta != null
        ? _buildHomeHeadline(_mainController.homeWeek, todayMeta)
        : _buildHomeHeadline(_mainController.homeWeek, null);
    todayCourseCount.value = todayCourses.length;
    todayCourseSummaries.assignAll(
      todayCourses.map(
        (course) => _buildCourseSummary(course, _mainController.classTableMeta),
      ),
    );
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
    ClassTableMeta? meta,
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

  String _buildHomeHeadline(int currentWeek, ClassMeta? todayMeta) {
    final weekText = currentWeek > 0 ? '第$currentWeek周' : '本周';
    if (todayMeta == null) {
      return '今天 · $weekText';
    }
    return '${todayMeta.weekdayName} · $weekText';
  }

  String _buildCourseSummary(ClassTableCourse course, ClassTableMeta? meta) {
    final startTime = _findStartTime(course.section, meta);
    final classroom = course.classroomName.trim().isEmpty
        ? '教室待定'
        : course.classroomName.trim();
    return '$startTime  ${course.courseName.trim()}  $classroom';
  }

  String _findStartTime(int section, ClassTableMeta? meta) {
    if (meta == null) {
      return '--:--';
    }
    for (final item in meta.periodSettings) {
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

  @override
  void onClose() {
    _syncWorker.dispose();
    super.onClose();
  }
}
