import 'package:class_tool/data/repo/bell_schedule_repo.dart';
import 'package:class_tool/data/repo/attendance_repo.dart';
import 'package:class_tool/data/repo/class_repo.dart';
import 'package:class_tool/data/local/app_database.dart';
import 'package:class_tool/data/repo/course_note_repo.dart';
import 'package:class_tool/data/repo/course_plan_repo.dart';
import 'package:class_tool/data/repo/credit_repo.dart';
import 'package:class_tool/data/repo/exam_repo.dart';
import 'package:class_tool/data/repo/grade_repo.dart';
import 'package:class_tool/data/repo/notification_repo.dart';
import 'package:class_tool/data/repo/school_calendar_repo.dart';
import 'package:class_tool/data/repo/selected_course_repo.dart';
import 'package:class_tool/data/repo/student_repo.dart';
import 'package:class_tool/data/repo/today_courses_widget_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/data/services/debug_time_service.dart';
import 'package:get/get.dart';

class Injector {
  Injector._();

  static void injectRepos() {
    if (!Get.isRegistered<UserRepo>()) {
      final userRepo = UserRepo();
      final appDatabase = AppDatabase();
      final classRepo = ClassRepo(userRepo: userRepo);
      final bellScheduleRepo = BellScheduleRepo(userRepo: userRepo);
      Get.put<AppDatabase>(appDatabase, permanent: true);
      Get.put<DebugTimeService>(DebugTimeService(), permanent: true);
      Get.put<UserRepo>(userRepo, permanent: true);
      Get.put<CourseNoteRepo>(
        CourseNoteRepo(database: appDatabase),
        permanent: true,
      );
      Get.put<AttendanceRepo>(
        AttendanceRepo(database: appDatabase),
        permanent: true,
      );
      Get.put<ClassRepo>(classRepo, permanent: true);
      Get.put<GradeRepo>(GradeRepo(userRepo: userRepo), permanent: true);
      Get.put<ExamRepo>(ExamRepo(userRepo: userRepo), permanent: true);
      Get.put<NotificationRepo>(
        NotificationRepo(userRepo: userRepo),
        permanent: true,
      );
      Get.put<SchoolCalendarRepo>(
        SchoolCalendarRepo(userRepo: userRepo),
        permanent: true,
      );
      Get.put<SelectedCourseRepo>(
        SelectedCourseRepo(userRepo: userRepo),
        permanent: true,
      );
      Get.put<CreditRepo>(CreditRepo(userRepo: userRepo), permanent: true);
      Get.put<CoursePlanRepo>(
        CoursePlanRepo(userRepo: userRepo),
        permanent: true,
      );
      Get.put<StudentRepo>(StudentRepo(userRepo: userRepo), permanent: true);
      Get.put<BellScheduleRepo>(bellScheduleRepo, permanent: true);
      Get.put<TodayCoursesWidgetRepo>(
        TodayCoursesWidgetRepo(
          userRepo: userRepo,
          classRepo: classRepo,
          bellScheduleRepo: bellScheduleRepo,
        ),
        permanent: true,
      );
      return;
    }

    if (!Get.isRegistered<ClassRepo>()) {
      Get.put<ClassRepo>(
        ClassRepo(userRepo: Get.find<UserRepo>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<AppDatabase>()) {
      Get.put<AppDatabase>(AppDatabase(), permanent: true);
    }

    if (!Get.isRegistered<DebugTimeService>()) {
      Get.put<DebugTimeService>(DebugTimeService(), permanent: true);
    }

    if (!Get.isRegistered<CourseNoteRepo>()) {
      Get.put<CourseNoteRepo>(
        CourseNoteRepo(database: Get.find<AppDatabase>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<AttendanceRepo>()) {
      Get.put<AttendanceRepo>(
        AttendanceRepo(database: Get.find<AppDatabase>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<GradeRepo>()) {
      Get.put<GradeRepo>(
        GradeRepo(userRepo: Get.find<UserRepo>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<ExamRepo>()) {
      Get.put<ExamRepo>(
        ExamRepo(userRepo: Get.find<UserRepo>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<CreditRepo>()) {
      Get.put<CreditRepo>(
        CreditRepo(userRepo: Get.find<UserRepo>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<NotificationRepo>()) {
      Get.put<NotificationRepo>(
        NotificationRepo(userRepo: Get.find<UserRepo>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<SchoolCalendarRepo>()) {
      Get.put<SchoolCalendarRepo>(
        SchoolCalendarRepo(userRepo: Get.find<UserRepo>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<SelectedCourseRepo>()) {
      Get.put<SelectedCourseRepo>(
        SelectedCourseRepo(userRepo: Get.find<UserRepo>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<CoursePlanRepo>()) {
      Get.put<CoursePlanRepo>(
        CoursePlanRepo(userRepo: Get.find<UserRepo>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<StudentRepo>()) {
      Get.put<StudentRepo>(
        StudentRepo(userRepo: Get.find<UserRepo>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<BellScheduleRepo>()) {
      Get.put<BellScheduleRepo>(
        BellScheduleRepo(userRepo: Get.find<UserRepo>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<TodayCoursesWidgetRepo>()) {
      Get.put<TodayCoursesWidgetRepo>(
        TodayCoursesWidgetRepo(
          userRepo: Get.find<UserRepo>(),
          classRepo: Get.find<ClassRepo>(),
          bellScheduleRepo: Get.find<BellScheduleRepo>(),
        ),
        permanent: true,
      );
    }
  }
}
