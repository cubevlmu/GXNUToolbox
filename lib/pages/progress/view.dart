/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/course_plan.dart';
import 'package:class_tool/pages/progress/controller.dart';
import 'package:fin_ui/app_combo_box.dart';
import 'package:fin_ui/app_context.dart';
import 'package:fin_ui/app_empty_state.dart';
import 'package:fin_ui/app_icon_button.dart';
import 'package:fin_ui/app_icons.dart';
import 'package:fin_ui/app_page.dart';
import 'package:fin_ui/app_progress_bar.dart';
import 'package:fin_ui/app_surface.dart';
import 'package:fin_ui/app_tag.dart';
import 'package:fin_ui/app_tokens.dart';
import 'package:fin_ui/fui_page_head.dart';
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
      backgroundColor: context.colors.background,
      body: GetBuilder<ProgressController>(
        id: 'progress-content',
        builder: (controller) {
          if (controller.isLoading.value && controller.response.value == null) {
            return _ProgressSkeletonView(
              onBack: () => Navigator.of(context).maybePop(),
            );
          }

          if (controller.error.isNotEmpty &&
              controller.response.value == null) {
            return _FeedbackState(
              title: '培养进度加载失败',
              message: controller.error.value,
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: controller.loadData,
            );
          }

          final response = controller.response.value;
          if (response == null || response.sections.isEmpty) {
            return _FeedbackState(
              title: '暂无培养进度',
              message: '点击刷新后重试',
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: controller.loadData,
            );
          }

          return FUIPage(
            children: [
              _ProgressHeader(
                onBack: () => Navigator.of(context).maybePop(),
                onRefresh: controller.isLoading.value
                    ? null
                    : controller.loadData,
              ),
              const SizedBox(height: FUITokens.gap16),
              _SemesterCombo(controller: controller),
              const SizedBox(height: FUITokens.gap16),
              _OverviewCard(
                completed: controller.completedCount,
                total: controller.totalCount,
              ),
              const SizedBox(height: FUITokens.gap16),
              _GroupHeader(count: _groupCount(response)),
              const SizedBox(height: FUITokens.gap8),
              for (final section in response.sections) ...[
                _PlanSectionHeader(section: section),
                const SizedBox(height: FUITokens.gap8),
                for (final group in section.groups) ...[
                  _GroupCard(
                    key: ValueKey<String>(
                      '${controller.selectedSemester.value}|${section.name}|${group.name}',
                    ),
                    group: group,
                  ),
                  const SizedBox(height: FUITokens.gap12),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.onBack, required this.onRefresh});

  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return FuiPageHead(
      title: '培养进度',
      subtitle: '区分培养方案内与计划外课程',
      actions: [
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

class _SemesterCombo extends StatelessWidget {
  const _SemesterCombo({required this.controller});

  final ProgressController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = ['', ...controller.semesterOptions];
      return FUISurface(
        padding: const EdgeInsets.all(14),
        child: FUIComboBox<String>(
          label: '学年学期',
          value: controller.selectedSemester.value,
          items: items,
          enabled: !controller.isLoading.value,
          itemLabelBuilder: (item) => item.isEmpty ? '全部学期' : item,
          onChanged: (value) {
            if (value != null) {
              controller.changeSemester(value);
            }
          },
        ),
      );
    });
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : completed / total;

    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: FUIIcons.progress),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: Text(
                  '完成进度',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FUITag(
                label: '$completed / $total',
                variant: ratio >= 1
                    ? FUITagVariant.success
                    : FUITagVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap14),
          FUIProgressBar(value: ratio),
          const SizedBox(height: FUITokens.gap14),
          Row(
            children: [
              Expanded(
                child: _Metric(label: '已完成', value: '$completed'),
              ),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: _Metric(label: '总课程', value: '$total'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            '课程模块',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          '$count 个分组',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GroupCard extends StatefulWidget {
  const _GroupCard({super.key, required this.group});

  final CoursePlanGroup group;

  @override
  State<_GroupCard> createState() => _GroupCardState();
}

class _PlanSectionHeader extends StatelessWidget {
  const _PlanSectionHeader({required this.section});

  final CoursePlanSection section;

  @override
  Widget build(BuildContext context) {
    final count = section.groups.fold<int>(
      0,
      (sum, group) => sum + group.items.length,
    );
    return Row(
      children: [
        Expanded(
          child: Text(
            section.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        FUITag(label: '$count 门'),
      ],
    );
  }
}

class _GroupCardState extends State<_GroupCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final completed = group.items.where((item) => item.isCompleted).length;
    final ratio = group.items.isEmpty ? 0.0 : completed / group.items.length;

    return FUISurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name.isEmpty ? '课程模块' : group.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: FUITokens.gap8),
                          FUIProgressBar(value: ratio),
                        ],
                      ),
                    ),
                    const SizedBox(width: FUITokens.gap12),
                    FUITag(
                      label: '$completed / ${group.items.length}',
                      variant: ratio >= 1
                          ? FUITagVariant.success
                          : FUITagVariant.primary,
                    ),
                    const SizedBox(width: FUITokens.gap8),
                    Icon(
                      _expanded ? FUIIcons.chevronDown : FUIIcons.chevronRight,
                      size: FUITokens.iconMd,
                      color: context.colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded)
            for (final item in group.items) _CourseTile(item: item),
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
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: FUITokens.gap6),
                Wrap(
                  spacing: FUITokens.gap8,
                  runSpacing: FUITokens.gap6,
                  children: [
                    if (item.courseCode.isNotEmpty)
                      FUITag(label: item.courseCode),
                    if (item.credits.isNotEmpty)
                      FUITag(label: '${item.credits} 学分'),
                    if (item.examType.isNotEmpty) FUITag(label: item.examType),
                    if (item.categoryLabel.isNotEmpty)
                      FUITag(label: item.categoryLabel),
                    if (item.courseType.isNotEmpty)
                      FUITag(label: item.courseType),
                    if (item.semester.isNotEmpty)
                      FUITag(label: item.semester),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: FUITokens.gap10),
          FUITag(
            label: item.displayResult,
            variant: _statusVariant(item),
          ),
        ],
      ),
    );
  }

  FUITagVariant _statusVariant(CoursePlanItem item) {
    if (item.isCompleted) return FUITagVariant.success;
    if (item.isInProgress) return FUITagVariant.primary;
    if (item.specialStatus.contains('旷考') ||
        item.specialStatus.contains('不及格')) {
      return FUITagVariant.danger;
    }
    if (item.specialStatus == '免修') return FUITagVariant.neutral;
    return FUITagVariant.warning;
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

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
        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: FUITokens.gap4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
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

class _ProgressSkeletonView extends StatelessWidget {
  const _ProgressSkeletonView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => FUIPage(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _ProgressHeader(onBack: onBack, onRefresh: null),
          const SizedBox(height: FUITokens.gap16),
          SkeletonBar(
            decoration: palette.line(radius: FUITokens.radiusMd),
            widthFactor: 1,
            height: 72,
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISurface(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                SkeletonBar(
                  decoration: palette.line(radius: 8),
                  widthFactor: 0.46,
                  height: 18,
                ),
                const SizedBox(height: FUITokens.gap14),
                SkeletonBar(
                  decoration: palette.line(radius: FUITokens.radiusFull),
                  widthFactor: 1,
                  height: 6,
                ),
                const SizedBox(height: FUITokens.gap14),
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
          const SizedBox(height: FUITokens.gap16),
          for (int i = 0; i < 4; i++) ...[
            _SkeletonGroup(palette: palette),
            const SizedBox(height: FUITokens.gap12),
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
            widthFactor: 0.52,
            height: 15,
          ),
          const SizedBox(height: FUITokens.gap8),
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 0.38,
            height: 12,
          ),
        ],
      ),
    );
  }
}

class _SkeletonGroup extends StatelessWidget {
  const _SkeletonGroup({required this.palette});

  final SkeletonPalette palette;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 0.62,
            height: 16,
          ),
          const SizedBox(height: FUITokens.gap12),
          SkeletonBar(
            decoration: palette.line(radius: FUITokens.radiusFull),
            widthFactor: 1,
            height: 6,
          ),
          const SizedBox(height: FUITokens.gap12),
          SkeletonBar(
            decoration: palette.line(radius: FUITokens.radiusMd),
            widthFactor: 1,
            height: 46,
          ),
          const SizedBox(height: FUITokens.gap8),
          SkeletonBar(
            decoration: palette.line(radius: FUITokens.radiusMd),
            widthFactor: 1,
            height: 46,
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
    required this.onRefresh,
  });

  final String title;
  final String message;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return FUIPage(
      children: [
        _ProgressHeader(onBack: onBack, onRefresh: onRefresh),
        const SizedBox(height: FUITokens.gap16),
        FUISurface(
          child: SizedBox(
            height: 320,
            child: FUIEmptyState(
              title: title,
              message: message,
              icon: FUIIcons.progress,
              actionLabel: '重试',
              onAction: onRefresh,
            ),
          ),
        ),
      ],
    );
  }
}

int _groupCount(CoursePlanResponse response) {
  return response.sections.fold<int>(
    0,
    (sum, section) => sum + section.groups.length,
  );
}
