import 'package:class_tool/data/repo/today_courses_widget_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/pages/login/view.dart';
import 'package:class_tool/pages/main/view.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

enum SplashStage { checkingNetwork, syncingLogin, offlineAvailable, syncFailed }

class SplashController extends GetxController {
  SplashController({UserRepo? userRepo})
    : _userRepo = userRepo ?? Get.find<UserRepo>();

  final UserRepo _userRepo;
  final Rx<SplashStage> stage = SplashStage.checkingNetwork.obs;
  final RxString message = '正在检查网络连接'.obs;

  bool _hasStoredLogin = false;

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  Future<void> retry() => _start();

  Future<void> goOffline() async {
    await _userRepo.restoreOfflineSession();
    if (_userRepo.isLogin) {
      _navigateToMain();
    } else {
      _navigateToLogin();
    }
  }

  void goLogin() {
    _navigateToLogin();
  }

  Future<void> _start() async {
    _hasStoredLogin = _userRepo.storage.hasLogin;
    if (!_hasStoredLogin) {
      LogUtil.info('[SplashController] no stored login, go to login page');
      _navigateToLogin();
      return;
    }

    stage.value = SplashStage.checkingNetwork;
    message.value = '正在检查网络连接';

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      LogUtil.warn('[SplashController] offline detected');
      stage.value = SplashStage.offlineAvailable;
      message.value = '当前无网络连接，可重试或进入离线模式';
      return;
    }

    stage.value = SplashStage.syncingLogin;
    message.value = '正在同步登录状态';

    try {
      await _userRepo.setup();
      if (_userRepo.isLogin) {
        LogUtil.info('[SplashController] login state synced, go to main page');
        _navigateToMain();
        return;
      }

      if (_hasStoredLogin) {
        stage.value = SplashStage.syncFailed;
        message.value = '同步登录状态失败，请重试或重新登录';
        return;
      }

      _navigateToLogin();
    } catch (e, s) {
      LogUtil.errorE('[SplashController] startup sync failed', e, s);
      stage.value = SplashStage.syncFailed;
      message.value = '同步登录状态失败，请重试或重新登录';
    }
  }

  void _navigateToMain() async {
    LogUtil.info("[Splash] Init courses repo.");
    await Get.find<TodayCoursesWidgetRepo>().initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isOverlaysOpen) {
        Get.offAll(() => const MainPage());
      } else {
        Get.offAll(() => const MainPage());
      }
    });
  }

  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isOverlaysOpen) {
        Get.offAll(() => const LoginPage());
      } else {
        Get.offAll(() => const LoginPage());
      }
    });
  }
}
