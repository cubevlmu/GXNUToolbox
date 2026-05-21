import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/data/model/exam.dart';
import 'package:class_tool/data/repo/repo_request_helper.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:get/get.dart';

class ExamRepo {
  ExamRepo({UserRepo? userRepo})
    : _helper = RepoRequestHelper(
        userRepo: userRepo ?? Get.find<UserRepo>(),
        logTag: 'ExamRepo',
      );

  final RepoRequestHelper _helper;
  final Map<String, Future<ExamQueryResponse>> _pageTasks = {};
  final Map<String, Future<List<ExamBatchOption>>> _batchTasks = {};
  final Map<String, List<ExamBatchOption>> _batchCache = {};
  Future<ExamFilterOptions>? _filterOptionsTask;
  ExamFilterOptions? _filterOptions;

  Future<ExamFilterOptions> fetchFilterOptions() {
    final cached = _filterOptions;
    if (cached != null) {
      return Future<ExamFilterOptions>.value(cached);
    }

    final activeTask = _filterOptionsTask;
    if (activeTask != null) {
      return activeTask;
    }

    final task = _helper.runWithLoginRetry(
      'fetch exam filter options',
      Api.getExamFilterOptions,
    ).then((options) {
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

  Future<List<ExamBatchOption>> fetchBatches({
    required String semester,
    bool forceRefresh = false,
  }) {
    if (!forceRefresh) {
      final cached = _batchCache[semester];
      if (cached != null) {
        return Future<List<ExamBatchOption>>.value(cached);
      }
    }

    return _helper.dedupe(_batchTasks, semester, () {
      return _helper.runWithLoginRetry(
        'fetch exam batches',
        () => Api.getExamBatches(semester: semester),
      ).then((batches) {
        _batchCache[semester] = batches;
        return batches;
      });
    });
  }

  Future<ExamQueryResponse> fetchPage({
    required String semester,
    required String pcid,
    int page = 1,
    String sort = 'zwh asc,id',
    String order = 'asc',
  }) {
    final key = '$semester|$pcid|$page|$sort|$order';
    return _helper.dedupe(_pageTasks, key, () {
      return _helper.runWithLoginRetry(
        'fetch exam page',
        () => Api.getExamList(
          semester: semester,
          pcid: pcid,
          page: page,
          sort: sort,
          order: order,
        ),
      );
    });
  }
}
