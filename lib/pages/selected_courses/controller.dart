import 'package:class_tool/data/model/selected_course.dart';
import 'package:class_tool/data/repo/selected_course_repo.dart';
import 'package:class_tool/data/services/local_semester_service.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:get/get.dart';

class SelectedCoursesController extends GetxController {
  SelectedCoursesController({SelectedCourseRepo? selectedCourseRepo})
    : _selectedCourseRepo =
          selectedCourseRepo ?? Get.find<SelectedCourseRepo>();

  static const int pageSize = 20;

  final SelectedCourseRepo _selectedCourseRepo;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _error = ''.obs;
  final RxList<SelectedCourseItem> _courses = <SelectedCourseItem>[].obs;
  final RxString _selectedSemester = ''.obs;
  final RxList<String> _semesterOptions = <String>[].obs;
  final RxInt _page = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _total = 0.obs;
  final RxDouble _totalCredits = 0.0.obs;
  final RxList<String> _semesters = <String>[].obs;
  int _requestVersion = 0;

  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get error => _error.value;
  List<SelectedCourseItem> get courses => _courses;
  String get selectedSemester => _selectedSemester.value;
  List<String> get semesterOptions => _semesterOptions;
  bool get hasData => courses.isNotEmpty;
  int get page => _page.value;
  int get totalPages => _totalPages.value;
  int get total => _total.value == 0 ? courses.length : _total.value;
  double get totalCredits => _totalCredits.value;
  List<String> get semesters => _semesters;
  bool get hasMore => page < totalPages;

  @override
  void onInit() {
    super.onInit();
    _semesterOptions.assignAll(_buildSemesterOptions());
    _selectedSemester.value = LocalSemesterService.currentSemester();
    Future<void>.microtask(refresh);
  }

  Future<void> changeSemester(String semester) async {
    if (_selectedSemester.value == semester) {
      return;
    }
    _selectedSemester.value = semester;
    _courses.clear();
    _total.value = 0;
    _totalPages.value = 1;
    _page.value = 1;
    _recomputeSummary();
    _requestVersion++;
    _isLoading.value = false;
    _isLoadingMore.value = false;
    await refresh();
  }

  @override
  Future<void> refresh() async {
    if (_isLoading.value) {
      return;
    }

    final version = ++_requestVersion;
    _isLoading.value = true;
    _isLoadingMore.value = false;
    _error.value = '';
    _page.value = 1;
    update(<Object>['selected-courses-content']);

    try {
      final result = await _fetchPage(1);
      if (!_isActiveRequest(version)) {
        return;
      }
      _courses.assignAll(result.results);
      _page.value = result.page <= 0 ? 1 : result.page;
      _totalPages.value = result.totalPages <= 0 ? 1 : result.totalPages;
      _total.value = result.total;
      _recomputeSummary();
      _error.value = '';
      LogUtil.info(
        '[SelectedCoursesController] refresh success total=${result.total}',
      );
    } catch (e, s) {
      if (!_isActiveRequest(version)) {
        return;
      }
      _error.value = e.toString();
      LogUtil.errorE('[SelectedCoursesController] refresh failed', e, s);
    } finally {
      if (_isActiveRequest(version)) {
        _isLoading.value = false;
        update(<Object>['selected-courses-content']);
      }
    }
  }

  Future<void> loadMore() async {
    if (_isLoading.value || _isLoadingMore.value || !hasMore) {
      return;
    }

    final version = ++_requestVersion;
    _isLoadingMore.value = true;
    update(<Object>['selected-courses-content']);

    try {
      final nextPage = page + 1;
      final result = await _fetchPage(nextPage);
      if (!_isActiveRequest(version)) {
        return;
      }
      _courses.addAll(result.results);
      _page.value = result.page <= 0 ? nextPage : result.page;
      _totalPages.value = result.totalPages <= 0
          ? totalPages
          : result.totalPages;
      _total.value = result.total;
      _recomputeSummary();
    } catch (e, s) {
      if (!_isActiveRequest(version)) {
        return;
      }
      _error.value = e.toString();
      LogUtil.errorE('[SelectedCoursesController] load more failed', e, s);
    } finally {
      if (_isActiveRequest(version)) {
        _isLoadingMore.value = false;
        update(<Object>['selected-courses-content']);
      }
    }
  }

  Future<SelectedCourseQueryResponse> _fetchPage(int targetPage) {
    return _selectedCourseRepo.fetchPage(
      page: targetPage,
      pageSize: pageSize,
      semester: _selectedSemester.value,
    );
  }

  void _recomputeSummary() {
    var credits = 0.0;
    final semesters = <String>{};
    for (final item in _courses) {
      credits += item.creditValue;
      if (item.semester.isNotEmpty) {
        semesters.add(item.semester);
      }
    }
    _totalCredits.value = credits;
    _semesters.assignAll(semesters);
  }

  List<String> _buildSemesterOptions() {
    final semesters = LocalSemesterService.recentSemesters();
    final current = LocalSemesterService.currentSemester();
    if (!semesters.contains(current)) {
      semesters.add(current);
    }
    return semesters;
  }

  bool _isActiveRequest(int version) {
    return !isClosed && version == _requestVersion;
  }
}
