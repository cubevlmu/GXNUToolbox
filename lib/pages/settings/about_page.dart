import 'package:fin_ui/app_context.dart';
import 'package:fin_ui/app_icons.dart';
import 'package:fin_ui/app_page.dart';
import 'package:fin_ui/app_section.dart';
import 'package:fin_ui/app_surface.dart';
import 'package:fin_ui/app_tile.dart';
import 'package:fin_ui/app_tokens.dart';
import 'package:fin_ui/fui_page_head.dart';
import 'package:class_tool/utils/app_info_util.dart';
import 'package:class_tool/utils/shared_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: FUIPage(
        children: [
          const _AboutHeader(),
          const SizedBox(height: FUITokens.gap16),
          FUISurface(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/icon.png',
                  width: 72,
                  height: 72,
                  cacheWidth: 72,
                  cacheHeight: 72,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                Text(
                  'GXNU Toolbox',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                FutureBuilder<String>(
                  future: AppInfoUtil.getVersionLabel(),
                  builder: (context, snapshot) {
                    final versionText = snapshot.data == null
                        ? '版本信息获取中'
                        : '版本 ${snapshot.data}';
                    return Text(
                      versionText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textTertiary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  '为广西师范大学学生设计，用于帮助用户查看学期、周次、每日课程安排与相关课表信息以及常用教务系统功能。',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FUISection(
            title: '联系方式',
            children: [
              FUITile(
                icon: FUIIcons.info,
                title: '联系作者',
                subtitle: '邮箱: khfahqp@gmail.com',
                showChevron: false,
                onTap: () => _handleContactAuthorTap(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FUISection(
            title: '项目信息',
            children: const [
              _AboutInfoTile(
                icon: FUIIcons.classroom,
                title: '服务内容',
                subtitle: '提供课程表、教学周次、每日安排、基础账户信息与常用教务系统功能查询。',
              ),
              _AboutInfoTile(
                icon: FUIIcons.info,
                title: '登录注意事项',
                subtitle:
                    'App 会在本地模拟网页登录学校系统。若触发验证码、异地登录校验、安全保护或登录失败次数过多，可能需要先通过浏览器完成一次人工登录。',
              ),
              _AboutInfoTile(
                icon: FUIIcons.building,
                title: '平台支持说明',
                subtitle: '自动同步、早安提醒、小组件与相关后台任务目前仅支持 Android 端；桌面端不提供这些功能入口。',
              ),
              _AboutInfoTile(
                icon: FUIIcons.privacy,
                title: '隐私与安全提示',
                subtitle:
                    '账号密码仅用于本机直接登录学校系统；课程表等数据请求均由你的设备直接发送到学校服务器。开发者服务器不会转发、记录或保存学校系统请求和数据，仅提供版本检测与更新服务。',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleContactAuthorTap(BuildContext context) async {
    final controller = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : null;
    if (controller == null || !controller.registerDeveloperModeTap()) {
      return;
    }

    final confirmed = await SharedDialog.showConfirmDialog(
      context,
      title: '开启开发者模式',
      content: '开启后，设置页会显示诊断日志板块。诊断摘要用于排查问题，请勿公开分享包含个人环境信息的内容。',
      cancelText: '取消',
      confirmText: '开启',
      variant: SharedDialogVariant.warning,
      icon: FUIIcons.bug,
    );
    if (!confirmed) {
      return;
    }
    await controller.enableDeveloperMode();
    if (!context.mounted) {
      return;
    }
    await SharedDialog.showConfirmDialog(
      context,
      title: '开发者模式已开启',
      content: '返回设置页后将显示诊断日志板块。',
      cancelText: '',
      confirmText: '知道了',
      variant: SharedDialogVariant.success,
    );
  }
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader();

  @override
  Widget build(BuildContext context) {
    return const FuiPageHead(title: '关于', subtitle: '应用信息、平台说明与隐私提示');
  }
}

class _AboutInfoTile extends StatelessWidget {
  const _AboutInfoTile({
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
      padding: FUIInsets.tile,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: BorderRadius.circular(FUITokens.radiusSm),
            ),
            child: Icon(icon, size: FUITokens.iconMd, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    height: 1.45,
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
