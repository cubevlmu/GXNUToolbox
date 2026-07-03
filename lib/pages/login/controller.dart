/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:class_tool/pages/splash/view.dart';
import 'package:fui/app_toast.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/shared_dialog.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final UserRepo _userRepo = Get.find<UserRepo>();

  String account = '';
  String password = '';
  final RxBool rememberLogin = true.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;

  bool get isInputEnabled => !isLoading.value;

  @override
  void onInit() {
    super.onInit();
    account = _userRepo.username;
    // rememberLogin.value = _userRepo.storage.autoRelogin;
  }

  void togglePasswordVisible() {
    obscurePassword.value = !obscurePassword.value;
  }

  void setRememberLogin(bool value) {
    rememberLogin.value = value;
  }

  void setAccount(String value) {
    account = value;
  }

  void setPassword(String value) {
    password = value;
  }

  Future<void> startLogin() async {
    if (isLoading.value) {
      LogUtil.debug(
        '[LoginController] login ignored because request is running',
      );
      return;
    }

    final trimmedAccount = account.trim();
    if (trimmedAccount.isEmpty) {
      LogUtil.warn('[LoginController] login blocked: empty username');
      FUIToast.warningGlobal(message: '请输入学号或工号');
      return;
    }
    if (password.isEmpty) {
      LogUtil.warn('[LoginController] login blocked: empty password');
      FUIToast.warningGlobal(message: '请输入密码');
      return;
    }

    LogUtil.info(
      '[LoginController] login start hasUsername=${trimmedAccount.isNotEmpty} autoRelogin=${rememberLogin.value}',
    );
    isLoading.value = true;
    try {
      final success = await _userRepo.login(
        trimmedAccount,
        password,
        autoRelogin: rememberLogin.value,
      );
      if (!success) {
        LogUtil.warn('[LoginController] login failed');
        await _showLoginErrorDialog();
        return;
      }

      LogUtil.info('[LoginController] login success');
      if (Get.isRegistered<SettingsController>()) {
        Get.find<SettingsController>().refreshUserInfo();
      }
      Get.offAll(() => const SplashPage());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _showLoginErrorDialog() async {
    final message = _userRepo.lastLoginError.isEmpty
        ? '请检查账号、密码或登录状态'
        : _userRepo.lastLoginError;
    final context = Get.context;
    if (context == null) {
      FUIToast.showGlobal(
        title: '登录失败',
        type: FUIToastType.error,
        duration: const Duration(seconds: 4),
        message: message,
      );
      return;
    }

    await SharedDialog.showConfirmDialog(
      context,
      title: '登录失败',
      content: message,
      confirmText: '知道了',
      cancelText: '',
      variant: SharedDialogVariant.danger,
    );
  }
}
