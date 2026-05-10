/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/bell_schedule.dart';
import 'package:class_tool/pages/time/controller.dart';
import 'package:class_tool/widgets/skeleton_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimePage extends StatefulWidget {
  const TimePage({super.key});

  @override
  State<TimePage> createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  late final TimeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TimeController(), permanent: false);
  }

  @override
  void dispose() {
    if (Get.isRegistered<TimeController>()) {
      Get.delete<TimeController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('作息时间'),
        actions: [
          GetBuilder<TimeController>(
            id: 'time-content',
            builder: (c) => IconButton(
              icon: const Icon(Icons.refresh_outlined),
              tooltip: '刷新',
              onPressed: c.isLoading.value ? null : c.refresh,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: GetBuilder<TimeController>(
          id: 'time-content',
          builder: (c) {
            if (c.isLoading.value && c.campuses.isEmpty) {
              return const _TimeSkeletonView();
            }
            if (c.error.isNotEmpty && c.campuses.isEmpty) {
              return _FeedbackState(
                title: '加载失败',
                subtitle: c.error.value,
                onRetry: c.refresh,
              );
            }
            if (c.campuses.isEmpty) {
              return _FeedbackState(
                title: '暂无数据',
                subtitle: '点击刷新重试',
                onRetry: c.refresh,
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() {
                    return SegmentedButton<int>(
                      segments: List.generate(
                        c.campuses.length,
                        (i) => ButtonSegment<int>(
                          value: i,
                          label: Text(c.campuses[i].campusName),
                        ),
                      ),
                      selected: {c.selectedCampusIndex.value},
                      onSelectionChanged: (v) {
                        c.selectedCampusIndex.value = v.first;
                      },
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Row(
                    children: [
                      Text(
                        '${c.semester.value} 学期',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                      Text(
                        '${c.campuses.length}个校区',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Obx(() {
                    final campus = c.selectedCampus;
                    if (campus == null) return const SizedBox.shrink();
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: campus.periods.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (_, index) {
                        final period = campus.periods[index];
                        return _PeriodTile(period: period);
                      },
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PeriodTile extends StatelessWidget {
  const _PeriodTile({required this.period});

  final PeriodItem period;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '${period.periodNumber}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                period.periodName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              period.timeText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSkeletonView extends StatelessWidget {
  const _TimeSkeletonView();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 0.26,
            height: 12,
          ),
          const SizedBox(height: 14),
          SkeletonBar(
            decoration: palette.line(radius: 10),
            widthFactor: 1.0,
            height: 38,
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < 8; i++) ...[
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Container(decoration: palette.line(radius: 10)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SkeletonBar(
                        decoration: palette.line(radius: 6),
                        widthFactor: 0.4,
                        height: 16,
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      height: 14,
                      child: Container(decoration: palette.line(radius: 6)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
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
              Icons.schedule_outlined,
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
