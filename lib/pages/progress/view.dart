/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/course_plan.dart';
import 'package:class_tool/pages/progress/controller.dart';
import 'package:class_tool/widgets/skeleton_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  late final ProgressController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProgressController(), permanent: false);
  }

  @override
  void dispose() {
    if (Get.isRegistered<ProgressController>()) {
      Get.delete<ProgressController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('培养进度'),
        actions: [
          GetBuilder<ProgressController>(
            id: 'progress-content',
            builder: (c) => IconButton(
              icon: const Icon(Icons.refresh_outlined),
              tooltip: '刷新',
              onPressed: c.isLoading.value ? null : c.loadData,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: GetBuilder<ProgressController>(
          id: 'progress-content',
          builder: (c) {
            if (c.isLoading.value && c.response.value == null) {
              return const _ProgressSkeletonView();
            }
            if (c.error.isNotEmpty && c.response.value == null) {
              return _FeedbackState(
                title: '加载失败',
                subtitle: c.error.value,
                onRetry: c.loadData,
              );
            }

            final resp = c.response.value;
            if (resp == null || resp.sections.isEmpty) {
              return _FeedbackState(
                title: '暂无数据',
                subtitle: '点击刷新重试',
                onRetry: c.loadData,
              );
            }

            return Column(
              children: [
                _SemesterBar(controller: c),
                if (c.totalCount > 0)
                  _ProgressBar(
                    completed: c.completedCount,
                    total: c.totalCount,
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: resp.sections.length,
                    itemBuilder: (_, sectionIndex) {
                      final section = resp.sections[sectionIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final group in section.groups)
                            _GroupCard(group: group),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SemesterBar extends StatelessWidget {
  const _SemesterBar({required this.controller});

  final ProgressController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Obx(() {
        return DropdownButtonFormField<String>(
          initialValue: controller.selectedSemester.value,
          decoration: const InputDecoration(
            labelText: '学年学期',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem<String>(
              value: '',
              child: Text('全部'),
            ),
            ...controller.semesterOptions.map((s) {
              return DropdownMenuItem<String>(value: s, child: Text(s));
            }),
          ],
          onChanged:
              controller.isLoading.value
                  ? null
                  : (v) {
                      if (v != null) controller.changeSemester(v);
                    },
        );
      }),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? completed / total : 0.0;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Row(
        children: [
          Text(
            '完成进度',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$completed / $total',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatefulWidget {
  const _GroupCard({required this.group});

  final CoursePlanGroup group;

  @override
  State<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<_GroupCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final group = widget.group;
    final completedCount =
        group.items.where((i) => i.isCompleted).length;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '$completedCount / ${group.items.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            ...group.items.map(
              (item) => _CourseTile(item: item),
            ),
        ],
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.item});

  final CoursePlanItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withAlpha(80)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.courseName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item.credits.isNotEmpty) ...[
                      Text(
                        '${item.credits}学分',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (item.examType.isNotEmpty) ...[
                      Text(
                        item.examType,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      item.categoryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _ScoreBadge(item: item, colorScheme: colorScheme),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.item, required this.colorScheme});

  final CoursePlanItem item;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isCompleted = item.isCompleted;
    final isInProgress = item.scoreText == '修读中';
    final bagsColor = isCompleted
        ? Colors.green.shade50
        : isInProgress
        ? Colors.blue.shade50
        : Colors.orange.shade50;
    final textColor = isCompleted
        ? Colors.green.shade700
        : isInProgress
        ? Colors.blue.shade700
        : Colors.orange.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bagsColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        item.scoreText,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _ProgressSkeletonView extends StatelessWidget {
  const _ProgressSkeletonView();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 1.0,
            height: 44,
          ),
          const SizedBox(height: 10),
          SkeletonBar(
            decoration: palette.line(radius: 4),
            widthFactor: 1.0,
            height: 8,
          ),
          const SizedBox(height: 14),
          for (int g = 0; g < 6; g++) ...[
            Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SkeletonBar(
                            decoration: palette.line(radius: 6),
                            widthFactor: 0.5,
                            height: 16,
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          height: 12,
                          child: Container(decoration: palette.line(radius: 6)),
                        ),
                      ],
                    ),
                    for (int i = 0; i < 3; i++) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonBar(
                                  decoration: palette.line(radius: 4),
                                  widthFactor: 0.7,
                                  height: 14,
                                ),
                                const SizedBox(height: 6),
                                SkeletonBar(
                                  decoration: palette.line(radius: 4),
                                  widthFactor: 0.4,
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            height: 22,
                            child: Container(decoration: palette.line(radius: 6)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeedbackState extends StatelessWidget {
  const _FeedbackState({
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 56,
              color: colorScheme.onSurfaceVariant.withAlpha(120),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
