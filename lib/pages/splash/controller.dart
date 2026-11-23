import 'dart:async';

import 'package:class_tool/data/repo/today_courses_widget_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/pages/login/view.dart';
import 'package:class_tool/pages/main/view.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// 启动页阶段。
enum SplashStage {
  checkingNetwork,
  syncingLogin,
  offlineAvailable,
  loginRateLimited,
  syncFailed,
}

class SplashController extends GetxController {
  SplashController({UserRepo? userRepo})
    : _userRepo = userRepo ?? Get.find<UserRepo>();

  final UserRepo _userRepo;
  final Rx<SplashStage> stage = SplashStage.checkingNetwork.obs;
  final RxString message = '正在准备启动'.obs;

  bool _hasStoredLogin = false;
  bool _checking = false;

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  Future<void> retry() async {
    if (_checking) {
      return;
    }

    switch (stage.value) {
      case SplashStage.syncFailed:
        await _retryLoginSync();
        return;
      case SplashStage.loginRateLimited:
        await _retryAutoLoginAfterRateLimit();
        return;
      case SplashStage.checkingNetwork:
      case SplashStage.syncingLogin:
      case SplashStage.offlineAvailable:
        await _start();
        return;
    }
  }

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
    if (_checking) {
      return;
    }

    _checking = true;
    try {
      await _continueStartup();
    } finally {
      _checking = false;
    }
  }

  Future<void> _continueStartup() async {
    _hasStoredLogin = _userRepo.storage.hasLogin;
    if (!_hasStoredLogin) {
      LogUtil.info('[SplashController] no stored login, go to login page');
      _navigateToLogin();
      return;
    }

    if (_userRepo.state == UserRepoState.expired &&
        _userRepo.lastLoginRateLimited) {
      _showLoginFailureStage();
      return;
    }

    if (_userRepo.isLogin &&
        !_userRepo.isOfflineMode &&
        _userRepo.pageContext != null) {
      LogUtil.info(
        '[SplashController] reuse in-memory login context, go to main page',
      );
      _navigateToMain();
      return;
    }

    _setStartupStage(SplashStage.checkingNetwork, '正在检查网络连接');

    final connectivityResults = await Connectivity().checkConnectivity();
    if (!connectivityResults.any((r) => r != ConnectivityResult.none)) {
      LogUtil.warn('[SplashController] offline detected');
      _setStartupStage(SplashStage.offlineAvailable, '当前无网络连接，可重试或进入离线模式');
      return;
    }

    _setStartupStage(SplashStage.syncingLogin, '正在同步登录状态');

    try {
      await _userRepo.setup();
      if (_userRepo.isLogin) {
        LogUtil.info('[SplashController] login state synced, go to main page');
        _navigateToMain();
        return;
      }

      if (_hasStoredLogin) {
        _showLoginFailureStage();
        return;
      }

      _navigateToLogin();
    } catch (e, s) {
      LogUtil.errorE('[SplashController] startup sync failed', e, s);
      _setStartupStage(SplashStage.syncFailed, '同步登录状态失败，请重试或重新登录');
    }
  }

  Future<void> _retryAutoLoginAfterRateLimit() async {
    _setStartupStage(SplashStage.syncingLogin, '正在重新尝试自动登录');

    try {
      final success = await _userRepo.retryAutoRelogin();
      if (success) {
        LogUtil.info(
          '[SplashController] rate-limited auto login retry succeeded',
        );
        _navigateToMain();
        return;
      }

      _showLoginFailureStage(retrying: true);
    } catch (e, s) {
      LogUtil.errorE(
        '[SplashController] rate-limited auto login retry failed',
        e,
        s,
      );
      _showLoginFailureStage(retrying: true);
    }
  }

  Future<void> _retryLoginSync() async {
    _hasStoredLogin = _userRepo.storage.hasLogin;
    if (!_hasStoredLogin) {
      LogUtil.info('[SplashController] retry skipped because no stored login');
      _navigateToLogin();
      return;
    }

    _setStartupStage(SplashStage.syncingLogin, '正在重新尝试登录');

    try {
      final success = await _userRepo.retryLoginSync();
      if (success) {
        LogUtil.info('[SplashController] retry login synced, go to main page');
        _navigateToMain();
        return;
      }

      _showLoginFailureStage(retrying: true);
    } catch (e, s) {
      LogUtil.errorE('[SplashController] retry login failed', e, s);
      _setStartupStage(SplashStage.syncFailed, '重新尝试登录失败，请重试或重新登录');
    }
  }

  void _showLoginFailureStage({bool retrying = false}) {
    if (_userRepo.lastLoginRateLimited) {
      _setStartupStage(
        SplashStage.loginRateLimited,
        '学校服务器请求过于频繁（429）。请稍后再手动重试自动登录，已保存的登录信息不会被清除。',
      );
      return;
    }

    _setStartupStage(
      SplashStage.syncFailed,
      retrying ? '重新尝试登录失败，请重试或重新登录' : '同步登录状态失败，请重试或重新登录',
    );
  }

  void _setStartupStage(SplashStage nextStage, String nextMessage) {
    stage.value = nextStage;
    message.value = nextMessage;
  }

  void _navigateToMain() async {
    LogUtil.info('[Splash] Init courses repo.');
    await Get.find<TodayCoursesWidgetRepo>().initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAll(() => const MainPage());
    });
  }

  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAll(() => const LoginPage());
    });
  }
}
