/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:class_tool/data/model/course_note.dart';
import 'package:class_tool/data/model/exam.dart';
import 'package:class_tool/data/repo/course_note_repo.dart';
import 'package:class_tool/data/services/calendar_export_service.dart';
import 'package:class_tool/pages/exams/controller.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:fui/app_button.dart';
import 'package:fui/app_combo_box.dart';
import 'package:fui/app_context.dart';
import 'package:fui/app_empty_state.dart';
import 'package:fui/app_icon_button.dart';
import 'package:fui/app_icons.dart';
import 'package:fui/app_page.dart';
import 'package:fui/app_surface.dart';
import 'package:fui/app_tag.dart';
import 'package:fui/app_toast.dart';
import 'package:fui/app_tokens.dart';
import 'package:fui/fui_page_head.dart';
import 'package:class_tool/widgets/app_bottom_sheet.dart';
import 'package:class_tool/widgets/simple_easy_refresher.dart';
import 'package:class_tool/widgets/skeleton_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  late final ExamsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ExamsController(), permanent: false);
  }

  @override
  void dispose() {
    if (Get.isRegistered<ExamsController>()) {
      Get.delete<ExamsController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: GetBuilder<ExamsController>(
        id: 'exam-content',
        builder: (controller) {
          final canInteract =
              !controller.isLoading && !controller.isLoadingMore;

          if (controller.isLoading && !controller.hasData) {
            return const _ExamSkeletonView();
          }

          if (controller.error.isNotEmpty && !controller.hasData) {
            return _FeedbackState(
              title: '考试信息加载失败',
              message: controller.error,
              onFilter: canInteract ? () => _openFilterSheet(context) : null,
              onRefresh: canInteract ? controller.refreshExams : null,
            );
          }

          if (!controller.canSearch) {
            return _FeedbackState(
              title: '请选择筛选条件',
              message: '选择学期和考试批次后刷新',
              onFilter: canInteract ? () => _openFilterSheet(context) : null,
              onRefresh: canInteract ? controller.refreshExams : null,
            );
          }

          if (!controller.hasData) {
            return _FeedbackState(
              title: '暂无考试安排',
              message: '当前筛选条件下没有考试记录',
              onFilter: canInteract ? () => _openFilterSheet(context) : null,
              onRefresh: canInteract ? controller.refreshExams : null,
            );
          }

          return SimpleEasyRefresher(
            easyRefreshController: controller.easyRefreshController,
            onRefresh: controller.refreshExams,
            onLoad: controller.loadMoreExams,
            autoRefreshOnStart: false,
            refreshEnabled: canInteract,
            loadEnabled: controller.hasMore && canInteract,
            childBuilder: (context, physics) => FUIPage(
              physics: canInteract
                  ? physics
                  : const NeverScrollableScrollPhysics(),
              children: [
                _ExamHeader(
                  onFilter: canInteract
                      ? () => _openFilterSheet(context)
                      : null,
                  onRefresh: canInteract ? controller.refreshExams : null,
                ),
                const SizedBox(height: FUITokens.gap16),
                _ExamSummary(
                  total: controller.total,
                  page: controller.page,
                  totalPages: controller.totalPages,
                  selectedSemester: controller.selectedSemester,
                  selectedBatch: _selectedBatchLabel(controller),
                ),
                const SizedBox(height: FUITokens.gap16),
                _ListHeader(total: controller.total),
                const SizedBox(height: FUITokens.gap8),
                for (final exam in controller.exams) ...[
                  _ExamCard(exam: exam),
                  const SizedBox(height: FUITokens.gap12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _selectedBatchLabel(ExamsController controller) {
    if (controller.selectedPcid.isEmpty) {
      return '全部批次';
    }
    final batch = controller.batches.firstWhereOrNull(
      (item) => item.pcid == controller.selectedPcid,
    );
    return batch?.label ?? controller.selectedPcid;
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    if (controller.isLoading || controller.isLoadingMore) return;
    await controller.ensureBatches();

    if (!context.mounted) return;
    final result = await showAppBottomSheet<_ExamFilterResult>(
      context: context,
      isScrollControlled: true,
      child: const _ExamFilterSheet(),
    );

    if (result != null) {
      if (result.semester != controller.selectedSemester) {
        await controller.changeSemester(result.semester);
      }
      if (result.pcid != controller.selectedPcid) {
        await controller.changeBatch(result.pcid);
      }
    }
  }
}

class _ExamHeader extends StatelessWidget {
  const _ExamHeader({required this.onFilter, required this.onRefresh});

  final VoidCallback? onFilter;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return FuiPageHead(
      title: '考试安排',
      subtitle: '查看考试时间、地点与座位信息',
      actions: [
        FUIIconButton(
          icon: FUIIcons.filter,
          tooltip: '筛选',
          variant: FUIIconButtonVariant.ghost,
          onPressed: onFilter,
        ),
        const SizedBox(width: FUITokens.gap8),
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

class _ExamSummary extends StatelessWidget {
  const _ExamSummary({
    required this.total,
    required this.page,
    required this.totalPages,
    required this.selectedSemester,
    required this.selectedBatch,
  });

  final int total;
  final int page;
  final int totalPages;
  final String selectedSemester;
  final String selectedBatch;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: FUIIcons.exam),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: Text(
                  '考试概览',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FUITag(label: '$total 场考试', variant: FUITagVariant.primary),
            ],
          ),
          const SizedBox(height: FUITokens.gap14),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(label: '学期', value: selectedSemester),
              ),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: _SummaryMetric(label: '批次', value: selectedBatch),
              ),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: _SummaryMetric(
                  label: '分页',
                  value: '第 $page/$totalPages 页',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

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
            value.isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: FUITokens.gap4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Text(
            '考试列表',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          '共 $total 场',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam});

  final ExamItem exam;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBox(icon: FUIIcons.exam),
              const SizedBox(width: FUITokens.gap12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.courseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: FUITokens.gap6),
                    Wrap(
                      spacing: FUITokens.gap8,
                      runSpacing: FUITokens.gap8,
                      children: [
                        if (exam.examBatchName.isNotEmpty)
                          FUITag(label: exam.examBatchName),
                        if (exam.examTypeLabel.isNotEmpty)
                          FUITag(
                            label: exam.examTypeLabel,
                            variant: FUITagVariant.primary,
                          ),
                        FUITag(
                          label: exam.makeupCount == 0
                              ? '非补考'
                              : '补考 ${exam.makeupCount} 次',
                          variant: exam.makeupCount == 0
                              ? FUITagVariant.neutral
                              : FUITagVariant.warning,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: FUITokens.gap10),
              _SeatBadge(seatNumber: exam.seatNumber),
            ],
          ),
          const SizedBox(height: FUITokens.gap14),
          _MetaRow(
            icon: FUIIcons.schedule,
            label: '时间',
            value: _examTimeText(exam),
          ),
          const SizedBox(height: FUITokens.gap8),
          _MetaRow(
            icon: FUIIcons.location,
            label: '地点',
            value: exam.location.isEmpty ? '地点待定' : exam.location,
          ),
          if (exam.className.isNotEmpty) ...[
            const SizedBox(height: FUITokens.gap8),
            _MetaRow(
              icon: FUIIcons.classroom,
              label: '班级',
              value: exam.className,
            ),
          ],
          const SizedBox(height: FUITokens.gap12),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final settingsController = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : null;
    if (settingsController == null) {
      return _buildCalendarButton(context);
    }

    return Obx(() {
      if (!settingsController.todoFeatureEnabled.value) {
        return _buildCalendarButton(context);
      }
      return Row(
        children: [
          Expanded(
            child: FUIButton(
              label: '加入待办',
              icon: FUIIcons.add,
              small: true,
              fullWidth: true,
              onPressed: () => _addToTodo(context),
            ),
          ),
          const SizedBox(width: FUITokens.gap8),
          Expanded(child: _buildCalendarButton(context)),
        ],
      );
    });
  }

  Widget _buildCalendarButton(BuildContext context) {
    return FUIButton(
      label: '加入日历',
      icon: FUIIcons.calendarAdd,
      small: true,
      variant: FUIButtonVariant.secondary,
      fullWidth: true,
      onPressed: () => _addToCalendar(context),
    );
  }

  Future<void> _addToTodo(BuildContext context) async {
    if (!Get.isRegistered<CourseNoteRepo>()) {
      FUIToast.error(context, message: '待办服务未初始化');
      return;
    }

    final examAt = _parseExamDateTime(exam);
    final courseName = exam.courseName.trim().isEmpty
        ? '考试安排'
        : exam.courseName.trim();
    try {
      await Get.find<CourseNoteRepo>().save(
        CourseNoteDraft(
          course: CourseNoteRepo.courseDraftFromParts(
            semester: '',
            courseName: courseName,
            classroom: exam.location,
            rawCourseId: exam.id,
          ),
          type: CourseNoteType.exam,
          title: courseName == '考试安排' ? courseName : '$courseName考试',
          content: _examTodoContent(exam),
          dueAt: examAt,
          remindAt: _defaultExamRemindAt(examAt),
        ),
      );
      if (!context.mounted) return;
      FUIToast.success(context, message: '已添加到待办任务');
    } catch (e) {
      if (!context.mounted) return;
      FUIToast.error(context, message: e.toString().split('\n').first);
    }
  }

  Future<void> _addToCalendar(BuildContext context) async {
    final examAt = _parseExamDateTime(exam);
    if (examAt == null) {
      FUIToast.warning(context, message: '考试时间不完整，无法导入日历');
      return;
    }
    try {
      final added = await CalendarExportService.addEventsOneByOne([
        Event(
          title: exam.courseName.isEmpty ? '考试安排' : '${exam.courseName}考试',
          description: _examCalendarDescription(exam),
          location: exam.location,
          startDate: examAt,
          endDate: examAt.add(const Duration(hours: 2)),
          allDay: false,
        ),
      ]);
      if (!context.mounted) return;
      FUIToast.success(context, message: added > 0 ? '已导入系统日历' : '日历中已存在');
    } catch (e) {
      if (!context.mounted) return;
      FUIToast.error(context, message: e.toString().split('\n').first);
    }
  }

  DateTime? _parseExamDateTime(ExamItem exam) {
    final dateMatch = RegExp(
      r'(\d{4})\D{0,2}(\d{1,2})\D{0,2}(\d{1,2})',
    ).firstMatch(exam.examDate);
    final timeMatch = RegExp(r'(\d{1,2}):(\d{1,2})').firstMatch(
      exam.startTime.isNotEmpty ? exam.startTime : exam.examTimeRange,
    );
    if (dateMatch == null || timeMatch == null) {
      return null;
    }
    final year = int.tryParse(dateMatch.group(1) ?? '');
    final month = int.tryParse(dateMatch.group(2) ?? '');
    final day = int.tryParse(dateMatch.group(3) ?? '');
    final hour = int.tryParse(timeMatch.group(1) ?? '');
    final minute = int.tryParse(timeMatch.group(2) ?? '');
    if (year == null ||
        month == null ||
        day == null ||
        hour == null ||
        minute == null) {
      return null;
    }
    return DateTime(year, month, day, hour, minute);
  }

  DateTime? _defaultExamRemindAt(DateTime? examAt) {
    if (examAt == null) {
      return null;
    }
    final remindAt = examAt.subtract(const Duration(days: 1));
    return remindAt.isAfter(DateTime.now()) ? remindAt : null;
  }

  String _examCalendarDescription(ExamItem exam) {
    return [
      if (exam.examBatchName.isNotEmpty) '批次: ${exam.examBatchName}',
      '时间: ${_examTimeText(exam)}',
      if (exam.location.isNotEmpty) '地点: ${exam.location}',
      if (exam.seatNumber.isNotEmpty) '座位号: ${exam.seatNumber}',
      if (exam.className.isNotEmpty) '班级: ${exam.className}',
      '来源: GXNU Class Tool',
      'class_tool_exam_id=${exam.id}',
    ].join('\n');
  }

  String _examTodoContent(ExamItem exam) {
    return [
      if (exam.examBatchName.isNotEmpty) '批次: ${exam.examBatchName}',
      if (exam.examTypeLabel.isNotEmpty) '类型: ${exam.examTypeLabel}',
      '时间: ${_examTimeText(exam)}',
      if (exam.location.isNotEmpty) '地点: ${exam.location}',
      if (exam.seatNumber.isNotEmpty) '座位号: ${exam.seatNumber}',
      if (exam.className.isNotEmpty) '班级: ${exam.className}',
      '来源: GXNU Class Tool',
    ].join('\n');
  }

  String _examTimeText(ExamItem exam) {
    final parts = [
      exam.examDate,
      exam.startTime,
      exam.examTimeRange,
    ].where((part) => part.isNotEmpty).toList(growable: false);
    return parts.isEmpty ? '时间待定' : parts.join(' ');
  }
}

class _SeatBadge extends StatelessWidget {
  const _SeatBadge({required this.seatNumber});

  final String seatNumber;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      constraints: const BoxConstraints(minWidth: 58),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            seatNumber.isEmpty ? '-' : seatNumber,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '座位',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.primary.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Icon(icon, size: FUITokens.iconSm, color: colors.textTertiary),
        const SizedBox(width: FUITokens.gap8),
        SizedBox(
          width: 38,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: FUITokens.gap8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
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

class _ExamFilterResult {
  const _ExamFilterResult({required this.semester, required this.pcid});

  final String semester;
  final String pcid;
}

class _ExamBatchChoice {
  const _ExamBatchChoice({required this.value, required this.label});

  final String value;
  final String label;
}

class _ExamFilterSheet extends StatefulWidget {
  const _ExamFilterSheet();

  @override
  State<_ExamFilterSheet> createState() => _ExamFilterSheetState();
}

class _ExamFilterSheetState extends State<_ExamFilterSheet> {
  late String semester;
  late String pcid;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<ExamsController>();
    semester = controller.selectedSemester;
    pcid = controller.selectedPcid;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExamsController>();
    final semesters = controller.semesters;
    final batchChoices = [
      const _ExamBatchChoice(value: '', label: '全部批次'),
      ...controller.batches.map(
        (batch) => _ExamBatchChoice(value: batch.pcid, label: batch.label),
      ),
    ];
    final selectedSemester = semesters.firstWhereOrNull(
      (item) => item.value == semester,
    );
    final selectedBatch = batchChoices.firstWhereOrNull(
      (item) => item.value == pcid,
    );

    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        initialChildSize: 0.48,
        minChildSize: 0.32,
        maxChildSize: 0.72,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              Row(
                children: [
                  _IconBox(icon: FUIIcons.filter),
                  const SizedBox(width: FUITokens.gap10),
                  Expanded(
                    child: Text(
                      '筛选条件',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FUITokens.gap16),
              FUISurface(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    FUIComboBox<ExamSemesterOption>(
                      label: '学年学期',
                      value: selectedSemester,
                      items: semesters,
                      itemLabelBuilder: (item) => item.label,
                      onChanged: (item) {
                        if (item == null) return;
                        setState(() {
                          semester = item.value;
                          pcid = '';
                        });
                      },
                    ),
                    const SizedBox(height: FUITokens.gap14),
                    FUIComboBox<_ExamBatchChoice>(
                      label: '考试批次',
                      value: selectedBatch,
                      items: batchChoices,
                      itemLabelBuilder: (item) => item.label,
                      onChanged: (item) {
                        if (item == null) return;
                        setState(() => pcid = item.value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FUITokens.gap14),
              FUIButton(
                label: '应用筛选',
                icon: FUIIcons.check,
                fullWidth: true,
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pop(_ExamFilterResult(semester: semester, pcid: pcid));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExamSkeletonView extends StatelessWidget {
  const _ExamSkeletonView();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => FUIPage(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _ExamHeader(onFilter: null, onRefresh: null),
          const SizedBox(height: FUITokens.gap16),
          FUISurface(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: palette.block(radius: FUITokens.radiusSm),
                    ),
                    const SizedBox(width: FUITokens.gap10),
                    Expanded(
                      child: SkeletonBar(
                        decoration: palette.line(radius: 8),
                        widthFactor: 0.44,
                        height: 18,
                      ),
                    ),
                    Container(
                      width: 76,
                      height: 24,
                      decoration: palette.block(radius: FUITokens.radiusFull),
                    ),
                  ],
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
          const SizedBox(height: FUITokens.gap12),
          for (int i = 0; i < 5; i++) ...[
            _SkeletonExamCard(palette: palette),
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
            widthFactor: 0.58,
            height: 15,
          ),
          const SizedBox(height: FUITokens.gap8),
          SkeletonBar(
            decoration: palette.line(radius: 8),
            widthFactor: 0.42,
            height: 12,
          ),
        ],
      ),
    );
  }
}

class _SkeletonExamCard extends StatelessWidget {
  const _SkeletonExamCard({required this.palette});

  final SkeletonPalette palette;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: palette.block(radius: FUITokens.radiusSm),
          ),
          const SizedBox(width: FUITokens.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBar(
                  decoration: palette.line(radius: 8),
                  widthFactor: 0.82,
                  height: 17,
                ),
                const SizedBox(height: FUITokens.gap8),
                SkeletonBar(
                  decoration: palette.line(radius: 8),
                  widthFactor: 0.5,
                  height: 12,
                ),
                const SizedBox(height: FUITokens.gap14),
                SkeletonBar(
                  decoration: palette.line(radius: 8),
                  widthFactor: 0.72,
                  height: 12,
                ),
              ],
            ),
          ),
          const SizedBox(width: FUITokens.gap10),
          Container(
            width: 58,
            height: 52,
            decoration: palette.block(radius: FUITokens.radiusMd),
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
    required this.onFilter,
    required this.onRefresh,
  });

  final String title;
  final String message;
  final VoidCallback? onFilter;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return FUIPage(
      children: [
        _ExamHeader(onFilter: onFilter, onRefresh: onRefresh),
        const SizedBox(height: FUITokens.gap16),
        FUISurface(
          child: SizedBox(
            height: 320,
            child: FUIEmptyState(
              title: title,
              message: message,
              icon: FUIIcons.exam,
              actionLabel: '重试',
              onAction: onRefresh,
            ),
          ),
        ),
      ],
    );
  }
}
