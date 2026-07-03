/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/credit_progress.dart';
import 'package:class_tool/pages/credit/controller.dart';
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

class CreditPage extends StatefulWidget {
  const CreditPage({super.key});

  @override
  State<CreditPage> createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  late final CreditController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CreditController(), permanent: false);
  }

  @override
  void dispose() {
    if (Get.isRegistered<CreditController>()) {
      Get.delete<CreditController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: GetBuilder<CreditController>(
        id: 'credit-content',
        builder: (controller) {
          if (controller.isLoading.value && controller.response.value == null) {
            return _CreditSkeletonView(
              onBack: () => Navigator.of(context).maybePop(),
            );
          }

          if (controller.error.isNotEmpty &&
              controller.response.value == null) {
            return _FeedbackState(
              title: '学分进程加载失败',
              message: controller.error.value,
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: controller.loadData,
            );
          }

          final response = controller.response.value;
          if (response == null || response.sections.isEmpty) {
            return _FeedbackState(
              title: '暂无学分数据',
              message: '点击刷新后重试',
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: controller.loadData,
            );
          }

          return FUIPage(
            children: [
              _CreditHeader(
                onBack: () => Navigator.of(context).maybePop(),
                onRefresh: controller.isLoading.value
                    ? null
                    : controller.loadData,
              ),
              const SizedBox(height: FUITokens.gap16),
              _SemesterCombo(controller: controller),
              const SizedBox(height: FUITokens.gap16),
              _SummaryCard(response: response),
              const SizedBox(height: FUITokens.gap16),
              _SectionHeader(count: response.sections.length),
              const SizedBox(height: FUITokens.gap8),
              for (final section in response.sections) ...[
                _CreditSectionCard(section: section),
                const SizedBox(height: FUITokens.gap12),
              ],
              _TotalCard(response: response),
            ],
          );
        },
      ),
    );
  }
}

class _CreditHeader extends StatelessWidget {
  const _CreditHeader({required this.onBack, required this.onRefresh});

  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return FuiPageHead(
      title: '学分进程',
      subtitle: '查看已修、未修与修读中学分',
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

  final CreditController controller;

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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.response});

  final CreditProgressResponse response;

  @override
  Widget build(BuildContext context) {
    final ratio = response.totalRequired <= 0
        ? 0.0
        : response.totalEarned / response.totalRequired;

    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: FUIIcons.credit),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: Text(
                  '学分总览',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FUITag(
                label: '${(ratio * 100).clamp(0, 100).toStringAsFixed(0)}%',
                variant: _progressVariant(ratio),
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap14),
          FUIProgressBar(value: ratio),
          const SizedBox(height: FUITokens.gap14),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: '应修',
                  value: _fmt(response.totalRequired),
                ),
              ),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: _Metric(label: '已修', value: _fmt(response.totalEarned)),
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap10),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: '未修',
                  value: _fmt(response.totalRemaining),
                ),
              ),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: _Metric(
                  label: '修读中',
                  value: _fmt(response.totalInProgress),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            '分类进度',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          '$count 个模块',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CreditSectionCard extends StatelessWidget {
  const _CreditSectionCard({required this.section});

  final CreditSection section;

  @override
  Widget build(BuildContext context) {
    final title = section.items.isEmpty
        ? '模块合计'
        : section.items.first.natureName;
    final ratio = section.totalRequired <= 0
        ? 0.0
        : section.totalEarned / section.totalRequired;

    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.isEmpty ? '学分模块' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              FUITag(
                label: _statusText(ratio),
                variant: _progressVariant(ratio),
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap12),
          FUIProgressBar(value: ratio),
          const SizedBox(height: FUITokens.gap12),
          Row(
            children: [
              Expanded(
                child: _SmallMetric(
                  label: '应修',
                  value: _fmt(section.totalRequired),
                ),
              ),
              Expanded(
                child: _SmallMetric(
                  label: '已修',
                  value: _fmt(section.totalEarned),
                ),
              ),
              Expanded(
                child: _SmallMetric(
                  label: '未修',
                  value: _fmt(section.totalRemaining),
                ),
              ),
              Expanded(
                child: _SmallMetric(
                  label: '修读中',
                  value: _fmt(section.totalInProgress),
                ),
              ),
            ],
          ),
          if (section.items.isNotEmpty) ...[
            const SizedBox(height: FUITokens.gap12),
            for (final item in section.items.take(4)) ...[
              _CreditItemRow(item: item),
              const SizedBox(height: FUITokens.gap8),
            ],
          ],
        ],
      ),
    );
  }
}

class _CreditItemRow extends StatelessWidget {
  const _CreditItemRow({required this.item});

  final CreditItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryName.isEmpty
                      ? item.natureName
                      : item.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: FUITokens.gap4),
                Text(
                  '已修 ${_fmt(item.earnedCredits)} / 应修 ${_fmt(item.requiredCredits)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          FUITag(
            label: item.remainingCredits <= 0
                ? '已完成'
                : '差 ${_fmt(item.remainingCredits)}',
            variant: item.remainingCredits <= 0
                ? FUITagVariant.success
                : FUITagVariant.warning,
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.response});

  final CreditProgressResponse response;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.all(14),
      backgroundColor: context.colors.primarySoft,
      borderColor: context.colors.primary.withValues(alpha: 0.24),
      child: Row(
        children: [
          _IconBox(icon: FUIIcons.check),
          const SizedBox(width: FUITokens.gap10),
          Expanded(
            child: Text(
              '总计：已修 ${_fmt(response.totalEarned)} / 应修 ${_fmt(response.totalRequired)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SmallMetric extends StatelessWidget {
  const _SmallMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: FUITokens.gap2),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
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
        borderRadius: BorderRadius.circular(FUITokens.radiusSm),
      ),
      child: Icon(icon, size: FUITokens.iconMd, color: colors.primary),
    );
  }
}

class _CreditSkeletonView extends StatelessWidget {
  const _CreditSkeletonView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => FUIPage(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _CreditHeader(onBack: onBack, onRefresh: null),
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
            _SkeletonSection(palette: palette),
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

class _SkeletonSection extends StatelessWidget {
  const _SkeletonSection({required this.palette});

  final SkeletonPalette palette;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: Column(
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
        _CreditHeader(onBack: onBack, onRefresh: onRefresh),
        const SizedBox(height: FUITokens.gap16),
        FUISurface(
          child: SizedBox(
            height: 320,
            child: FUIEmptyState(
              title: title,
              message: message,
              icon: FUIIcons.credit,
              actionLabel: '重试',
              onAction: onRefresh,
            ),
          ),
        ),
      ],
    );
  }
}

String _fmt(double value) {
  return value == value.truncateToDouble()
      ? '${value.toInt()}'
      : value.toStringAsFixed(1);
}

String _statusText(double ratio) {
  if (ratio >= 1) return '已完成';
  if (ratio <= 0) return '未开始';
  return '进行中';
}

FUITagVariant _progressVariant(double ratio) {
  if (ratio >= 1) return FUITagVariant.success;
  if (ratio <= 0) return FUITagVariant.warning;
  return FUITagVariant.primary;
}
