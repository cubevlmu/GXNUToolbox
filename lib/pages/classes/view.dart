import 'package:class_tool/pages/classes/controller.dart';
import 'package:class_tool/pages/classes/table_schedule_page.dart';
import 'package:class_tool/pages/classes/widgets/course_detail_sheet.dart';
import 'package:class_tool/pages/classes/widgets/schedule_picker_sheet.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:fin_ui/app_context.dart';
import 'package:fin_ui/app_empty_state.dart';
import 'package:fin_ui/app_icon_button.dart';
import 'package:fin_ui/app_icons.dart';
import 'package:fin_ui/app_refresh.dart';
import 'package:fin_ui/app_surface.dart';
import 'package:fin_ui/app_tag.dart';
import 'package:fin_ui/app_tokens.dart';
import 'package:fin_ui/fui_navigation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  int _selectedWeekday = DateTime.now().weekday;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GetBuilder<ClassesController>(
                  id: 'classes-header',
                  builder: (controller) =>
                      _ClassesHeader(controller: controller),
                ),
                const SizedBox(height: FUITokens.gap12),
                GetBuilder<ClassesController>(
                  id: 'classes-header',
                  builder: (controller) =>
                      _ClassesToolbar(controller: controller),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FUIRefresh(
                  onRefresh: Get.find<ClassesController>().refreshSchedule,
                  refreshOnStart: false,
                  loadEnabled: false,
                  childBuilder: (context, physics) => ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                      scrollbars: false,
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                        PointerDeviceKind.stylus,
                        PointerDeviceKind.unknown,
                      },
                    ),
                    child: GetBuilder<ClassesController>(
                      id: 'schedule-table',
                      builder: (controller) {
                        if (controller.scheduleError.isNotEmpty &&
                            !controller.hasScheduleData) {
                          return _ClassesFeedbackState(
                            title: '课表加载失败',
                            subtitle: controller.scheduleError,
                          );
                        }

                        if (controller.isLoading &&
                            !controller.hasScheduleData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: context.colors.primary,
                              strokeWidth: 2.4,
                            ),
                          );
                        }

                        return _AgendaScheduleView(
                          controller: controller,
                          physics: physics,
                          selectedWeekday: _selectedWeekday,
                          onWeekdaySelected: (value) {
                            setState(() => _selectedWeekday = value);
                          },
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 18,
                  child: GetBuilder<ClassesController>(
                    id: 'schedule-table',
                    builder: (controller) {
                      if (!controller.shouldShowReturnToday(_selectedWeekday)) {
                        return const SizedBox.shrink();
                      }
                      return _ReturnTodayFloatingButton(
                        onPressed: () {
                          controller.returnToToday(
                            onWeekdayResolved: (value) {
                              if (mounted) {
                                setState(() => _selectedWeekday = value);
                              }
                            },
                          );
                        },
                      );
                    },
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

class _ClassesToolbar extends StatelessWidget {
  const _ClassesToolbar({required this.controller});

  final ClassesController controller;

  @override
  Widget build(BuildContext context) {
    final enabled = !controller.isLoading;
    final colors = context.colors;
    final foregroundColor = enabled ? colors.textPrimary : colors.textSecondary;

    return FUISurface(
      backgroundColor: colors.surface,
      borderColor: colors.border,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _ScheduleSelector(
            flex: 5,
            label: '学期',
            value: _compactSemester(controller.selectedSemester),
            enabled: enabled,
            foregroundColor: foregroundColor,
            selectedValue: '${controller.selectedSemester}学期',
            items: controller.semesters
                .map((item) => SelectionSheetItem(label: '${item.label}学期'))
                .toList(growable: false),
            onSelected: (value) {
              controller.changeSemester(value.replaceFirst('学期', ''));
            },
          ),
          Container(
            width: 1,
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: foregroundColor.withValues(alpha: 0.18),
          ),
          _ScheduleSelector(
            flex: 3,
            label: '周目',
            value: _compactWeek(controller.selectedWeek),
            enabled: enabled,
            foregroundColor: foregroundColor,
            selectedValue: controller.selectedWeek,
            items: controller.weeks
                .map(
                  (item) => SelectionSheetItem(
                    label: item.label,
                    subtitle: item.extra,
                  ),
                )
                .toList(growable: false),
            onSelected: controller.changeWeek,
          ),
        ],
      ),
    );
  }
}

class _ClassesHeader extends StatelessWidget {
  const _ClassesHeader({required this.controller});

  final ClassesController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subtitle = [
      if (controller.selectedSemester.isNotEmpty) controller.selectedSemester,
      if (controller.selectedWeek.isNotEmpty) controller.selectedWeek,
    ].join(' · ');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '课表',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: FUITokens.gap4),
              Text(
                subtitle.isEmpty ? '查看本周课程安排' : subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        FUIIconButton(
          icon: FUIIcons.refresh,
          tooltip: '刷新课表',
          variant: FUIIconButtonVariant.ghost,
          onPressed: controller.isLoading ? null : controller.refreshSchedule,
        ),
        const SizedBox(width: FUITokens.gap8),
        FUIIconButton(
          icon: FUIIcons.calendar,
          tooltip: '表格课表',
          variant: FUIIconButtonVariant.ghost,
          onPressed: () => FuiNavigation.openDetail(
            context,
            title: '表格课表',
            builder: (_) => const TableSchedulePage(),
          ),
        ),
      ],
    );
  }
}

class _ReturnTodayFloatingButton extends StatelessWidget {
  const _ReturnTodayFloatingButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: '回到今天',
      child: FloatingActionButton(
        heroTag: 'classes_return_today',
        elevation: 4,
        backgroundColor: colors.primary,
        foregroundColor: colors.textInverse,
        onPressed: onPressed,
        child: const Icon(FUIIcons.today, size: 28),
      ),
    );
  }
}

class _AgendaScheduleView extends StatelessWidget {
  const _AgendaScheduleView({
    required this.controller,
    required this.physics,
    required this.selectedWeekday,
    required this.onWeekdaySelected,
  });

  final ClassesController controller;
  final ScrollPhysics physics;
  final int selectedWeekday;
  final ValueChanged<int> onWeekdaySelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selectedDayIndex = (selectedWeekday - 1).clamp(0, 6);
    final selectedCourses =
        controller.visibleCourseBlocks
            .where((course) => course.dayIndex == selectedDayIndex)
            .toList(growable: false)
          ..sort((a, b) => a.startSection.compareTo(b.startSection));

    return ListView(
      physics: AlwaysScrollableScrollPhysics(parent: physics),
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 24),
      children: [
        _WeekDateStrip(
          days: controller.days,
          selectedWeekday: selectedWeekday,
          onSelected: onWeekdaySelected,
          onWeekSwipe: controller.changeWeekByOffset,
        ),
        const SizedBox(height: FUITokens.gap16),
        Row(
          children: [
            Expanded(
              child: Text(
                '${_weekdayLabel(selectedWeekday)}课程',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${selectedCourses.length} 节',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: FUITokens.gap8),
        _SelectedDaySchedule(
          courses: selectedCourses,
          weekdayLabel: controller.days.length > selectedDayIndex
              ? controller.days[selectedDayIndex].weekdayText
              : _weekdayLabel(selectedWeekday),
          periodSettings: controller.effectivePeriodSettings,
        ),
      ],
    );
  }
}

class _WeekDateStrip extends StatelessWidget {
  const _WeekDateStrip({
    required this.days,
    required this.selectedWeekday,
    required this.onSelected,
    required this.onWeekSwipe,
  });

  final List<ScheduleDay> days;
  final int selectedWeekday;
  final ValueChanged<int> onSelected;
  final ValueChanged<int> onWeekSwipe;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() < 180) {
          return;
        }
        onWeekSwipe(velocity < 0 ? 1 : -1);
      },
      child: Row(
        children: List.generate(7, (index) {
          final weekday = index + 1;
          final day = index < days.length ? days[index] : null;
          final selected = weekday == selectedWeekday;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(weekday),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    day?.weekdayText ??
                        _weekdayLabel(weekday).replaceFirst('周', ''),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FUITokens.gap6),
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? colors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _dayNumberText(day?.dateText, weekday),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: selected
                            ? colors.textInverse
                            : colors.textPrimary,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: FUITokens.gap4),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: day?.isToday == true
                          ? colors.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String _dayNumberText(String? raw, int fallback) {
    final matches = RegExp(r'\d+').allMatches(raw ?? '').toList();
    return matches.isEmpty ? '$fallback' : matches.last.group(0)!;
  }
}

class _SelectedDaySchedule extends StatelessWidget {
  const _SelectedDaySchedule({
    required this.courses,
    required this.weekdayLabel,
    required this.periodSettings,
  });

  final List<CourseBlock> courses;
  final String weekdayLabel;
  final List<ClassPeriodSetting> periodSettings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FUISurface(
      padding: EdgeInsets.zero,
      child: courses.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(FUITokens.gap16),
              child: Row(
                children: [
                  Icon(FUIIcons.check, color: colors.textTertiary, size: 18),
                  const SizedBox(width: FUITokens.gap8),
                  Text(
                    '当天暂无课程',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < courses.length; i++) ...[
                  _CompactCourseRow(
                    course: courses[i],
                    weekdayLabel: weekdayLabel,
                    periodSettings: periodSettings,
                  ),
                  if (i != courses.length - 1)
                    Divider(height: 1, color: colors.border),
                ],
              ],
            ),
    );
  }
}

class _CompactCourseRow extends StatelessWidget {
  const _CompactCourseRow({
    required this.course,
    required this.weekdayLabel,
    required this.periodSettings,
  });

  final CourseBlock course;
  final String weekdayLabel;
  final List<ClassPeriodSetting> periodSettings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showCourseDetailSheet(
        context: context,
        course: course,
        weekdayLabel: weekdayLabel,
      ),
      child: Padding(
        padding: const EdgeInsets.all(FUITokens.gap12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 68,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _startTimeText(course),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: FUITokens.gap4),
                  Text(
                    _endTimeText(course),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: colors.textTertiary),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 58, color: colors.border),
            const SizedBox(width: FUITokens.gap12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: FUITokens.gap8),
                      Expanded(
                        child: Text(
                          course.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FUITokens.gap6),
                  if (course.classroom.isNotEmpty)
                    _CourseMetaRow(
                      icon: FUIIcons.location,
                      text: course.classroom,
                    ),
                  if (course.teacher.isNotEmpty)
                    _CourseMetaRow(icon: FUIIcons.person, text: course.teacher),
                  if (course.weeks.isNotEmpty)
                    _CourseMetaRow(icon: FUIIcons.calendar, text: course.weeks),
                ],
              ),
            ),
            const SizedBox(width: FUITokens.gap8),
            FUITag(
              label: _sectionRangeText(course),
              variant: FUITagVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _startTimeText(CourseBlock course) {
    final start = _periodForSection(course.startSection);
    if (start == null || start.startTime.isEmpty) {
      return '第${course.startSection}节';
    }
    return start.startTime;
  }

  String _endTimeText(CourseBlock course) {
    final end = course.startSection + course.sectionSpan - 1;
    final period = _periodForSection(end);
    if (period == null || period.endTime.isEmpty) {
      return course.sectionSpan <= 1 ? '单节课' : '至第$end节';
    }
    return period.endTime;
  }

  String _sectionRangeText(CourseBlock course) {
    final end = course.startSection + course.sectionSpan - 1;
    return course.sectionSpan <= 1
        ? '第${course.startSection}节'
        : '第${course.startSection}-$end节';
  }

  ClassPeriodSetting? _periodForSection(int section) {
    for (final item in periodSettings) {
      if (item.section == section) return item;
    }
    return null;
  }
}

String _weekdayLabel(int weekday) {
  const labels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return labels[(weekday - 1).clamp(0, 6)];
}

class _CourseMetaRow extends StatelessWidget {
  const _CourseMetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: FUITokens.iconSm, color: colors.textTertiary),
        const SizedBox(width: FUITokens.gap6),
        Expanded(
          child: Text(
            text.isEmpty ? '待定' : text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _ScheduleSelector extends StatelessWidget {
  const _ScheduleSelector({
    required this.flex,
    required this.label,
    required this.value,
    required this.enabled,
    required this.foregroundColor,
    required this.selectedValue,
    required this.items,
    required this.onSelected,
  });

  final int flex;
  final String label;
  final String value;
  final bool enabled;
  final Color foregroundColor;
  final String selectedValue;
  final List<SelectionSheetItem> items;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: _SelectorRow(
        label: label,
        value: value,
        enabled: enabled,
        foregroundColor: foregroundColor,
        onTap: enabled
            ? () => showScheduleSelectionSheet(
                context: context,
                selectedValue: selectedValue,
                items: items,
                onSelected: onSelected,
              )
            : null,
      ),
    );
  }
}

class _SelectorRow extends StatelessWidget {
  const _SelectorRow({
    required this.label,
    required this.value,
    required this.enabled,
    required this.foregroundColor,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool enabled;
  final Color foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              Text(
                '$label: ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: Text(
                  value.isEmpty ? '未选择' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: foregroundColor),
                ),
              ),
              const SizedBox(width: 1),
              Icon(FUIIcons.chevronDown, color: foregroundColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassesFeedbackState extends StatelessWidget {
  const _ClassesFeedbackState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FUIEmptyState(
          title: title,
          message: subtitle,
          icon: FUIIcons.calendar,
        ),
      ),
    );
  }
}

String _compactWeek(String raw) {
  final match = RegExp(r'\d+').firstMatch(raw);
  return match?.group(0) ?? raw;
}

String _compactSemester(String raw) {
  if (raw.isEmpty) {
    return raw;
  }

  final rangeMatch = RegExp(r'(\d{4})[-到](\d{4})').firstMatch(raw);
  final termMatch = RegExp(r'第?\s*(\d+)\s*学期').firstMatch(raw);
  final trailingTermMatch = RegExp(r'[-_](\d+)$').firstMatch(raw);

  if (rangeMatch != null) {
    final startYear = rangeMatch.group(1)!;
    final endYear = rangeMatch.group(2)!;
    final term =
        termMatch?.group(1) ??
        trailingTermMatch?.group(1) ??
        RegExp(r'(\d)$').firstMatch(raw)?.group(1);
    if (term != null) {
      return '$startYear-$endYear $term';
    }
    return '$startYear-$endYear';
  }

  return raw.replaceAll('学期', '').trim();
}
