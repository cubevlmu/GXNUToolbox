import 'dart:async';

import 'package:class_tool/data/repo/today_courses_widget_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/data/services/app_update_service.dart';
import 'package:class_tool/pages/login/view.dart';
import 'package:class_tool/pages/main/view.dart';
import 'package:class_tool/widgets/app_update_prompt.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gx_update_client/gx_update_client.dart';

/// 启动页阶段。
///
/// 更新检查与登录状态同步并行执行，避免非关键版本校验拖慢启动。
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
  final Rx<SplashStage> stage = SplashStage.checkingNetwork.obs;
  final RxString message = '正在准备启动'.obs;

  final RxString updateTitle = ''.obs;
  final RxString updateVersion = ''.obs;
  final RxString updateChangelog = ''.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxBool hasPendingUpdate = false.obs;

  bool _hasStoredLogin = false;
  bool _checking = false;
  bool _navigated = false;
  bool _updateBlocksStartup = false;
  SplashStage _activeStartupStage = SplashStage.checkingNetwork;
  String _activeStartupMessage = '正在准备启动';
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

    _updateBlocksStartup = true;
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
    _updateBlocksStartup = false;
    _clearPendingUpdate();
    if (_checking) {
      _restoreStartupStage();
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
    _navigated = false;
    _updateBlocksStartup = false;
    try {
      _clearPendingUpdate();
      _startUpdateCheckInBackground();
      await _continueStartup();
    } finally {
      _checking = false;
    }
  }

  void _startUpdateCheckInBackground() {
    unawaited(_checkUpdateInBackground());
  }

  Future<void> _checkUpdateInBackground() async {
    if (!AppUpdateService.isSupported) {
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      LogUtil.info(
        '[SplashController] skip startup update check because network is unavailable',
      );
      return;
    }

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

      _handleUpdateCheckResponse(response);
    } catch (e, s) {
      LogUtil.errorE('[SplashController] background update check failed', e, s);
    }
  }

  void _handleUpdateCheckResponse(CheckUpdateResponse response) {
    if (!response.legal.allowed) {
      _updateBlocksStartup = true;
      _setPendingUpdate(response.update);
      final text = response.legal.message.trim().isEmpty
          ? '当前版本已停止支持，请更新后继续使用'
          : response.legal.message.trim();
      if (_navigated) {
        _showUpdatePromptAfterNavigation(response);
        return;
      }
      stage.value = SplashStage.updateBlocked;
      message.value = text;
      return;
    }

    if (response.update.available) {
      _setPendingUpdate(response.update);
      if (response.update.isForce) {
        _updateBlocksStartup = true;
        if (_navigated) {
          _showUpdatePromptAfterNavigation(response);
          return;
        }
        stage.value = SplashStage.forceUpdate;
        message.value = '当前版本需要更新后才能继续使用';
        return;
      }

      if (!AppUpdateService.startupOptionalUpdatePromptEnabled) {
        LogUtil.info(
          '[SplashController] optional update prompt disabled, continue startup',
        );
        _clearPendingUpdate();
        return;
      }

      if (_navigated) {
        _showUpdatePromptAfterNavigation(response);
        return;
      }

      if (_isStartupBusyStage(stage.value)) {
        stage.value = SplashStage.updateAvailable;
        message.value = '发现新版本，建议更新后使用';
      }
      return;
    }

    _clearPendingUpdate();
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

    _setStartupStage(SplashStage.checkingNetwork, '正在检查网络连接');

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      LogUtil.warn('[SplashController] offline detected');
      _setStartupStage(
        SplashStage.offlineAvailable,
        '当前无网络连接，可重试或进入离线模式',
        force: true,
      );
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
        _setStartupStage(
          SplashStage.syncFailed,
          '同步登录状态失败，请重试或重新登录',
          force: true,
        );
        return;
      }

      _navigateToLogin();
    } catch (e, s) {
      LogUtil.errorE('[SplashController] startup sync failed', e, s);
      _setStartupStage(
        SplashStage.syncFailed,
        '同步登录状态失败，请重试或重新登录',
        force: true,
      );
    }
  }

  Future<void> _retryLoginSync() async {
    _hasStoredLogin = _userRepo.storage.hasLogin;
    if (!_hasStoredLogin) {
      LogUtil.info('[SplashController] retry skipped because no stored login');
      _navigateToLogin();
      return;
    }

    _setStartupStage(SplashStage.syncingLogin, '正在重新尝试登录', force: true);

    try {
      final success = await _userRepo.retryLoginSync();
      if (success) {
        LogUtil.info('[SplashController] retry login synced, go to main page');
        _navigateToMain();
        return;
      }

      _setStartupStage(
        SplashStage.syncFailed,
        '重新尝试登录失败，请重试或重新登录',
        force: true,
      );
    } catch (e, s) {
      LogUtil.errorE('[SplashController] retry login failed', e, s);
      _setStartupStage(
        SplashStage.syncFailed,
        '重新尝试登录失败，请重试或重新登录',
        force: true,
      );
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

  void _setStartupStage(
    SplashStage nextStage,
    String nextMessage, {
    bool force = false,
  }) {
    _activeStartupStage = nextStage;
    _activeStartupMessage = nextMessage;
    if (force || !_isUpdateForegroundStage(stage.value)) {
      stage.value = nextStage;
      message.value = nextMessage;
    }
  }

  void _restoreStartupStage() {
    stage.value = _activeStartupStage;
    message.value = _activeStartupMessage;
  }

  bool _isUpdateForegroundStage(SplashStage value) {
    return value == SplashStage.updateAvailable ||
        value == SplashStage.forceUpdate ||
        value == SplashStage.updateBlocked ||
        value == SplashStage.downloadingUpdate;
  }

  bool _isStartupBusyStage(SplashStage value) {
    return value == SplashStage.checkingUpdate ||
        value == SplashStage.checkingNetwork ||
        value == SplashStage.syncingLogin;
  }

  void _showUpdatePromptAfterNavigation(CheckUpdateResponse response) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = Get.overlayContext ?? Get.context;
      if (context == null) {
        return;
      }
      unawaited(
        AppUpdatePrompt.showResponse(
          context,
          response,
          showLatestToast: false,
          allowOptionalPrompt:
              AppUpdateService.startupOptionalUpdatePromptEnabled,
        ),
      );
    });
  }

  void _navigateToMain() async {
    if (_updateBlocksStartup) {
      LogUtil.warn('[SplashController] navigation blocked by update gate');
      return;
    }
    LogUtil.info('[Splash] Init courses repo.');
    await Get.find<TodayCoursesWidgetRepo>().initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_updateBlocksStartup) {
        LogUtil.warn(
          '[SplashController] pending main navigation cancelled by update gate',
        );
        return;
      }
      _navigated = true;
      if (!Get.isOverlaysOpen) {
        Get.offAll(() => const MainPage());
      } else {
        Get.offAll(() => const MainPage());
      }
    });
  }

  void _navigateToLogin() {
    if (_updateBlocksStartup) {
      LogUtil.warn(
        '[SplashController] login navigation blocked by update gate',
      );
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_updateBlocksStartup) {
        LogUtil.warn(
          '[SplashController] pending login navigation cancelled by update gate',
        );
        return;
      }
      _navigated = true;
      if (!Get.isOverlaysOpen) {
        Get.offAll(() => const LoginPage());
      } else {
        Get.offAll(() => const LoginPage());
      }
    });
  }
}
