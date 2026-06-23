import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/data/model/school_calendar.dart';
import 'package:class_tool/data/repo/repo_request_helper.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/data/services/local_semester_service.dart';
import 'package:get/get.dart';

class SchoolCalendarRepo {
  SchoolCalendarRepo({UserRepo? userRepo})
    : _helper = RepoRequestHelper(
        userRepo: userRepo ?? Get.find<UserRepo>(),
        logTag: 'SchoolCalendarRepo',
      );

  final RepoRequestHelper _helper;
  final Map<String, Future<SchoolCalendarResponse>> _semesterTasks = {};

  String computeSemester() {
    return LocalSemesterService.currentSemester();
  }

  List<String> buildSemesterOptions() {
    return LocalSemesterService.recentSemesters();
  }

  Future<SchoolCalendarResponse> fetchCalendar({required String semester}) {
    return _helper.dedupe(_semesterTasks, semester, () {
      return _helper.runWithLoginRetry(
        'fetch school calendar',
        () => Api.getSchoolCalendar(semester: semester),
      );
    });
  }
}
