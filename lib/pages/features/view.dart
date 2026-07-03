import 'package:class_tool/pages/credit/view.dart';
import 'package:class_tool/pages/attendance/view.dart';
import 'package:class_tool/pages/course_notes/view.dart';
import 'package:class_tool/pages/exams/view.dart';
import 'package:class_tool/pages/info/view.dart';
import 'package:class_tool/pages/notifications/view.dart';
import 'package:class_tool/pages/progress/view.dart';
import 'package:class_tool/pages/query/view.dart';
import 'package:class_tool/pages/school_calendar/view.dart';
import 'package:class_tool/pages/selected_courses/view.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:class_tool/pages/time/view.dart';
import 'package:fui/app_context.dart';
import 'package:fui/app_icons.dart';
import 'package:fui/app_page.dart';
import 'package:fui/app_section.dart';
import 'package:fui/app_tile.dart';
import 'package:fui/app_toast.dart';
import 'package:fui/app_tokens.dart';
import 'package:fui/fui_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Obx(() {
      final showTodo = settingsController.todoFeatureEnabled.value;
      final showAttendance = settingsController.attendanceFeatureEnabled.value;
      return Scaffold(
        backgroundColor: context.colors.background,
        body: FUIPage(
          children: [
            const _FeaturesHeader(),
            const SizedBox(height: FUITokens.gap16),
            FUISection(
              title: '学习与教务',
              children: [
                FUITile(
                  icon: FUIIcons.grade,
                  title: '成绩查询',
                  subtitle: '查看最高成绩、绩点、学分和成绩分项',
                  minHeight: 60,
                  onTap: () => _openPage(context, '成绩查询', const QueryPage()),
                ),
                FUITile(
                  icon: FUIIcons.exam,
                  title: '考试查询',
                  subtitle: '查看考试时间、座位号和考试形式',
                  minHeight: 60,
                  onTap: () => _openPage(context, '考试查询', const ExamsPage()),
                ),
                FUITile(
                  icon: FUIIcons.progress,
                  title: '培养进度',
                  subtitle: '查看培养方案中各模块课程修读情况',
                  minHeight: 60,
                  onTap: () => _openPage(context, '培养进度', const ProgressPage()),
                ),
                FUITile(
                  icon: FUIIcons.book,
                  title: '已选课程',
                  subtitle: '查看已选课程、教师和上课时间地点',
                  minHeight: 60,
                  onTap: () =>
                      _openPage(context, '已选课程', const SelectedCoursesPage()),
                ),
                FUITile(
                  icon: FUIIcons.credit,
                  title: '学分进程',
                  subtitle: '查看各模块学分修读进度统计',
                  minHeight: 60,
                  onTap: () => _openPage(context, '学分进程', const CreditPage()),
                ),
                FUITile(
                  icon: FUIIcons.person,
                  title: '学生信息',
                  subtitle: '查看学籍、基本信息与联系方式',
                  minHeight: 60,
                  onTap: () => _openPage(context, '学生信息', const InfoPage()),
                ),
              ],
            ),
            const SizedBox(height: FUITokens.gap16),
            if (showTodo || showAttendance) ...[
              FUISection(
                title: '实用功能',
                children: [
                  if (showTodo)
                    FUITile(
                      icon: FUIIcons.book,
                      title: '待办任务',
                      subtitle: '记录课程作业、待办事项和提醒',
                      minHeight: 60,
                      onTap: () =>
                          _openPage(context, '待办任务', const CourseNotesPage()),
                    ),
                  if (showAttendance)
                    FUITile(
                      icon: FUIIcons.check,
                      title: '统计',
                      subtitle: '导入名单，按日期记录状态和备注',
                      minHeight: 60,
                      onTap: () =>
                          _openPage(context, '统计', const AttendancePage()),
                    ),
                ],
              ),
              const SizedBox(height: FUITokens.gap16),
            ],
            FUISection(
              title: '校园服务',
              children: [
                FUITile(
                  icon: FUIIcons.schedule,
                  title: '作息时间',
                  subtitle: '查看各校区上课时间安排',
                  minHeight: 60,
                  onTap: () => _openPage(context, '作息时间', const TimePage()),
                ),
                FUITile(
                  icon: FUIIcons.calendar,
                  title: '校历',
                  subtitle: '查看学期周次和校历安排',
                  minHeight: 60,
                  onTap: () =>
                      _openPage(context, '校历', const SchoolCalendarPage()),
                ),
                FUITile(
                  icon: FUIIcons.classroom,
                  title: '教室查询',
                  subtitle: '查看各校区教室信息和使用情况',
                  minHeight: 60,
                  onTap: () {
                    FUIToast.info(context, message: '功能开发中');
                  },
                ),
                FUITile(
                  icon: FUIIcons.notification,
                  title: '通知公告',
                  subtitle: '查看校园通知和公告信息',
                  minHeight: 60,
                  onTap: () =>
                      _openPage(context, '通知公告', const NotificationsPage()),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

Future<void> _openPage(BuildContext context, String title, Widget page) {
  return FuiNavigation.openDetail(context, title: title, builder: (_) => page);
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
        const SizedBox(height: FUITokens.gap4),
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
