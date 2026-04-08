import 'package:class_tool/data/repo/class_repo.dart';
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
      Get.put<TodayCoursesWidgetRepo>(
        TodayCoursesWidgetRepo(userRepo: userRepo, classRepo: classRepo),
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

    if (!Get.isRegistered<TodayCoursesWidgetRepo>()) {
      Get.put<TodayCoursesWidgetRepo>(
        TodayCoursesWidgetRepo(
          userRepo: Get.find<UserRepo>(),
          classRepo: Get.find<ClassRepo>(),
        ),
        permanent: true,
      );
    }
  }
}
