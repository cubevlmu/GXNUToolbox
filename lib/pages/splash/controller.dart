import 'package:class_tool/constant.dart';
import 'package:class_tool/data/repo/today_courses_widget_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/data/services/app_update_service.dart';
import 'package:class_tool/pages/login/view.dart';
import 'package:class_tool/pages/main/view.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gx_update_client/gx_update_client.dart';

/// 启动页阶段。
///
/// 更新检查放在登录状态同步之前，避免旧版本继续进入主流程。
enum SplashStage {
  checkingUpdate,
  updateAvailable,
  forceUpdate,
  downloadingUpdate,
  updateBlocked,
  checkingNetwork,
  syncingLogin,
  offlineAvailable,
  syncFailed,
}

class SplashController extends GetxController {
  SplashController({UserRepo? userRepo})
    : _userRepo = userRepo ?? Get.find<UserRepo>();

  final UserRepo _userRepo;
  final Rx<SplashStage> stage = SplashStage.checkingUpdate.obs;
  final RxString message = '正在检查应用版本'.obs;

  final RxString updateTitle = ''.obs;
  final RxString updateVersion = ''.obs;
  final RxString updateChangelog = ''.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxBool hasPendingUpdate = false.obs;

  bool _hasStoredLogin = false;
  bool _checking = false;
  UpdateInfo? _pendingUpdate;

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
      case SplashStage.updateBlocked:
      case SplashStage.forceUpdate:
      case SplashStage.updateAvailable:
        await _start();
        return;
      case SplashStage.checkingUpdate:
      case SplashStage.downloadingUpdate:
      case SplashStage.checkingNetwork:
      case SplashStage.syncingLogin:
      case SplashStage.offlineAvailable:
        await _start();
        return;
    }
  }

  Future<void> downloadUpdate() async {
    final update = _pendingUpdate;
    if (update == null || !update.available) {
      await _start();
      return;
    }

    stage.value = SplashStage.downloadingUpdate;
    downloadProgress.value = 0;
    message.value = '正在下载更新包';

    try {
      await AppUpdateService.downloadAndInstall(
        update,
        onProgress: (progress) {
          final fraction = progress.fraction;
          if (fraction == null) {
            message.value = '正在下载更新包';
            return;
          }
          final normalized = fraction.clamp(0.0, 1.0);
          downloadProgress.value = normalized;
          message.value = '正在下载更新包 ${(normalized * 100).toStringAsFixed(0)}%';
        },
      );

      message.value = '安装界面已打开，请按系统提示完成安装';
      stage.value = update.isForce
          ? SplashStage.forceUpdate
          : SplashStage.updateAvailable;
    } on AppUpdateInstallPermissionRequiredException {
      message.value = '请先允许本应用安装未知来源应用，然后返回点击立即更新';
      stage.value = update.isForce
          ? SplashStage.forceUpdate
          : SplashStage.updateAvailable;
    } catch (e, s) {
      LogUtil.errorE('[SplashController] update download/install failed', e, s);
      message.value = '更新包下载或校验失败，请重试';
      stage.value = update.isForce
          ? SplashStage.forceUpdate
          : SplashStage.updateAvailable;
    }
  }

  Future<void> skipUpdate() async {
    final update = _pendingUpdate;
    if (update != null && update.isForce) {
      return;
    }
    await _continueStartup();
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
      _clearPendingUpdate();
      final canContinue = await _checkUpdateGate();
      if (!canContinue) {
        return;
      }
      await _continueStartup();
    } finally {
      _checking = false;
    }
  }

  Future<bool> _checkUpdateGate() async {
    if (!AppUpdateService.isSupported) {
      return true;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // 无网络时不在这里拦截，交给原有离线模式逻辑处理。
      return true;
    }

    stage.value = SplashStage.checkingUpdate;
    message.value = '正在检查应用版本';

    try {
      final response = await AppUpdateService.check();

      LogUtil.info(
        '[SplashController] update check result: '
        'legal.allowed=${response.legal.allowed}, '
        'legal.code=${response.legal.code}, '
        'update.available=${response.update.available}, '
        'update.version=${response.update.version}, '
        'update.versionCode=${response.update.versionCode}',
      );

      if (!response.legal.allowed) {
        _setPendingUpdate(response.update);
        stage.value = SplashStage.updateBlocked;
        message.value = response.legal.message.trim().isEmpty
            ? '当前版本已停止支持，请更新后继续使用'
            : response.legal.message.trim();
        return false;
      }

      if (response.update.available) {
        _setPendingUpdate(response.update);
        if (response.update.isForce) {
          stage.value = SplashStage.forceUpdate;
          message.value = '当前版本需要更新后才能继续使用';
          return false;
        }

        if (AppUpdateService.startupOptionalUpdatePromptEnabled) {
          stage.value = SplashStage.updateAvailable;
          message.value = '发现新版本，建议更新后使用';
          return false;
        }

        LogUtil.info(
          '[SplashController] optional update prompt disabled, continue startup',
        );
        _clearPendingUpdate();
        return true;
      }

      return true;
    } catch (e, s) {
      LogUtil.errorE('[SplashController] update check failed', e, s);
      if (AppConstants.updateBlockOnCheckFailure) {
        stage.value = SplashStage.updateBlocked;
        message.value = '无法完成版本校验，请检查网络后重试';
        return false;
      }
      return true;
    }
  }

  Future<void> _continueStartup() async {
    _hasStoredLogin = _userRepo.storage.hasLogin;
    if (!_hasStoredLogin) {
      LogUtil.info('[SplashController] no stored login, go to login page');
      _navigateToLogin();
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

  Future<void> _retryLoginSync() async {
    _hasStoredLogin = _userRepo.storage.hasLogin;
    if (!_hasStoredLogin) {
      LogUtil.info('[SplashController] retry skipped because no stored login');
      _navigateToLogin();
      return;
    }

    stage.value = SplashStage.syncingLogin;
    message.value = '正在重新尝试登录';

    try {
      final success = await _userRepo.retryLoginSync();
      if (success) {
        LogUtil.info('[SplashController] retry login synced, go to main page');
        _navigateToMain();
        return;
      }

      stage.value = SplashStage.syncFailed;
      message.value = '重新尝试登录失败，请重试或重新登录';
    } catch (e, s) {
      LogUtil.errorE('[SplashController] retry login failed', e, s);
      stage.value = SplashStage.syncFailed;
      message.value = '重新尝试登录失败，请重试或重新登录';
    }
  }

  void _setPendingUpdate(UpdateInfo update) {
    if (!update.available) {
      _clearPendingUpdate();
      return;
    }

    _pendingUpdate = update;
    hasPendingUpdate.value = true;
    updateTitle.value = update.title.trim().isEmpty
        ? '发现新版本'
        : update.title.trim();
    updateVersion.value = update.version.trim().isEmpty
        ? '版本号 ${update.versionCode}'
        : 'v${update.version} (${update.versionCode})';
    updateChangelog.value = update.changelog.trim();
  }

  void _clearPendingUpdate() {
    _pendingUpdate = null;
    hasPendingUpdate.value = false;
    updateTitle.value = '';
    updateVersion.value = '';
    updateChangelog.value = '';
    downloadProgress.value = 0;
  }

  void _navigateToMain() async {
    LogUtil.info('[Splash] Init courses repo.');
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
