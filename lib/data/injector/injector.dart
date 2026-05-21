import 'package:class_tool/data/repo/bell_schedule_repo.dart';
import 'package:class_tool/data/repo/class_repo.dart';
import 'package:class_tool/data/repo/course_plan_repo.dart';
import 'package:class_tool/data/repo/credit_repo.dart';
import 'package:class_tool/data/repo/exam_repo.dart';
import 'package:class_tool/data/repo/grade_repo.dart';
import 'package:class_tool/data/repo/student_repo.dart';
import 'package:class_tool/data/repo/today_courses_widget_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:get/get.dart';

class Injector {
  Injector._();

  static void injectRepos() {
    if (!Get.isRegistered<UserRepo>()) {
      final userRepo = UserRepo();
      final classRepo = ClassRepo(userRepo: userRepo);
      Get.put<UserRepo>(userRepo, permanent: true);
      Get.put<ClassRepo>(classRepo, permanent: true);
      Get.put<GradeRepo>(GradeRepo(userRepo: userRepo), permanent: true);
      Get.put<ExamRepo>(ExamRepo(userRepo: userRepo), permanent: true);
      Get.put<CreditRepo>(CreditRepo(userRepo: userRepo), permanent: true);
      Get.put<CoursePlanRepo>(
        CoursePlanRepo(userRepo: userRepo),
        permanent: true,
      );
      Get.put<StudentRepo>(StudentRepo(userRepo: userRepo), permanent: true);
      Get.put<TodayCoursesWidgetRepo>(
        TodayCoursesWidgetRepo(userRepo: userRepo, classRepo: classRepo),
        permanent: true,
      );
      Get.put<BellScheduleRepo>(
        BellScheduleRepo(userRepo: userRepo),
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

    if (!Get.isRegistered<TodayCoursesWidgetRepo>()) {
      Get.put<TodayCoursesWidgetRepo>(
        TodayCoursesWidgetRepo(
          userRepo: Get.find<UserRepo>(),
          classRepo: Get.find<ClassRepo>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<BellScheduleRepo>()) {
      Get.put<BellScheduleRepo>(
        BellScheduleRepo(userRepo: Get.find<UserRepo>()),
        permanent: true,
      );
    }
  }
}
