import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/data/model/grade.dart';
import 'package:class_tool/data/repo/repo_request_helper.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:get/get.dart';

class GradeRepo {
  GradeRepo({UserRepo? userRepo})
    : _helper = RepoRequestHelper(
        userRepo: userRepo ?? Get.find<UserRepo>(),
        logTag: 'GradeRepo',
      );

  final RepoRequestHelper _helper;
  final Map<String, Future<GradeQueryResponse>> _pageTasks = {};
  Future<GradeFilterOptions>? _filterOptionsTask;
  Future<GradeRankResponse>? _rankTask;
  GradeFilterOptions? _filterOptions;

  Future<GradeQueryResponse> fetchPage({
    String startSemester = '001',
    String endSemester = '001',
    int page = 1,
    int pageSize = 20,
    String passStatus = '',
    String courseNature = '',
    String courseType = '',
    String retakeFlag = '',
    String showFollowed = '1',
    String courseAttribution = '',
    String sort = 'kcmc asc,id',
    String order = 'asc',
  }) {
    final key = [
      startSemester,
      endSemester,
      page,
      pageSize,
      passStatus,
      courseNature,
      courseType,
      retakeFlag,
      showFollowed,
      courseAttribution,
      sort,
      order,
    ].join('|');

    return _helper.dedupe(_pageTasks, key, () {
      return _helper.runWithLoginRetry(
        'fetch grade page',
        () => Api.getGradeList(
          startSemester: startSemester,
          endSemester: endSemester,
          page: page,
          pageSize: pageSize,
          passStatus: passStatus,
          courseNature: courseNature,
          courseType: courseType,
          retakeFlag: retakeFlag,
          showFollowed: showFollowed,
          courseAttribution: courseAttribution,
          sort: sort,
          order: order,
        ),
      );
    });
  }

  Future<GradeFilterOptions> fetchFilterOptions() {
    final cached = _filterOptions;
    if (cached != null) {
      return Future<GradeFilterOptions>.value(cached);
    }

    final activeTask = _filterOptionsTask;
    if (activeTask != null) {
      return activeTask;
    }

    final task = _helper
        .runWithLoginRetry(
          'fetch grade filter options',
          Api.getGradeFilterOptions,
        )
        .then((options) {
          _filterOptions = options;
          return options;
        });
    _filterOptionsTask = task;
    return task.whenComplete(() {
      if (identical(_filterOptionsTask, task)) {
        _filterOptionsTask = null;
      }
    });
  }

  Future<GradeRankResponse> fetchRank() {
    final activeTask = _rankTask;
    if (activeTask != null) {
      return activeTask;
    }

    final task = _helper.runWithLoginRetry(
      'fetch grade rank',
      Api.getGradeRank,
    );
    _rankTask = task;
    return task.whenComplete(() {
      if (identical(_rankTask, task)) {
        _rankTask = null;
      }
    });
  }
}
