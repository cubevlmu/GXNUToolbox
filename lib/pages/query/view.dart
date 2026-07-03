/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/grade.dart';
import 'package:class_tool/pages/query/controller.dart';
import 'package:fui/app_button.dart';
import 'package:fui/app_combo_box.dart';
import 'package:fui/app_context.dart';
import 'package:fui/app_empty_state.dart';
import 'package:fui/app_icon_button.dart';
import 'package:fui/app_icons.dart';
import 'package:fui/app_page.dart';
import 'package:fui/app_surface.dart';
import 'package:fui/app_tag.dart';
import 'package:fui/app_tokens.dart';
import 'package:fui/fui_page_head.dart';
import 'package:class_tool/widgets/app_bottom_sheet.dart';
import 'package:class_tool/widgets/simple_easy_refresher.dart';
import 'package:class_tool/widgets/skeleton_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QueryPage extends StatefulWidget {
  const QueryPage({super.key});

  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  late final QueryController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(QueryController(), permanent: false);
  }

  @override
  void dispose() {
    if (Get.isRegistered<QueryController>()) {
      Get.delete<QueryController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: GetBuilder<QueryController>(
        id: 'query-content',
        builder: (controller) {
          final canInteract =
              !controller.isLoading && !controller.isLoadingMore;

          if (controller.isLoading && !controller.hasData) {
            return const _QuerySkeletonView();
          }

          if (controller.error.isNotEmpty && !controller.hasData) {
            return _QueryFeedbackState(
              title: '成绩加载失败',
              message: controller.error,
              onFilter: canInteract ? () => _openFilterSheet(context) : null,
              onRefresh: canInteract ? controller.refreshGrades : null,
            );
          }

          if (!controller.hasData) {
            return _QueryFeedbackState(
              title: '暂无成绩',
              message: '点击筛选或刷新后再试',
              onFilter: canInteract ? () => _openFilterSheet(context) : null,
              onRefresh: canInteract ? controller.refreshGrades : null,
            );
          }

          return SimpleEasyRefresher(
            easyRefreshController: controller.easyRefreshController,
            onRefresh: controller.refreshGrades,
            onLoad: controller.loadMoreGrades,
            autoRefreshOnStart: false,
            refreshEnabled: canInteract,
            loadEnabled: controller.hasMore && canInteract,
            childBuilder: (context, physics) => FUIPage(
              physics: canInteract
                  ? physics
                  : const NeverScrollableScrollPhysics(),
              children: [
                _QueryHeader(
                  onFilter: canInteract
                      ? () => _openFilterSheet(context)
                      : null,
                  onRefresh: canInteract ? controller.refreshGrades : null,
                ),
                const SizedBox(height: FUITokens.gap16),
                _SummaryCard(
                  grades: controller.grades,
                  total: controller.total,
                  majorRank: controller.majorRank,
                ),
                const SizedBox(height: FUITokens.gap16),
                _ResultsHeader(
                  total: controller.total,
                  page: controller.page,
                  totalPages: controller.totalPages,
                ),
                const SizedBox(height: FUITokens.gap8),
                for (final grade in controller.grades) ...[
                  _GradeCard(grade: grade),
                  const SizedBox(height: FUITokens.gap12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    if (controller.isLoading || controller.isLoadingMore) {
      return;
    }

    final result = await showAppBottomSheet<GradeFilter>(
      context: context,
      isScrollControlled: true,
      child: GradeFilterSheet(
        initialFilter: controller.filter,
        options: controller.filterOptions,
      ),
    );

    if (result != null) {
      await controller.applyFilter(result);
    }
  }
}

class _QueryHeader extends StatelessWidget {
  const _QueryHeader({required this.onFilter, required this.onRefresh});

  final VoidCallback? onFilter;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return FuiPageHead(
      title: '成绩查询',
      subtitle: '最高成绩 / 绩点 / 学分',
      actions: [
        FUIIconButton(
          icon: FUIIcons.filter,
          tooltip: '筛选',
          variant: FUIIconButtonVariant.ghost,
          onPressed: onFilter,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.grades,
    required this.total,
    required this.majorRank,
  });

  final List<CourseGrade> grades;
  final int total;
  final String majorRank;

  @override
  Widget build(BuildContext context) {
    final totalCredit = grades.fold<double>(
      0,
      (sum, item) => sum + item.credit,
    );
    final totalCreditPoint = grades.fold<double>(
      0,
      (sum, item) => sum + item.creditPoint,
    );
    final avgGpa = totalCredit == 0 ? 0 : totalCreditPoint / totalCredit;
    final avgScore = grades.isEmpty
        ? 0.0
        : grades.fold<double>(0, (sum, item) => sum + item.score) /
              grades.length;

    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SectionIcon(icon: FUIIcons.chart),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: Text(
                  '成绩概览',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FUITag(
                label: total > 0 ? '$total 门课程' : '${grades.length} 门课程',
                variant: FUITagVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap14),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: '平均绩点',
                  value: avgGpa.toStringAsFixed(2),
                ),
              ),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: _SummaryMetric(
                  label: '平均分',
                  value: avgScore.toStringAsFixed(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap10),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: '已载入学分',
                  value: totalCredit.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: _SummaryMetric(
                  label: '专业排名',
                  value: majorRank.isEmpty ? '-' : majorRank,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: FUITokens.gap4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final int total;
  final int page;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '成绩详情',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            '第 $page/$totalPages 页 · 共 $total 门',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  const _GradeCard({required this.grade});

  final CourseGrade grade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;

    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade.courseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: FUITokens.gap6),
                    Row(
                      children: [
                        Icon(
                          FUIIcons.calendar,
                          size: FUITokens.iconSm,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: FUITokens.gap4),
                        Expanded(
                          child: Text(
                            grade.semester,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: FUITokens.gap10),
              _ScoreBadge(score: grade.finalGrade),
            ],
          ),
          const SizedBox(height: FUITokens.gap14),
          Wrap(
            spacing: FUITokens.gap8,
            runSpacing: FUITokens.gap8,
            children: [
              if (grade.courseNatureLabel.isNotEmpty)
                FUITag(
                  label: grade.courseNatureLabel,
                  variant: FUITagVariant.primary,
                ),
              if (grade.examTypeLabel.isNotEmpty)
                FUITag(label: grade.examTypeLabel),
              if (grade.studyNatureLabel.isNotEmpty)
                FUITag(label: grade.studyNatureLabel),
              if (grade.specialGradeLabel.isNotEmpty)
                FUITag(
                  label: grade.specialGradeLabel,
                  variant: _tagVariantForSpecialGrade(grade.specialGradeLabel),
                ),
            ],
          ),
          const SizedBox(height: FUITokens.gap14),
          Row(
            children: [
              Expanded(
                child: _DataBlock(
                  icon: FUIIcons.chart,
                  label: '绩点',
                  value: grade.gradePoint.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: FUITokens.gap8),
              Expanded(
                child: _DataBlock(
                  icon: FUIIcons.credit,
                  label: '学分',
                  value: grade.credit.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: FUITokens.gap8),
              Expanded(
                child: _DataBlock(
                  icon: FUIIcons.book,
                  label: '初修',
                  value: grade.retakeGrade,
                ),
              ),
            ],
          ),
          if (grade.gradeMode.isNotEmpty || grade.gradeBreakdown.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: FUITokens.gap12),
              child: Text(
                grade.gradeMode.isNotEmpty
                    ? grade.gradeMode
                    : grade.gradeBreakdown,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  FUITagVariant _tagVariantForSpecialGrade(String label) {
    if (label.contains('不及格') || label.contains('重修')) {
      return FUITagVariant.danger;
    }
    if (label.contains('及格') || label.contains('通过')) {
      return FUITagVariant.success;
    }
    return FUITagVariant.neutral;
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final String score;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final variant = _scoreVariant(score);
    final (bg, fg) = switch (variant) {
      FUITagVariant.success => (colors.successSoft, colors.success),
      FUITagVariant.warning => (colors.warningSoft, colors.warning),
      FUITagVariant.danger => (colors.dangerSoft, colors.danger),
      _ => (colors.primarySoft, colors.primary),
    };

    return Container(
      constraints: const BoxConstraints(minWidth: 58),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score.isEmpty ? '-' : score,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '成绩',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: fg.withValues(alpha: 0.78)),
          ),
        ],
      ),
    );
  }

  FUITagVariant _scoreVariant(String value) {
    final scoreValue = double.tryParse(value);
    if (scoreValue == null) {
      return FUITagVariant.primary;
    }
    if (scoreValue < 60) {
      return FUITagVariant.danger;
    }
    if (scoreValue < 75) {
      return FUITagVariant.warning;
    }
    return FUITagVariant.success;
  }
}

class _DataBlock extends StatelessWidget {
  const _DataBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: FUITokens.iconSm, color: colors.primary),
          Text(
            value.isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SectionIcon extends StatelessWidget {
  const _SectionIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(FUITokens.radiusSm),
      ),
      child: Icon(icon, size: FUITokens.iconMd, color: colors.primary),
    );
  }
}

class GradeFilterSheet extends StatefulWidget {
  const GradeFilterSheet({
    super.key,
    required this.initialFilter,
    required this.options,
  });

  final GradeFilter initialFilter;
  final GradeFilterOptions options;

  @override
  State<GradeFilterSheet> createState() => _GradeFilterSheetState();
}

class _GradeFilterSheetState extends State<GradeFilterSheet> {
  late GradeFilter filter;

  @override
  void initState() {
    super.initState();
    filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              Row(
                children: [
                  _SectionIcon(icon: FUIIcons.filter),
                  const SizedBox(width: FUITokens.gap10),
                  Expanded(
                    child: Text(
                      '筛选条件',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FUITokens.gap16),
              FUISurface(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _DropdownField(
                      label: '起始学年学期',
                      value: filter.startSemester,
                      options: widget.options.startSemesters,
                      onChanged: (value) => setState(
                        () => filter = filter.copyWith(
                          startSemester: value ?? '001',
                        ),
                      ),
                    ),
                    _DropdownField(
                      label: '终止学年学期',
                      value: filter.endSemester,
                      options: widget.options.endSemesters,
                      onChanged: (value) => setState(
                        () => filter = filter.copyWith(
                          endSemester: value ?? '001',
                        ),
                      ),
                    ),
                    _DropdownField(
                      label: '是否及格',
                      value: filter.passStatus,
                      options: widget.options.passStatuses,
                      onChanged: (value) => setState(
                        () => filter = filter.copyWith(passStatus: value ?? ''),
                      ),
                    ),
                    _DropdownField(
                      label: '课程平台',
                      value: filter.courseNature,
                      options: widget.options.courseNatures,
                      onChanged: (value) => setState(
                        () =>
                            filter = filter.copyWith(courseNature: value ?? ''),
                      ),
                    ),
                    _DropdownField(
                      label: '是否补考',
                      value: filter.makeup,
                      options: widget.options.makeupTypes,
                      onChanged: (value) => setState(
                        () => filter = filter.copyWith(makeup: value ?? ''),
                      ),
                    ),
                    _DropdownField(
                      label: '是否显示公章',
                      value: filter.seal,
                      options: widget.options.sealOptions,
                      onChanged: (value) => setState(
                        () => filter = filter.copyWith(seal: value ?? '1'),
                      ),
                    ),
                    _DropdownField(
                      label: '课程归属',
                      value: filter.courseAttribution,
                      options: widget.options.courseAttributions,
                      onChanged: (value) => setState(
                        () => filter = filter.copyWith(
                          courseAttribution: value ?? '',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FUITokens.gap14),
              FUIButton(
                label: '应用筛选',
                icon: FUIIcons.check,
                fullWidth: true,
                onPressed: () => Navigator.pop(context, filter),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<GradeFilterOption> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = _resolveItems(options, value);
    final selected = items.any((item) => item.value == value)
        ? items.firstWhere((item) => item.value == value)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FUIComboBox<GradeFilterOption>(
        label: label,
        value: selected,
        items: items,
        itemLabelBuilder: (item) =>
            item.label.isEmpty ? item.value : item.label,
        onChanged: (item) => onChanged(item?.value),
      ),
    );
  }

  List<GradeFilterOption> _resolveItems(
    List<GradeFilterOption> options,
    String currentValue,
  ) {
    if (options.isEmpty && currentValue.isNotEmpty) {
      return [GradeFilterOption(value: currentValue, label: currentValue)];
    }
    return options;
  }
}

class _QueryFeedbackState extends StatelessWidget {
  const _QueryFeedbackState({
    required this.title,
    required this.message,
    required this.onFilter,
    required this.onRefresh,
  });

  final String title;
  final String message;
  final VoidCallback? onFilter;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return FUIPage(
      children: [
        _QueryHeader(onFilter: onFilter, onRefresh: onRefresh),
        const SizedBox(height: FUITokens.gap16),
        FUISurface(
          child: SizedBox(
            height: 320,
            child: FUIEmptyState(
              title: title,
              message: message,
              icon: FUIIcons.grade,
              actionLabel: '重试',
              onAction: onRefresh,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuerySkeletonView extends StatelessWidget {
  const _QuerySkeletonView();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => FUIPage(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _QueryHeader(onFilter: null, onRefresh: null),
          const SizedBox(height: FUITokens.gap16),
          FUISurface(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: palette.block(radius: FUITokens.radiusSm),
                    ),
                    const SizedBox(width: FUITokens.gap10),
                    Expanded(
                      child: SkeletonBar(
                        decoration: palette.line(radius: 8),
                        widthFactor: 0.42,
                        height: 18,
                      ),
                    ),
                    Container(
                      width: 72,
                      height: 24,
                      decoration: palette.block(radius: FUITokens.radiusFull),
                    ),
                  ],
                ),
                const SizedBox(height: FUITokens.gap14),
                Row(
                  children: [
                    Expanded(child: _SkeletonMetric(palette: palette)),
                    const SizedBox(width: FUITokens.gap10),
                    Expanded(child: _SkeletonMetric(palette: palette)),
                  ],
                ),
                const SizedBox(height: FUITokens.gap10),
                Row(
                  children: [
                    Expanded(child: _SkeletonMetric(palette: palette)),
                    const SizedBox(width: FUITokens.gap10),
                    Expanded(child: _SkeletonMetric(palette: palette)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: FUITokens.gap12),
          _SkeletonGradeCard(palette: palette),
          const SizedBox(height: FUITokens.gap12),
          _SkeletonGradeCard(palette: palette),
          const SizedBox(height: FUITokens.gap12),
          _SkeletonGradeCard(palette: palette),
        ],
      ),
    );
  }
}

class _SkeletonMetric extends StatelessWidget {
  const _SkeletonMetric({required this.palette});

  final SkeletonPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 0.54,
            height: 18,
          ),
          const SizedBox(height: FUITokens.gap8),
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 0.72,
            height: 12,
          ),
        ],
      ),
    );
  }
}

class _SkeletonGradeCard extends StatelessWidget {
  const _SkeletonGradeCard({required this.palette});

  final SkeletonPalette palette;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBar(
                      decoration: palette.line(radius: 8),
                      widthFactor: 0.76,
                      height: 18,
                    ),
                    const SizedBox(height: FUITokens.gap8),
                    SkeletonBar(
                      decoration: palette.line(radius: 8),
                      widthFactor: 0.42,
                      height: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: FUITokens.gap12),
              Container(
                width: 58,
                height: 52,
                decoration: palette.block(radius: FUITokens.radiusMd),
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap14),
          Row(
            children: [
              Container(
                width: 88,
                height: 24,
                decoration: palette.block(radius: FUITokens.radiusFull),
              ),
              const SizedBox(width: FUITokens.gap8),
              Container(
                width: 58,
                height: 24,
                decoration: palette.block(radius: FUITokens.radiusFull),
              ),
              const SizedBox(width: FUITokens.gap8),
              Container(
                width: 58,
                height: 24,
                decoration: palette.block(radius: FUITokens.radiusFull),
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap14),
          Row(
            children: [
              Expanded(child: _SkeletonDataBlock(palette: palette)),
              const SizedBox(width: FUITokens.gap8),
              Expanded(child: _SkeletonDataBlock(palette: palette)),
              const SizedBox(width: FUITokens.gap8),
              Expanded(child: _SkeletonDataBlock(palette: palette)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonDataBlock extends StatelessWidget {
  const _SkeletonDataBlock({required this.palette});

  final SkeletonPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: palette.block(radius: FUITokens.radiusXs),
          ),
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 0.58,
            height: 14,
          ),
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 0.42,
            height: 11,
          ),
        ],
      ),
    );
  }
}
