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
import 'package:class_tool/utils/shared_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
            AppTile(
              icon: AppIcons.update,
              title: '检查更新',
              subtitle: '功能暂未开放',
              minHeight: 60,
              onTap: () {
                AppToast.info(
                  context,
                  message: '检查更新功能暂未开放',
                );
              },
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
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
