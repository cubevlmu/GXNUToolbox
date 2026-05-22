import 'package:class_tool/pages/splash/controller.dart';
import 'package:class_tool/ui/app_button.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final SplashController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SplashController(), permanent: false);
  }

  @override
  void dispose() {
    if (Get.isRegistered<SplashController>()) {
      Get.delete<SplashController>();
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
                      controller.stage.value == SplashStage.syncFailed
                          ? AppIcons.error
                          : controller.stage.value ==
                                SplashStage.offlineAvailable
                          ? AppIcons.warning
                          : AppIcons.refresh,
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
                    if (controller.stage.value == SplashStage.checkingNetwork ||
                        controller.stage.value == SplashStage.syncingLogin)
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
                      AppButton(
                        label: '重新检查',
                        icon: AppIcons.refresh,
                        fullWidth: true,
                        onPressed: controller.retry,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: '进入离线模式',
                        icon: AppIcons.warning,
                        variant: AppButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: controller.goOffline,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: '返回登录页',
                        variant: AppButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: controller.goLogin,
                      ),
                    ],
                    if (controller.stage.value == SplashStage.syncFailed) ...[
                      AppButton(
                        label: '重试',
                        icon: AppIcons.refresh,
                        fullWidth: true,
                        onPressed: controller.retry,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: '重新登录',
                        icon: AppIcons.login,
                        variant: AppButtonVariant.secondary,
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
}
