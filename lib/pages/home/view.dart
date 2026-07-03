import 'dart:async';

import 'package:class_tool/data/model/home_quick_action.dart';
import 'package:class_tool/data/model/course_note.dart';
import 'package:class_tool/data/model/today_course_snapshot.dart';
import 'package:class_tool/pages/classes/controller.dart';
import 'package:class_tool/pages/attendance/view.dart';
import 'package:class_tool/pages/credit/view.dart';
import 'package:class_tool/pages/exams/view.dart';
import 'package:class_tool/pages/home/controller.dart';
import 'package:class_tool/pages/course_notes/view.dart';
import 'package:class_tool/pages/info/view.dart';
import 'package:class_tool/pages/notifications/view.dart';
import 'package:class_tool/pages/progress/view.dart';
import 'package:class_tool/pages/query/view.dart';
import 'package:class_tool/pages/school_calendar/view.dart';
import 'package:class_tool/pages/selected_courses/view.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:class_tool/pages/time/view.dart';
import 'package:fui/app_button.dart';
import 'package:fui/app_colors.dart';
import 'package:fui/app_context.dart';
import 'package:fui/app_icon_button.dart';
import 'package:fui/app_icons.dart';
import 'package:fui/app_surface.dart';
import 'package:fui/app_tag.dart';
import 'package:fui/app_toast.dart';
import 'package:fui/app_tokens.dart';
import 'package:fui/fui_navigation.dart';
import 'package:class_tool/widgets/app_bottom_sheet.dart';
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
            padding: FUIInsets.page,
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
              const SizedBox(height: FUITokens.gap14),
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
              const SizedBox(height: FUITokens.gap14),
              const _QuickActions(),
            ],
          ),
        );
      }

      return SafeArea(
        top: true,
        bottom: false,
        child: ListView(
          padding: FUIInsets.page,
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
            const SizedBox(height: FUITokens.gap12),
            _TodayOverview(
              courseCount: controller.todayCourseCount.value,
              pendingTaskCount:
                  Get.find<SettingsController>().todoFeatureEnabled.value
                  ? controller.pendingTaskCount
                  : null,
              weekdayText: controller.todayWeekdayText.value,
              weekText: controller.currentWeekText.value,
            ),
            const SizedBox(height: FUITokens.gap12),
            const _QuickActions(),
            const SizedBox(height: FUITokens.gap12),
            _HomeTimelineSection(
              todayCourses: controller.todayCourses,
              nextCourse: controller.nextCourse.value,
              todayTasks: controller.todayTasks,
              weekTasks: controller.weekTasks,
              now: controller.timelineNow,
            ),
          ],
        ),
      );
    });
  }
}

enum _TimelineTab { today, week }

class _HomeTimelineSection extends StatefulWidget {
  const _HomeTimelineSection({
    required this.todayCourses,
    required this.nextCourse,
    required this.todayTasks,
    required this.weekTasks,
    required this.now,
  });

  final List<TodayCourseItemSnapshot> todayCourses;
  final TodayCourseItemSnapshot? nextCourse;
  final List<CourseNoteEntry> todayTasks;
  final List<CourseNoteEntry> weekTasks;
  final DateTime now;

  @override
  State<_HomeTimelineSection> createState() => _HomeTimelineSectionState();
}

class _HomeTimelineSectionState extends State<_HomeTimelineSection>
    with SingleTickerProviderStateMixin {
  _TimelineTab _tab = _TimelineTab.today;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }
      final next = _TimelineTab.values[_tabController.index];
      if (next != _tab) {
        setState(() => _tab = next);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final settingsController = Get.find<SettingsController>();
    return Obx(() {
      final showTasks = settingsController.todoFeatureEnabled.value;
      final selectedTab = showTasks ? _tab : _TimelineTab.today;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTasks) ...[
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: colors.primary,
              unselectedLabelColor: colors.textSecondary,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              labelStyle: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              unselectedLabelStyle: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              indicatorColor: colors.primary,
              indicatorWeight: 2,
              dividerColor: colors.border,
              labelPadding: const EdgeInsets.only(right: 24),
              onTap: (index) {
                setState(() => _tab = _TimelineTab.values[index]);
              },
              tabs: const [
                Tab(text: '时间线'),
                Tab(text: '本周任务'),
              ],
            ),
            const SizedBox(height: FUITokens.gap10),
          ],
          if (selectedTab == _TimelineTab.today)
            _TodayTimeline(
              courses: widget.todayCourses,
              nextCourse: widget.nextCourse,
              tasks: showTasks ? widget.todayTasks : const [],
              showTasks: showTasks,
              now: widget.now,
            )
          else
            _WeekTaskTimeline(tasks: widget.weekTasks, now: widget.now),
        ],
      );
    });
  }
}

class _TimelineItemData {
  const _TimelineItemData({required this.child, required this.markerColor});

  final Widget child;
  final Color markerColor;
}

class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.items});

  final List<_TimelineItemData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          _TimelineLine(
            markerColor: items[i].markerColor,
            isFirst: i == 0,
            isLast: i == items.length - 1,
            child: items[i].child,
          ),
      ],
    );
  }
}

class _TimelineCourseContent extends StatelessWidget {
  const _TimelineCourseContent({
    required this.course,
    required this.highlighted,
  });

  final TodayCourseItemSnapshot course;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: FUITokens.gap14),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              course.timeText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: highlighted ? colors.primary : colors.textTertiary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: FUITokens.gap8),
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (highlighted) ...[
                      const SizedBox(width: FUITokens.gap6),
                      const FUITag(
                        label: '下一节',
                        variant: FUITagVariant.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: FUITokens.gap2),
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

class _TodayTimeline extends StatelessWidget {
  const _TodayTimeline({
    required this.courses,
    required this.nextCourse,
    required this.tasks,
    required this.showTasks,
    required this.now,
  });

  final List<TodayCourseItemSnapshot> courses;
  final TodayCourseItemSnapshot? nextCourse;
  final List<CourseNoteEntry> tasks;
  final bool showTasks;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final visibleCourses = _mergeCourses().where(_isCourseUpcoming).toList();
    final visibleTasks = tasks.where(_isTaskUpcoming).take(4).toList();
    final hasItems = visibleCourses.isNotEmpty || visibleTasks.isNotEmpty;
    if (!hasItems) {
      return _TimelineEmpty(
        icon: FUIIcons.check,
        text: showTasks ? '今天没有课程和到期任务' : '今天没有课程',
      );
    }
    final items = <_TimelineItemData>[
      for (final course in visibleCourses)
        _TimelineItemData(
          markerColor: nextCourse != null && _sameCourse(course, nextCourse!)
              ? context.colors.primary
              : context.colors.textTertiary,
          child: _TimelineCourseContent(
            course: course,
            highlighted: nextCourse != null && _sameCourse(course, nextCourse!),
          ),
        ),
      for (final task in visibleTasks)
        _TimelineItemData(
          markerColor: task.isOverdue
              ? context.colors.danger
              : context.colors.primary,
          child: _TimelineTaskLine(entry: task),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_TimelineList(items: items)],
    );
  }

  bool _isCourseUpcoming(TodayCourseItemSnapshot course) {
    final courseAt = _parseTodayTime(course.timeText);
    if (courseAt == null) {
      return true;
    }
    return !courseAt.isBefore(now);
  }

  bool _isTaskUpcoming(CourseNoteEntry entry) {
    final dueAt = entry.note.dueAt;
    if (dueAt == null) {
      return true;
    }
    return !dueAt.isBefore(now);
  }

  List<TodayCourseItemSnapshot> _mergeCourses() {
    final result = <TodayCourseItemSnapshot>[];
    if (nextCourse != null) {
      result.add(nextCourse!);
    }
    for (final course in courses) {
      if (result.any((item) => _sameCourse(item, course))) {
        continue;
      }
      result.add(course);
    }
    return result.take(5).toList(growable: false);
  }

  bool _sameCourse(TodayCourseItemSnapshot a, TodayCourseItemSnapshot b) {
    return a.timeText == b.timeText &&
        a.titleText == b.titleText &&
        a.roomText == b.roomText;
  }

  DateTime? _parseTodayTime(String raw) {
    final match = RegExp(r'(\d{1,2}):(\d{1,2})').firstMatch(raw);
    if (match == null) {
      return null;
    }
    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    if (hour == null || minute == null) {
      return null;
    }
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}

class _WeekTaskTimeline extends StatelessWidget {
  const _WeekTaskTimeline({required this.tasks, required this.now});

  final List<CourseNoteEntry> tasks;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final visibleTasks = tasks.where(_isTaskUpcoming).take(6).toList();
    if (visibleTasks.isEmpty) {
      return const _TimelineEmpty(icon: FUIIcons.check, text: '本周没有待处理任务');
    }
    final items = [
      for (final task in visibleTasks)
        _TimelineItemData(
          markerColor: task.isOverdue
              ? context.colors.danger
              : context.colors.primary,
          child: _TimelineTaskLine(entry: task),
        ),
    ];
    return _TimelineList(items: items);
  }

  bool _isTaskUpcoming(CourseNoteEntry entry) {
    final dueAt = entry.note.dueAt;
    if (dueAt == null) {
      return true;
    }
    return !dueAt.isBefore(now);
  }
}

class _TimelineTaskLine extends StatelessWidget {
  const _TimelineTaskLine({required this.entry});

  final CourseNoteEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: FUITokens.gap14),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openTaskDetail(context),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      const SizedBox(width: FUITokens.gap6),
                      FUITag(
                        label: entry.type.label,
                        variant: entry.isOverdue
                            ? FUITagVariant.danger
                            : FUITagVariant.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: FUITokens.gap2),
                  Text(
                    '${entry.course.courseName}${_dueText(entry.note.dueAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: FUITokens.gap6),
            Icon(FUIIcons.chevronRight, size: 16, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }

  Future<void> _openTaskDetail(BuildContext context) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      child: _HomeTaskDetailSheet(entry: entry),
    );
  }

  String _dueText(DateTime? dueAt) {
    if (dueAt == null) return '';
    return ' · ${dueAt.month.toString().padLeft(2, '0')}-${dueAt.day.toString().padLeft(2, '0')} ${dueAt.hour.toString().padLeft(2, '0')}:${dueAt.minute.toString().padLeft(2, '0')}';
  }
}

class _HomeTaskDetailSheet extends StatelessWidget {
  const _HomeTaskDetailSheet({required this.entry});

  final CourseNoteEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final note = entry.note;
    final dueText = _formatTaskDateTime(note.dueAt);
    final remindText = _formatTaskDateTime(note.remindAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: FUITokens.gap8),
              FUITag(
                label: entry.type.label,
                variant: note.isDone
                    ? FUITagVariant.neutral
                    : entry.isOverdue
                    ? FUITagVariant.danger
                    : FUITagVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap8),
          Text(
            entry.isGeneralTask ? '普通待办' : entry.course.courseName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (note.content.trim().isNotEmpty) ...[
            const SizedBox(height: FUITokens.gap12),
            Text(
              note.content.trim(),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: FUITokens.gap14),
          Wrap(
            spacing: FUITokens.gap8,
            runSpacing: FUITokens.gap8,
            children: [
              if (dueText.isNotEmpty)
                FUITag(
                  label: entry.isOverdue ? '已逾期 $dueText' : '截止 $dueText',
                  variant: entry.isOverdue
                      ? FUITagVariant.danger
                      : FUITagVariant.warning,
                ),
              if (remindText.isNotEmpty) FUITag(label: '提醒 $remindText'),
              if (note.calendarExported) const FUITag(label: '已导入日历'),
            ],
          ),
          const SizedBox(height: FUITokens.gap16),
          Row(
            children: [
              Expanded(
                child: FUIButton(
                  label: note.isDone ? '标为未完成' : '完成',
                  icon: FUIIcons.checkmark,
                  variant: FUIButtonVariant.secondary,
                  onPressed: () => _setDone(context, !note.isDone),
                ),
              ),
              const SizedBox(width: FUITokens.gap8),
              Expanded(
                child: FUIButton(
                  label: '导入日历',
                  icon: FUIIcons.calendarAdd,
                  variant: FUIButtonVariant.secondary,
                  onPressed: () => _export(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap8),
          Row(
            children: [
              Expanded(
                child: FUIButton(
                  label: '删除',
                  icon: FUIIcons.delete,
                  variant: FUIButtonVariant.danger,
                  onPressed: () => _delete(context),
                ),
              ),
              const SizedBox(width: FUITokens.gap8),
              Expanded(
                child: FUIButton(
                  label: '更多',
                  icon: FUIIcons.more,
                  variant: FUIButtonVariant.primary,
                  onPressed: () => _openAllTasks(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _setDone(BuildContext context, bool isDone) async {
    try {
      await Get.find<HomeController>().setTaskDone(entry, isDone);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      FUIToast.success(context, message: isDone ? '已完成任务' : '已恢复任务');
    } catch (e) {
      if (!context.mounted) return;
      FUIToast.error(context, message: e.toString().split('\n').first);
    }
  }

  Future<void> _export(BuildContext context) async {
    try {
      final exported = await Get.find<HomeController>().exportTaskToCalendar(
        entry,
      );
      if (!context.mounted) return;
      if (exported) {
        FUIToast.success(context, message: '已导入系统日历');
      } else {
        FUIToast.info(context, message: '已跳过重复日程');
      }
    } catch (e) {
      if (!context.mounted) return;
      FUIToast.error(context, message: e.toString().split('\n').first);
    }
  }

  Future<void> _delete(BuildContext context) async {
    try {
      await Get.find<HomeController>().deleteTask(entry);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      FUIToast.success(context, message: '已删除任务');
    } catch (e) {
      if (!context.mounted) return;
      FUIToast.error(context, message: e.toString().split('\n').first);
    }
  }

  void _openAllTasks(BuildContext context) {
    Navigator.of(context).pop();
    FuiNavigation.openDetail(
      context,
      title: '课程任务',
      builder: (_) => const CourseNotesPage(),
    );
  }
}

class _TimelineLine extends StatelessWidget {
  const _TimelineLine({
    required this.markerColor,
    required this.isFirst,
    required this.isLast,
    required this.child,
  });

  final Color markerColor;
  final bool isFirst;
  final bool isLast;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final lineColor = context.colors.border;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 6,
                  color: isFirst ? Colors.transparent : lineColor,
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: markerColor,
                    borderRadius: BorderRadius.circular(FUITokens.radiusFull),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : lineColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: FUITokens.gap8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

String _formatTaskDateTime(DateTime? value) {
  if (value == null) return '';
  final now = DateTime.now();
  final date = value.year == now.year
      ? '${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'
      : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  return '$date ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class _TimelineEmpty extends StatelessWidget {
  const _TimelineEmpty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FUITokens.gap8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.textTertiary),
          const SizedBox(width: FUITokens.gap8),
          Expanded(
            child: Text(
              text,
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
        FUIIconButton(
          icon: FUIIcons.refresh,
          tooltip: '刷新课表',
          variant: FUIIconButtonVariant.ghost,
          onPressed: isRefreshing ? null : onRefresh,
        ),
        FUIIconButton(
          icon: FUIIcons.notification,
          tooltip: '通知',
          variant: FUIIconButtonVariant.ghost,
          onPressed: () => FuiNavigation.openDetail(
            context,
            title: '通知',
            builder: (_) => const NotificationsPage(),
          ),
        ),
      ],
    );
  }
}

class _TodayOverview extends StatelessWidget {
  const _TodayOverview({
    required this.courseCount,
    this.pendingTaskCount,
    required this.weekdayText,
    required this.weekText,
  });

  final int courseCount;
  final int? pendingTaskCount;
  final String weekdayText;
  final String weekText;

  @override
  Widget build(BuildContext context) {
    return _HomeSection(
      title: '今日概览',
      child: FUISurface(
        padding: const EdgeInsets.symmetric(
          horizontal: FUITokens.gap10,
          vertical: FUITokens.gap12,
        ),
        child: Row(
          children: [
            Expanded(
              child: _OverviewStat(
                icon: FUIIcons.calendar,
                value: '$courseCount',
                label: '今日课程',
              ),
            ),
            if (pendingTaskCount != null) ...[
              const _OverviewDivider(),
              Expanded(
                child: _OverviewStat(
                  icon: FUIIcons.check,
                  value: '$pendingTaskCount',
                  label: '待完成',
                ),
              ),
            ],
            const _OverviewDivider(),
            Expanded(
              child: _OverviewStat(
                icon: FUIIcons.classroom,
                value: _compactWeekLabel(weekText),
                label: '当前周',
              ),
            ),
            const _OverviewDivider(),
            Expanded(
              child: _OverviewStat(
                icon: FUIIcons.schedule,
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
          const SizedBox(height: FUITokens.gap6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: FUITokens.gap2),
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
      margin: const EdgeInsets.symmetric(horizontal: FUITokens.gap4),
      color: context.colors.border,
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

    return FUISurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(FUIIcons.warning, size: 22, color: colors.warning),
              const SizedBox(width: FUITokens.gap10),
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
                    const SizedBox(height: FUITokens.gap6),
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
          const SizedBox(height: FUITokens.gap14),
          FUIButton(
            label: '重试加载',
            icon: FUIIcons.refresh,
            variant: FUIButtonVariant.secondary,
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
    final settingsController = Get.find<SettingsController>();

    return Obx(() {
      if (!settingsController.homeQuickActionsEnabled.value) {
        return const SizedBox.shrink();
      }
      final actions = settingsController.homeQuickActions
          .where(settingsController.isHomeQuickActionAvailable)
          .map((item) => _buildQuickAction(context, item))
          .toList(growable: false);
      if (actions.isEmpty) {
        return const SizedBox.shrink();
      }
      return _HomeSection(
        title: '快捷操作',
        child: FUISurface(
          padding: EdgeInsets.zero,
          child: _QuickActionGrid(actions: actions),
        ),
      );
    });
  }

  _QuickAction _buildQuickAction(
    BuildContext context,
    HomeQuickActionPreference action,
  ) {
    return _QuickAction(
      icon: _homeQuickActionIcon(action),
      label: action.label,
      onTap: () => _openQuickAction(context, action),
    );
  }

  void _openQuickAction(
    BuildContext context,
    HomeQuickActionPreference action,
  ) {
    Widget page;
    switch (action) {
      case HomeQuickActionPreference.grades:
        page = const QueryPage();
        break;
      case HomeQuickActionPreference.exams:
        page = const ExamsPage();
        break;
      case HomeQuickActionPreference.tasks:
        page = const CourseNotesPage();
        break;
      case HomeQuickActionPreference.attendance:
        page = const AttendancePage();
        break;
      case HomeQuickActionPreference.selectedCourses:
        page = const SelectedCoursesPage();
        break;
      case HomeQuickActionPreference.credit:
        page = const CreditPage();
        break;
      case HomeQuickActionPreference.progress:
        page = const ProgressPage();
        break;
      case HomeQuickActionPreference.studentInfo:
        page = const InfoPage();
        break;
      case HomeQuickActionPreference.time:
        page = const TimePage();
        break;
      case HomeQuickActionPreference.schoolCalendar:
        page = const SchoolCalendarPage();
        break;
      case HomeQuickActionPreference.classroom:
        FUIToast.info(context, message: '功能开发中');
        return;
      case HomeQuickActionPreference.notifications:
        page = const NotificationsPage();
        break;
    }
    FuiNavigation.openDetail(
      context,
      title: _quickActionTitle(action),
      builder: (_) => page,
    );
  }

  String _quickActionTitle(HomeQuickActionPreference action) {
    switch (action) {
      case HomeQuickActionPreference.grades:
        return '成绩查询';
      case HomeQuickActionPreference.exams:
        return '考试查询';
      case HomeQuickActionPreference.tasks:
        return '待办任务';
      case HomeQuickActionPreference.attendance:
        return '统计';
      case HomeQuickActionPreference.selectedCourses:
        return '已选课程';
      case HomeQuickActionPreference.credit:
        return '学分进程';
      case HomeQuickActionPreference.progress:
        return '培养进度';
      case HomeQuickActionPreference.studentInfo:
        return '学生信息';
      case HomeQuickActionPreference.time:
        return '作息时间';
      case HomeQuickActionPreference.schoolCalendar:
        return '校历';
      case HomeQuickActionPreference.classroom:
        return '教室查询';
      case HomeQuickActionPreference.notifications:
        return '通知';
    }
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.actions});

  final List<_QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final rows = <List<_QuickAction>>[];
    for (var i = 0; i < actions.length; i += 4) {
      rows.add(actions.sublist(i, (i + 4).clamp(0, actions.length)));
    }
    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          _QuickActionRow(actions: rows[rowIndex]),
          if (rowIndex != rows.length - 1)
            Divider(height: 1, color: context.colors.border),
        ],
      ],
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
        for (var i = 0; i < 4; i++) ...[
          Expanded(
            child: i < actions.length
                ? _QuickActionCell(action: actions[i])
                : const SizedBox(height: 76),
          ),
          if (i != 3)
            Container(width: 1, height: 42, color: context.colors.border),
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
        height: 76,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, size: 20, color: colors.primary),
            const SizedBox(height: FUITokens.gap6),
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
  const _HomeSection({required this.title, required this.child});

  final String title;
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
          ],
        ),
        const SizedBox(height: FUITokens.gap8),
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

IconData _homeQuickActionIcon(HomeQuickActionPreference action) {
  switch (action) {
    case HomeQuickActionPreference.grades:
      return FUIIcons.grade;
    case HomeQuickActionPreference.exams:
      return FUIIcons.exam;
    case HomeQuickActionPreference.tasks:
      return FUIIcons.book;
    case HomeQuickActionPreference.attendance:
      return FUIIcons.check;
    case HomeQuickActionPreference.selectedCourses:
      return FUIIcons.list;
    case HomeQuickActionPreference.credit:
      return FUIIcons.credit;
    case HomeQuickActionPreference.progress:
      return FUIIcons.progress;
    case HomeQuickActionPreference.studentInfo:
      return FUIIcons.person;
    case HomeQuickActionPreference.time:
      return FUIIcons.schedule;
    case HomeQuickActionPreference.schoolCalendar:
      return FUIIcons.calendar;
    case HomeQuickActionPreference.classroom:
      return FUIIcons.classroom;
    case HomeQuickActionPreference.notifications:
      return FUIIcons.notification;
  }
}

class _HomeSkeletonView extends StatelessWidget {
  const _HomeSkeletonView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final skeletonDeco = BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(FUITokens.radiusLg),
      border: Border.all(color: colors.border),
    );

    return SafeArea(
      top: true,
      bottom: false,
      child: SkeletonShimmer(
        builder: (context, palette) => ListView(
          padding: FUIInsets.page,
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
                  decoration: palette.block(radius: FUITokens.radiusSm),
                ),
              ],
            ),
            const SizedBox(height: FUITokens.gap14),
            Container(
              decoration: skeletonDeco,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 46,
                    decoration: palette.block(radius: FUITokens.radiusFull),
                  ),
                  const SizedBox(width: FUITokens.gap12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBar(
                          decoration: palette.line(radius: 10),
                          widthFactor: 0.62,
                          height: 18,
                        ),
                        const SizedBox(height: FUITokens.gap8),
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
            const SizedBox(height: FUITokens.gap14),
            Container(
              decoration: skeletonDeco,
              padding: const EdgeInsets.symmetric(
                horizontal: FUITokens.gap10,
                vertical: FUITokens.gap12,
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
            const SizedBox(height: FUITokens.gap14),
            Container(
              decoration: skeletonDeco,
              padding: const EdgeInsets.all(14),
              child: _SkeletonCourseItem(palette: palette, colors: colors),
            ),
            const SizedBox(height: FUITokens.gap14),
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
            decoration: palette.block(radius: FUITokens.radiusSm),
          ),
          const SizedBox(height: FUITokens.gap8),
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 0.46,
            height: 14,
          ),
          const SizedBox(height: FUITokens.gap6),
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
      margin: const EdgeInsets.symmetric(horizontal: FUITokens.gap4),
      color: context.colors.border,
    );
  }
}

class _SkeletonCourseItem extends StatelessWidget {
  const _SkeletonCourseItem({required this.palette, required this.colors});

  final SkeletonPalette palette;
  final FUIPalette colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3,
          height: 60,
          decoration: palette.block(radius: FUITokens.radiusFull),
        ),
        const SizedBox(width: FUITokens.gap10),
        Container(
          width: 64,
          height: 38,
          decoration: palette.block(radius: FUITokens.radiusSm),
        ),
        Container(
          width: 1,
          height: 58,
          margin: const EdgeInsets.symmetric(horizontal: FUITokens.gap12),
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
              const SizedBox(height: FUITokens.gap8),
              SkeletonBar(
                decoration: palette.line(radius: 8),
                widthFactor: 0.54,
                height: 12,
              ),
              const SizedBox(height: FUITokens.gap6),
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
                    decoration: palette.block(radius: FUITokens.radiusSm),
                  ),
                  const SizedBox(height: FUITokens.gap8),
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
