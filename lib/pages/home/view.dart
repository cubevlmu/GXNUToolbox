import 'dart:async';

import 'package:class_tool/data/model/today_course_snapshot.dart';
import 'package:class_tool/pages/classes/controller.dart';
import 'package:class_tool/pages/credit/view.dart';
import 'package:class_tool/pages/exams/view.dart';
import 'package:class_tool/pages/home/controller.dart';
import 'package:class_tool/pages/main/controller.dart';
import 'package:class_tool/pages/notifications/view.dart';
import 'package:class_tool/pages/query/view.dart';
import 'package:class_tool/pages/selected_courses/view.dart';
import 'package:class_tool/ui/app_button.dart';
import 'package:class_tool/ui/app_colors.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_icon_button.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_surface.dart';
import 'package:class_tool/ui/app_tag.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:class_tool/widgets/skeleton_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final classesController = Get.find<ClassesController>();

    return Obx(() {
      if (controller.showSkeleton) {
        return const _HomeSkeletonView();
      }

      if (controller.initialLoadFailed) {
        return SafeArea(
          top: true,
          bottom: false,
          child: ListView(
            padding: AppInsets.page,
            children: [
              _HomeHeader(
                isRefreshing: controller.isLoading,
                onRefresh: () {
                  unawaited(
                    classesController.syncScheduleOverview(
                      forceRefresh: true,
                      syncExternalOutputs: true,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppTokens.gap14),
              _InitialLoadFailedPanel(
                message: controller.initialLoadError,
                onRetry: () {
                  unawaited(
                    classesController.syncScheduleOverview(
                      forceRefresh: true,
                      syncExternalOutputs: true,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppTokens.gap14),
              const _QuickActions(),
            ],
          ),
        );
      }

      return SafeArea(
        top: true,
        bottom: false,
        child: ListView(
          padding: AppInsets.page,
          children: [
            _HomeHeader(
              isRefreshing: controller.isLoading,
              onRefresh: () {
                unawaited(
                  classesController.syncScheduleOverview(
                    forceRefresh: true,
                    syncExternalOutputs: true,
                  ),
                );
              },
            ),
            const SizedBox(height: AppTokens.gap14),
            _WelcomePanel(
              semesterText: controller.semesterText.value,
              weekText: controller.currentWeekText.value,
            ),
            const SizedBox(height: AppTokens.gap14),
            _TodayOverview(
              courseCount: controller.todayCourseCount.value,
              weekdayText: controller.todayWeekdayText.value,
              weekText: controller.currentWeekText.value,
            ),
            const SizedBox(height: AppTokens.gap14),
            _NextCourseSection(
              nextCourse: controller.nextCourse.value,
              totalCount: controller.todayCourseCount.value,
            ),
            const SizedBox(height: AppTokens.gap14),
            const _QuickActions(),
          ],
        ),
      );
    });
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.isRefreshing, required this.onRefresh});

  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(
                  text: 'GXNU ',
                  style: TextStyle(color: colors.primary),
                ),
                const TextSpan(text: 'Toolbox'),
              ],
            ),
          ),
        ),
        AppIconButton(
          icon: AppIcons.refresh,
          tooltip: '刷新课表',
          variant: AppIconButtonVariant.ghost,
          onPressed: isRefreshing ? null : onRefresh,
        ),
        AppIconButton(
          icon: AppIcons.notification,
          tooltip: '通知',
          variant: AppIconButtonVariant.ghost,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationsPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.semesterText, required this.weekText});

  final String semesterText;
  final String weekText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subtitle = [
      if (semesterText.trim().isNotEmpty) semesterText,
      if (weekText.trim().isNotEmpty) weekText,
    ].join(' · ');

    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 46,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
            ),
          ),
          const SizedBox(width: AppTokens.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greetingText(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppTokens.gap4),
                Text(
                  subtitle.isEmpty ? '查看今天的课程与教务安排' : subtitle,
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
      ),
    );
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了，注意休息';
    if (hour < 11) return '早上好，开始今天的安排';
    if (hour < 14) return '中午好，看看下午课程';
    if (hour < 18) return '下午好，继续保持节奏';
    return '晚上好，回顾今天安排';
  }
}

class _TodayOverview extends StatelessWidget {
  const _TodayOverview({
    required this.courseCount,
    required this.weekdayText,
    required this.weekText,
  });

  final int courseCount;
  final String weekdayText;
  final String weekText;

  @override
  Widget build(BuildContext context) {
    return _HomeSection(
      title: '今日概览',
      child: AppSurface(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.gap10,
          vertical: AppTokens.gap12,
        ),
        child: Row(
          children: [
            Expanded(
              child: _OverviewStat(
                icon: AppIcons.calendar,
                value: '$courseCount',
                label: '今日课程',
              ),
            ),
            // const _OverviewDivider(),
            // const Expanded(
            //   child: _OverviewStat(
            //     icon: AppIcons.search,
            //     value: '6项',
            //     label: '教务查询',
            //   ),
            // ),
            const _OverviewDivider(),
            Expanded(
              child: _OverviewStat(
                icon: AppIcons.classroom,
                value: _compactWeekLabel(weekText),
                label: '当前周',
              ),
            ),
            const _OverviewDivider(),
            Expanded(
              child: _OverviewStat(
                icon: AppIcons.schedule,
                value: _compactTodayLabel(weekdayText),
                label: '今天',
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _compactTodayLabel(String value) {
    final compact = value.split('·').first.trim();
    return compact.isEmpty ? '今天' : compact;
  }

  static String _compactWeekLabel(String value) {
    final compact = value
        .replaceAll('第', '')
        .replaceAll('周', '')
        .replaceAll(' ', '')
        .trim();
    return compact.isEmpty || compact == '--' ? '--' : compact;
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 76,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(height: AppTokens.gap6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppTokens.gap2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewDivider extends StatelessWidget {
  const _OverviewDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: AppTokens.gap4),
      color: context.colors.border,
    );
  }
}

class _NextCourseSection extends StatelessWidget {
  const _NextCourseSection({
    required this.nextCourse,
    required this.totalCount,
  });

  final TodayCourseItemSnapshot? nextCourse;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return _HomeSection(
      title: '下一节课',
      trailing: totalCount > 0 ? '今日 $totalCount 门' : null,
      child: nextCourse == null
          ? const _EmptyTodayCourse()
          : _NextCoursePanel(course: nextCourse!),
    );
  }
}

class _NextCoursePanel extends StatelessWidget {
  const _NextCoursePanel({required this.course});

  final TodayCourseItemSnapshot course;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 60,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
            ),
          ),
          const SizedBox(width: AppTokens.gap10),
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.timeText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        course.titleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTokens.gap8),
                    const AppTag(label: '下一节', variant: AppTagVariant.primary),
                  ],
                ),
                const SizedBox(height: AppTokens.gap6),
                Text(
                  course.roomText,
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
      ),
    );
  }
}

class _EmptyTodayCourse extends StatelessWidget {
  const _EmptyTodayCourse();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(AppIcons.check, size: 18, color: colors.textTertiary),
          const SizedBox(width: AppTokens.gap8),
          Expanded(
            child: Text(
              '今日暂无课程',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialLoadFailedPanel extends StatelessWidget {
  const _InitialLoadFailedPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final detail = _compactErrorMessage(message);

    return AppSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(AppIcons.warning, size: 22, color: colors.warning),
              const SizedBox(width: AppTokens.gap10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '课表加载失败',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppTokens.gap6),
                    Text(
                      detail.isEmpty ? '请检查网络或登录状态后重试。' : detail,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.gap14),
          AppButton(
            label: '重试加载',
            icon: AppIcons.refresh,
            variant: AppButtonVariant.secondary,
            fullWidth: true,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }

  String _compactErrorMessage(String raw) {
    final normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return '';
    }
    return normalized.length > 120
        ? '${normalized.substring(0, 120)}...'
        : normalized;
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final mainController = Get.find<MainController>();
    final actions = [
      _QuickAction(
        icon: AppIcons.calendar,
        label: '课表查询',
        onTap: () => mainController.onDestinationSelected(1),
      ),
      _QuickAction(
        icon: AppIcons.grade,
        label: '成绩查询',
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const QueryPage()));
        },
      ),
      _QuickAction(
        icon: AppIcons.exam,
        label: '考试安排',
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const ExamsPage()));
        },
      ),
      _QuickAction(
        icon: AppIcons.book,
        label: '已选课程',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const SelectedCoursesPage(),
            ),
          );
        },
      ),
      _QuickAction(
        icon: AppIcons.credit,
        label: '学分进度',
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const CreditPage()));
        },
      ),
      _QuickAction(
        icon: AppIcons.apps,
        label: '更多功能',
        onTap: () => mainController.onDestinationSelected(2),
      ),
    ];

    return _HomeSection(
      title: '快捷操作',
      child: AppSurface(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _QuickActionRow(actions: actions.take(3).toList(growable: false)),
            Divider(height: 1, color: context.colors.border),
            _QuickActionRow(actions: actions.skip(3).toList(growable: false)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow({required this.actions});

  final List<_QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          Expanded(child: _QuickActionCell(action: actions[i])),
          if (i != actions.length - 1)
            Container(width: 1, height: 58, color: context.colors.border),
        ],
      ],
    );
  }
}

class _QuickActionCell extends StatelessWidget {
  const _QuickActionCell({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: action.onTap,
      child: SizedBox(
        height: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, size: 22, color: colors.primary),
            const SizedBox(height: AppTokens.gap6),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({required this.title, required this.child, this.trailing});

  final String title;
  final String? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTokens.gap8),
        child,
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _HomeSkeletonView extends StatelessWidget {
  const _HomeSkeletonView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final skeletonDeco = BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      border: Border.all(color: colors.border),
    );

    return SafeArea(
      top: true,
      bottom: false,
      child: SkeletonShimmer(
        builder: (context, palette) => ListView(
          padding: AppInsets.page,
          children: [
            Row(
              children: [
                Expanded(
                  child: SkeletonBar(
                    decoration: palette.line(radius: 10),
                    widthFactor: 0.58,
                    height: 26,
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: palette.block(radius: AppTokens.radiusSm),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.gap14),
            Container(
              decoration: skeletonDeco,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 46,
                    decoration: palette.block(radius: AppTokens.radiusFull),
                  ),
                  const SizedBox(width: AppTokens.gap12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBar(
                          decoration: palette.line(radius: 10),
                          widthFactor: 0.62,
                          height: 18,
                        ),
                        const SizedBox(height: AppTokens.gap8),
                        SkeletonBar(
                          decoration: palette.line(radius: 8),
                          widthFactor: 0.78,
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.gap14),
            Container(
              decoration: skeletonDeco,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.gap10,
                vertical: AppTokens.gap12,
              ),
              child: Row(
                children: [
                  Expanded(child: _SkeletonOverviewItem(palette: palette)),
                  const _SkeletonDivider(),
                  Expanded(child: _SkeletonOverviewItem(palette: palette)),
                  const _SkeletonDivider(),
                  Expanded(child: _SkeletonOverviewItem(palette: palette)),
                  const _SkeletonDivider(),
                  Expanded(child: _SkeletonOverviewItem(palette: palette)),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.gap14),
            Container(
              decoration: skeletonDeco,
              padding: const EdgeInsets.all(14),
              child: _SkeletonCourseItem(palette: palette, colors: colors),
            ),
            const SizedBox(height: AppTokens.gap14),
            Container(
              decoration: skeletonDeco,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SkeletonQuickActionRow(palette: palette),
                  Divider(height: 1, color: colors.border),
                  _SkeletonQuickActionRow(palette: palette),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonOverviewItem extends StatelessWidget {
  const _SkeletonOverviewItem({required this.palette});

  final SkeletonPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: palette.block(radius: AppTokens.radiusSm),
          ),
          const SizedBox(height: AppTokens.gap8),
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 0.46,
            height: 14,
          ),
          const SizedBox(height: AppTokens.gap6),
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 0.62,
            height: 10,
          ),
        ],
      ),
    );
  }
}

class _SkeletonDivider extends StatelessWidget {
  const _SkeletonDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: AppTokens.gap4),
      color: context.colors.border,
    );
  }
}

class _SkeletonCourseItem extends StatelessWidget {
  const _SkeletonCourseItem({required this.palette, required this.colors});

  final SkeletonPalette palette;
  final AppPalette colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3,
          height: 60,
          decoration: palette.block(radius: AppTokens.radiusFull),
        ),
        const SizedBox(width: AppTokens.gap10),
        Container(
          width: 64,
          height: 38,
          decoration: palette.block(radius: AppTokens.radiusSm),
        ),
        Container(
          width: 1,
          height: 58,
          margin: const EdgeInsets.symmetric(horizontal: AppTokens.gap12),
          color: colors.border,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBar(
                decoration: palette.line(radius: 8),
                widthFactor: 0.72,
                height: 14,
              ),
              const SizedBox(height: AppTokens.gap8),
              SkeletonBar(
                decoration: palette.line(radius: 8),
                widthFactor: 0.54,
                height: 12,
              ),
              const SizedBox(height: AppTokens.gap6),
              SkeletonBar(
                decoration: palette.line(radius: 8),
                widthFactor: 0.42,
                height: 12,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonQuickActionRow extends StatelessWidget {
  const _SkeletonQuickActionRow({required this.palette});

  final SkeletonPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: SizedBox(
              height: 68,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: palette.block(radius: AppTokens.radiusSm),
                  ),
                  const SizedBox(height: AppTokens.gap8),
                  SkeletonBar(
                    decoration: palette.line(radius: 8),
                    widthFactor: 0.48,
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
          if (i != 2)
            Container(width: 1, height: 58, color: context.colors.border),
        ],
      ],
    );
  }
}
