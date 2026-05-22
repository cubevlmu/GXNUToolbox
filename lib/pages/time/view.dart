/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/bell_schedule.dart';
import 'package:class_tool/pages/time/controller.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_empty_state.dart';
import 'package:class_tool/ui/app_icon_button.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_page.dart';
import 'package:class_tool/ui/app_segmented_control.dart';
import 'package:class_tool/ui/app_surface.dart';
import 'package:class_tool/ui/app_tag.dart';
import 'package:class_tool/ui/app_tokens.dart';
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
      backgroundColor: context.colors.background,
      body: GetBuilder<TimeController>(
        id: 'time-content',
        builder: (controller) {
          if (controller.isLoading.value && controller.campuses.isEmpty) {
            return _TimeSkeletonView(
              onBack: () => Navigator.of(context).maybePop(),
            );
          }

          if (controller.error.isNotEmpty && controller.campuses.isEmpty) {
            return _FeedbackState(
              title: '作息时间加载失败',
              message: controller.error.value,
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: controller.refresh,
            );
          }

          if (controller.campuses.isEmpty) {
            return _FeedbackState(
              title: '暂无作息数据',
              message: '点击刷新后重试',
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: controller.refresh,
            );
          }

          return AppPage(
            children: [
              _TimeHeader(
                onBack: () => Navigator.of(context).maybePop(),
                onRefresh:
                    controller.isLoading.value ? null : controller.refresh,
              ),
              const SizedBox(height: AppTokens.gap16),
              _CampusSelector(controller: controller),
              const SizedBox(height: AppTokens.gap16),
              Obx(() {
                final campus = controller.selectedCampus;
                if (campus == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ScheduleSummary(
                      campus: campus,
                      semester: controller.semester.value,
                      campusCount: controller.campuses.length,
                    ),
                    const SizedBox(height: AppTokens.gap16),
                    _ListHeader(count: campus.periods.length),
                    const SizedBox(height: AppTokens.gap8),
                    for (final period in campus.periods) ...[
                      _PeriodTile(period: period),
                      const SizedBox(height: AppTokens.gap10),
                    ],
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _TimeHeader extends StatelessWidget {
  const _TimeHeader({required this.onBack, required this.onRefresh});

  final VoidCallback onBack;
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
                '作息时间',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppTokens.gap4),
              Text(
                '查看各校区上课时间安排',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        AppIconButton(
          icon: AppIcons.refresh,
          tooltip: '刷新',
          variant: AppIconButtonVariant.outline,
          onPressed: onRefresh,
        ),
      ],
    );
  }
}

class _CampusSelector extends StatelessWidget {
  const _CampusSelector({required this.controller});

  final TimeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AppSegmentedControl<int>(
        value: controller.selectedCampusIndex.value,
        items: [
          for (var i = 0; i < controller.campuses.length; i++)
            AppSegmentedItem<int>(
              value: i,
              label: controller.campuses[i].campusName,
              icon: AppIcons.building,
            ),
        ],
        onChanged: (value) => controller.selectedCampusIndex.value = value,
      );
    });
  }
}

class _ScheduleSummary extends StatelessWidget {
  const _ScheduleSummary({
    required this.campus,
    required this.semester,
    required this.campusCount,
  });

  final CampusSchedule campus;
  final String semester;
  final int campusCount;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _IconBox(icon: AppIcons.schedule),
          const SizedBox(width: AppTokens.gap10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campus.campusName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppTokens.gap4),
                Text(
                  '$semester 学期 · $campusCount 个校区',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          AppTag(
            label: '${campus.periods.length} 节',
            variant: AppTagVariant.primary,
          ),
        ],
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            '节次安排',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Text(
          '$count 条',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _PeriodTile extends StatelessWidget {
  const _PeriodTile({required this.period});

  final PeriodItem period;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            alignment: Alignment.center,
            child: Text(
              '${period.periodNumber}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: AppTokens.gap12),
          Expanded(
            child: Text(
              period.periodName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: AppTokens.gap10),
          Text(
            period.timeText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
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
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Icon(icon, size: AppTokens.iconMd, color: colors.primary),
    );
  }
}

class _TimeSkeletonView extends StatelessWidget {
  const _TimeSkeletonView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => AppPage(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _TimeHeader(onBack: onBack, onRefresh: null),
          const SizedBox(height: AppTokens.gap16),
          SkeletonBar(
            decoration: palette.line(radius: AppTokens.radiusSm),
            widthFactor: 1,
            height: 52,
          ),
          const SizedBox(height: AppTokens.gap16),
          SkeletonBar(
            decoration: palette.line(radius: AppTokens.radiusMd),
            widthFactor: 1,
            height: 70,
          ),
          const SizedBox(height: AppTokens.gap16),
          for (int i = 0; i < 8; i++) ...[
            SkeletonBar(
              decoration: palette.line(radius: AppTokens.radiusLg),
              widthFactor: 1,
              height: 64,
            ),
            const SizedBox(height: AppTokens.gap10),
          ],
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
    return AppPage(
      children: [
        _TimeHeader(onBack: onBack, onRefresh: onRefresh),
        const SizedBox(height: AppTokens.gap16),
        AppSurface(
          child: SizedBox(
            height: 320,
            child: AppEmptyState(
              title: title,
              message: message,
              icon: AppIcons.schedule,
              actionLabel: '重试',
              onAction: onRefresh,
            ),
          ),
        ),
      ],
    );
  }
}
