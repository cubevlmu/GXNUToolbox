import 'dart:async';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:class_tool/data/services/calendar_export_service.dart';
import 'package:class_tool/data/services/schedule_export_service.dart';
import 'package:class_tool/pages/classes/controller.dart';
import 'package:class_tool/pages/classes/widgets/schedule_picker_sheet.dart';
import 'package:class_tool/pages/classes/widgets/schedule_table.dart';
import 'package:fui/app_context.dart';
import 'package:fui/app_icon_button.dart';
import 'package:fui/app_icons.dart';
import 'package:fui/app_toast.dart';
import 'package:fui/fui_page_head.dart';
import 'package:class_tool/utils/shared_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableSchedulePage extends StatefulWidget {
  const TableSchedulePage({super.key});

  @override
  State<TableSchedulePage> createState() => _TableSchedulePageState();
}

class _TableSchedulePageState extends State<TableSchedulePage> {
  final GlobalKey _tableBoundaryKey = GlobalKey();
  bool _isSaving = false;
  bool _isImportingCalendar = false;

  Future<void> _saveImage() async {
    if (_isSaving) {
      return;
    }
    final controller = Get.find<ClassesController>();
    setState(() => _isSaving = true);
    try {
      final result = await ScheduleExportService.saveScheduleTableImage(
        repaintBoundaryKey: _tableBoundaryKey,
        semester: controller.selectedSemester,
        weekText: controller.selectedWeek,
      );
      if (!mounted) return;
      await SharedDialog.showConfirmDialog(
        context,
        title: '课表图片已保存',
        content: result.savedToGallery ? '已保存到系统图库' : result.displayPath,
        confirmText: '知道了',
        cancelText: '',
        variant: SharedDialogVariant.success,
      );
    } catch (e) {
      if (!mounted) return;
      FUIToast.error(context, message: e.toString().split('\n').first);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _importCalendarEvents() async {
    if (_isImportingCalendar) {
      return;
    }

    final controller = Get.find<ClassesController>();
    late final List<Event> events;
    try {
      events = CalendarExportService.buildEventsFromWeekSchedule(
        semester: controller.selectedSemester,
        selectedWeek: controller.selectedWeekNumber,
        weekMeta: controller.currentWeekMeta,
        courseBlocks: controller.visibleCourseBlocks,
        periodSettings: controller.effectivePeriodSettings,
      );
    } catch (e) {
      if (!mounted) return;
      FUIToast.error(context, message: e.toString().split('\n').first);
      return;
    }

    if (events.isEmpty) {
      FUIToast.info(context, message: '本周没有可导入的课程');
      return;
    }

    final confirmed = await SharedDialog.showConfirmDialog(
      context,
      title: '导入日历',
      content: '将本周 ${events.length} 门课一次性写入系统日历。已导入过的日程会自动跳过。',
      confirmText: '开始导入',
      cancelText: '取消',
      variant: SharedDialogVariant.info,
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _isImportingCalendar = true);
    try {
      final added = await CalendarExportService.addEventsOneByOne(events);
      if (!mounted) return;
      FUIToast.success(context, message: '已导入 $added/${events.length} 个日程');
    } catch (e) {
      if (!mounted) return;
      FUIToast.error(context, message: e.toString().split('\n').first);
    } finally {
      if (mounted) {
        setState(() => _isImportingCalendar = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TableScheduleHeader(
              isSaving: _isSaving,
              isImportingCalendar: _isImportingCalendar,
              onSaveImage: _saveImage,
              onImportCalendar: _importCalendarEvents,
            ),
            Expanded(
              child: GetBuilder<ClassesController>(
                id: 'schedule-table',
                builder: (controller) {
                  return ScheduleTableContent(
                    controller: controller,
                    physics: const AlwaysScrollableScrollPhysics(),
                    repaintBoundaryKey: _tableBoundaryKey,
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
  const _TableScheduleHeader({
    required this.isSaving,
    required this.isImportingCalendar,
    required this.onSaveImage,
    required this.onImportCalendar,
  });

  final bool isSaving;
  final bool isImportingCalendar;
  final Future<void> Function() onSaveImage;
  final Future<void> Function() onImportCalendar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final supportsCalendarImport =
        Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
        child: GetBuilder<ClassesController>(
          id: 'classes-header',
          builder: (controller) {
            return FuiPageHead(
              title: '表格课表',
              subtitle:
                  '${controller.selectedSemester} · ${controller.selectedWeek}',
              actions: [
                if (supportsCalendarImport)
                  FUIIconButton(
                    icon: FUIIcons.calendarAdd,
                    tooltip: isImportingCalendar ? '正在导入' : '导入日历',
                    variant: FUIIconButtonVariant.ghost,
                    onPressed: controller.isLoading || isImportingCalendar
                        ? null
                        : () => unawaited(onImportCalendar()),
                  ),
                FUIIconButton(
                  icon: FUIIcons.save,
                  tooltip: isSaving ? '正在保存' : '保存为图片',
                  variant: FUIIconButtonVariant.ghost,
                  onPressed: controller.isLoading || isSaving
                      ? null
                      : () => unawaited(onSaveImage()),
                ),
                FUIIconButton(
                  icon: FUIIcons.calendar,
                  tooltip: '选择周次',
                  variant: FUIIconButtonVariant.ghost,
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
