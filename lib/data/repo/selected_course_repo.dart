import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/data/model/selected_course.dart';
import 'package:class_tool/data/repo/repo_request_helper.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:get/get.dart';

class SelectedCourseRepo {
  SelectedCourseRepo({UserRepo? userRepo})
    : _helper = RepoRequestHelper(
        userRepo: userRepo ?? Get.find<UserRepo>(),
        logTag: 'SelectedCourseRepo',
      );

  final RepoRequestHelper _helper;
  final Map<String, Future<SelectedCourseQueryResponse>> _pageTasks = {};

  Future<SelectedCourseQueryResponse> fetchPage({
    int page = 1,
    int pageSize = 20,
    String semester = '',
  }) {
    final key = '$semester|$page|$pageSize';
    return _helper.dedupe(_pageTasks, key, () {
      return _helper.runWithLoginRetry(
        'fetch selected course page',
        () => Api.getSelectedCourseList(
          page: page,
          pageSize: pageSize,
          semester: semester,
        ),
      );
    });
  }
}
