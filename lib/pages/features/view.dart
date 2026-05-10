import 'package:class_tool/pages/credit/view.dart';
import 'package:class_tool/pages/exams/view.dart';
import 'package:class_tool/pages/info/view.dart';
import 'package:class_tool/pages/progress/view.dart';
import 'package:class_tool/pages/query/view.dart';
import 'package:class_tool/pages/time/view.dart';
import 'package:flutter/material.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('教务查询')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: _FeatureTile(
              icon: Icons.account_circle_outlined,
              title: '学生信息',
              subtitle: '查看学籍、基本信息与联系方式',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const InfoPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: _FeatureTile(
              icon: Icons.assignment_outlined,
              title: '考试查询',
              subtitle: '查看考试时间、座位号和考试形式',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ExamsPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: _FeatureTile(
              icon: Icons.schedule_outlined,
              title: '作息时间',
              subtitle: '查看各校区上课时间安排',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const TimePage()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: _FeatureTile(
              icon: Icons.school_outlined,
              title: '培养进度',
              subtitle: '查看培养方案中各模块课程修读情况',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProgressPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: _FeatureTile(
              icon: Icons.pie_chart_outline,
              title: '学分进程',
              subtitle: '查看各模块学分修读进度统计',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CreditPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: _FeatureTile(
              icon: Icons.workspace_premium_outlined,
              title: '成绩查询',
              subtitle: '查看最高成绩、绩点、学分和成绩分项',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const QueryPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: colorScheme.onSecondaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
