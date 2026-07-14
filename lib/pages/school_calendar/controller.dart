import 'package:class_tool/data/model/school_calendar.dart';
import 'package:class_tool/data/repo/school_calendar_repo.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:get/get.dart';

class SchoolCalendarController extends GetxController {
  SchoolCalendarController({SchoolCalendarRepo? schoolCalendarRepo})
    : _schoolCalendarRepo =
          schoolCalendarRepo ?? Get.find<SchoolCalendarRepo>();

  final SchoolCalendarRepo _schoolCalendarRepo;

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxString _selectedSemester = ''.obs;
  final RxList<String> _semesterOptions = <String>[].obs;
  final Rxn<SchoolCalendarResponse> _calendar = Rxn<SchoolCalendarResponse>();
  int _requestVersion = 0;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  String get selectedSemester => _selectedSemester.value;
  List<String> get semesterOptions => _semesterOptions;
  SchoolCalendarResponse? get calendar => _calendar.value;
  List<SchoolCalendarWeekRow> get rows => _calendar.value?.rows ?? const [];
  bool get hasData => rows.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _semesterOptions.assignAll(_schoolCalendarRepo.buildSemesterOptions());
    _selectedSemester.value = _schoolCalendarRepo.computeSemester();
    if (!_semesterOptions.contains(_selectedSemester.value)) {
      _semesterOptions.insert(0, _selectedSemester.value);
    }
    Future<void>.microtask(refresh);
  }

  Future<void> selectSemester(String semester) async {
    if (semester.isEmpty || semester == _selectedSemester.value) {
      return;
    }
    _selectedSemester.value = semester;
    await refresh();
  }

  @override
  Future<void> refresh() async {
    final semester = _selectedSemester.value;
    if (semester.isEmpty) {
      return;
    }

    final version = ++_requestVersion;
    _isLoading.value = true;
    _error.value = '';
    update(<Object>['school-calendar-content']);

    try {
      final response = await _schoolCalendarRepo.fetchCalendar(
        semester: semester,
      );
      if (!_isActiveRequest(version)) {
        return;
      }
      _calendar.value = response;
      _error.value = '';
      LogUtil.info(
        '[SchoolCalendarController] refresh success semester=$semester rows=${response.rows.length}',
      );
    } catch (e, s) {
      if (!_isActiveRequest(version)) {
        return;
      }
      _error.value = e.toString();
      LogUtil.errorE('[SchoolCalendarController] refresh failed', e, s);
    } finally {
      if (_isActiveRequest(version)) {
        _isLoading.value = false;
        update(<Object>['school-calendar-content']);
      }
    }
  }

  Map<String, List<SchoolCalendarWeekRow>> rowsByMonth() {
    final grouped = <String, List<SchoolCalendarWeekRow>>{};
    for (final row in rows) {
      final key = row.monthText.isEmpty ? '未分组' : row.monthText;
      grouped.putIfAbsent(key, () => <SchoolCalendarWeekRow>[]).add(row);
    }
    return grouped;
  }

  bool _isActiveRequest(int version) {
    return !isClosed && version == _requestVersion;
  }
}
