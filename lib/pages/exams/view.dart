/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/exam.dart';
import 'package:class_tool/pages/exams/controller.dart';
import 'package:class_tool/widgets/simple_easy_refresher.dart';
import 'package:class_tool/widgets/skeleton_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  late final ExamsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ExamsController(), permanent: false);
  }

  @override
  void dispose() {
    if (Get.isRegistered<ExamsController>()) {
      Get.delete<ExamsController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('考试查询'),
        actions: [
          GetBuilder<ExamsController>(
            id: 'exam-content',
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
          GetBuilder<ExamsController>(
            id: 'exam-content',
            builder: (controller) {
              final enabled =
                  !controller.isLoading && !controller.isLoadingMore;
              return IconButton(
                icon: const Icon(Icons.refresh_outlined),
                tooltip: '刷新',
                onPressed:
                    enabled && controller.canSearch
                        ? controller.refreshExams
                        : null,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: GetBuilder<ExamsController>(
          id: 'exam-content',
          builder: (controller) {
            if (controller.isLoading && !controller.hasData) {
              return const _ExamSkeletonView();
            }

            if (controller.error.isNotEmpty && !controller.hasData) {
              return _FeedbackState(
                title: '考试信息加载失败',
                subtitle: controller.error,
                onRetry: controller.refreshExams,
              );
            }

            if (!controller.canSearch) {
              return _FeedbackState(
                title: '请选择筛选条件',
                subtitle: '选择学期和考试批次后点击刷新',
                onRetry: controller.refreshExams,
              );
            }

            if (!controller.hasData) {
              return _FeedbackState(
                title: '暂无考试信息',
                subtitle: '当前筛选条件下没有考试记录',
                onRetry: controller.refreshExams,
              );
            }

            return Column(
              children: [
                _HeaderRow(
                  total: controller.total,
                  colorScheme: colorScheme,
                ),
                Expanded(
                  child: SimpleEasyRefresher(
                    easyRefreshController: controller.easyRefreshController,
                    onRefresh: controller.refreshExams,
                    onLoad: controller.loadMoreExams,
                    autoRefreshOnStart: false,
                    refreshEnabled:
                        !controller.isLoading && !controller.isLoadingMore,
                    loadEnabled:
                        controller.hasMore &&
                        !controller.isLoading &&
                        !controller.isLoadingMore,
                    childBuilder:
                        (context, physics) =>
                            ListView.separated(
                              physics:
                                  controller.isLoading ||
                                          controller.isLoadingMore
                                      ? const NeverScrollableScrollPhysics()
                                      : physics,
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                0,
                                12,
                                24,
                              ),
                              itemBuilder: (context, index) {
                                return _ExamCard(
                                  exam: controller.exams[index],
                                );
                              },
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                              itemCount: controller.exams.length,
                            ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    if (controller.isLoading || controller.isLoadingMore) return;
    await controller.ensureBatches();

    final result = await showModalBottomSheet<_ExamFilterResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _ExamFilterSheet(),
    );

    if (result != null) {
      if (result.semester != controller.selectedSemester) {
        await controller.changeSemester(result.semester);
      }
      if (result.pcid != controller.selectedPcid) {
        await controller.changeBatch(result.pcid);
      }
    }
  }
}

class _ExamFilterResult {
  const _ExamFilterResult({required this.semester, required this.pcid});
  final String semester;
  final String pcid;
}

class _ExamFilterSheet extends StatelessWidget {
  const _ExamFilterSheet();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExamsController>();
    final semesters = controller.semesters;
    final batches = controller.batches;
    final currentSemester = controller.selectedSemester;
    final currentPcid = controller.selectedPcid;

    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.28,
      maxChildSize: 0.72,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            4,
            24,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: ListView(
            controller: scrollController,
            children: [
              const Text(
                '筛选条件',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: currentSemester,
                decoration: const InputDecoration(
                  labelText: '学年学期',
                  border: OutlineInputBorder(),
                ),
                items:
                    semesters.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.value,
                        child: Text(s.label),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null && value != currentSemester) {
                    Navigator.of(context).pop(
                      _ExamFilterResult(semester: value, pcid: ''),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: currentPcid,
                decoration: const InputDecoration(
                  labelText: '考试批次',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('全部'),
                  ),
                  ...batches.map((b) {
                    return DropdownMenuItem<String>(
                      value: b.pcid,
                      child: Text(b.label),
                    );
                  }),
                ],
                onChanged: (value) {
                  if (value != null) {
                    Navigator.of(context).pop(
                      _ExamFilterResult(
                        semester: currentSemester,
                        pcid: value,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.total, required this.colorScheme});

  final int total;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          Text(
            '考试列表',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Expanded(child: SizedBox.shrink()),
          Text(
            '共 $total 场考试',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam});

  final ExamItem exam;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.courseName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exam.examBatchName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _InfoTag(
              label: exam.examTypeLabel,
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  Text(
                    exam.seatNumber.isEmpty ? '-' : exam.seatNumber,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    '座位',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _InfoTag(
              label: '补考${exam.makeupCount}次',
              colorScheme: colorScheme,
              muted: exam.makeupCount == 0,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({
    required this.label,
    required this.colorScheme,
    this.muted = false,
  });

  final String label;
  final ColorScheme colorScheme;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: muted
            ? colorScheme.surfaceContainerHighest
            : colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: muted
              ? colorScheme.onSurfaceVariant
              : colorScheme.onTertiaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ExamSkeletonView extends StatelessWidget {
  const _ExamSkeletonView();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) {
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [
            for (int i = 0; i < 8; i++) ...[
              Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBar(
                              decoration: palette.line(radius: 8),
                              widthFactor: 0.8,
                              height: 16,
                            ),
                            const SizedBox(height: 8),
                            SkeletonBar(
                              decoration: palette.line(radius: 8),
                              widthFactor: 0.5,
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 44,
                        height: 22,
                        child: Container(decoration: palette.line(radius: 6)),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: Container(decoration: palette.line(radius: 6)),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        height: 22,
                        child: Container(decoration: palette.line(radius: 6)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ],
        );
      },
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
              Icons.assignment_outlined,
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
