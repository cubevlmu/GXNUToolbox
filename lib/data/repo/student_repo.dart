import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/data/model/student_info.dart';
import 'package:class_tool/data/repo/repo_request_helper.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:get/get.dart';

class StudentRepo {
  StudentRepo({UserRepo? userRepo})
    : _helper = RepoRequestHelper(
        userRepo: userRepo ?? Get.find<UserRepo>(),
        logTag: 'StudentRepo',
      );

  final RepoRequestHelper _helper;
  Future<StudentInfo>? _infoTask;

  Future<StudentInfo> fetchInfo() {
    final activeTask = _infoTask;
    if (activeTask != null) {
      return activeTask;
    }

    final task = _helper.runWithLoginRetry(
      'fetch student info',
      Api.getStudentInfo,
    );
    _infoTask = task;
    return task.whenComplete(() {
      if (identical(_infoTask, task)) {
        _infoTask = null;
      }
    });
  }
}
