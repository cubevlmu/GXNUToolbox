import 'package:class_tool/pages/classes/controller.dart';
import 'package:class_tool/pages/classes/widgets/schedule_picker_sheet.dart';
import 'package:class_tool/pages/classes/widgets/schedule_table.dart';
import 'package:class_tool/widgets/simple_easy_refresher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClassesPage extends StatelessWidget {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClassesController>();

    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: GetBuilder<ClassesController>(
              id: 'classes-header',
              builder: (controller) => _ClassesToolbar(controller: controller),
            ),
          ),
          Expanded(
            child: SimpleEasyRefresher(
              easyRefreshController: controller.easyRefreshController,
              autoRefreshOnStart: false,
              refreshEnabled: false,
              loadEnabled: false,
              childBuilder: (context, physics) => ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  scrollbars: false,
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.unknown,
                  },
                ),
                child: GetBuilder<ClassesController>(
                  id: 'schedule-table',
                  builder: (controller) {
                    if (controller.scheduleError.isNotEmpty &&
                        !controller.hasScheduleData) {
                      return _ClassesFeedbackState(
                        title: '课表加载失败',
                        subtitle: controller.scheduleError,
                      );
                    }

                    if (controller.isLoading && !controller.hasScheduleData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Stack(
                      children: [
                        ScheduleTableContent(
                          controller: controller,
                          physics: physics,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassesToolbar extends StatelessWidget {
  const _ClassesToolbar({required this.controller});

  final ClassesController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = !controller.isLoading;
    final containerColor = enabled
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHigh;
    final foregroundColor = enabled
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Card(
      color: containerColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _ScheduleSelector(
              flex: 5,
              label: '学期',
              value: _compactSemester(controller.selectedSemester),
              enabled: enabled,
              foregroundColor: foregroundColor,
              selectedValue: '${controller.selectedSemester}学期',
              items: controller.semesters
                  .map((item) => SelectionSheetItem(label: '${item.label}学期'))
                  .toList(growable: false),
              onSelected: (value) {
                controller.changeSemester(value.replaceFirst('学期', ''));
              },
            ),
            Container(
              width: 1,
              height: 18,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: foregroundColor.withValues(alpha: 0.18),
            ),
            _ScheduleSelector(
              flex: 3,
              label: '周目',
              value: _compactWeek(controller.selectedWeek),
              enabled: enabled,
              foregroundColor: foregroundColor,
              selectedValue: controller.selectedWeek,
              items: controller.weeks
                  .map(
                    (item) => SelectionSheetItem(
                      label: item.label,
                      subtitle: item.extra,
                    ),
                  )
                  .toList(growable: false),
              onSelected: controller.changeWeek,
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton.filledTonal(
                onPressed: enabled ? controller.refreshSchedule : null,
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: enabled
                      ? colorScheme.surface.withValues(alpha: 0.42)
                      : colorScheme.surfaceContainerHighest,
                  disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: enabled
                      ? foregroundColor
                      : colorScheme.onSurfaceVariant,
                  disabledForegroundColor: colorScheme.onSurfaceVariant,
                ),
                icon: controller.isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 16),
                tooltip: '刷新课表',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleSelector extends StatelessWidget {
  const _ScheduleSelector({
    required this.flex,
    required this.label,
    required this.value,
    required this.enabled,
    required this.foregroundColor,
    required this.selectedValue,
    required this.items,
    required this.onSelected,
  });

  final int flex;
  final String label;
  final String value;
  final bool enabled;
  final Color foregroundColor;
  final String selectedValue;
  final List<SelectionSheetItem> items;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: _SelectorRow(
        label: label,
        value: value,
        enabled: enabled,
        foregroundColor: foregroundColor,
        onTap: enabled
            ? () => showScheduleSelectionSheet(
                context: context,
                selectedValue: selectedValue,
                items: items,
                onSelected: onSelected,
              )
            : null,
      ),
    );
  }
}

class _SelectorRow extends StatelessWidget {
  const _SelectorRow({
    required this.label,
    required this.value,
    required this.enabled,
    required this.foregroundColor,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool enabled;
  final Color foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              Text(
                '$label: ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: Text(
                  value.isEmpty ? '未选择' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: foregroundColor),
                ),
              ),
              const SizedBox(width: 1),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: foregroundColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassesFeedbackState extends StatelessWidget {
  const _ClassesFeedbackState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          '$title\n$subtitle',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

String _compactWeek(String raw) {
  final match = RegExp(r'\d+').firstMatch(raw);
  return match?.group(0) ?? raw;
}

String _compactSemester(String raw) {
  if (raw.isEmpty) {
    return raw;
  }

  final rangeMatch = RegExp(r'(\d{4})[-到](\d{4})').firstMatch(raw);
  final termMatch = RegExp(r'第?\s*(\d+)\s*学期').firstMatch(raw);
  final trailingTermMatch = RegExp(r'[-_](\d+)$').firstMatch(raw);

  if (rangeMatch != null) {
    final startYear = rangeMatch.group(1)!;
    final endYear = rangeMatch.group(2)!;
    final term =
        termMatch?.group(1) ??
        trailingTermMatch?.group(1) ??
        RegExp(r'(\d)$').firstMatch(raw)?.group(1);
    if (term != null) {
      return '$startYear-$endYear $term';
    }
    return '$startYear-$endYear';
  }

  return raw.replaceAll('学期', '').trim();
}
