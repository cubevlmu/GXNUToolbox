import 'package:class_tool/data/repo/class_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:get/get.dart';

class Injector {
  Injector._();

  static void injectRepos() {
    if (!Get.isRegistered<UserRepo>()) {
      final userRepo = UserRepo();
      Get.put<UserRepo>(userRepo, permanent: true);
      Get.put<ClassRepo>(ClassRepo(userRepo: userRepo), permanent: true);
      return;
    }

    if (!Get.isRegistered<ClassRepo>()) {
      Get.put<ClassRepo>(
        ClassRepo(userRepo: Get.find<UserRepo>()),
        permanent: true,
      );
    }
  }
}
