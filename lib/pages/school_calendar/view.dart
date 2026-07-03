import 'package:class_tool/data/model/school_calendar.dart';
import 'package:class_tool/pages/school_calendar/controller.dart';
import 'package:fin_ui/app_combo_box.dart';
import 'package:fin_ui/app_context.dart';
import 'package:fin_ui/app_empty_state.dart';
import 'package:fin_ui/app_icon_button.dart';
import 'package:fin_ui/app_icons.dart';
import 'package:fin_ui/app_page.dart';
import 'package:fin_ui/app_surface.dart';
import 'package:fin_ui/app_tag.dart';
import 'package:fin_ui/app_tokens.dart';
import 'package:class_tool/widgets/app_bottom_sheet.dart';
import 'package:class_tool/widgets/skeleton_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SchoolCalendarPage extends StatefulWidget {
  const SchoolCalendarPage({super.key});

  @override
  State<SchoolCalendarPage> createState() => _SchoolCalendarPageState();
}

class _SchoolCalendarPageState extends State<SchoolCalendarPage> {
  late final SchoolCalendarController controller;
  final String _controllerTag = UniqueKey().toString();
  int _selectedMonthIndex = 0;
  String _activeMonthListKey = '';

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      SchoolCalendarController(),
      tag: _controllerTag,
      permanent: false,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<SchoolCalendarController>(tag: _controllerTag)) {
      Get.delete<SchoolCalendarController>(tag: _controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: GetBuilder<SchoolCalendarController>(
        tag: _controllerTag,
        id: 'school-calendar-content',
        builder: (controller) {
          final canInteract = !controller.isLoading;

          if (controller.isLoading && !controller.hasData) {
            return _CalendarSkeletonView(
              onBack: () => Navigator.of(context).maybePop(),
            );
          }

          if (controller.error.isNotEmpty && !controller.hasData) {
            return _FeedbackState(
              title: '校历加载失败',
              message: controller.error,
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: canInteract ? controller.refresh : null,
            );
          }

          if (!controller.hasData) {
            return _FeedbackState(
              title: '暂无校历数据',
              message: '切换学期或刷新后重试',
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: canInteract ? controller.refresh : null,
            );
          }

          final calendar = controller.calendar;
          final monthEntries = controller.rowsByMonth().entries.toList();
          final selectedMonthIndex = _resolveSelectedMonthIndex(
            controller.selectedSemester,
            monthEntries,
          );

          return FUIPage(
            physics: canInteract
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            children: [
              _CalendarHeader(
                onBack: () => Navigator.of(context).maybePop(),
                onRefresh: canInteract ? controller.refresh : null,
              ),
              const SizedBox(height: FUITokens.gap12),
              _SemesterSelector(controller: controller, enabled: canInteract),
              const SizedBox(height: FUITokens.gap12),
              _MonthCalendarCard(
                semester: calendar?.semester ?? controller.selectedSemester,
                monthEntries: monthEntries,
                selectedIndex: selectedMonthIndex,
                remarkCount: calendar?.remarkCount ?? 0,
                onPrevious: selectedMonthIndex > 0
                    ? () => _changeMonth(selectedMonthIndex - 1)
                    : null,
                onNext: selectedMonthIndex < monthEntries.length - 1
                    ? () => _changeMonth(selectedMonthIndex + 1)
                    : null,
                onDayTap: (row, day) => _openDaySheet(context, row, day),
              ),
              if (controller.error.isNotEmpty) ...[
                const SizedBox(height: FUITokens.gap12),
                _InlineError(message: controller.error),
              ],
            ],
          );
        },
      ),
    );
  }

  int _resolveSelectedMonthIndex(
    String semester,
    List<MapEntry<String, List<SchoolCalendarWeekRow>>> monthEntries,
  ) {
    final monthListKey =
        '$semester|${monthEntries.map((entry) => entry.key).join(',')}';
    if (_activeMonthListKey != monthListKey) {
      _activeMonthListKey = monthListKey;
      _selectedMonthIndex = _currentMonthIndex(monthEntries);
    }
    final monthCount = monthEntries.length;
    if (monthCount <= 0) {
      _selectedMonthIndex = 0;
      return 0;
    }
    if (_selectedMonthIndex >= monthCount) {
      _selectedMonthIndex = monthCount - 1;
    }
    return _selectedMonthIndex;
  }

  int _currentMonthIndex(
    List<MapEntry<String, List<SchoolCalendarWeekRow>>> monthEntries,
  ) {
    if (monthEntries.isEmpty) {
      return 0;
    }

    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final index = monthEntries.indexWhere((entry) => entry.key == currentMonth);
    return index < 0 ? 0 : index;
  }

  void _changeMonth(int nextIndex) {
    setState(() {
      _selectedMonthIndex = nextIndex;
    });
  }

  Future<void> _openDaySheet(
    BuildContext context,
    SchoolCalendarWeekRow row,
    SchoolCalendarDay day,
  ) async {
    await showAppBottomSheet<void>(
      context: context,
      child: _CalendarDaySheet(row: row, day: day),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({required this.onBack, required this.onRefresh});

  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        FUIIconButton(
          icon: FUIIcons.chevronLeft,
          tooltip: '返回',
          variant: FUIIconButtonVariant.outline,
          onPressed: onBack,
        ),
        const SizedBox(width: FUITokens.gap12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '校历',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: FUITokens.gap4),
              Text(
                '按月份、周次查看学期校历',
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
          tooltip: '刷新',
          variant: FUIIconButtonVariant.ghost,
          onPressed: onRefresh,
        ),
      ],
    );
  }
}

class _SemesterSelector extends StatelessWidget {
  const _SemesterSelector({required this.controller, required this.enabled});

  final SchoolCalendarController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: FUIComboBox<String>(
        label: '学年学期',
        value: controller.selectedSemester,
        items: controller.semesterOptions,
        itemLabelBuilder: (item) => '$item 学期',
        enabled: enabled,
        onChanged: (item) {
          if (item == null) return;
          controller.selectSemester(item);
        },
      ),
    );
  }
}

class _MonthCalendarCard extends StatelessWidget {
  const _MonthCalendarCard({
    required this.semester,
    required this.monthEntries,
    required this.selectedIndex,
    required this.remarkCount,
    required this.onPrevious,
    required this.onNext,
    required this.onDayTap,
  });

  final String semester;
  final List<MapEntry<String, List<SchoolCalendarWeekRow>>> monthEntries;
  final int selectedIndex;
  final int remarkCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final void Function(SchoolCalendarWeekRow row, SchoolCalendarDay day)
  onDayTap;

  static const double _cellGap = 4;
  static const double _rowHeight = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final entry = monthEntries.isEmpty
        ? const MapEntry<String, List<SchoolCalendarWeekRow>>(
            '未分组',
            <SchoolCalendarWeekRow>[],
          )
        : monthEntries[selectedIndex];
    final rows = entry.value;

    return FUISurface(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: FUIIcons.calendar),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: FUITokens.gap2),
                    Text(
                      '$semester 学期 · ${selectedIndex + 1}/${monthEntries.length} 月',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              FUIIconButton(
                icon: FUIIcons.chevronLeft,
                tooltip: '上个月',
                variant: FUIIconButtonVariant.ghost,
                onPressed: onPrevious,
              ),
              FUIIconButton(
                icon: FUIIcons.chevronRight,
                tooltip: '下个月',
                variant: FUIIconButtonVariant.ghost,
                onPressed: onNext,
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap10),
          Wrap(
            spacing: FUITokens.gap8,
            runSpacing: FUITokens.gap8,
            children: [
              FUITag(label: '${rows.length} 周'),
              FUITag(
                label: '${monthEntries.length} 个月',
                variant: FUITagVariant.neutral,
              ),
              FUITag(
                label: '$remarkCount 条备注',
                variant: remarkCount > 0
                    ? FUITagVariant.primary
                    : FUITagVariant.neutral,
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap10),
          LayoutBuilder(
            builder: (context, constraints) {
              final weekColumnWidth = constraints.maxWidth < 360 ? 34.0 : 42.0;
              return Column(
                children: [
                  _TableHeader(
                    weekColumnWidth: weekColumnWidth,
                    cellGap: _cellGap,
                  ),
                  const SizedBox(height: FUITokens.gap4),
                  for (final row in rows) ...[
                    SizedBox(
                      height: _rowHeight,
                      child: Row(
                        children: [
                          _WeekCell(width: weekColumnWidth, text: row.weekText),
                          for (var weekday = 1; weekday <= 7; weekday++)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: _cellGap),
                                child: _DayCell(
                                  day: row.dayAt(weekday),
                                  borderColor: colors.border,
                                  onTap: (day) => onDayTap(row, day),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FUITokens.gap4),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.weekColumnWidth, required this.cellGap});

  final double weekColumnWidth;
  final double cellGap;

  @override
  Widget build(BuildContext context) {
    final labels = ['周次', '一', '二', '三', '四', '五', '六', '日'];
    final colors = context.colors;
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          if (i == 0)
            Container(
              width: weekColumnWidth,
              height: 26,
              margin: EdgeInsets.only(right: cellGap),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(FUITokens.radiusXs),
              ),
              child: Text(
                labels[i],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Expanded(
              child: Container(
                height: 26,
                margin: EdgeInsets.only(right: cellGap),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(FUITokens.radiusXs),
                ),
                child: Text(
                  labels[i],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _WeekCell extends StatelessWidget {
  const _WeekCell({required this.width, required this.text});

  final double width;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: width,
      height: double.infinity,
      margin: const EdgeInsets.only(right: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(FUITokens.radiusXs),
      ),
      child: Text(
        text.isEmpty ? '-' : text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.borderColor,
    required this.onTap,
  });

  final SchoolCalendarDay? day;
  final Color borderColor;
  final ValueChanged<SchoolCalendarDay> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final item = day;
    if (item == null) {
      return Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(FUITokens.radiusXs),
          border: Border.all(color: borderColor),
        ),
      );
    }

    final background = item.isToday
        ? colors.primary
        : item.hasRemark
        ? colors.primarySoft
        : colors.surface;
    final textColor = item.isToday
        ? colors.textInverse
        : item.hasRemark
        ? colors.primary
        : colors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(FUITokens.radiusXs),
        onTap: () => onTap(item),
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(FUITokens.radiusXs),
            border: Border.all(
              color: item.isToday ? colors.primary : borderColor,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.dayText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (item.hasRemark) ...[
                const SizedBox(height: 3),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: item.isToday ? colors.textInverse : colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarDaySheet extends StatelessWidget {
  const _CalendarDaySheet({required this.row, required this.day});

  final SchoolCalendarWeekRow row;
  final SchoolCalendarDay day;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        Row(
          children: [
            _IconBox(icon: FUIIcons.calendar),
            const SizedBox(width: FUITokens.gap10),
            Expanded(
              child: Text(
                '校历详情',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: FUITokens.gap16),
        Text(
          day.dateLabel,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: FUITokens.gap10),
        Wrap(
          spacing: FUITokens.gap8,
          runSpacing: FUITokens.gap8,
          children: [
            FUITag(label: day.weekdayLabel),
            FUITag(label: '第${row.weekText.isEmpty ? '-' : row.weekText}周'),
            if (row.semester.isNotEmpty) FUITag(label: row.semester),
            if (day.isToday)
              const FUITag(label: '今天', variant: FUITagVariant.primary),
          ],
        ),
        const SizedBox(height: FUITokens.gap16),
        FUISurface(
          padding: const EdgeInsets.all(14),
          child: Text(
            day.hasRemark ? day.remark : '暂无备注信息',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: day.hasRemark ? colors.textPrimary : colors.textTertiary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.all(12),
      backgroundColor: context.colors.dangerSoft,
      borderColor: context.colors.danger.withValues(alpha: 0.24),
      child: Row(
        children: [
          Icon(
            FUIIcons.warning,
            size: FUITokens.iconMd,
            color: context.colors.danger,
          ),
          const SizedBox(width: FUITokens.gap8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(FUITokens.radiusSm),
      ),
      child: Icon(icon, size: FUITokens.iconMd, color: colors.primary),
    );
  }
}

class _CalendarSkeletonView extends StatelessWidget {
  const _CalendarSkeletonView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => FUIPage(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _CalendarHeader(onBack: onBack, onRefresh: null),
          const SizedBox(height: FUITokens.gap16),
          SkeletonBar(
            decoration: palette.line(radius: FUITokens.radiusMd),
            widthFactor: 1,
            height: 74,
          ),
          const SizedBox(height: FUITokens.gap16),
          SkeletonBar(
            decoration: palette.line(radius: FUITokens.radiusMd),
            widthFactor: 1,
            height: 70,
          ),
          const SizedBox(height: FUITokens.gap16),
          for (var i = 0; i < 3; i++) ...[
            SkeletonBar(
              decoration: palette.line(radius: FUITokens.radiusLg),
              widthFactor: 1,
              height: 250,
            ),
            const SizedBox(height: FUITokens.gap16),
          ],
        ],
      ),
    );
  }
}

class _FeedbackState extends StatelessWidget {
  const _FeedbackState({
    required this.title,
    required this.message,
    required this.onBack,
    required this.onRefresh,
  });

  final String title;
  final String message;
  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return FUIPage(
      children: [
        _CalendarHeader(onBack: onBack, onRefresh: onRefresh),
        const SizedBox(height: FUITokens.gap16),
        FUISurface(
          child: SizedBox(
            height: 320,
            child: FUIEmptyState(
              title: title,
              message: message,
              icon: FUIIcons.calendar,
              actionLabel: onRefresh == null ? null : '重试',
              onAction: onRefresh,
            ),
          ),
        ),
      ],
    );
  }
}
