/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/credit_progress.dart';
import 'package:class_tool/pages/credit/controller.dart';
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
      appBar: AppBar(
        title: const Text('学分进程'),
        actions: [
          GetBuilder<CreditController>(
            id: 'credit-content',
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
        child: GetBuilder<CreditController>(
          id: 'credit-content',
          builder: (c) {
            if (c.isLoading.value && c.response.value == null) {
              return const _CreditSkeletonView();
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
                _SemesterDropdown(controller: c),
                if (resp.totalRequired > 0) _SummaryCard(resp: resp),
                const SizedBox(height: 6),
                _TableHeader(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    itemCount: resp.sections.length + 1,
                    itemBuilder: (_, index) {
                      if (index == resp.sections.length) {
                        return _TotalRow(resp: resp);
                      }
                      final section = resp.sections[index];
                      return Column(
                        children: [
                          if (section.items.isEmpty)
                            _GroupRow(section: section)
                          else ...[
                            _GroupRow(section: section, isHeader: true),
                            for (final item in section.items)
                              _ItemRow(item: item),
                          ],
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

class _SemesterDropdown extends StatelessWidget {
  const _SemesterDropdown({required this.controller});

  final CreditController controller;

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
            const DropdownMenuItem<String>(value: '', child: Text('全部')),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.resp});

  final CreditProgressResponse resp;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Card(
        color: colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _SummaryTile(
                label: '应修',
                value: _fmt(resp.totalRequired),
              ),
              _SummaryTile(
                label: '已修',
                value: _fmt(resp.totalEarned),
                color: Colors.green.shade700,
              ),
              _SummaryTile(
                label: '未修',
                value: _fmt(resp.totalRemaining),
                color: Colors.orange.shade700,
              ),
              _SummaryTile(
                label: '修读中',
                value: _fmt(resp.totalInProgress),
                color: Colors.blue.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(double v) => v == v.truncateToDouble() ? '${v.toInt()}' : '$v';
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 2),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 32),
          const Expanded(child: Text('模块', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          const Expanded(child: Text('属性', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          const SizedBox(width: 44, child: Text('应修', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
          const SizedBox(width: 44, child: Text('已修', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
          const SizedBox(width: 44, child: Text('未修', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
          const SizedBox(width: 56, child: Text('修读中', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.section, this.isHeader = false});

  final CreditSection section;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(isHeader ? 120 : 80),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          if (isHeader)
            const Icon(Icons.keyboard_arrow_right, size: 16)
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              section.items.isNotEmpty && !isHeader
                  ? section.items.first.natureName
                  : '合计',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: SizedBox.shrink()),
          _Num(value: _fmt(section.totalRequired)),
          _Num(value: _fmt(section.totalEarned), color: Colors.green.shade700),
          _Num(value: _fmt(section.totalRemaining), color: Colors.orange.shade700),
          _Num(value: _fmt(section.totalInProgress), color: Colors.blue.shade700),
        ],
      ),
    );
  }

  String _fmt(double v) => v == v.truncateToDouble() ? '${v.toInt()}' : '$v';
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final CreditItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.fromLTRB(44, 6, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.natureName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.categoryName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _Num(value: _fmt(item.requiredCredits)),
          _Num(value: _fmt(item.earnedCredits), color: Colors.green.shade700),
          _Num(value: _fmt(item.remainingCredits), color: Colors.orange.shade700),
          _Num(value: _fmt(item.inProgressCredits), color: Colors.blue.shade700),
        ],
      ),
    );
  }

  String _fmt(double v) => v == v.truncateToDouble() ? '${v.toInt()}' : '$v';
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.resp});

  final CreditProgressResponse resp;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.check_circle_outline, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '总计',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Expanded(child: SizedBox.shrink()),
          _Num(value: _fmt(resp.totalRequired)),
          _Num(value: _fmt(resp.totalEarned), color: Colors.green),
          _Num(value: _fmt(resp.totalRemaining), color: Colors.orange),
          _Num(value: _fmt(resp.totalInProgress), color: Colors.blue),
        ],
      ),
    );
  }

  String _fmt(double v) => v == v.truncateToDouble() ? '${v.toInt()}' : '$v';
}

class _Num extends StatelessWidget {
  const _Num({required this.value, this.color});

  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _CreditSkeletonView extends StatelessWidget {
  const _CreditSkeletonView();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
        children: [
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 1.0,
            height: 44,
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  for (int i = 0; i < 4; i++) ...[
                    Expanded(
                      child: Column(
                        children: [
                          SkeletonBar(
                            decoration: palette.line(radius: 4),
                            widthFactor: 0.5,
                            height: 18,
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
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < 5; i++) ...[
            SkeletonBar(
              decoration: palette.line(radius: 6),
              widthFactor: 1.0,
              height: 32,
            ),
            const SizedBox(height: 4),
            for (int j = 0; j < 2; j++) ...[
              SkeletonBar(
                decoration: palette.line(radius: 4),
                widthFactor: 1.0,
                height: 24,
              ),
              const SizedBox(height: 2),
            ],
            const SizedBox(height: 6),
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
              Icons.pie_chart_outline,
              size: 56,
              color: colorScheme.onSurfaceVariant.withAlpha(120),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
