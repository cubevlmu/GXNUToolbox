import 'package:class_tool/pages/splash/controller.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
                          ? Icons.error_outline_rounded
                          : controller.stage.value ==
                                SplashStage.offlineAvailable
                          ? Icons.wifi_off_rounded
                          : Icons.sync_rounded,
                      size: 56,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'GXNU课程表',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.message.value,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (controller.stage.value == SplashStage.checkingNetwork ||
                        controller.stage.value == SplashStage.syncingLogin)
                      const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.6),
                        ),
                      ),
                    if (controller.stage.value ==
                        SplashStage.offlineAvailable) ...[
                      FilledButton(
                        onPressed: controller.retry,
                        child: const Text('重新检查'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: controller.goOffline,
                        child: const Text('进入离线模式'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: controller.goLogin,
                        child: const Text('返回登录页'),
                      ),
                    ],
                    if (controller.stage.value == SplashStage.syncFailed) ...[
                      FilledButton(
                        onPressed: controller.retry,
                        child: const Text('重试'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: controller.goLogin,
                        child: const Text('重新登录'),
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
