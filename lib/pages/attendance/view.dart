import 'package:class_tool/data/model/attendance.dart';
import 'package:class_tool/pages/attendance/controller.dart';
import 'package:fui/app_button.dart';
import 'package:fui/app_combo_box.dart';
import 'package:fui/app_context.dart';
import 'package:fui/app_empty_state.dart';
import 'package:fui/app_icon_button.dart';
import 'package:fui/app_icons.dart';
import 'package:fui/app_page.dart';
import 'package:fui/app_section.dart';
import 'package:fui/app_surface.dart';
import 'package:fui/app_tag.dart';
import 'package:fui/app_text_field.dart';
import 'package:fui/app_toast.dart';
import 'package:fui/app_tokens.dart';
import 'package:fui/fui_navigation.dart';
import 'package:fui/fui_page_head.dart';
import 'package:class_tool/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage>
    with SingleTickerProviderStateMixin {
  late final AttendanceController controller;
  late final TabController _tabController;
  final String _controllerTag = UniqueKey().toString();
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      AttendanceController(),
      tag: _controllerTag,
      permanent: false,
    );
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabIndex != _tabController.index) {
        setState(() => _tabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (Get.isRegistered<AttendanceController>(tag: _controllerTag)) {
      Get.delete<AttendanceController>(tag: _controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: GetBuilder<AttendanceController>(
        tag: _controllerTag,
        id: 'attendance-content',
        builder: (controller) {
          return FUIPage(
            children: [
              _AttendanceHeader(
                onImport: () => _openGroupEditor(context, controller),
                onCreateSession: controller.groups.isEmpty
                    ? null
                    : () => _openSessionEditor(context, controller),
              ),
              const SizedBox(height: FUITokens.gap16),
              _AttendanceOverview(
                groupCount: controller.groups.length,
                sessionCount: controller.sessions.length,
                studentCount: controller.groups.fold<int>(
                  0,
                  (sum, item) => sum + item.studentCount,
                ),
              ),
              const SizedBox(height: FUITokens.gap16),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: context.colors.primary,
                unselectedLabelColor: context.colors.textSecondary,
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                indicatorColor: context.colors.primary,
                dividerColor: context.colors.border,
                labelPadding: const EdgeInsets.only(right: 24),
                onTap: (index) => setState(() => _tabIndex = index),
                tabs: const [
                  Tab(text: '记录'),
                  Tab(text: '名单'),
                ],
              ),
              const SizedBox(height: FUITokens.gap12),
              if (_tabIndex == 0)
                _RecordTab(
                  sessions: controller.sessions,
                  onOpenMatrix: controller.groups.isEmpty
                      ? null
                      : () => FuiNavigation.openDetail(
                          context,
                          title: '统计矩阵',
                          builder: (_) => AttendanceMatrixPage(
                            groups: controller.groups.toList(growable: false),
                          ),
                        ),
                  onOpen: (session) => FuiNavigation.openDetail(
                    context,
                    title: session.session.title,
                    builder: (_) =>
                        AttendanceSessionPage(sessionId: session.session.id),
                  ),
                  onDelete: (session) =>
                      controller.deleteSession(session.session.id),
                )
              else
                _GroupTab(
                  groups: controller.groups,
                  onImport: () => _openGroupEditor(context, controller),
                  onDelete: (group) => controller.deleteGroup(group.group.id),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openGroupEditor(
    BuildContext context,
    AttendanceController controller,
  ) async {
    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      child: _GroupEditor(
        onSave: (name, roster) async {
          await controller.createGroup(name: name, rosterText: roster);
        },
      ),
    );
  }

  Future<void> _openSessionEditor(
    BuildContext context,
    AttendanceController controller,
  ) async {
    final sessionId = await showAppBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      child: _SessionEditor(
        groups: controller.groups,
        onSave: (groupId, title, date) {
          return controller.createSession(
            groupId: groupId,
            title: title,
            sessionDate: date,
          );
        },
      ),
    );
    if (!context.mounted || sessionId == null) return;
    await FuiNavigation.openDetail(
      context,
      title: '统计记录',
      builder: (_) => AttendanceSessionPage(sessionId: sessionId),
    );
  }
}

class _AttendanceHeader extends StatelessWidget {
  const _AttendanceHeader({
    required this.onImport,
    required this.onCreateSession,
  });

  final VoidCallback onImport;
  final VoidCallback? onCreateSession;

  @override
  Widget build(BuildContext context) {
    return FuiPageHead(
      title: '统计',
      subtitle: '名单、日期记录、状态备注',
      actions: [
        FUIIconButton(
          icon: FUIIcons.person,
          tooltip: '导入名单',
          variant: FUIIconButtonVariant.ghost,
          onPressed: onImport,
        ),
        FUIIconButton(
          icon: FUIIcons.add,
          tooltip: '新建统计',
          variant: FUIIconButtonVariant.ghost,
          onPressed: onCreateSession,
        ),
      ],
    );
  }
}

class _AttendanceOverview extends StatelessWidget {
  const _AttendanceOverview({
    required this.groupCount,
    required this.sessionCount,
    required this.studentCount,
  });

  final int groupCount;
  final int sessionCount;
  final int studentCount;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              icon: FUIIcons.classroom,
              value: '$groupCount',
              label: '名单',
            ),
          ),
          const _MetricDivider(),
          Expanded(
            child: _Metric(
              icon: FUIIcons.person,
              value: '$studentCount',
              label: '学生',
            ),
          ),
          const _MetricDivider(),
          Expanded(
            child: _Metric(
              icon: FUIIcons.check,
              value: '$sessionCount',
              label: '统计',
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: context.colors.primary),
          const SizedBox(height: FUITokens.gap4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.colors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: context.colors.border);
  }
}

class _RecordTab extends StatelessWidget {
  const _RecordTab({
    required this.sessions,
    required this.onOpenMatrix,
    required this.onOpen,
    required this.onDelete,
  });

  final List<AttendanceSessionSummary> sessions;
  final VoidCallback? onOpenMatrix;
  final ValueChanged<AttendanceSessionSummary> onOpen;
  final ValueChanged<AttendanceSessionSummary> onDelete;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return FUISurface(
        child: const SizedBox(
          height: 220,
          child: FUIEmptyState(
            icon: FUIIcons.check,
            title: '暂无记录',
            message: '新建统计后，可以在这里按时间查看和导出。',
          ),
        ),
      );
    }
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${sessions.length} 条统计记录',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FUIButton(
              label: '表格统计',
              icon: FUIIcons.chart,
              small: true,
              variant: FUIButtonVariant.secondary,
              onPressed: onOpenMatrix,
            ),
          ],
        ),
        const SizedBox(height: FUITokens.gap10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sessions.length,
          separatorBuilder: (_, _) => const SizedBox(height: FUITokens.gap10),
          itemBuilder: (context, index) {
            final session = sessions[index];
            return _SessionTile(
              summary: session,
              onTap: () => onOpen(session),
              onDelete: () => onDelete(session),
            );
          },
        ),
      ],
    );
  }
}

class _GroupTab extends StatelessWidget {
  const _GroupTab({
    required this.groups,
    required this.onImport,
    required this.onDelete,
  });

  final List<AttendanceGroupSummary> groups;
  final VoidCallback onImport;
  final ValueChanged<AttendanceGroupSummary> onDelete;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return FUISurface(
        child: SizedBox(
          height: 220,
          child: FUIEmptyState(
            icon: FUIIcons.person,
            title: '暂无名单',
            message: '先导入名单，再按日期创建统计。',
            actionLabel: '导入名单',
            onAction: onImport,
          ),
        ),
      );
    }
    return FUISection(
      children: [
        for (final group in groups)
          _GroupTile(group: group, onDelete: () => onDelete(group)),
      ],
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group, required this.onDelete});

  final AttendanceGroupSummary group;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: FUIInsets.tile,
      child: Row(
        children: [
          Icon(FUIIcons.classroom, size: 20, color: context.colors.primary),
          const SizedBox(width: FUITokens.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.group.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${group.studentCount} 人 · ${group.sessionCount} 次统计',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          FUIIconButton(
            icon: FUIIcons.delete,
            tooltip: '删除名单',
            variant: FUIIconButtonVariant.ghost,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.summary,
    required this.onTap,
    required this.onDelete,
  });

  final AttendanceSessionSummary summary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.primarySoft,
              borderRadius: BorderRadius.circular(FUITokens.radiusSm),
            ),
            child: Icon(
              FUIIcons.chart,
              size: 20,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: FUITokens.gap10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.session.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: FUITokens.gap4),
                Text(
                  '${summary.group.name} · ${_formatDateTime(summary.session.sessionDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: FUITokens.gap6),
                Wrap(
                  spacing: FUITokens.gap6,
                  runSpacing: FUITokens.gap6,
                  children: [
                    _StatusChip(
                      icon: FUIIcons.checkmark,
                      label: '${summary.present}',
                      variant: FUITagVariant.success,
                    ),
                    _StatusChip(
                      icon: FUIIcons.close,
                      label: '${summary.absent}',
                      variant: summary.absent > 0
                          ? FUITagVariant.danger
                          : FUITagVariant.neutral,
                    ),
                  ],
                ),
              ],
            ),
          ),
          FUIIconButton(
            icon: FUIIcons.delete,
            tooltip: '删除统计',
            variant: FUIIconButtonVariant.ghost,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _GroupEditor extends StatefulWidget {
  const _GroupEditor({required this.onSave});

  final Future<void> Function(String name, String roster) onSave;

  @override
  State<_GroupEditor> createState() => _GroupEditorState();
}

class _GroupEditorState extends State<_GroupEditor> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rosterController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _rosterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        Text(
          '导入名单',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: FUITokens.gap14),
        FUITextField(
          controller: _nameController,
          label: '名单名称',
          hintText: '例如 软工 25-1 / 活动小组',
          prefixIcon: FUIIcons.classroom,
        ),
        const SizedBox(height: FUITokens.gap12),
        Text(
          '名单内容',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: FUITokens.gap6),
        TextField(
          controller: _rosterController,
          minLines: 5,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: '每行一人：\n20250001 张三\n20250002,李四\n王五',
          ),
        ),
        const SizedBox(height: FUITokens.gap16),
        FUIButton(
          label: '保存名单',
          icon: FUIIcons.save,
          fullWidth: true,
          loading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.onSave(_nameController.text, _rosterController.text);
      if (!mounted) return;
      Navigator.of(context).pop();
      FUIToast.success(context, message: '已导入名单');
    } catch (e) {
      if (!mounted) return;
      FUIToast.error(context, message: e.toString().split('\n').first);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _SessionEditor extends StatefulWidget {
  const _SessionEditor({required this.groups, required this.onSave});

  final List<AttendanceGroupSummary> groups;
  final Future<int> Function(int groupId, String title, DateTime date) onSave;

  @override
  State<_SessionEditor> createState() => _SessionEditorState();
}

class _SessionEditorState extends State<_SessionEditor> {
  final TextEditingController _titleController = TextEditingController();
  late int _groupId = widget.groups.first.group.id;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        Text(
          '新建统计',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: FUITokens.gap14),
        FUIComboBox<int>(
          label: '班级名单',
          value: _groupId,
          items: widget.groups.map((item) => item.group.id).toList(),
          itemLabelBuilder: (id) => widget.groups
              .firstWhere((item) => item.group.id == id)
              .group
              .name,
          onChanged: (value) {
            if (value != null) setState(() => _groupId = value);
          },
        ),
        const SizedBox(height: FUITokens.gap12),
        FUITextField(
          controller: _titleController,
          label: '标题',
          hintText: '例如 第 4 周周一统计',
          prefixIcon: FUIIcons.check,
        ),
        const SizedBox(height: FUITokens.gap12),
        FUISurface(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(child: Text('时间：${_formatDateTime(_date)}')),
              FUIButton(
                label: '日期',
                small: true,
                variant: FUIButtonVariant.secondary,
                onPressed: _pickDate,
              ),
              const SizedBox(width: FUITokens.gap8),
              FUIButton(
                label: '时间',
                small: true,
                variant: FUIButtonVariant.secondary,
                onPressed: _pickTime,
              ),
            ],
          ),
        ),
        const SizedBox(height: FUITokens.gap16),
        FUIButton(
          label: '开始统计',
          icon: FUIIcons.add,
          fullWidth: true,
          loading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (value != null) {
      setState(
        () => _date = DateTime(
          value.year,
          value.month,
          value.day,
          _date.hour,
          _date.minute,
        ),
      );
    }
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (value != null) {
      setState(
        () => _date = DateTime(
          _date.year,
          _date.month,
          _date.day,
          value.hour,
          value.minute,
        ),
      );
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final sessionId = await widget.onSave(
        _groupId,
        _titleController.text,
        _date,
      );
      if (!mounted) return;
      Navigator.of(context).pop(sessionId);
    } catch (e) {
      if (!mounted) return;
      FUIToast.error(context, message: e.toString().split('\n').first);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class AttendanceSessionPage extends StatefulWidget {
  const AttendanceSessionPage({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<AttendanceSessionPage> createState() => _AttendanceSessionPageState();
}

class _AttendanceSessionPageState extends State<AttendanceSessionPage> {
  late final AttendanceSessionController controller;
  final String _controllerTag = UniqueKey().toString();

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      AttendanceSessionController(sessionId: widget.sessionId),
      tag: _controllerTag,
      permanent: false,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<AttendanceSessionController>(tag: _controllerTag)) {
      Get.delete<AttendanceSessionController>(tag: _controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: GetBuilder<AttendanceSessionController>(
        tag: _controllerTag,
        id: 'attendance-session-content',
        builder: (controller) {
          final summary = controller.summary.value;
          return FUIPage(
            children: [
              FuiPageHead(
                title: summary?.session.title ?? '统计详情',
                actions: [
                  FUIIconButton(
                    icon: FUIIcons.list,
                    tooltip: controller.tableMode.value ? '操作视图' : '表格视图',
                    variant: FUIIconButtonVariant.ghost,
                    onPressed: controller.toggleTableMode,
                  ),
                  FUIIconButton(
                    icon: FUIIcons.copy,
                    tooltip: '导出表格',
                    variant: FUIIconButtonVariant.ghost,
                    onPressed: () => _exportTable(context, controller),
                  ),
                ],
              ),
              const SizedBox(height: FUITokens.gap14),
              if (summary != null) ...[
                _AttendanceOverview(
                  groupCount: 1,
                  studentCount: summary.total,
                  sessionCount: summary.present,
                ),
                const SizedBox(height: FUITokens.gap12),
                Wrap(
                  spacing: FUITokens.gap8,
                  children: [
                    FUITag(label: summary.group.name),
                    FUITag(label: _formatDateTime(summary.session.sessionDate)),
                    _StatusChip(
                      icon: FUIIcons.checkmark,
                      label: '${summary.present}',
                      variant: FUITagVariant.success,
                    ),
                    _StatusChip(
                      icon: FUIIcons.close,
                      label: '${summary.absent}',
                      variant: summary.absent > 0
                          ? FUITagVariant.danger
                          : FUITagVariant.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: FUITokens.gap14),
              ],
              if (controller.records.isEmpty)
                const _NoticeLine(text: '暂无学生记录')
              else if (controller.tableMode.value)
                _AttendanceTable(entries: controller.records)
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.records.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: FUITokens.gap8),
                  itemBuilder: (context, index) {
                    final entry = controller.records[index];
                    return _AttendanceRecordCard(
                      entry: entry,
                      onPresent: () => controller.setPresent(entry, true),
                      onAbsent: () => controller.setPresent(entry, false),
                      onRemark: () =>
                          _openRemarkEditor(context, controller, entry),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportTable(
    BuildContext context,
    AttendanceSessionController controller,
  ) async {
    await Clipboard.setData(ClipboardData(text: controller.buildTableText()));
    if (!context.mounted) return;
    FUIToast.success(context, message: '已复制表格，可粘贴到 Excel/WPS');
  }

  Future<void> _openRemarkEditor(
    BuildContext context,
    AttendanceSessionController controller,
    AttendanceRecordEntry entry,
  ) async {
    final textController = TextEditingController(text: entry.record.remark);
    await showAppBottomSheet<void>(
      context: context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.student.name} 备注',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: FUITokens.gap12),
            TextField(
              controller: textController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(hintText: '迟到、请假或其他说明'),
            ),
            const SizedBox(height: FUITokens.gap16),
            FUIButton(
              label: '保存备注',
              icon: FUIIcons.save,
              fullWidth: true,
              onPressed: () async {
                await controller.setRemark(entry, textController.text);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
    textController.dispose();
  }
}

class _AttendanceRecordCard extends StatelessWidget {
  const _AttendanceRecordCard({
    required this.entry,
    required this.onPresent,
    required this.onAbsent,
    required this.onRemark,
  });

  final AttendanceRecordEntry entry;
  final VoidCallback onPresent;
  final VoidCallback onAbsent;
  final VoidCallback onRemark;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.student.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (entry.student.studentNo.isNotEmpty ||
                    entry.record.remark.isNotEmpty) ...[
                  const SizedBox(height: FUITokens.gap4),
                  Text(
                    [
                      if (entry.student.studentNo.isNotEmpty)
                        entry.student.studentNo,
                      if (entry.record.remark.isNotEmpty) entry.record.remark,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _RecordMarkButton(
            icon: FUIIcons.checkmark,
            tooltip: '标记为已到',
            selected: entry.record.present,
            selectedColor: context.colors.success,
            selectedBackground: context.colors.successSoft,
            onTap: onPresent,
          ),
          const SizedBox(width: FUITokens.gap6),
          _RecordMarkButton(
            icon: FUIIcons.close,
            tooltip: '标记为未到',
            selected: !entry.record.present,
            selectedColor: context.colors.danger,
            selectedBackground: context.colors.dangerSoft,
            onTap: onAbsent,
          ),
          FUIIconButton(
            icon: FUIIcons.info,
            tooltip: '备注',
            variant: FUIIconButtonVariant.ghost,
            onPressed: onRemark,
          ),
        ],
      ),
    );
  }
}

class _RecordMarkButton extends StatelessWidget {
  const _RecordMarkButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.selectedColor,
    required this.selectedBackground,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final Color selectedColor;
  final Color selectedBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? selectedBackground : colors.surfaceAlt,
            borderRadius: BorderRadius.circular(FUITokens.radiusSm),
            border: Border.all(
              color: selected
                  ? selectedColor.withValues(alpha: 0.35)
                  : colors.border,
            ),
          ),
          child: SizedBox(
            width: 38,
            height: 34,
            child: Icon(
              icon,
              size: 18,
              color: selected ? selectedColor : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AttendanceTable extends StatelessWidget {
  const _AttendanceTable({required this.entries});

  final List<AttendanceRecordEntry> entries;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 560,
          child: Table(
            columnWidths: const {
              0: FixedColumnWidth(44),
              1: FlexColumnWidth(1.1),
              2: FixedColumnWidth(54),
              3: FlexColumnWidth(1.2),
            },
            children: [
              _row(context, const [
                Text('序号'),
                Text('姓名'),
                Text('状态'),
                Text('备注'),
              ], header: true),
              for (var i = 0; i < entries.length; i++)
                _row(context, [
                  Text('${i + 1}'),
                  Text(entries[i].student.name),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _StatusIcon(present: entries[i].record.present),
                  ),
                  Text(entries[i].record.remark),
                ]),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _row(
    BuildContext context,
    List<Widget> cells, {
    bool header = false,
  }) {
    return TableRow(
      children: [
        for (final cell in cells)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: header
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
                fontWeight: header ? FontWeight.w800 : FontWeight.w600,
              ),
              child: cell,
            ),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.variant,
  });

  final IconData icon;
  final String label;
  final FUITagVariant variant;

  @override
  Widget build(BuildContext context) {
    return FUITag(icon: icon, label: label, variant: variant);
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.present, this.compact = false});

  final bool present;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = present ? colors.success : colors.danger;
    final background = present ? colors.successSoft : colors.dangerSoft;
    return Tooltip(
      message: present ? '已到' : '未到',
      child: Container(
        width: compact ? 24 : 28,
        height: compact ? 24 : 28,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(FUITokens.radiusSm),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Icon(
          present ? FUIIcons.checkmark : FUIIcons.close,
          size: compact ? 14 : 16,
          color: color,
        ),
      ),
    );
  }
}

class AttendanceMatrixPage extends StatefulWidget {
  const AttendanceMatrixPage({super.key, required this.groups});

  final List<AttendanceGroupSummary> groups;

  @override
  State<AttendanceMatrixPage> createState() => _AttendanceMatrixPageState();
}

class _AttendanceMatrixPageState extends State<AttendanceMatrixPage> {
  late final AttendanceController _controller = AttendanceController();
  late int _groupId = widget.groups.first.group.id;
  DateTime? _startDate;
  DateTime? _endDate;
  late Future<AttendanceMatrix> _future = _buildMatrix();

  Future<AttendanceMatrix> _buildMatrix() {
    return _controller.buildMatrix(
      _groupId,
      startDate: _startDate == null ? null : _dateOnly(_startDate!),
      endDate: _endDate == null ? null : _dayAfter(_endDate!),
    );
  }

  void _changeGroup(int? value) {
    if (value == null || value == _groupId) return;
    setState(() {
      _groupId = value;
      _future = _buildMatrix();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FUIPage(
        children: [
          const FuiPageHead(title: '表格统计'),
          const SizedBox(height: FUITokens.gap14),
          _MatrixFilters(
            groupId: _groupId,
            groups: widget.groups,
            startDate: _startDate,
            endDate: _endDate,
            onGroupChanged: _changeGroup,
            onStartDateChanged: (value) {
              setState(() {
                _startDate = value;
                if (_endDate != null &&
                    value != null &&
                    _endDate!.isBefore(value)) {
                  _endDate = value;
                }
                _future = _buildMatrix();
              });
            },
            onEndDateChanged: (value) {
              setState(() {
                _endDate = value;
                if (_startDate != null &&
                    value != null &&
                    _startDate!.isAfter(value)) {
                  _startDate = value;
                }
                _future = _buildMatrix();
              });
            },
            onClearRange: () {
              setState(() {
                _startDate = null;
                _endDate = null;
                _future = _buildMatrix();
              });
            },
          ),
          const SizedBox(height: FUITokens.gap12),
          FutureBuilder<AttendanceMatrix>(
            future: _future,
            builder: (context, snapshot) {
              final matrix = snapshot.data;
              if (snapshot.connectionState != ConnectionState.done) {
                return const _NoticeLine(text: '正在生成表格...');
              }
              if (snapshot.hasError || matrix == null) {
                return const _NoticeLine(text: '表格生成失败');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${matrix.group.name} · ${matrix.columns.length} 次统计 · ${matrix.rows.length} 人',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: context.colors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      FUIButton(
                        label: '导出',
                        icon: FUIIcons.copy,
                        small: true,
                        variant: FUIButtonVariant.secondary,
                        onPressed: () => _exportMatrix(context, matrix),
                      ),
                    ],
                  ),
                  const SizedBox(height: FUITokens.gap10),
                  _AttendanceMatrixTable(matrix: matrix),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportMatrix(
    BuildContext context,
    AttendanceMatrix matrix,
  ) async {
    await Clipboard.setData(ClipboardData(text: _buildMatrixText(matrix)));
    if (!context.mounted) return;
    FUIToast.success(context, message: '已复制表格，可粘贴到 Excel/WPS');
  }
}

class _MatrixFilters extends StatelessWidget {
  const _MatrixFilters({
    required this.groupId,
    required this.groups,
    required this.startDate,
    required this.endDate,
    required this.onGroupChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onClearRange,
  });

  final int groupId;
  final List<AttendanceGroupSummary> groups;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<int?> onGroupChanged;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final VoidCallback onClearRange;

  @override
  Widget build(BuildContext context) {
    return FUISurface(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          FUIComboBox<int>(
            label: '名单',
            value: groupId,
            items: groups.map((item) => item.group.id).toList(),
            itemLabelBuilder: (id) =>
                groups.firstWhere((item) => item.group.id == id).group.name,
            onChanged: onGroupChanged,
          ),
          const SizedBox(height: FUITokens.gap10),
          Row(
            children: [
              Expanded(
                child: _DateFilterButton(
                  label: '开始',
                  value: startDate,
                  onChanged: onStartDateChanged,
                ),
              ),
              const SizedBox(width: FUITokens.gap8),
              Expanded(
                child: _DateFilterButton(
                  label: '结束',
                  value: endDate,
                  onChanged: onEndDateChanged,
                ),
              ),
              const SizedBox(width: FUITokens.gap8),
              FUIIconButton(
                icon: FUIIcons.close,
                tooltip: '清除范围',
                variant: FUIIconButtonVariant.ghost,
                onPressed: startDate == null && endDate == null
                    ? null
                    : onClearRange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return FUIButton(
      label: value == null ? label : '$label ${_formatDate(value!)}',
      icon: FUIIcons.calendar,
      small: true,
      variant: FUIButtonVariant.secondary,
      onPressed: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 2),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
    );
  }
}

class _AttendanceMatrixTable extends StatelessWidget {
  const _AttendanceMatrixTable({required this.matrix});

  final AttendanceMatrix matrix;

  @override
  Widget build(BuildContext context) {
    if (matrix.columns.isEmpty) {
      return const FUISurface(
        child: SizedBox(
          height: 160,
          child: FUIEmptyState(
            icon: FUIIcons.chart,
            title: '暂无统计记录',
            message: '新建统计后这里会按时间生成表格。',
          ),
        ),
      );
    }
    final width = 112 + matrix.columns.length * 96.0;
    return FUISurface(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: width.clamp(360, 1800).toDouble(),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: {
              0: const FixedColumnWidth(112),
              for (var i = 0; i < matrix.columns.length; i++)
                i + 1: const FixedColumnWidth(96),
            },
            children: [
              _row(context, [
                const Text('姓名'),
                for (final column in matrix.columns)
                  Text(_formatShortDateTime(column.session.sessionDate)),
              ], header: true),
              for (final row in matrix.rows)
                _row(context, [
                  Text(row.student.name),
                  for (final cell in row.cells) _MatrixCellView(cell: cell),
                ]),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _row(
    BuildContext context,
    List<Widget> cells, {
    bool header = false,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.border)),
      ),
      children: [
        for (final cell in cells)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
            child: DefaultTextStyle.merge(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: header
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
                fontWeight: header ? FontWeight.w800 : FontWeight.w600,
              ),
              child: cell,
            ),
          ),
      ],
    );
  }
}

class _MatrixCellView extends StatelessWidget {
  const _MatrixCellView({required this.cell});

  final AttendanceMatrixCell cell;

  @override
  Widget build(BuildContext context) {
    final present = cell.present;
    if (present == null) {
      return const SizedBox(height: 28);
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _StatusIcon(present: present, compact: true),
          if (cell.remark.isNotEmpty)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: context.colors.warning,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoticeLine extends StatelessWidget {
  const _NoticeLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: FUIInsets.tile,
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
      ),
    );
  }
}

String _formatDate(DateTime value) {
  return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime _dayAfter(DateTime value) {
  return DateTime(value.year, value.month, value.day + 1);
}

String _formatDateTime(DateTime value) {
  return '${_formatDate(value)} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

String _formatShortDateTime(DateTime value) {
  return '${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}\n${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

String _cellText(AttendanceMatrixCell cell) {
  if (cell.present == null) return '';
  final mark = cell.present! ? '已到' : '未到';
  return cell.remark.isEmpty ? mark : '$mark ${cell.remark}';
}

String _buildMatrixText(AttendanceMatrix matrix) {
  final lines = <String>[
    [
      '姓名',
      for (final column in matrix.columns)
        _formatDateTime(column.session.sessionDate),
    ].join('\t'),
  ];
  for (final row in matrix.rows) {
    lines.add(
      [
        row.student.name,
        for (final cell in row.cells) _cellText(cell),
      ].join('\t'),
    );
  }
  return lines.join('\n');
}
