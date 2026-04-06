import 'package:class_tool/pages/home/controller.dart';
import 'package:class_tool/widgets/skeleton_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (controller.showSkeleton) {
        return _HomeSkeletonView(colorScheme: colorScheme);
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '开始今天的课程安排',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${controller.semesterText.value} · ${controller.currentWeekText.value}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.82,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: '今日课程',
                  value: '${controller.todayCourseCount.value}门',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: '今日',
                  value: _compactTodayLabel(controller.todayWeekdayText.value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('今日安排', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Builder(
                builder: (context) {
                  final items = controller.todayCourseSummaries;
                  if (items.isEmpty) {
                    return Text(
                      '今天没有课程安排',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  }
                  return Column(
                    children: items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TodayCourseItem(summary: item),
                          ),
                        )
                        .toList(growable: false),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  String _compactTodayLabel(String value) {
    final compact = value.split('·').first.trim();
    return compact.isEmpty ? '今天' : compact;
  }
}

class _HomeSkeletonView extends StatelessWidget {
  const _HomeSkeletonView({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBar(
                    decoration: palette.line(radius: 10),
                    widthFactor: 0.52,
                    height: 20,
                  ),
                  const SizedBox(height: 10),
                  SkeletonBar(
                    decoration: palette.line(radius: 10),
                    widthFactor: 0.72,
                    height: 14,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 104,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SkeletonBar(
                            decoration: palette.line(radius: 8),
                            widthFactor: 0.38,
                            height: 12,
                          ),
                          const SizedBox(height: 12),
                          SkeletonBar(
                            decoration: palette.line(radius: 10),
                            widthFactor: 0.52,
                            height: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 104,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SkeletonBar(
                            decoration: palette.line(radius: 8),
                            widthFactor: 0.32,
                            height: 12,
                          ),
                          const SizedBox(height: 12),
                          SkeletonBar(
                            decoration: palette.line(radius: 10),
                            widthFactor: 0.44,
                            height: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 0.24,
            height: 16,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SkeletonCourseItem(palette: palette),
                  SizedBox(height: 10),
                  _SkeletonCourseItem(palette: palette),
                  SizedBox(height: 10),
                  _SkeletonCourseItem(palette: palette),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCourseItem extends StatelessWidget {
  const _SkeletonCourseItem({required this.palette});

  final SkeletonPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 30,
            decoration: palette.block(radius: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBar(
                  decoration: palette.line(radius: 8),
                  widthFactor: 0.72,
                  height: 14,
                ),
                const SizedBox(height: 8),
                SkeletonBar(
                  decoration: palette.line(radius: 8),
                  widthFactor: 0.46,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 104,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayCourseItem extends StatelessWidget {
  const _TodayCourseItem({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final parts = summary.split(RegExp(r'\s{2,}'));
    final timeText = parts.isNotEmpty ? parts[0].trim() : '--:--';
    final titleText = parts.length > 1 ? parts[1].trim() : '课程待定';
    final roomText = parts.length > 2 ? parts[2].trim() : '教室待定';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              timeText,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titleText, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  roomText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
