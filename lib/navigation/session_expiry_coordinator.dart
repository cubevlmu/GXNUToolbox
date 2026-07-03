import 'package:class_tool/pages/splash/view.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SessionExpiryCoordinator {
  SessionExpiryCoordinator._();

  static bool _redirecting = false;

  static Future<void> redirectToSplash() async {
    if (_redirecting) {
      return;
    }

    _redirecting = true;
    LogUtil.warn('[SessionExpiryCoordinator] redirect to splash');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Get.offAll(() => const SplashPage());
      } finally {
        _redirecting = false;
      }
    });
  }
}
