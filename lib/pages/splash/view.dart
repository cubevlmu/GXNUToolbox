import 'package:class_tool/pages/splash/controller.dart';
import 'package:fui/app_button.dart';
import 'package:fui/app_context.dart';
import 'package:fui/app_icons.dart';
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
                    if (_shouldShowUpdateCard(controller.stage.value)) ...[
                      const SizedBox(height: 18),
                      _UpdateCard(controller: controller),
                    ],
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
                        SplashStage.downloadingUpdate) ...[
                      LinearProgressIndicator(
                        value: controller.downloadProgress.value <= 0
                            ? null
                            : controller.downloadProgress.value,
                        color: colors.primary,
                        backgroundColor: colors.primarySoft,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ],
                    if (controller.stage.value ==
                        SplashStage.updateAvailable) ...[
                      FUIButton(
                        label: '立即更新',
                        icon: FUIIcons.update,
                        fullWidth: true,
                        onPressed: controller.downloadUpdate,
                      ),
                      const SizedBox(height: 12),
                      FUIButton(
                        label: '暂不更新',
                        variant: FUIButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: controller.skipUpdate,
                      ),
                    ],
                    if (controller.stage.value == SplashStage.forceUpdate) ...[
                      FUIButton(
                        label: '立即更新',
                        icon: FUIIcons.update,
                        fullWidth: true,
                        onPressed: controller.downloadUpdate,
                      ),
                      const SizedBox(height: 12),
                      FUIButton(
                        label: '重新检查',
                        icon: FUIIcons.refresh,
                        variant: FUIButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: controller.retry,
                      ),
                    ],
                    if (controller.stage.value ==
                        SplashStage.updateBlocked) ...[
                      if (controller.hasPendingUpdate.value) ...[
                        FUIButton(
                          label: '立即更新',
                          icon: FUIIcons.update,
                          fullWidth: true,
                          onPressed: controller.downloadUpdate,
                        ),
                        const SizedBox(height: 12),
                      ],
                      FUIButton(
                        label: '重新检查',
                        icon: FUIIcons.refresh,
                        variant: FUIButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: controller.retry,
                      ),
                    ],
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
      case SplashStage.updateAvailable:
      case SplashStage.forceUpdate:
      case SplashStage.downloadingUpdate:
        return FUIIcons.update;
      case SplashStage.updateBlocked:
      case SplashStage.syncFailed:
        return FUIIcons.error;
      case SplashStage.offlineAvailable:
        return FUIIcons.warning;
      case SplashStage.checkingUpdate:
      case SplashStage.checkingNetwork:
      case SplashStage.syncingLogin:
        return FUIIcons.refresh;
    }
  }

  bool _isBusyStage(SplashStage stage) {
    return stage == SplashStage.checkingUpdate ||
        stage == SplashStage.checkingNetwork ||
        stage == SplashStage.syncingLogin;
  }

  bool _shouldShowUpdateCard(SplashStage stage) {
    return stage == SplashStage.updateAvailable ||
        stage == SplashStage.forceUpdate ||
        stage == SplashStage.updateBlocked ||
        stage == SplashStage.downloadingUpdate;
  }
}

class _UpdateCard extends StatelessWidget {
  const _UpdateCard({required this.controller});

  final SplashController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (!controller.hasPendingUpdate.value) {
      return const SizedBox.shrink();
    }

    final changelog = controller.updateChangelog.value.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            controller.updateTitle.value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            controller.updateVersion.value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (changelog.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              changelog,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
