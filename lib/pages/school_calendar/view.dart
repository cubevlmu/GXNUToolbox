import 'package:class_tool/data/model/school_calendar.dart';
import 'package:class_tool/pages/school_calendar/controller.dart';
import 'package:class_tool/ui/app_combo_box.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_empty_state.dart';
import 'package:class_tool/ui/app_icon_button.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_page.dart';
import 'package:class_tool/ui/app_surface.dart';
import 'package:class_tool/ui/app_tag.dart';
import 'package:class_tool/ui/app_tokens.dart';
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

  @override
  void initState() {
    super.initState();
    controller = Get.put(SchoolCalendarController(), permanent: false);
  }

  @override
  void dispose() {
    if (Get.isRegistered<SchoolCalendarController>()) {
      Get.delete<SchoolCalendarController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: GetBuilder<SchoolCalendarController>(
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

          return AppPage(
            physics: canInteract
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            children: [
              _CalendarHeader(
                onBack: () => Navigator.of(context).maybePop(),
                onRefresh: canInteract ? controller.refresh : null,
              ),
              const SizedBox(height: AppTokens.gap12),
              _SemesterSelector(controller: controller, enabled: canInteract),
              const SizedBox(height: AppTokens.gap12),
              if (calendar != null) ...[
                _CalendarSummary(calendar: calendar),
                const SizedBox(height: AppTokens.gap12),
              ],
              _CalendarGrid(
                groupedRows: controller.rowsByMonth(),
                onDayTap: (row, day) => _openDaySheet(context, row, day),
              ),
              if (controller.error.isNotEmpty) ...[
                const SizedBox(height: AppTokens.gap12),
                _InlineError(message: controller.error),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _openDaySheet(
    BuildContext context,
    SchoolCalendarWeekRow row,
    SchoolCalendarDay day,
  ) async {
    await showAppBottomSheet<void>(
      context: context,
      heightFactor: 0.38,
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
        AppIconButton(
          icon: AppIcons.chevronLeft,
          tooltip: '返回',
          variant: AppIconButtonVariant.outline,
          onPressed: onBack,
        ),
        const SizedBox(width: AppTokens.gap12),
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
              const SizedBox(height: AppTokens.gap4),
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
        AppIconButton(
          icon: AppIcons.refresh,
          tooltip: '刷新',
          variant: AppIconButtonVariant.ghost,
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
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: AppComboBox<String>(
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

class _CalendarSummary extends StatelessWidget {
  const _CalendarSummary({required this.calendar});

  final SchoolCalendarResponse calendar;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _IconBox(icon: AppIcons.calendar),
          const SizedBox(width: AppTokens.gap10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${calendar.semester} 学期',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppTokens.gap4),
                Text(
                  '${calendar.monthTexts.length} 个月 · ${calendar.rows.length} 个周次',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AppTag(
            label: '${calendar.remarkCount} 条备注',
            variant: calendar.remarkCount > 0
                ? AppTagVariant.primary
                : AppTagVariant.neutral,
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.groupedRows, required this.onDayTap});

  final Map<String, List<SchoolCalendarWeekRow>> groupedRows;
  final void Function(SchoolCalendarWeekRow row, SchoolCalendarDay day)
  onDayTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in groupedRows.entries) ...[
          _MonthCalendarTable(
            monthText: entry.key,
            rows: entry.value,
            onDayTap: onDayTap,
          ),
          const SizedBox(height: AppTokens.gap10),
        ],
      ],
    );
  }
}

class _MonthCalendarTable extends StatelessWidget {
  const _MonthCalendarTable({
    required this.monthText,
    required this.rows,
    required this.onDayTap,
  });

  final String monthText;
  final List<SchoolCalendarWeekRow> rows;
  final void Function(SchoolCalendarWeekRow row, SchoolCalendarDay day)
  onDayTap;

  static const double _weekColumnWidth = 44;
  static const double _dayColumnWidth = 58;
  static const double _cellGap = 3;
  static const double _rowHeight = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tableWidth = _weekColumnWidth + _dayColumnWidth * 7 + _cellGap * 8;

    return AppSurface(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: AppIcons.calendar),
              const SizedBox(width: AppTokens.gap10),
              Expanded(
                child: Text(
                  monthText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AppTag(label: '${rows.length} 周'),
            ],
          ),
          const SizedBox(height: AppTokens.gap8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _TableHeader(
                    weekColumnWidth: _weekColumnWidth,
                    dayColumnWidth: _dayColumnWidth,
                    cellGap: _cellGap,
                  ),
                  const SizedBox(height: AppTokens.gap4),
                  for (final row in rows) ...[
                    SizedBox(
                      height: _rowHeight,
                      child: Row(
                        children: [
                          _WeekCell(
                            width: _weekColumnWidth,
                            text: row.weekText,
                          ),
                          for (var weekday = 1; weekday <= 7; weekday++)
                            _DayCell(
                              width: _dayColumnWidth,
                              day: row.dayAt(weekday),
                              borderColor: colors.border,
                              marginRight: _cellGap,
                              onTap: (day) => onDayTap(row, day),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.gap4),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.weekColumnWidth,
    required this.dayColumnWidth,
    required this.cellGap,
  });

  final double weekColumnWidth;
  final double dayColumnWidth;
  final double cellGap;

  @override
  Widget build(BuildContext context) {
    final labels = ['周次', '一', '二', '三', '四', '五', '六', '日'];
    final colors = context.colors;
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Container(
            width: i == 0 ? weekColumnWidth : dayColumnWidth,
            height: 26,
            margin: EdgeInsets.only(right: cellGap),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(AppTokens.radiusXs),
            ),
            child: Text(
              labels[i],
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w700,
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
        borderRadius: BorderRadius.circular(AppTokens.radiusXs),
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
    required this.width,
    required this.day,
    required this.borderColor,
    required this.marginRight,
    required this.onTap,
  });

  final double width;
  final SchoolCalendarDay? day;
  final Color borderColor;
  final double marginRight;
  final ValueChanged<SchoolCalendarDay> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final item = day;
    if (item == null) {
      return Container(
        width: width,
        height: double.infinity,
        margin: EdgeInsets.only(right: marginRight),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(AppTokens.radiusXs),
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
        borderRadius: BorderRadius.circular(AppTokens.radiusXs),
        onTap: () => onTap(item),
        child: Container(
          width: width,
          height: double.infinity,
          margin: EdgeInsets.only(right: marginRight),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppTokens.radiusXs),
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
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
            _IconBox(icon: AppIcons.calendar),
            const SizedBox(width: AppTokens.gap10),
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
        const SizedBox(height: AppTokens.gap16),
        Text(
          day.dateLabel,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppTokens.gap10),
        Wrap(
          spacing: AppTokens.gap8,
          runSpacing: AppTokens.gap8,
          children: [
            AppTag(label: day.weekdayLabel),
            AppTag(label: '第${row.weekText.isEmpty ? '-' : row.weekText}周'),
            if (row.semester.isNotEmpty) AppTag(label: row.semester),
            if (day.isToday)
              const AppTag(label: '今天', variant: AppTagVariant.primary),
          ],
        ),
        const SizedBox(height: AppTokens.gap16),
        AppSurface(
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
    return AppSurface(
      padding: const EdgeInsets.all(12),
      backgroundColor: context.colors.dangerSoft,
      borderColor: context.colors.danger.withValues(alpha: 0.24),
      child: Row(
        children: [
          Icon(
            AppIcons.warning,
            size: AppTokens.iconMd,
            color: context.colors.danger,
          ),
          const SizedBox(width: AppTokens.gap8),
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
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Icon(icon, size: AppTokens.iconMd, color: colors.primary),
    );
  }
}

class _CalendarSkeletonView extends StatelessWidget {
  const _CalendarSkeletonView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => AppPage(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _CalendarHeader(onBack: onBack, onRefresh: null),
          const SizedBox(height: AppTokens.gap16),
          SkeletonBar(
            decoration: palette.line(radius: AppTokens.radiusMd),
            widthFactor: 1,
            height: 74,
          ),
          const SizedBox(height: AppTokens.gap16),
          SkeletonBar(
            decoration: palette.line(radius: AppTokens.radiusMd),
            widthFactor: 1,
            height: 70,
          ),
          const SizedBox(height: AppTokens.gap16),
          for (var i = 0; i < 3; i++) ...[
            SkeletonBar(
              decoration: palette.line(radius: AppTokens.radiusLg),
              widthFactor: 1,
              height: 250,
            ),
            const SizedBox(height: AppTokens.gap16),
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
    return AppPage(
      children: [
        _CalendarHeader(onBack: onBack, onRefresh: onRefresh),
        const SizedBox(height: AppTokens.gap16),
        AppSurface(
          child: SizedBox(
            height: 320,
            child: AppEmptyState(
              title: title,
              message: message,
              icon: AppIcons.calendar,
              actionLabel: onRefresh == null ? null : '重试',
              onAction: onRefresh,
            ),
          ),
        ),
      ],
    );
  }
}
