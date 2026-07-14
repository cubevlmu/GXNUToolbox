import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/data/model/credit_progress.dart';
import 'package:class_tool/data/repo/repo_request_helper.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:get/get.dart';

class CreditRepo {
  CreditRepo({UserRepo? userRepo})
    : _helper = RepoRequestHelper(
        userRepo: userRepo ?? Get.find<UserRepo>(),
        logTag: 'CreditRepo',
      );

  final RepoRequestHelper _helper;
  final Map<String, Future<CreditProgressResponse>> _tasks = {};

  Future<CreditProgressResponse> fetchProgress({String semester = ''}) {
    return _helper.dedupe(_tasks, semester, () {
      return _helper.runWithLoginRetry(
        'fetch credit progress',
        () => Api.getCreditProgress(semester: semester),
      );
    });
  }
}
