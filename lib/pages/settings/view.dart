import 'package:class_tool/pages/login/view.dart';
import 'package:class_tool/pages/settings/about_page.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:class_tool/utils/shared_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Card(
          child: Obx(
            () => Column(
              children: [
                _SettingsTile(
                  icon: Icons.badge_outlined,
                  title: '身份',
                  subtitle: controller.studentName.value,
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.location_on_outlined,
                  title: '校区',
                  subtitle: controller.campus.value,
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.calendar_today_outlined,
                  title: '当前学期',
                  subtitle: controller.semester.value,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.palette_outlined),
                    const SizedBox(width: 12),
                    Text(
                      '主题模式',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Obx(
                  () => SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_rounded),
                        tooltip: '自动',
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        tooltip: '浅色',
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        tooltip: '深色',
                      ),
                    ],
                    selected: {controller.themeMode.value},
                    multiSelectionEnabled: false,
                    emptySelectionAllowed: false,
                    showSelectedIcon: false,
                    onSelectionChanged: (value) {
                      if (value.isNotEmpty) {
                        controller.changeThemeMode(value.first);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Obx(
            () => Column(
              children: [
                _ToggleTile(
                  icon: Icons.schedule_rounded,
                  title: '自动同步',
                  subtitle: '每天早上 7 点自动刷新小组件',
                  description: '开启后，系统会按计划执行后台任务；部分机型可能将应用显示为存在后台活动。',
                  value: controller.autoWidgetSyncEnabled.value,
                  onChanged: controller.changeAutoWidgetSync,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                const Divider(height: 1),
                _ToggleTile(
                  icon: Icons.notifications_active_outlined,
                  title: '早安提醒',
                  subtitle: '同步成功后发送今日课程通知',
                  description: '通知会突出显示今天共有几节课，并给出第一节课的时间、教室和课程名。',
                  value: controller.morningBriefingEnabled.value,
                  enabled: controller.autoWidgetSyncEnabled.value,
                  onChanged: controller.changeMorningBriefing,
                  borderRadius: kDebugMode
                      ? BorderRadius.zero
                      : const BorderRadius.vertical(
                          bottom: Radius.circular(28),
                        ),
                ),
                if (kDebugMode) ...[
                  const Divider(height: 1),
                  _ActionTile(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                    leading: const Icon(Icons.bug_report_outlined),
                    title: const Text('测试每日同步'),
                    subtitle: const Text('仅调试包显示，手动触发一次早晨同步与提醒'),
                    onTap: controller.runMorningSyncDebug,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _ActionTile(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                leading: const Icon(Icons.system_update_rounded),
                title: const Text('检查更新'),
                subtitle: const Text('功能暂未开放'),
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('检查更新功能暂未开放')));
                },
              ),
              const Divider(height: 1),
              _ActionTile(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('关于'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AboutPage()),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
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
          icon: const Icon(Icons.logout_rounded),
          label: const Text('退出登录'),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      dense: true,
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.borderRadius,
    required this.onTap,
  });

  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          dense: true,
        ),
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
    required this.borderRadius,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.55);
    final bodyColor = enabled
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.62);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, color: bodyColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: titleColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: bodyColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(value: value, onChanged: enabled ? onChanged : null),
            ],
          ),
        ),
      ),
    );
  }
}
