import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_icon_button.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_page.dart';
import 'package:class_tool/ui/app_section.dart';
import 'package:class_tool/ui/app_surface.dart';
import 'package:class_tool/ui/app_tile.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:class_tool/utils/app_info_util.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: AppPage(
        children: [
          const _AboutHeader(),
          const SizedBox(height: AppTokens.gap16),
          AppSurface(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/icon.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                Text(
                  'GXNU Class Tool',
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
          const AppSection(
            title: '联系方式',
            children: [
              AppTile(
                icon: AppIcons.info,
                title: '联系作者',
                subtitle: '邮箱: khfahqp@gmail.com',
                showChevron: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppSection(
            title: '项目信息',
            children: const [
              _AboutInfoTile(
                icon: AppIcons.classroom,
                title: '服务内容',
                subtitle: '查看课程表、周次、每日安排与基础账户信息，以及常用教务系统功能。',
              ),
              _AboutInfoTile(
                icon: AppIcons.info,
                title: '登录注意事项',
                subtitle:
                    '不同功能可能依赖不同系统，请关闭"单处登录"；若触发验证码、异地登录或登录失败次数过多，可能需要重新人工登录。',
              ),
              _AboutInfoTile(
                icon: AppIcons.building,
                title: '平台支持说明',
                subtitle: '自动同步、早安提醒、小组件与相关后台任务目前仅支持 Android 端；桌面端不提供这些功能入口。',
              ),
              _AboutInfoTile(
                icon: AppIcons.privacy,
                title: '隐私与安全提示',
                subtitle:
                    '账号密码仅用于本地登录流程，不会上传保存；但第三方工具访问校园系统仍存在一定账户风控与登录失效风险，请确认后使用。',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        AppIconButton(
          icon: AppIcons.chevronLeft,
          tooltip: '返回',
          variant: AppIconButtonVariant.outline,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: AppTokens.gap8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '关于',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppTokens.gap2),
              Text(
                '应用信息、平台说明与隐私提示',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
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
      padding: AppInsets.tile,
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
