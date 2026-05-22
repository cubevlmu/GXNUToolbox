import 'dart:io';

import 'package:class_tool/data/services/app_update_service.dart';
import 'package:class_tool/pages/login/view.dart';
import 'package:class_tool/pages/settings/about_page.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:class_tool/ui/app_button.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_page.dart';
import 'package:class_tool/ui/app_section.dart';
import 'package:class_tool/ui/app_segmented_control.dart';
import 'package:class_tool/ui/app_tile.dart';
import 'package:class_tool/ui/app_toast.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/shared_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gx_update_client/gx_update_client.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return AppPage(
      children: [
        const _SettingsHeader(),
        const SizedBox(height: AppTokens.gap16),
        AppSection(
          title: '外观设置',
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTokens.gap14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '主题模式',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppTokens.gap10),
                  Obx(
                    () => AppSegmentedControl<ThemeMode>(
                      value: controller.themeMode.value,
                      items: const [
                        AppSegmentedItem(
                          value: ThemeMode.system,
                          label: '自动',
                          icon: AppIcons.autoBrightness,
                        ),
                        AppSegmentedItem(
                          value: ThemeMode.light,
                          label: '浅色',
                          icon: AppIcons.lightMode,
                        ),
                        AppSegmentedItem(
                          value: ThemeMode.dark,
                          label: '深色',
                          icon: AppIcons.darkMode,
                        ),
                      ],
                      onChanged: controller.changeThemeMode,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.gap16),
        Obx(
          () => AppSection(
            title: '账号与安全',
            children: [
              AppTile(
                icon: AppIcons.badge,
                title: '身份',
                subtitle: controller.studentName.value,
                showChevron: false,
                minHeight: 60,
              ),
              AppTile(
                icon: AppIcons.location,
                title: '校区',
                subtitle: controller.campus.value,
                showChevron: false,
                minHeight: 60,
              ),
              AppTile(
                icon: AppIcons.calendar,
                title: '当前学期',
                subtitle: controller.semester.value,
                showChevron: false,
                minHeight: 60,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.gap16),
        if (controller.supportsScheduledSync)
          Obx(
            () => AppSection(
              title: '通知与同步',
              children: [
                _ToggleTile(
                  icon: AppIcons.schedule,
                  title: '自动同步',
                  subtitle: '每天早上 7 点自动刷新小组件',
                  description: '开启后，系统会按计划执行后台任务；部分机型可能将应用显示为存在后台活动。',
                  value: controller.autoWidgetSyncEnabled.value,
                  onChanged: controller.changeAutoWidgetSync,
                ),
                _ToggleTile(
                  icon: AppIcons.notificationActive,
                  title: '早安提醒',
                  subtitle: '同步成功后发送今日课程通知',
                  description: '通知会突出显示今天共有几节课，并给出第一节课的时间、教室和课程名。',
                  value: controller.morningBriefingEnabled.value,
                  onChanged: controller.changeMorningBriefing,
                ),
                if (kDebugMode)
                  AppTile(
                    icon: AppIcons.bug,
                    title: '测试每日同步',
                    subtitle: '仅调试包显示，手动触发一次早晨同步与提醒',
                    minHeight: 60,
                    onTap: controller.runMorningSyncDebug,
                  ),
              ],
            ),
          )
        else
          AppSection(
            title: '通知与同步',
            children: const [
              _NoticeTile(
                icon: AppIcons.info,
                title: '平台支持说明',
                subtitle: '自动同步、早安提醒和相关后台任务仅在 Android 端提供，当前桌面端不支持这些功能。',
              ),
            ],
          ),
        const SizedBox(height: AppTokens.gap16),
        AppSection(
          title: '通用设置',
          children: [
            Obx(
              () => _ToggleTile(
                icon: AppIcons.update,
                title: '启动更新提醒',
                subtitle: controller.startupUpdatePromptEnabled.value
                    ? '普通新版本会在启动时提示'
                    : '普通新版本静默跳过',
                description: '默认开启。关闭后仍会校验版本；强制更新、版本停用或封禁仍会提示并按原流程处理。',
                value: controller.startupUpdatePromptEnabled.value,
                onChanged: controller.changeStartupUpdatePrompt,
              ),
            ),
            AppTile(
              icon: AppIcons.update,
              title: '检查更新',
              subtitle: '点击查询最新版本',
              minHeight: 60,
              onTap: () => _checkUpdate(context),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.gap16),
        AppSection(
          title: '关于',
          children: [
            AppTile(
              icon: AppIcons.info,
              title: '关于 GXNU Class Tool',
              subtitle: '版本、隐私与平台说明',
              minHeight: 60,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AboutPage()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppTokens.gap14),
        AppButton(
          label: '退出登录',
          icon: AppIcons.logout,
          variant: AppButtonVariant.danger,
          fullWidth: true,
          onPressed: () async {
            final confirmed = await SharedDialog.showConfirmDialog(
              context,
              title: '确认退出登录',
              content: '退出后将清除本地登录状态，是否继续？',
              cancelText: '取消',
              confirmText: '退出',
            );
            if (!confirmed) {
              return;
            }
            await controller.logout();
            Get.offAll(() => const LoginPage());
          },
        ),
      ],
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '设置',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppTokens.gap4),
        Text(
          '管理账号、外观和同步提醒',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: AppInsets.tile,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppTokens.iconMd, color: colors.textTertiary),
          const SizedBox(width: AppTokens.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTokens.gap4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(icon, size: AppTokens.iconMd, color: colors.primary),
          ),
          const SizedBox(width: AppTokens.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTokens.gap2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTokens.gap6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textTertiary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.gap12),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

Future<void> _checkUpdate(BuildContext context) async {
  try {
    final response = await AppUpdateService.check();
    if (!context.mounted) return;

    if (!response.legal.allowed) {
      final message = response.legal.message.trim().isEmpty
          ? '当前版本已停止支持，请更新后继续使用。'
          : response.legal.message.trim();

      if (!response.update.available) {
        await SharedDialog.showConfirmDialog(
          context,
          title: '版本已停止支持',
          content: '$message\n\n服务端暂未配置可下载的新版安装包，请稍后重试。',
          confirmText: '退出应用',
          cancelText: '',
        );
        await _closeApp();
        return;
      }

      final changelog = response.update.changelog.trim();
      final content = StringBuffer()
        ..writeln(message)
        ..writeln()
        ..writeln(
          '可更新到: v${response.update.version} (build ${response.update.versionCode})',
        );

      if (changelog.isNotEmpty) {
        content
          ..writeln()
          ..writeln('更新内容：')
          ..write(changelog);
      }

      final confirmed = await SharedDialog.showConfirmDialog(
        context,
        title: '版本已停止支持',
        content: content.toString(),
        confirmText: '立即更新',
        cancelText: '退出应用',
      );

      if (!context.mounted) return;

      if (confirmed) {
        await _downloadAndInstallUpdate(context, response.update);
      } else {
        await _closeApp();
      }
      return;
    }

    if (response.update.available) {
      final changelog = response.update.changelog.trim();
      final content = StringBuffer()
        ..writeln('版本 ${response.update.version} 已发布，是否下载更新？');

      if (changelog.isNotEmpty) {
        content
          ..writeln()
          ..writeln('更新内容：')
          ..write(changelog);
      }

      final download = await SharedDialog.showConfirmDialog(
        context,
        title: '发现新版本',
        content: content.toString(),
        confirmText: '下载',
        cancelText: '稍后',
      );

      if (!context.mounted) return;

      if (download) {
        await _downloadAndInstallUpdate(context, response.update);
      }
      return;
    }

    AppToast.info(context, message: '已是最新版本');
  } on AppUpdateCheckUnavailableException {
    if (context.mounted) {
      AppToast.error(context, message: '更新服务未配置，无法检查更新');
    }
  } catch (e, _) {
    if (context.mounted) {
      AppToast.error(
        context,
        message: '检查更新失败: ${e.toString().split('\n').first}',
      );
      LogUtil.errorE('[SettingsPage] check update failed', e, null);
    }
  }
}

Future<void> _downloadAndInstallUpdate(
  BuildContext context,
  UpdateInfo update,
) async {
  await SharedDialog.showProgressDialog(
    context: context,
    title: '正在下载更新包',
    loadingMessage: '正在准备下载...',
    cancelText: '取消',
    completeMessage: Platform.isWindows
        ? '更新包已下载，请按提示完成安装'
        : '安装界面已打开，请按系统提示完成安装',
    completeButtonText: '完成',
    task: (controller) async {
      try {
        await AppUpdateService.downloadAndInstall(
          update,
          shouldCancel: () => controller.isCancelled,
          onProgress: (progress) {
            if (controller.isCancelled) return;
            final fraction = progress.fraction;
            if (fraction == null) return;
            final percent = (fraction.clamp(0.0, 1.0) * 100).toStringAsFixed(0);
            controller.updateProgress(fraction, message: '正在下载更新包 $percent%');
          },
        );
        if (controller.isCancelled) return false;
        return true;
      } on GxUpdateCancelledException {
        return false;
      } on AppUpdateInstallPermissionRequiredException {
        controller.updateProgress(1, message: '请先允许安装未知来源应用，然后重新点击立即更新');
        return false;
      } catch (e, s) {
        LogUtil.errorE('[SettingsPage] update download/install failed', e, s);
        controller.updateProgress(
          1,
          message: '下载或安装更新失败: ${e.toString().split('\n').first}',
        );
        return false;
      }
    },
  );
}

Future<void> _closeApp() async {
  if (Platform.isAndroid) {
    await SystemNavigator.pop(animated: true);
    return;
  }

  exit(0);
}
