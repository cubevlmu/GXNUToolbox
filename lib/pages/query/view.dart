/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/grade.dart';
import 'package:class_tool/pages/query/controller.dart';
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
      appBar: AppBar(
        title: const Text('最高成绩查询'),
        actions: [
          GetBuilder<QueryController>(
            id: 'query-content',
            builder: (controller) {
              final enabled =
                  !controller.isLoading && !controller.isLoadingMore;
              return IconButton(
                icon: const Icon(Icons.tune_outlined),
                tooltip: '筛选',
                onPressed: enabled ? () => _openFilterSheet(context) : null,
              );
            },
          ),
          GetBuilder<QueryController>(
            id: 'query-content',
            builder: (controller) {
              final enabled =
                  !controller.isLoading && !controller.isLoadingMore;
              return IconButton(
                icon: const Icon(Icons.refresh_outlined),
                tooltip: '刷新',
                onPressed: enabled ? controller.refreshGrades : null,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: GetBuilder<QueryController>(
          id: 'query-content',
          builder: (controller) {
            if (controller.isLoading && !controller.hasData) {
              return const _QuerySkeletonView();
            }

            if (controller.error.isNotEmpty && !controller.hasData) {
              return _QueryFeedbackState(
                title: '成绩加载失败',
                subtitle: controller.error,
                onRetry: controller.refreshGrades,
              );
            }

            if (!controller.hasData) {
              return _QueryFeedbackState(
                title: '暂无成绩',
                subtitle: '点击搜索或调整筛选条件后再试',
                onRetry: controller.refreshGrades,
              );
            }

            return SimpleEasyRefresher(
              easyRefreshController: controller.easyRefreshController,
              onRefresh: controller.refreshGrades,
              onLoad: controller.loadMoreGrades,
              autoRefreshOnStart: false,
              refreshEnabled:
                  !controller.isLoading && !controller.isLoadingMore,
              loadEnabled:
                  controller.hasMore &&
                  !controller.isLoading &&
                  !controller.isLoadingMore,
              childBuilder: (context, physics) => ListView.separated(
                physics: controller.isLoading || controller.isLoadingMore
                    ? const NeverScrollableScrollPhysics()
                    : physics,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                itemCount: controller.grades.length + 1,
                separatorBuilder: (_, index) =>
                    SizedBox(height: index == 0 ? 14 : 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SummaryCard(
                          grades: controller.grades,
                          majorRank: controller.majorRank,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                          child: Row(
                            children: [
                              Text(
                                '成绩详情:',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                              Text(
                                '共 ${controller.total} 门课程',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return _GradeCard(grade: controller.grades[index - 1]);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    if (controller.isLoading || controller.isLoadingMore) {
      return;
    }

    final result = await showModalBottomSheet<GradeFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => GradeFilterSheet(
        initialFilter: controller.filter,
        options: controller.filterOptions,
      ),
    );

    if (result != null) {
      await controller.applyFilter(result);
    }
  }
}

class _QuerySkeletonView extends StatelessWidget {
  const _QuerySkeletonView();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _SkeletonSummaryItem(
                      palette: palette,
                      widthFactor: 0.58,
                    ),
                  ),
                  Expanded(
                    child: _SkeletonSummaryItem(
                      palette: palette,
                      widthFactor: 0.52,
                    ),
                  ),
                  Expanded(
                    child: _SkeletonSummaryItem(
                      palette: palette,
                      widthFactor: 0.48,
                    ),
                  ),
                  Expanded(
                    child: _SkeletonSummaryItem(
                      palette: palette,
                      widthFactor: 0.42,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SkeletonGradeCard(palette: palette),
          const SizedBox(height: 12),
          _SkeletonGradeCard(palette: palette),
          const SizedBox(height: 12),
          _SkeletonGradeCard(palette: palette),
        ],
      ),
    );
  }
}

class _SkeletonSummaryItem extends StatelessWidget {
  const _SkeletonSummaryItem({
    required this.palette,
    required this.widthFactor,
  });

  final SkeletonPalette palette;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FractionallySizedBox(
          widthFactor: widthFactor,
          child: Container(height: 18, decoration: palette.line(radius: 8)),
        ),
        const SizedBox(height: 7),
        FractionallySizedBox(
          widthFactor: 0.52,
          child: Container(height: 12, decoration: palette.line(radius: 8)),
        ),
      ],
    );
  }
}

class _SkeletonGradeCard extends StatelessWidget {
  const _SkeletonGradeCard({required this.palette});

  final SkeletonPalette palette;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      const SizedBox(height: 9),
                      SkeletonBar(
                        decoration: palette.line(radius: 8),
                        widthFactor: 0.38,
                        height: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 54,
                  height: 52,
                  decoration: palette.block(radius: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 88,
                  height: 28,
                  decoration: palette.block(radius: 999),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 58,
                  height: 28,
                  decoration: palette.block(radius: 999),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 58,
                  height: 28,
                  decoration: palette.block(radius: 999),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: palette.block(radius: 14),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 72,
                  height: 72,
                  decoration: palette.block(radius: 14),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 72,
                  height: 72,
                  decoration: palette.block(radius: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SkeletonBar(
              decoration: palette.line(radius: 8),
              widthFactor: 0.82,
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.grades, required this.majorRank});

  final List<CourseGrade> grades;
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

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: _SummaryItem(
                label: '绩点',
                value: avgGpa.toStringAsFixed(2),
              ),
            ),
            Expanded(
              child: _SummaryItem(
                label: '平均分',
                value: avgScore.toStringAsFixed(1),
              ),
            ),
            Expanded(
              child: _SummaryItem(
                label: '学分',
                value: totalCredit.toStringAsFixed(1),
              ),
            ),
            Expanded(
              child: _SummaryItem(
                label: '排名',
                value: majorRank.isEmpty ? '-' : majorRank,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

class _GradeCard extends StatelessWidget {
  const _GradeCard({required this.grade});

  final CourseGrade grade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.event_note_outlined,
                            size: 15,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              grade.semester,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ScoreBadge(score: grade.finalGrade),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (grade.courseNatureLabel.isNotEmpty)
                  _InfoChip(label: grade.courseNatureLabel),
                if (grade.examTypeLabel.isNotEmpty)
                  _InfoChip(label: grade.examTypeLabel),
                if (grade.studyNatureLabel.isNotEmpty)
                  _InfoChip(label: grade.studyNatureLabel),
                _InfoChip(label: grade.specialGradeLabel),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _DataBlock(
                  icon: Icons.trending_up_rounded,
                  label: '绩点',
                  value: grade.gradePoint.toStringAsFixed(1),
                ),
                const SizedBox(width: 8),
                _DataBlock(
                  icon: Icons.stars_outlined,
                  label: '学分',
                  value: grade.credit.toStringAsFixed(1),
                ),
                const SizedBox(width: 8),
                _DataBlock(
                  icon: Icons.history_edu_outlined,
                  label: '初修',
                  value: grade.retakeGrade,
                ),
              ],
            ),
            if (grade.gradeMode.isNotEmpty || grade.gradeBreakdown.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  grade.gradeMode.isNotEmpty
                      ? grade.gradeMode
                      : grade.gradeBreakdown,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

@immutable
class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final String score;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 54),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score.isEmpty ? '-' : score,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '成绩',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 72,
      width: 72,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
              Text(
                '筛选条件',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _DropdownField(
                label: '起始学年学期',
                value: filter.startSemester,
                options: widget.options.startSemesters,
                onChanged: (value) => setState(
                  () => filter = filter.copyWith(startSemester: value ?? '001'),
                ),
              ),
              _DropdownField(
                label: '终止学年学期',
                value: filter.endSemester,
                options: widget.options.endSemesters,
                onChanged: (value) => setState(
                  () => filter = filter.copyWith(endSemester: value ?? '001'),
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
                  () => filter = filter.copyWith(courseNature: value ?? ''),
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
                  () =>
                      filter = filter.copyWith(courseAttribution: value ?? ''),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.pop(context, filter),
                child: const Text('应用筛选'),
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
    final items = _dropdownItems(options, value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: items.any((item) => item.value == value) ? value : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropdownItems(
    List<GradeFilterOption> options,
    String currentValue,
  ) {
    final source = options.isEmpty && currentValue.isNotEmpty
        ? [GradeFilterOption(value: currentValue, label: currentValue)]
        : options;
    return source
        .map(
          (option) => DropdownMenuItem<String>(
            value: option.value,
            child: Text(option.label.isEmpty ? option.value : option.label),
          ),
        )
        .toList(growable: false);
  }
}

class _QueryFeedbackState extends StatelessWidget {
  const _QueryFeedbackState({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
