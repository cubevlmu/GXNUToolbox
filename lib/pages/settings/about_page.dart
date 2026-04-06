import 'package:class_tool/utils/app_info_util.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: const Image(
                      image: AssetImage('assets/images/icon.png'),
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'GXNU课程表',
                    style: Theme.of(context).textTheme.titleLarge,
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
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '为广西师范大学学生设计，用于帮助用户查看学期、周次、每日课程安排与相关课表信息。',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: const [
                _AboutInfoTile(
                  icon: Icons.school_outlined,
                  title: '服务内容',
                  subtitle: '查看课程表、周次、每日安排与基础账户信息',
                ),
                Divider(height: 1),
                _AboutInfoTile(
                  icon: Icons.info_outline_rounded,
                  title: '登录注意事项',
                  subtitle:
                      '不同功能可能依赖不同系统，请关闭“单处登录”；若触发验证码、异地登录或登录失败次数过多，可能需要重新人工登录。',
                ),
                Divider(height: 1),
                _AboutInfoTile(
                  icon: Icons.privacy_tip_outlined,
                  title: '隐私与安全提示',
                  subtitle:
                      '账号密码仅用于本地登录流程，不会上传保存；但第三方工具访问校园系统仍存在一定账户风控与登录失效风险，请确认后使用。',
                ),
              ],
            ),
          ),
        ],
      ),
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
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
      ),
      isThreeLine: true,
      dense: true,
    );
  }
}
