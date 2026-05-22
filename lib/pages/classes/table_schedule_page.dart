import 'package:class_tool/pages/classes/controller.dart';
import 'package:class_tool/pages/classes/widgets/schedule_picker_sheet.dart';
import 'package:class_tool/pages/classes/widgets/schedule_table.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_icon_button.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableSchedulePage extends StatelessWidget {
  const TableSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _TableScheduleHeader(),
            Expanded(
              child: GetBuilder<ClassesController>(
                id: 'schedule-table',
                builder: (controller) {
                  return ScheduleTableContent(
                    controller: controller,
                    physics: const AlwaysScrollableScrollPhysics(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableScheduleHeader extends StatelessWidget {
  const _TableScheduleHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
        child: Row(
          children: [
            AppIconButton(
              icon: AppIcons.chevronLeft,
              tooltip: '返回',
              variant: AppIconButtonVariant.outline,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: AppTokens.gap4),
            Expanded(
              child: GetBuilder<ClassesController>(
                id: 'classes-header',
                builder: (controller) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '表格课表',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: AppTokens.gap2),
                      Text(
                        '${controller.selectedSemester} · ${controller.selectedWeek}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                      ),
                    ],
                  );
                },
              ),
            ),
            GetBuilder<ClassesController>(
              id: 'classes-header',
              builder: (controller) {
                return AppIconButton(
                  icon: AppIcons.calendar,
                  tooltip: '选择周次',
                  variant: AppIconButtonVariant.ghost,
                  onPressed: controller.isLoading
                      ? null
                      : () => showScheduleSelectionSheet(
                            context: context,
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
