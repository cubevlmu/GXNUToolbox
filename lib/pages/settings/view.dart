import 'package:class_tool/pages/login/view.dart';
import 'package:class_tool/pages/settings/about_page.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:class_tool/utils/shared_dialog.dart';
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
