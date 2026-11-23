import 'package:class_tool/pages/splash/controller.dart';
import 'package:fin_ui/app_button.dart';
import 'package:fin_ui/app_context.dart';
import 'package:fin_ui/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final SplashController controller;
  final String _controllerTag = UniqueKey().toString();

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      SplashController(),
      tag: _controllerTag,
      permanent: false,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<SplashController>(tag: _controllerTag)) {
      Get.delete<SplashController>(tag: _controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Obx(
                () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      _stageIcon(controller.stage.value),
                      size: 56,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'GXNU课程表',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.message.value,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (_isBusyStage(controller.stage.value))
                      Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: colors.primary,
                            strokeWidth: 2.6,
                          ),
                        ),
                      ),
                    if (controller.stage.value ==
                        SplashStage.offlineAvailable) ...[
                      FUIButton(
                        label: '重新检查',
                        icon: FUIIcons.refresh,
                        fullWidth: true,
                        onPressed: controller.retry,
                      ),
                      const SizedBox(height: 12),
                      FUIButton(
                        label: '进入离线模式',
                        icon: FUIIcons.warning,
                        variant: FUIButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: controller.goOffline,
                      ),
                      const SizedBox(height: 12),
                      FUIButton(
                        label: '返回登录页',
                        variant: FUIButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: controller.goLogin,
                      ),
                    ],
                    if (controller.stage.value == SplashStage.syncFailed) ...[
                      FUIButton(
                        label: '重试',
                        icon: FUIIcons.refresh,
                        fullWidth: true,
                        onPressed: controller.retry,
                      ),
                      const SizedBox(height: 12),
                      FUIButton(
                        label: '重新登录',
                        icon: FUIIcons.login,
                        variant: FUIButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: controller.goLogin,
                      ),
                    ],
                    if (controller.stage.value ==
                        SplashStage.loginRateLimited) ...[
                      FUIButton(
                        label: '重试自动登录',
                        icon: FUIIcons.refresh,
                        fullWidth: true,
                        onPressed: controller.retry,
                      ),
                      const SizedBox(height: 12),
                      FUIButton(
                        label: '重新登录',
                        icon: FUIIcons.login,
                        variant: FUIButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: controller.goLogin,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _stageIcon(SplashStage stage) {
    switch (stage) {
      case SplashStage.syncFailed:
        return FUIIcons.error;
      case SplashStage.loginRateLimited:
      case SplashStage.offlineAvailable:
        return FUIIcons.warning;
      case SplashStage.checkingNetwork:
      case SplashStage.syncingLogin:
        return FUIIcons.refresh;
    }
  }

  bool _isBusyStage(SplashStage stage) {
    return stage == SplashStage.checkingNetwork ||
        stage == SplashStage.syncingLogin;
  }
}
