import 'package:class_tool/data/model/course_note.dart';
import 'package:class_tool/pages/course_notes/controller.dart';
import 'package:fin_ui/app_button.dart';
import 'package:fin_ui/app_combo_box.dart';
import 'package:fin_ui/app_context.dart';
import 'package:fin_ui/app_dialog.dart';
import 'package:fin_ui/app_empty_state.dart';
import 'package:fin_ui/app_icon_button.dart';
import 'package:fin_ui/app_icons.dart';
import 'package:fin_ui/app_page.dart';
import 'package:fin_ui/app_surface.dart';
import 'package:fin_ui/app_tag.dart';
import 'package:fin_ui/app_text_field.dart';
import 'package:fin_ui/app_toast.dart';
import 'package:fin_ui/app_tokens.dart';
import 'package:fin_ui/fui_page_head.dart';
import 'package:class_tool/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CourseNoteDetailItem {
  const CourseNoteDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class CourseNotesPage extends StatefulWidget {
  const CourseNotesPage({
    super.key,
    this.course,
    this.openEditorOnStart = false,
    this.detailItems = const [],
    this.showCourseInfo = true,
  });

  final CourseNoteCourseDraft? course;
  final bool openEditorOnStart;
  final List<CourseNoteDetailItem> detailItems;
  final bool showCourseInfo;

  @override
  State<CourseNotesPage> createState() => _CourseNotesPageState();
}

class _CourseNotesPageState extends State<CourseNotesPage> {
  late final CourseNotesController controller;
  final String _controllerTag = UniqueKey().toString();
  final Set<int> _selectedNoteIds = <int>{};
  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      CourseNotesController(initialCourse: widget.course),
      tag: _controllerTag,
      permanent: false,
    );
    if (widget.openEditorOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openEditor(context, controller);
      });
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<CourseNotesController>(tag: _controllerTag)) {
      Get.delete<CourseNotesController>(tag: _controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: GetBuilder<CourseNotesController>(
        tag: _controllerTag,
        id: 'course-notes-content',
        builder: (controller) {
          return FUIPage(
            children: [
              _CourseNotesHeader(
                title: course?.courseName ?? '课程任务',
                subtitle: course == null ? '查看课程任务和普通待办' : '记录作业、备注和提醒',
                selectionMode: _selectionMode,
                selectedCount: _selectedNoteIds.length,
                onAdd: controller.canCreate
                    ? () => _openEditor(context, controller)
                    : null,
                onBatchDelete: controller.hasData
                    ? () => _setSelectionMode(!_selectionMode)
                    : null,
                onDeleteSelected: _selectedNoteIds.isEmpty
                    ? null
                    : () => _confirmDeleteSelected(context, controller),
              ),
              const SizedBox(height: FUITokens.gap14),
              if (course != null && widget.showCourseInfo) ...[
                _CourseInfoCard(
                  course: course,
                  detailItems: widget.detailItems,
                ),
                const SizedBox(height: FUITokens.gap14),
              ],
              _FilterRow(controller: controller),
              if (controller.hasData && _selectionMode) ...[
                const SizedBox(height: FUITokens.gap10),
                _BatchActionRow(
                  selectedCount: _selectedNoteIds.length,
                  totalCount: controller.items.length,
                  allSelected:
                      _selectedNoteIds.length == controller.items.length,
                  onClose: () => _setSelectionMode(false),
                  onSelectAll: () => _selectAllVisible(controller),
                  onClear: _clearSelection,
                  onExport: _selectedNoteIds.isEmpty
                      ? null
                      : () => _exportSelectedToCalendar(context, controller),
                  onDelete: _selectedNoteIds.isEmpty
                      ? null
                      : () => _confirmDeleteSelected(context, controller),
                ),
              ],
              const SizedBox(height: FUITokens.gap12),
              if (controller.error.isNotEmpty) ...[
                _InlineError(message: controller.error),
                const SizedBox(height: FUITokens.gap12),
              ],
              if (!controller.hasData)
                FUISurface(
                  child: SizedBox(
                    height: 300,
                    child: FUIEmptyState(
                      icon: FUIIcons.book,
                      title: course == null ? '暂无待办任务' : '暂无课程备注',
                      message: course == null
                          ? '可以新增普通待办，也可以从课程详情添加课程记录。'
                          : '可以添加作业、考试、待办或普通备注。',
                      actionLabel: controller.canCreate ? '新增记录' : null,
                      onAction: controller.canCreate
                          ? () => _openEditor(context, controller)
                          : null,
                    ),
                  ),
                )
              else
                for (final entry in controller.items) ...[
                  _CourseNoteCard(
                    entry: entry,
                    selectionMode: _selectionMode,
                    selected: _selectedNoteIds.contains(entry.note.id),
                    showTodayAction: !entry.isExam,
                    isManualTodayTask: controller.isManualTodayTask(entry),
                    onSelect: () => _toggleSelection(entry.note.id),
                    onToggleDone: (value) async {
                      await controller.setDone(entry, value);
                    },
                    onAddToToday: () async {
                      try {
                        await controller.addToToday(entry);
                        if (!context.mounted) return;
                        FUIToast.success(context, message: '已加入今日任务');
                      } catch (e) {
                        if (!context.mounted) return;
                        FUIToast.error(
                          context,
                          message: e.toString().split('\n').first,
                        );
                      }
                    },
                    onRemoveFromToday: () async {
                      try {
                        await controller.removeFromToday(entry);
                        if (!context.mounted) return;
                        FUIToast.success(context, message: '已移除今日任务');
                      } catch (e) {
                        if (!context.mounted) return;
                        FUIToast.error(
                          context,
                          message: e.toString().split('\n').first,
                        );
                      }
                    },
                    onExport: () async {
                      try {
                        final exported = await controller.exportToCalendar(
                          entry,
                        );
                        if (!context.mounted) return;
                        if (exported) {
                          FUIToast.success(context, message: '已导入系统日历');
                        } else {
                          FUIToast.info(context, message: '已跳过重复日程');
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        FUIToast.error(
                          context,
                          message: e.toString().split('\n').first,
                        );
                      }
                    },
                    onEdit: () =>
                        _openEditor(context, controller, initialEntry: entry),
                    onDelete: () =>
                        _confirmDeleteSingle(context, controller, entry),
                  ),
                  const SizedBox(height: FUITokens.gap10),
                ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    CourseNotesController controller, {
    CourseNoteEntry? initialEntry,
  }) async {
    final course = initialEntry != null
        ? CourseNoteCourseDraft(
            courseKey: initialEntry.course.courseKey,
            courseName: initialEntry.course.courseName,
            teacherName: initialEntry.course.teacherName,
            classroom: initialEntry.course.classroom,
            semester: initialEntry.course.semester,
            rawCourseId: initialEntry.course.rawCourseId,
          )
        : controller.createCourse;
    await showCourseNoteEditorSheet(
      context: context,
      course: course,
      initialEntry: initialEntry,
      onSave: controller.save,
    );
  }

  Future<void> _confirmDeleteSingle(
    BuildContext context,
    CourseNotesController controller,
    CourseNoteEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return FUIDialog(
          title: '删除任务',
          icon: FUIIcons.delete,
          content: Text('确定删除「${entry.note.title}」吗？删除后不会再提醒。'),
          actions: [
            FUIButton(
              label: '取消',
              variant: FUIButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FUIButton(
              label: '删除',
              variant: FUIButtonVariant.danger,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    try {
      await controller.delete(entry);
      if (!context.mounted) return;
      FUIToast.success(context, message: '已删除任务');
    } catch (e) {
      if (!context.mounted) return;
      FUIToast.error(context, message: e.toString().split('\n').first);
    }
  }

  void _setSelectionMode(bool value) {
    setState(() {
      _selectionMode = value;
      _selectedNoteIds.clear();
    });
  }

  void _toggleSelection(int noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
      } else {
        _selectedNoteIds.add(noteId);
      }
    });
  }

  void _selectAllVisible(CourseNotesController controller) {
    setState(() {
      final visibleIds = controller.items.map((entry) => entry.note.id).toSet();
      if (_selectedNoteIds.length == visibleIds.length) {
        _selectedNoteIds.clear();
      } else {
        _selectedNoteIds
          ..clear()
          ..addAll(visibleIds);
      }
    });
  }

  void _clearSelection() {
    setState(_selectedNoteIds.clear);
  }

  Future<void> _confirmDeleteSelected(
    BuildContext context,
    CourseNotesController controller,
  ) async {
    final ids = _selectedNoteIds.toList(growable: false);
    if (ids.isEmpty) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return FUIDialog(
          title: '删除选中任务',
          icon: FUIIcons.delete,
          content: Text('将删除 ${ids.length} 条任务，删除后不会再提醒。'),
          actions: [
            FUIButton(
              label: '取消',
              variant: FUIButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FUIButton(
              label: '删除',
              variant: FUIButtonVariant.danger,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    try {
      await controller.deleteMany(ids);
      if (!context.mounted) return;
      setState(() {
        _selectionMode = false;
        _selectedNoteIds.clear();
      });
      FUIToast.success(context, message: '已删除选中任务');
    } catch (e) {
      if (!context.mounted) return;
      FUIToast.error(context, message: e.toString().split('\n').first);
    }
  }

  Future<void> _exportSelectedToCalendar(
    BuildContext context,
    CourseNotesController controller,
  ) async {
    final ids = _selectedNoteIds.toList(growable: false);
    if (ids.isEmpty) {
      return;
    }
    try {
      final result = await controller.exportManyToCalendar(ids);
      if (!context.mounted) return;
      FUIToast.success(
        context,
        message:
            '已导入 ${result.added}/${result.total} 个日程，跳过 ${result.skipped} 个',
      );
      if (result.failed > 0) {
        FUIToast.warning(context, message: '${result.failed} 个任务导入失败');
      }
    } catch (e) {
      if (!context.mounted) return;
      FUIToast.error(context, message: e.toString().split('\n').first);
    }
  }
}

class _CourseNotesHeader extends StatelessWidget {
  const _CourseNotesHeader({
    required this.title,
    required this.subtitle,
    required this.selectionMode,
    required this.selectedCount,
    required this.onAdd,
    required this.onBatchDelete,
    required this.onDeleteSelected,
  });

  final String title;
  final String subtitle;
  final bool selectionMode;
  final int selectedCount;
  final VoidCallback? onAdd;
  final VoidCallback? onBatchDelete;
  final VoidCallback? onDeleteSelected;

  @override
  Widget build(BuildContext context) {
    return FuiPageHead(
      title: title,
      subtitle: subtitle,
      actions: [
        if (onAdd != null)
          FUIIconButton(
            icon: FUIIcons.add,
            tooltip: '新增记录',
            variant: FUIIconButtonVariant.ghost,
            onPressed: onAdd,
          ),
        if (selectionMode)
          FUIIconButton(
            icon: FUIIcons.delete,
            tooltip: selectedCount == 0 ? '选择后删除' : '删除选中',
            variant: FUIIconButtonVariant.ghost,
            onPressed: onDeleteSelected,
          )
        else if (onBatchDelete != null)
          FUIIconButton(
            icon: FUIIcons.list,
            tooltip: '批量删除',
            variant: FUIIconButtonVariant.ghost,
            onPressed: onBatchDelete,
          ),
      ],
    );
  }
}

class _BatchActionRow extends StatelessWidget {
  const _BatchActionRow({
    required this.selectedCount,
    required this.totalCount,
    required this.allSelected,
    required this.onClose,
    required this.onSelectAll,
    required this.onClear,
    required this.onExport,
    required this.onDelete,
  });

  final int selectedCount;
  final int totalCount;
  final bool allSelected;
  final VoidCallback onClose;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final VoidCallback? onExport;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '已选择 $selectedCount/$totalCount',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          FUIIconButton(
            icon: allSelected ? FUIIcons.close : FUIIcons.checkmark,
            tooltip: allSelected ? '取消全选' : '全选',
            variant: FUIIconButtonVariant.ghost,
            onPressed: onSelectAll,
          ),
          FUIIconButton(
            icon: FUIIcons.list,
            tooltip: '清空选择',
            variant: FUIIconButtonVariant.ghost,
            onPressed: onClear,
          ),
          FUIIconButton(
            icon: FUIIcons.calendarAdd,
            tooltip: '批量导入日历',
            variant: FUIIconButtonVariant.ghost,
            onPressed: onExport,
          ),
          FUIIconButton(
            icon: FUIIcons.delete,
            tooltip: '删除选中',
            variant: FUIIconButtonVariant.ghost,
            onPressed: onDelete,
          ),
          FUIIconButton(
            icon: FUIIcons.close,
            tooltip: '退出批量删除',
            variant: FUIIconButtonVariant.ghost,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _CourseInfoCard extends StatelessWidget {
  const _CourseInfoCard({required this.course, required this.detailItems});

  final CourseNoteCourseDraft course;
  final List<CourseNoteDetailItem> detailItems;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.courseName,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: FUITokens.gap8),
          Wrap(
            spacing: FUITokens.gap8,
            runSpacing: FUITokens.gap8,
            children: [
              if (course.semester.isNotEmpty) FUITag(label: course.semester),
              if (course.teacherName.isNotEmpty)
                FUITag(label: course.teacherName),
              if (course.classroom.isNotEmpty) FUITag(label: course.classroom),
            ],
          ),
          if (detailItems.isNotEmpty) ...[
            const SizedBox(height: FUITokens.gap12),
            Divider(height: 1, color: context.colors.border),
            const SizedBox(height: FUITokens.gap10),
            for (final item in detailItems)
              if (item.value.trim().isNotEmpty) _CourseDetailLine(item: item),
          ],
        ],
      ),
    );
  }
}

class _CourseDetailLine extends StatelessWidget {
  const _CourseDetailLine({required this.item});

  final CourseNoteDetailItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: FUITokens.gap8),
      child: Row(
        children: [
          Icon(item.icon, size: 16, color: colors.primary),
          const SizedBox(width: FUITokens.gap8),
          SizedBox(
            width: 58,
            child: Text(
              item.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatefulWidget {
  const _FilterRow({required this.controller});

  final CourseNotesController controller;

  @override
  State<_FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends State<_FilterRow>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.controller.pendingOnly ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant _FilterRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final desiredIndex = widget.controller.pendingOnly ? 1 : 0;
    if (_tabController.index != desiredIndex) {
      _tabController.index = desiredIndex;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: colors.primary,
      unselectedLabelColor: colors.textSecondary,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      labelStyle: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
      unselectedLabelStyle: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      indicatorColor: colors.primary,
      indicatorWeight: 2,
      dividerColor: colors.border,
      labelPadding: const EdgeInsets.only(right: 24),
      onTap: (index) {
        final pendingOnly = index == 1;
        if (widget.controller.pendingOnly != pendingOnly) {
          widget.controller.togglePendingOnly();
        }
      },
      tabs: const [
        Tab(text: '全部'),
        Tab(text: '待完成'),
      ],
    );
  }
}

class _CourseNoteCard extends StatelessWidget {
  const _CourseNoteCard({
    required this.entry,
    required this.selectionMode,
    required this.selected,
    required this.showTodayAction,
    required this.isManualTodayTask,
    required this.onSelect,
    required this.onToggleDone,
    required this.onAddToToday,
    required this.onRemoveFromToday,
    required this.onExport,
    required this.onEdit,
    required this.onDelete,
  });

  final CourseNoteEntry entry;
  final bool selectionMode;
  final bool selected;
  final bool showTodayAction;
  final bool isManualTodayTask;
  final VoidCallback onSelect;
  final ValueChanged<bool> onToggleDone;
  final VoidCallback onAddToToday;
  final VoidCallback onRemoveFromToday;
  final VoidCallback onExport;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final note = entry.note;
    final dueText = _formatDateTime(note.dueAt);
    final remindText = _formatDateTime(note.remindAt);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: selectionMode ? onSelect : onEdit,
      child: FUISurface(
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (selectionMode)
              Checkbox(
                value: selected,
                visualDensity: VisualDensity.compact,
                onChanged: (_) => onSelect(),
              )
            else
              Checkbox(
                value: note.isDone,
                visualDensity: VisualDensity.compact,
                onChanged: (value) => onToggleDone(value ?? false),
              ),
            const SizedBox(width: FUITokens.gap4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: note.isDone
                                    ? colors.textTertiary
                                    : colors.textPrimary,
                                fontWeight: FontWeight.w800,
                                decoration: note.isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                        ),
                      ),
                      const SizedBox(width: FUITokens.gap8),
                      FUITag(
                        label: entry.type.label,
                        variant: note.isDone
                            ? FUITagVariant.neutral
                            : FUITagVariant.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: FUITokens.gap4),
                  Text(
                    entry.isGeneralTask ? '普通待办' : entry.course.courseName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (note.content.isNotEmpty) ...[
                    const SizedBox(height: FUITokens.gap4),
                    Text(
                      note.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: FUITokens.gap8),
                  Wrap(
                    spacing: FUITokens.gap8,
                    runSpacing: FUITokens.gap8,
                    children: [
                      if (dueText.isNotEmpty)
                        FUITag(
                          label: entry.isOverdue
                              ? '已逾期 $dueText'
                              : '截止 $dueText',
                          variant: entry.isOverdue
                              ? FUITagVariant.danger
                              : FUITagVariant.warning,
                        ),
                      if (remindText.isNotEmpty)
                        FUITag(label: '提醒 $remindText'),
                      if (note.calendarExported) const FUITag(label: '已导入日历'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: FUITokens.gap4),
            if (!selectionMode)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showTodayAction)
                    FUIIconButton(
                      icon: isManualTodayTask ? FUIIcons.close : FUIIcons.today,
                      tooltip: isManualTodayTask ? '移除今日任务' : '加入今日任务',
                      variant: FUIIconButtonVariant.ghost,
                      onPressed: isManualTodayTask
                          ? onRemoveFromToday
                          : onAddToToday,
                    ),
                  FUIIconButton(
                    icon: Icons.edit_outlined,
                    tooltip: '编辑',
                    variant: FUIIconButtonVariant.ghost,
                    onPressed: onEdit,
                  ),
                  FUIIconButton(
                    icon: FUIIcons.calendarAdd,
                    tooltip: '导入日历',
                    variant: FUIIconButtonVariant.ghost,
                    onPressed: onExport,
                  ),
                  FUIIconButton(
                    icon: FUIIcons.delete,
                    tooltip: '删除',
                    variant: FUIIconButtonVariant.ghost,
                    onPressed: onDelete,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCourseNoteEditorSheet({
  required BuildContext context,
  required CourseNoteCourseDraft course,
  CourseNoteEntry? initialEntry,
  required Future<void> Function(CourseNoteDraft draft) onSave,
}) {
  return showAppBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    child: _CourseNoteEditor(
      course: course,
      initialEntry: initialEntry,
      onSave: onSave,
    ),
  );
}

class _CourseNoteEditor extends StatefulWidget {
  const _CourseNoteEditor({
    required this.course,
    this.initialEntry,
    required this.onSave,
  });

  final CourseNoteCourseDraft course;
  final CourseNoteEntry? initialEntry;
  final Future<void> Function(CourseNoteDraft draft) onSave;

  @override
  State<_CourseNoteEditor> createState() => _CourseNoteEditorState();
}

class _CourseNoteEditorState extends State<_CourseNoteEditor> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  CourseNoteType _type = CourseNoteType.homework;
  DateTime? _dueAt;
  DateTime? _remindAt;
  bool _exportCalendar = false;
  bool _saving = false;

  bool get _isEditing => widget.initialEntry != null;
  bool get _isGeneralTask => widget.course.courseKey == generalTaskCourseKey;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialEntry;
    if (initial != null) {
      _titleController.text = initial.note.title;
      _contentController.text = initial.note.content;
      _type = initial.type;
      _dueAt = initial.note.dueAt;
      _remindAt = initial.note.remindAt;
      return;
    }
    if (_isGeneralTask) {
      _type = CourseNoteType.todo;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        Text(
          _isEditing
              ? (_isGeneralTask ? '编辑普通任务' : '编辑课程记录')
              : (_isGeneralTask ? '新增普通任务' : '新增课程记录'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: FUITokens.gap16),
        FUIComboBox<CourseNoteType>(
          label: '类型',
          value: _type,
          items: _isGeneralTask
              ? const [CourseNoteType.todo, CourseNoteType.note]
              : CourseNoteType.values,
          itemLabelBuilder: (item) => item.label,
          onChanged: (value) {
            if (value != null) setState(() => _type = value);
          },
        ),
        const SizedBox(height: FUITokens.gap12),
        FUITextField(
          controller: _titleController,
          label: '标题',
          hintText: '例如 实验报告 / 第三章习题',
          prefixIcon: FUIIcons.book,
        ),
        const SizedBox(height: FUITokens.gap12),
        Text(
          '内容',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FUITokens.gap6),
        TextField(
          controller: _contentController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(hintText: '记录要求、提交方式或补充说明'),
        ),
        const SizedBox(height: FUITokens.gap12),
        _DateActionRow(
          label: '截止时间',
          value: _formatDateTime(_dueAt),
          onPick: () async => _pickDateTime(
            initialValue: _dueAt,
            setter: (value) => _dueAt = value,
          ),
          onClear: _dueAt == null ? null : () => setState(() => _dueAt = null),
        ),
        const SizedBox(height: FUITokens.gap8),
        _DateActionRow(
          label: '提醒时间',
          value: _formatDateTime(_remindAt),
          onPick: () async => _pickDateTime(
            initialValue: _remindAt,
            setter: (value) => _remindAt = value,
          ),
          onClear: _remindAt == null
              ? null
              : () => setState(() => _remindAt = null),
        ),
        const SizedBox(height: FUITokens.gap10),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _exportCalendar,
          onChanged: (value) => setState(() => _exportCalendar = value),
          title: const Text('保存后导入系统日历'),
          subtitle: const Text('需要设置截止时间'),
        ),
        const SizedBox(height: FUITokens.gap16),
        FUIButton(
          label: '保存',
          icon: FUIIcons.save,
          loading: _saving,
          fullWidth: true,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }

  Future<void> _pickDateTime({
    required DateTime? initialValue,
    required ValueChanged<DateTime> setter,
  }) async {
    final now = DateTime.now();
    final baseValue = initialValue ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: baseValue,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(baseValue),
    );
    if (time == null || !mounted) return;
    setState(() {
      setter(DateTime(date.year, date.month, date.day, time.hour, time.minute));
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      FUIToast.warning(context, message: '请填写标题');
      return;
    }
    if (_exportCalendar && _dueAt == null) {
      FUIToast.warning(context, message: '导入日历需要先设置截止时间');
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(
        CourseNoteDraft(
          id: widget.initialEntry?.note.id,
          course: widget.course,
          type: _type,
          title: title,
          content: _contentController.text,
          dueAt: _dueAt,
          remindAt: _remindAt,
          linkedClassDate: widget.initialEntry?.note.linkedClassDate,
          exportCalendar: _exportCalendar,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      FUIToast.success(context, message: _isGeneralTask ? '已保存任务' : '已保存课程记录');
    } catch (e) {
      if (!mounted) return;
      FUIToast.error(context, message: e.toString().split('\n').first);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _DateActionRow extends StatelessWidget {
  const _DateActionRow({
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final String label;
  final String value;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value.isEmpty ? label : '$label: $value',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          FUIButton(
            label: '选择',
            small: true,
            variant: FUIButtonVariant.secondary,
            onPressed: onPick,
          ),
          if (onClear != null) ...[
            const SizedBox(width: FUITokens.gap8),
            FUIIconButton(
              icon: FUIIcons.close,
              tooltip: '清除',
              variant: FUIIconButtonVariant.ghost,
              onPressed: onClear,
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.all(12),
      backgroundColor: context.colors.dangerSoft,
      borderColor: context.colors.danger.withValues(alpha: 0.24),
      child: Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: context.colors.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime? value) {
  if (value == null) return '';
  final now = DateTime.now();
  final date = value.year == now.year
      ? '${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'
      : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  return '$date ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
