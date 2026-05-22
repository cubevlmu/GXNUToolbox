import 'package:class_tool/pages/credit/view.dart';
import 'package:class_tool/pages/exams/view.dart';
import 'package:class_tool/pages/info/view.dart';
import 'package:class_tool/pages/main/controller.dart';
import 'package:class_tool/pages/progress/view.dart';
import 'package:class_tool/pages/query/view.dart';
import 'package:class_tool/pages/time/view.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_page.dart';
import 'package:class_tool/ui/app_section.dart';
import 'package:class_tool/ui/app_tile.dart';
import 'package:class_tool/ui/app_toast.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainController = Get.find<MainController>();

    return Scaffold(
      backgroundColor: context.colors.background,
      body: AppPage(
        children: [
          const _FeaturesHeader(),
          const SizedBox(height: AppTokens.gap16),
          AppSection(
            title: '学习与教务',
            children: [
              AppTile(
                icon: AppIcons.grade,
                title: '成绩查询',
                subtitle: '查看最高成绩、绩点、学分和成绩分项',
                minHeight: 60,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const QueryPage()),
                  );
                },
              ),
              AppTile(
                icon: AppIcons.exam,
                title: '考试查询',
                subtitle: '查看考试时间、座位号和考试形式',
                minHeight: 60,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const ExamsPage()),
                  );
                },
              ),
              AppTile(
                icon: AppIcons.progress,
                title: '培养进度',
                subtitle: '查看培养方案中各模块课程修读情况',
                minHeight: 60,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProgressPage(),
                    ),
                  );
                },
              ),
              AppTile(
                icon: AppIcons.credit,
                title: '学分进程',
                subtitle: '查看各模块学分修读进度统计',
                minHeight: 60,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const CreditPage()),
                  );
                },
              ),
              AppTile(
                icon: AppIcons.person,
                title: '学生信息',
                subtitle: '查看学籍、基本信息与联系方式',
                minHeight: 60,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const InfoPage()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppTokens.gap16),
          AppSection(
            title: '校园服务',
            children: [
              AppTile(
                icon: AppIcons.schedule,
                title: '作息时间',
                subtitle: '查看各校区上课时间安排',
                minHeight: 60,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const TimePage()),
                  );
                },
              ),
              AppTile(
                icon: AppIcons.classroom,
                title: '教室查询',
                subtitle: '查看各校区教室信息和使用情况',
                minHeight: 60,
                onTap: () {
                  AppToast.info(context, message: '功能开发中');
                },
              ),
              AppTile(
                icon: AppIcons.notification,
                title: '通知公告',
                subtitle: '查看校园通知和公告信息',
                minHeight: 60,
                onTap: () {
                  AppToast.info(context, message: '功能开发中');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturesHeader extends StatelessWidget {
  const _FeaturesHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '全部功能',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppTokens.gap4),
        Text(
          '常用教务入口已按学习场景分组',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
