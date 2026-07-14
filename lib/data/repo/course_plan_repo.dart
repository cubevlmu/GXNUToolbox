import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/data/model/course_plan.dart';
import 'package:class_tool/data/repo/repo_request_helper.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:get/get.dart';

class CoursePlanRepo {
  CoursePlanRepo({UserRepo? userRepo})
    : _helper = RepoRequestHelper(
        userRepo: userRepo ?? Get.find<UserRepo>(),
        logTag: 'CoursePlanRepo',
      );

  final RepoRequestHelper _helper;
  final Map<String, Future<CoursePlanResponse>> _tasks = {};

  Future<CoursePlanResponse> fetchPlan({String semester = ''}) {
    return _helper.dedupe(_tasks, semester, () {
      return _helper.runWithLoginRetry(
        'fetch course plan',
        () => Api.getCoursePlanList(semester: semester),
      );
    });
  }
}
