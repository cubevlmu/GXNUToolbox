import 'package:class_tool/pages/classes/controller.dart';
import 'package:class_tool/pages/classes/widgets/course_detail_sheet.dart';
import 'package:class_tool/ui/app_colors.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:flutter/material.dart';

class ScheduleTableContent extends StatelessWidget {
  const ScheduleTableContent({
    super.key,
    required this.controller,
    required this.physics,
    this.repaintBoundaryKey,
  });

  static const double _defaultSectionHeight = 84;

  final ClassesController controller;
  final ScrollPhysics physics;
  final GlobalKey? repaintBoundaryKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tableBackgroundTop = Color.alphaBlend(
      colors.primary.withValues(alpha: 0.04),
      colors.background,
    );
    final tableBackgroundBottom = Color.alphaBlend(
      colors.info.withValues(alpha: 0.03),
      colors.surface,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = _ScheduleMetrics.resolve(context, constraints.maxWidth);
        final dayCount = controller.days.isEmpty ? 7 : controller.days.length;
        final viewportWidth =
            (constraints.maxWidth - metrics.horizontalPadding * 2)
                .floorToDouble();
        final tableWidth = viewportWidth < metrics.minTableWidth
            ? metrics.minTableWidth
            : viewportWidth;
        final leftColumnWidth = (tableWidth * metrics.leftColumnFactor)
            .clamp(metrics.leftColumnMinWidth, metrics.leftColumnMaxWidth)
            .floorToDouble();
        final remainingWidth = tableWidth - leftColumnWidth;
        final dayColumnWidth = (remainingWidth / dayCount).clamp(
          metrics.dayColumnMinWidth,
          180.0,
        );
        final sectionHeight = (dayColumnWidth * metrics.sectionHeightFactor)
            .clamp(metrics.minSectionHeight, _defaultSectionHeight);
        final contentWidth = leftColumnWidth + dayCount * dayColumnWidth;
        final contentHeight =
            metrics.headerHeight + controller.sectionCount * sectionHeight;

        final verticalPhysics = AlwaysScrollableScrollPhysics(parent: physics);

        return SingleChildScrollView(
          physics: verticalPhysics,
          padding: EdgeInsets.fromLTRB(
            metrics.horizontalPadding,
            0,
            metrics.horizontalPadding,
            metrics.bottomPadding,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: RepaintBoundary(
              key: repaintBoundaryKey,
              child: Container(
                width: contentWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(metrics.tableRadius),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(metrics.tableRadius),
                  child: Container(
                    height: contentHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [tableBackgroundTop, tableBackgroundBottom],
                      ),
                    ),
                    child: Stack(
                      children: [
                        _ScheduleGridBackground(
                          controller: controller,
                          metrics: metrics,
                          leftColumnWidth: leftColumnWidth,
                          dayColumnWidth: dayColumnWidth,
                          sectionHeight: sectionHeight,
                        ),
                        Stack(
                          children: controller.visibleCourseBlocks
                              .map(
                                (course) => Positioned(
                                  left:
                                      leftColumnWidth +
                                      course.dayIndex * dayColumnWidth +
                                      metrics.courseInset,
                                  top:
                                      metrics.headerHeight +
                                      (course.startSection - 1) *
                                          sectionHeight +
                                      metrics.courseInset,
                                  width:
                                      dayColumnWidth - metrics.courseInset * 2,
                                  height:
                                      course.sectionSpan * sectionHeight -
                                      metrics.courseInset * 2,
                                  child: _CourseBlockCard(
                                    course: course,
                                    metrics: metrics,
                                    onTap: () => showCourseDetailSheet(
                                      context: context,
                                      course: course,
                                      weekdayLabel: controller
                                          .days[course.dayIndex]
                                          .weekdayText,
                                    ),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScheduleGridBackground extends StatelessWidget {
  const _ScheduleGridBackground({
    required this.controller,
    required this.metrics,
    required this.leftColumnWidth,
    required this.dayColumnWidth,
    required this.sectionHeight,
  });

  final ClassesController controller;
  final _ScheduleMetrics metrics;
  final double leftColumnWidth;
  final double dayColumnWidth;
  final double sectionHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final headerCellColor = colors.surfaceAlt;
    final todayHeaderCellColor = Color.alphaBlend(
      colors.primary.withValues(alpha: 0.1),
      colors.surfaceAlt,
    );
    final leftHeaderColor = colors.surfacePressed;
    final borderColor = colors.border;
    final innerBorderColor = colors.border.withValues(alpha: 0.65);

    return Column(
      children: [
        SizedBox(
          height: metrics.headerHeight,
          child: Row(
            children: [
              Container(
                width: leftColumnWidth,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: leftHeaderColor,
                  border: Border(
                    right: BorderSide(color: borderColor),
                    bottom: BorderSide(color: borderColor),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          controller.monthLabel,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: metrics.headerMetaFontSize,
                              ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '节次',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontSize: metrics.headerMetaFontSize),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...controller.days.map(
                (day) => Container(
                  width: dayColumnWidth,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: day.isToday ? todayHeaderCellColor : headerCellColor,
                    border: Border(
                      right: BorderSide(color: borderColor),
                      bottom: BorderSide(color: borderColor),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.dateText,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: metrics.headerDateFontSize,
                        ),
                      ),
                      Text(
                        day.weekdayText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: metrics.headerWeekdayFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(controller.sectionCount, (index) {
          final section = index + 1;
          return SizedBox(
            height: sectionHeight,
            child: Row(
              children: [
                Container(
                  width: leftColumnWidth,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: borderColor),
                      bottom: BorderSide(color: innerBorderColor),
                    ),
                  ),
                  child: Text(
                    '$section',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: metrics.sectionLabelFontSize,
                    ),
                  ),
                ),
                ...List.generate(
                  controller.days.length,
                  (_) => Container(
                    width: dayColumnWidth,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: borderColor),
                        bottom: BorderSide(color: innerBorderColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _CourseBlockCard extends StatelessWidget {
  const _CourseBlockCard({
    required this.course,
    required this.metrics,
    required this.onTap,
  });

  final CourseBlock course;
  final _ScheduleMetrics metrics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final foregroundColor = _foregroundColorFor(course.color);
        final secondaryForegroundColor = foregroundColor.withValues(
          alpha: 0.84,
        );
        final titleFontSize = _adaptiveFontSize(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          max: metrics.titleFontMax,
          min: metrics.titleFontMin,
          factor: metrics.titleFontFactor,
        );
        final bodyFontSize = _adaptiveFontSize(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          max: metrics.bodyFontMax,
          min: metrics.bodyFontMin,
          factor: metrics.bodyFontFactor,
        );
        final titleLineHeight = titleFontSize * metrics.titleLineHeight;
        final bodyLineHeight = bodyFontSize * metrics.bodyLineHeight;
        final availableHeight = constraints.maxHeight - metrics.cardPadding * 2;
        final titleLines = (availableHeight * 0.54 / titleLineHeight)
            .floor()
            .clamp(2, 8);
        final classroomLines = (availableHeight * 0.38 / bodyLineHeight)
            .floor()
            .clamp(1, 8);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(metrics.cardRadius),
            onTap: onTap,
            child: Ink(
              padding: EdgeInsets.all(metrics.cardPadding),
              decoration: BoxDecoration(
                color: course.color,
                borderRadius: BorderRadius.circular(metrics.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.textPrimary.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: titleLines,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: foregroundColor,
                      fontSize: titleFontSize,
                      height: metrics.titleLineHeight,
                    ),
                  ),
                  SizedBox(height: metrics.cardGap),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        course.classroom,
                        maxLines: classroomLines,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: secondaryForegroundColor,
                          fontSize: bodyFontSize,
                          height: metrics.bodyLineHeight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _adaptiveFontSize({
    required double width,
    required double height,
    required double min,
    required double max,
    required double factor,
  }) {
    final widthBased = width * factor;
    final heightBased = height * 0.11;
    final resolved = widthBased < heightBased ? widthBased : heightBased;
    return resolved.clamp(min, max);
  }

  Color _foregroundColorFor(Color background) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    if (brightness == Brightness.dark) {
      return AppColors.dark.textPrimary;
    }
    return AppColors.light.textPrimary;
  }
}

class _ScheduleMetrics {
  const _ScheduleMetrics({
    required this.minTableWidth,
    required this.horizontalPadding,
    required this.bottomPadding,
    required this.leftColumnFactor,
    required this.leftColumnMinWidth,
    required this.leftColumnMaxWidth,
    required this.dayColumnMinWidth,
    required this.sectionHeightFactor,
    required this.minSectionHeight,
    required this.headerHeight,
    required this.tableRadius,
    required this.courseInset,
    required this.cardRadius,
    required this.cardPadding,
    required this.cardGap,
    required this.headerMetaFontSize,
    required this.headerDateFontSize,
    required this.headerWeekdayFontSize,
    required this.sectionLabelFontSize,
    required this.titleFontMin,
    required this.titleFontMax,
    required this.bodyFontMin,
    required this.bodyFontMax,
    required this.titleFontFactor,
    required this.bodyFontFactor,
    required this.titleLineHeight,
    required this.bodyLineHeight,
  });

  final double minTableWidth;
  final double horizontalPadding;
  final double bottomPadding;
  final double leftColumnFactor;
  final double leftColumnMinWidth;
  final double leftColumnMaxWidth;
  final double dayColumnMinWidth;
  final double sectionHeightFactor;
  final double minSectionHeight;
  final double headerHeight;
  final double tableRadius;
  final double courseInset;
  final double cardRadius;
  final double cardPadding;
  final double cardGap;
  final double headerMetaFontSize;
  final double headerDateFontSize;
  final double headerWeekdayFontSize;
  final double sectionLabelFontSize;
  final double titleFontMin;
  final double titleFontMax;
  final double bodyFontMin;
  final double bodyFontMax;
  final double titleFontFactor;
  final double bodyFontFactor;
  final double titleLineHeight;
  final double bodyLineHeight;

  static _ScheduleMetrics resolve(BuildContext context, double width) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final compact = shortestSide < 600 || width < 480;
    if (compact) {
      return const _ScheduleMetrics(
        minTableWidth: 308,
        horizontalPadding: 4,
        bottomPadding: 12,
        leftColumnFactor: 0.058,
        leftColumnMinWidth: 16,
        leftColumnMaxWidth: 22,
        dayColumnMinWidth: 37,
        sectionHeightFactor: 1.1,
        minSectionHeight: 68,
        headerHeight: 34,
        tableRadius: 10,
        courseInset: 2,
        cardRadius: 8,
        cardPadding: 4.5,
        cardGap: 2,
        headerMetaFontSize: 8.5,
        headerDateFontSize: 9.5,
        headerWeekdayFontSize: 8.5,
        sectionLabelFontSize: 10.5,
        titleFontMin: 10.5,
        titleFontMax: 14.5,
        bodyFontMin: 9,
        bodyFontMax: 12.5,
        titleFontFactor: 0.205,
        bodyFontFactor: 0.175,
        titleLineHeight: 1.1,
        bodyLineHeight: 1.1,
      );
    }

    return const _ScheduleMetrics(
      minTableWidth: 420,
      horizontalPadding: 12,
      bottomPadding: 16,
      leftColumnFactor: 0.08,
      leftColumnMinWidth: 28,
      leftColumnMaxWidth: 42,
      dayColumnMinWidth: 50,
      sectionHeightFactor: 0.86,
      minSectionHeight: 64,
      headerHeight: 48,
      tableRadius: 16,
      courseInset: 4,
      cardRadius: 14,
      cardPadding: 8,
      cardGap: 4,
      headerMetaFontSize: 11,
      headerDateFontSize: 14,
      headerWeekdayFontSize: 12,
      sectionLabelFontSize: 14,
      titleFontMin: 11,
      titleFontMax: 18,
      bodyFontMin: 10.5,
      bodyFontMax: 16,
      titleFontFactor: 0.215,
      bodyFontFactor: 0.19,
      titleLineHeight: 1.18,
      bodyLineHeight: 1.2,
    );
  }
}
