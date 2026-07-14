/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/bell_schedule.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:class_tool/pages/time/controller.dart';
import 'package:fin_ui/app_button_group_tab_bar.dart';
import 'package:fin_ui/app_context.dart';
import 'package:fin_ui/app_empty_state.dart';
import 'package:fin_ui/app_icon_button.dart';
import 'package:fin_ui/app_icons.dart';
import 'package:fin_ui/app_page.dart';
import 'package:fin_ui/app_surface.dart';
import 'package:fin_ui/app_tag.dart';
import 'package:fin_ui/app_tokens.dart';
import 'package:fin_ui/fui_page_head.dart';
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
            return const _TimeSkeletonView();
          }

          if (controller.error.isNotEmpty && controller.campuses.isEmpty) {
            return _FeedbackState(
              title: '作息时间加载失败',
              message: controller.error.value,
              onRefresh: controller.refresh,
            );
          }

          if (controller.campuses.isEmpty) {
            return _FeedbackState(
              title: '暂无作息数据',
              message: '点击刷新后重试',
              onRefresh: controller.refresh,
            );
          }

          return FUIPage(
            children: [
              _TimeHeader(
                onRefresh: controller.isLoading.value
                    ? null
                    : controller.refresh,
              ),
              const SizedBox(height: FUITokens.gap16),
              _CampusSelector(controller: controller),
              const SizedBox(height: FUITokens.gap16),
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
                    const SizedBox(height: FUITokens.gap16),
                    _ListHeader(count: campus.periods.length),
                    const SizedBox(height: FUITokens.gap8),
                    _PeriodTimeline(periods: campus.periods),
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
  const _TimeHeader({required this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return FuiPageHead(
      title: '作息时间',
      subtitle: '查看各校区上课时间安排',
      actions: [
        FUIIconButton(
          icon: FUIIcons.refresh,
          tooltip: '刷新',
          variant: FUIIconButtonVariant.outline,
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
    final settings = Get.find<SettingsController>();
    return Obx(() {
      final selectedIndex = controller.selectedCampusIndex.value.clamp(
        0,
        controller.campuses.length - 1,
      ).toInt();
      return FUIButtonGroupTabBar(
        selectedIndex: selectedIndex,
        items: [
          for (var i = 0; i < controller.campuses.length; i++)
            FUIButtonGroupTabItem(
              label: controller.campuses[i].campusName,
              icon: _campusIcon(i),
              tooltip: controller.campuses[i].campusName,
            ),
        ],
        showLabels: !settings.buttonGroupIconOnly.value,
        alignment: settings.buttonGroupAlignment.value.alignment,
        onSelected: (value) => controller.selectedCampusIndex.value = value,
      );
    });
  }

  IconData _campusIcon(int index) {
    return switch (index) {
      0 => FUIIcons.building,
      1 => FUIIcons.school,
      _ => FUIIcons.location,
    };
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
    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _IconBox(icon: FUIIcons.schedule),
          const SizedBox(width: FUITokens.gap10),
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
                const SizedBox(height: FUITokens.gap4),
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
          FUITag(
            label: '${campus.periods.length} 节',
            variant: FUITagVariant.primary,
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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

class _PeriodTimeline extends StatelessWidget {
  const _PeriodTimeline({required this.periods});

  final List<PeriodItem> periods;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
      child: Column(
        children: [
          for (var i = 0; i < periods.length; i++)
            _PeriodTimelineItem(
              period: periods[i],
              isFirst: i == 0,
              isLast: i == periods.length - 1,
            ),
        ],
      ),
    );
  }
}

class _PeriodTimelineItem extends StatelessWidget {
  const _PeriodTimelineItem({
    required this.period,
    required this.isFirst,
    required this.isLast,
  });

  final PeriodItem period;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 38,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 4,
                  color: isFirst ? Colors.transparent : colors.border,
                ),
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primarySoft,
                    borderRadius: BorderRadius.circular(FUITokens.radiusFull),
                  ),
                  child: Text(
                    '${period.periodNumber}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : colors.border,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: FUITokens.gap8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: FUITokens.gap12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      period.periodName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: FUITokens.gap10),
                  Text(
                    period.timeText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
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
        borderRadius: BorderRadius.circular(FUITokens.radiusSm),
      ),
      child: Icon(icon, size: FUITokens.iconMd, color: colors.primary),
    );
  }
}

class _TimeSkeletonView extends StatelessWidget {
  const _TimeSkeletonView();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => FUIPage(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _TimeHeader(onRefresh: null),
          const SizedBox(height: FUITokens.gap16),
          SkeletonBar(
            decoration: palette.line(radius: FUITokens.radiusSm),
            widthFactor: 1,
            height: 52,
          ),
          const SizedBox(height: FUITokens.gap16),
          SkeletonBar(
            decoration: palette.line(radius: FUITokens.radiusMd),
            widthFactor: 1,
            height: 70,
          ),
          const SizedBox(height: FUITokens.gap16),
          for (int i = 0; i < 8; i++) ...[
            SkeletonBar(
              decoration: palette.line(radius: FUITokens.radiusLg),
              widthFactor: 1,
              height: 64,
            ),
            const SizedBox(height: FUITokens.gap10),
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
    required this.onRefresh,
  });

  final String title;
  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return FUIPage(
      children: [
        _TimeHeader(onRefresh: onRefresh),
        const SizedBox(height: FUITokens.gap16),
        FUISurface(
          child: SizedBox(
            height: 320,
            child: FUIEmptyState(
              title: title,
              message: message,
              icon: FUIIcons.schedule,
              actionLabel: '重试',
              onAction: onRefresh,
            ),
          ),
        ),
      ],
    );
  }
}
