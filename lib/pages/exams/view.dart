/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/exam.dart';
import 'package:class_tool/pages/exams/controller.dart';
import 'package:class_tool/ui/app_button.dart';
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
    return Scaffold(
      backgroundColor: context.colors.background,
      body: GetBuilder<ExamsController>(
        id: 'exam-content',
        builder: (controller) {
          final canInteract =
              !controller.isLoading && !controller.isLoadingMore;

          if (controller.isLoading && !controller.hasData) {
            return _ExamSkeletonView(
              onBack: () => Navigator.of(context).maybePop(),
            );
          }

          if (controller.error.isNotEmpty && !controller.hasData) {
            return _FeedbackState(
              title: '考试信息加载失败',
              message: controller.error,
              onBack: () => Navigator.of(context).maybePop(),
              onFilter: canInteract ? () => _openFilterSheet(context) : null,
              onRefresh: canInteract ? controller.refreshExams : null,
            );
          }

          if (!controller.canSearch) {
            return _FeedbackState(
              title: '请选择筛选条件',
              message: '选择学期和考试批次后刷新',
              onBack: () => Navigator.of(context).maybePop(),
              onFilter: canInteract ? () => _openFilterSheet(context) : null,
              onRefresh: canInteract ? controller.refreshExams : null,
            );
          }

          if (!controller.hasData) {
            return _FeedbackState(
              title: '暂无考试安排',
              message: '当前筛选条件下没有考试记录',
              onBack: () => Navigator.of(context).maybePop(),
              onFilter: canInteract ? () => _openFilterSheet(context) : null,
              onRefresh: canInteract ? controller.refreshExams : null,
            );
          }

          return SimpleEasyRefresher(
            easyRefreshController: controller.easyRefreshController,
            onRefresh: controller.refreshExams,
            onLoad: controller.loadMoreExams,
            autoRefreshOnStart: false,
            refreshEnabled: canInteract,
            loadEnabled: controller.hasMore && canInteract,
            childBuilder: (context, physics) => AppPage(
              physics: canInteract
                  ? physics
                  : const NeverScrollableScrollPhysics(),
              children: [
                _ExamHeader(
                  onBack: () => Navigator.of(context).maybePop(),
                  onFilter:
                      canInteract ? () => _openFilterSheet(context) : null,
                  onRefresh: canInteract ? controller.refreshExams : null,
                ),
                const SizedBox(height: AppTokens.gap16),
                _ExamSummary(
                  total: controller.total,
                  page: controller.page,
                  totalPages: controller.totalPages,
                  selectedSemester: controller.selectedSemester,
                  selectedBatch: _selectedBatchLabel(controller),
                ),
                const SizedBox(height: AppTokens.gap16),
                _ListHeader(total: controller.total),
                const SizedBox(height: AppTokens.gap8),
                for (final exam in controller.exams) ...[
                  _ExamCard(exam: exam),
                  const SizedBox(height: AppTokens.gap12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _selectedBatchLabel(ExamsController controller) {
    if (controller.selectedPcid.isEmpty) {
      return '全部批次';
    }
    final batch = controller.batches.firstWhereOrNull(
      (item) => item.pcid == controller.selectedPcid,
    );
    return batch?.label ?? controller.selectedPcid;
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    if (controller.isLoading || controller.isLoadingMore) return;
    await controller.ensureBatches();

    if (!context.mounted) return;
    final result = await showAppBottomSheet<_ExamFilterResult>(
      context: context,
      isScrollControlled: true,
      child: const _ExamFilterSheet(),
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

class _ExamHeader extends StatelessWidget {
  const _ExamHeader({
    required this.onBack,
    required this.onFilter,
    required this.onRefresh,
  });

  final VoidCallback onBack;
  final VoidCallback? onFilter;
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
                '考试安排',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppTokens.gap4),
              Text(
                '查看考试时间、地点与座位信息',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppTokens.gap8),
        AppIconButton(
          icon: AppIcons.filter,
          tooltip: '筛选',
          variant: AppIconButtonVariant.ghost,
          onPressed: onFilter,
        ),
        const SizedBox(width: AppTokens.gap8),
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

class _ExamSummary extends StatelessWidget {
  const _ExamSummary({
    required this.total,
    required this.page,
    required this.totalPages,
    required this.selectedSemester,
    required this.selectedBatch,
  });

  final int total;
  final int page;
  final int totalPages;
  final String selectedSemester;
  final String selectedBatch;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: AppIcons.exam),
              const SizedBox(width: AppTokens.gap10),
              Expanded(
                child: Text(
                  '考试概览',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              AppTag(label: '$total 场考试', variant: AppTagVariant.primary),
            ],
          ),
          const SizedBox(height: AppTokens.gap14),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(label: '学期', value: selectedSemester),
              ),
              const SizedBox(width: AppTokens.gap10),
              Expanded(
                child: _SummaryMetric(label: '批次', value: selectedBatch),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.gap10),
          _SummaryMetric(label: '分页', value: '第 $page/$totalPages 页'),
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
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.gap4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Text(
            '考试列表',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Text(
          '共 $total 场',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam});

  final ExamItem exam;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBox(icon: AppIcons.exam),
              const SizedBox(width: AppTokens.gap12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.courseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppTokens.gap6),
                    Wrap(
                      spacing: AppTokens.gap8,
                      runSpacing: AppTokens.gap8,
                      children: [
                        if (exam.examBatchName.isNotEmpty)
                          AppTag(label: exam.examBatchName),
                        if (exam.examTypeLabel.isNotEmpty)
                          AppTag(
                            label: exam.examTypeLabel,
                            variant: AppTagVariant.primary,
                          ),
                        AppTag(
                          label: exam.makeupCount == 0
                              ? '非补考'
                              : '补考 ${exam.makeupCount} 次',
                          variant: exam.makeupCount == 0
                              ? AppTagVariant.neutral
                              : AppTagVariant.warning,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.gap10),
              _SeatBadge(seatNumber: exam.seatNumber),
            ],
          ),
          const SizedBox(height: AppTokens.gap14),
          _MetaRow(
            icon: AppIcons.schedule,
            label: '时间',
            value: _examTimeText(exam),
          ),
          const SizedBox(height: AppTokens.gap8),
          _MetaRow(
            icon: AppIcons.location,
            label: '地点',
            value: exam.location.isEmpty ? '地点待定' : exam.location,
          ),
          if (exam.className.isNotEmpty) ...[
            const SizedBox(height: AppTokens.gap8),
            _MetaRow(
              icon: AppIcons.classroom,
              label: '班级',
              value: exam.className,
            ),
          ],
        ],
      ),
    );
  }

  String _examTimeText(ExamItem exam) {
    final parts = [
      exam.examDate,
      exam.startTime,
      exam.examTimeRange,
    ].where((part) => part.isNotEmpty).toList(growable: false);
    return parts.isEmpty ? '时间待定' : parts.join(' ');
  }
}

class _SeatBadge extends StatelessWidget {
  const _SeatBadge({required this.seatNumber});

  final String seatNumber;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      constraints: const BoxConstraints(minWidth: 58),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            seatNumber.isEmpty ? '-' : seatNumber,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          Text(
            '座位',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.primary.withValues(alpha: 0.78),
                ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
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

    return Row(
      children: [
        Icon(icon, size: AppTokens.iconSm, color: colors.textTertiary),
        const SizedBox(width: AppTokens.gap8),
        SizedBox(
          width: 38,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(width: AppTokens.gap8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
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

class _ExamFilterResult {
  const _ExamFilterResult({required this.semester, required this.pcid});

  final String semester;
  final String pcid;
}

class _ExamBatchChoice {
  const _ExamBatchChoice({required this.value, required this.label});

  final String value;
  final String label;
}

class _ExamFilterSheet extends StatefulWidget {
  const _ExamFilterSheet();

  @override
  State<_ExamFilterSheet> createState() => _ExamFilterSheetState();
}

class _ExamFilterSheetState extends State<_ExamFilterSheet> {
  late String semester;
  late String pcid;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<ExamsController>();
    semester = controller.selectedSemester;
    pcid = controller.selectedPcid;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExamsController>();
    final semesters = controller.semesters;
    final batchChoices = [
      const _ExamBatchChoice(value: '', label: '全部批次'),
      ...controller.batches.map(
        (batch) => _ExamBatchChoice(value: batch.pcid, label: batch.label),
      ),
    ];
    final selectedSemester = semesters.firstWhereOrNull(
      (item) => item.value == semester,
    );
    final selectedBatch = batchChoices.firstWhereOrNull(
      (item) => item.value == pcid,
    );

    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        initialChildSize: 0.48,
        minChildSize: 0.32,
        maxChildSize: 0.72,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              Row(
                children: [
                  _IconBox(icon: AppIcons.filter),
                  const SizedBox(width: AppTokens.gap10),
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
              const SizedBox(height: AppTokens.gap16),
              AppSurface(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    AppComboBox<ExamSemesterOption>(
                      label: '学年学期',
                      value: selectedSemester,
                      items: semesters,
                      itemLabelBuilder: (item) => item.label,
                      onChanged: (item) {
                        if (item == null) return;
                        setState(() {
                          semester = item.value;
                          pcid = '';
                        });
                      },
                    ),
                    const SizedBox(height: AppTokens.gap14),
                    AppComboBox<_ExamBatchChoice>(
                      label: '考试批次',
                      value: selectedBatch,
                      items: batchChoices,
                      itemLabelBuilder: (item) => item.label,
                      onChanged: (item) {
                        if (item == null) return;
                        setState(() => pcid = item.value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.gap14),
              AppButton(
                label: '应用筛选',
                icon: AppIcons.check,
                fullWidth: true,
                onPressed: () {
                  Navigator.of(context).pop(
                    _ExamFilterResult(semester: semester, pcid: pcid),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExamSkeletonView extends StatelessWidget {
  const _ExamSkeletonView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => AppPage(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _ExamHeader(onBack: onBack, onFilter: null, onRefresh: null),
          const SizedBox(height: AppTokens.gap16),
          AppSurface(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: palette.block(radius: AppTokens.radiusSm),
                    ),
                    const SizedBox(width: AppTokens.gap10),
                    Expanded(
                      child: SkeletonBar(
                        decoration: palette.line(radius: 8),
                        widthFactor: 0.44,
                        height: 18,
                      ),
                    ),
                    Container(
                      width: 76,
                      height: 24,
                      decoration: palette.block(radius: AppTokens.radiusFull),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.gap14),
                Row(
                  children: [
                    Expanded(child: _SkeletonMetric(palette: palette)),
                    const SizedBox(width: AppTokens.gap10),
                    Expanded(child: _SkeletonMetric(palette: palette)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.gap12),
          for (int i = 0; i < 5; i++) ...[
            _SkeletonExamCard(palette: palette),
            const SizedBox(height: AppTokens.gap12),
          ],
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
      height: 68,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 0.58,
            height: 15,
          ),
          const SizedBox(height: AppTokens.gap8),
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 0.42,
            height: 12,
          ),
        ],
      ),
    );
  }
}

class _SkeletonExamCard extends StatelessWidget {
  const _SkeletonExamCard({required this.palette});

  final SkeletonPalette palette;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: palette.block(radius: AppTokens.radiusSm),
          ),
          const SizedBox(width: AppTokens.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBar(
                  decoration: palette.line(radius: 8),
                  widthFactor: 0.82,
                  height: 17,
                ),
                const SizedBox(height: AppTokens.gap8),
                SkeletonBar(
                  decoration: palette.line(radius: 8),
                  widthFactor: 0.5,
                  height: 12,
                ),
                const SizedBox(height: AppTokens.gap14),
                SkeletonBar(
                  decoration: palette.line(radius: 8),
                  widthFactor: 0.72,
                  height: 12,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.gap10),
          Container(
            width: 58,
            height: 52,
            decoration: palette.block(radius: AppTokens.radiusMd),
          ),
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
    required this.onFilter,
    required this.onRefresh,
  });

  final String title;
  final String message;
  final VoidCallback onBack;
  final VoidCallback? onFilter;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        _ExamHeader(
          onBack: onBack,
          onFilter: onFilter,
          onRefresh: onRefresh,
        ),
        const SizedBox(height: AppTokens.gap16),
        AppSurface(
          child: SizedBox(
            height: 320,
            child: AppEmptyState(
              title: title,
              message: message,
              icon: AppIcons.exam,
              actionLabel: '重试',
              onAction: onRefresh,
            ),
          ),
        ),
      ],
    );
  }
}
