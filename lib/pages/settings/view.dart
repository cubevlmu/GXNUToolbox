import 'package:class_tool/pages/login/view.dart';
import 'package:class_tool/pages/settings/about_page.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:class_tool/data/model/home_quick_action.dart';
import 'package:fin_ui/app_button.dart';
import 'package:fin_ui/app_context.dart';
import 'package:fin_ui/app_icons.dart';
import 'package:fin_ui/app_page.dart';
import 'package:fin_ui/app_section.dart';
import 'package:fin_ui/app_segmented_control.dart';
import 'package:fin_ui/app_tile.dart';
import 'package:fin_ui/app_toast.dart';
import 'package:fin_ui/app_tokens.dart';
import 'package:fin_ui/fui_navigation.dart';
import 'package:fin_ui/fui_page_head.dart';
import 'package:class_tool/utils/shared_dialog.dart';
import 'package:class_tool/widgets/github_update_prompt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return FUIPage(
      children: [
        const _SettingsHeader(),
        const SizedBox(height: FUITokens.gap16),
        FUISection(
          title: '设置分类',
          children: [
            FUITile(
              icon: FUIIcons.palette,
              title: '外观',
              subtitle: '主题模式、颜色、按钮组标签栏',
              onTap: () => _push(context, const _AppearanceSettingsPage()),
            ),
            FUITile(
              icon: FUIIcons.badge,
              title: '账号',
              subtitle: '身份、校区、当前学期',
              onTap: () => _push(context, const _AccountSettingsPage()),
            ),
            FUITile(
              icon: FUIIcons.notificationActive,
              title: '通知与同步',
              subtitle: '自动同步、早安提醒',
              onTap: () => _push(context, const _SyncSettingsPage()),
            ),
            FUITile(
              icon: FUIIcons.update,
              title: '通用',
              subtitle: '首页快捷操作、更新提醒',
              onTap: () => _push(context, const _GeneralSettingsPage()),
            ),
            if (controller.showDiagnosticLogs)
              FUITile(
                icon: FUIIcons.bug,
                title: '调试诊断',
                subtitle: '客户端时间、日志和同步诊断',
                onTap: () => _push(context, const _DebugSettingsPage()),
              ),
            FUITile(
              icon: FUIIcons.info,
              title: '关于 GXNU Toolbox',
              subtitle: '版本、隐私与平台说明',
              onTap: () => _push(context, const AboutPage()),
            ),
          ],
        ),
        const SizedBox(height: FUITokens.gap14),
        FUIButton(
          label: '退出登录',
          icon: FUIIcons.logout,
          variant: FUIButtonVariant.danger,
          fullWidth: true,
          onPressed: () async {
            final confirmed = await SharedDialog.showConfirmDialog(
              context,
              title: '确认退出登录',
              content: '退出后将清除本地登录状态，是否继续？',
              cancelText: '取消',
              confirmText: '退出',
              variant: SharedDialogVariant.danger,
              icon: FUIIcons.logout,
            );
            if (!confirmed) {
              return;
            }
            await controller.logout();
            Get.offAll(() => const LoginPage());
          },
        ),
      ],
    );
  }

  static void _push(BuildContext context, Widget page) {
    FuiNavigation.openDetail(context, builder: (_) => page);
  }
}

class _SettingsSubPage extends StatelessWidget {
  const _SettingsSubPage({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FUIPage(
        children: [
          FuiPageHead(title: title, subtitle: subtitle),
          const SizedBox(height: FUITokens.gap16),
          ...children,
        ],
      ),
    );
  }
}

class _AppearanceSettingsPage extends StatelessWidget {
  const _AppearanceSettingsPage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return _SettingsSubPage(
      title: '外观',
      subtitle: '调整应用显示方式',
      children: [
        FUISection(
          title: '主题模式',
          children: [
            _SettingControlBlock(
              title: '主题模式',
              subtitle: '选择应用界面使用的明暗外观',
              child: Obx(
                () => FUISegmentedControl<ThemeMode>(
                  value: controller.themeMode.value,
                  items: const [
                    FUISegmentedItem(
                      value: ThemeMode.system,
                      label: '自动',
                      icon: FUIIcons.autoBrightness,
                    ),
                    FUISegmentedItem(
                      value: ThemeMode.light,
                      label: '浅色',
                      icon: FUIIcons.lightMode,
                    ),
                    FUISegmentedItem(
                      value: ThemeMode.dark,
                      label: '深色',
                      icon: FUIIcons.darkMode,
                    ),
                  ],
                  onChanged: controller.changeThemeMode,
                ),
              ),
            ),
            _SettingControlBlock(
              title: '主题颜色',
              subtitle: '用于按钮、高亮状态和首页时间线',
              child: Obx(
                () => _AccentPicker(
                  selected: controller.accent.value,
                  onSelected: controller.changeAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: FUITokens.gap16),
        FUISection(
          title: '按钮组标签栏',
          children: [
            Obx(
              () => _ToggleTile(
                icon: FUIIcons.apps,
                title: '仅显示图标',
                subtitle: '隐藏按钮组中的文字标签',
                description: '作息时间等页面的按钮组会使用此设置',
                value: controller.buttonGroupIconOnly.value,
                onChanged: controller.changeButtonGroupIconOnly,
              ),
            ),
            _SettingControlBlock(
              title: '对齐方式',
              subtitle: '调整按钮组在可用宽度内的位置',
              child: Obx(
                () => FUISegmentedControl<ButtonGroupAlignmentPreference>(
                  value: controller.buttonGroupAlignment.value,
                  items: [
                    for (final item in ButtonGroupAlignmentPreference.values)
                      FUISegmentedItem(
                        value: item,
                        label: item.label,
                        icon: item == ButtonGroupAlignmentPreference.centered
                            ? FUIIcons.apps
                            : FUIIcons.list,
                      ),
                  ],
                  onChanged: controller.changeButtonGroupAlignment,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingControlBlock extends StatelessWidget {
  const _SettingControlBlock({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(FUITokens.gap14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: FUITokens.gap2),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: FUITokens.gap10),
          child,
        ],
      ),
    );
  }
}

class _AccentPicker extends StatelessWidget {
  const _AccentPicker({required this.selected, required this.onSelected});

  final AppAccentPreference selected;
  final ValueChanged<AppAccentPreference> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: FUITokens.gap10,
      runSpacing: FUITokens.gap10,
      children: [
        for (final item in AppAccentPreference.values)
          _AccentButton(
            accent: item,
            selected: item == selected,
            onTap: () => onSelected(item),
          ),
      ],
    );
  }
}

class _AccentButton extends StatelessWidget {
  const _AccentButton({
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final AppAccentPreference accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final swatch = accent.usesSystemColor ? colors.primary : accent.seedColor;
    return Material(
      color: selected ? colors.primarySoft : colors.surfaceAlt,
      borderRadius: BorderRadius.circular(FUITokens.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(FUITokens.radiusSm),
        onTap: onTap,
        child: SizedBox(
          width: 104,
          height: 38,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: FUITokens.gap12),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: swatch,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border),
                ),
              ),
              const SizedBox(width: FUITokens.gap8),
              Expanded(
                child: Text(
                  accent.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected ? colors.primary : colors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: FUITokens.gap4),
              SizedBox(
                width: 16,
                height: 16,
                child: selected
                    ? Icon(FUIIcons.checkmark, size: 16, color: colors.primary)
                    : null,
              ),
              const SizedBox(width: FUITokens.gap8),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeQuickActionPicker extends StatelessWidget {
  const _HomeQuickActionPicker({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final availableActions = HomeQuickActionPreference.values
          .where(controller.isHomeQuickActionAvailable)
          .toList(growable: false);
      final selected = controller.homeQuickActions
          .where(controller.isHomeQuickActionAvailable)
          .toSet();
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    selected.isEmpty
                        ? '未显示入口，首页会隐藏快捷操作'
                        : '显示 ${selected.length} / 8 个入口',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FUIButton(
                  label: '恢复默认',
                  small: true,
                  variant: FUIButtonVariant.secondary,
                  onPressed: controller.resetHomeQuickActions,
                ),
              ],
            ),
            const SizedBox(height: FUITokens.gap10),
            Wrap(
              spacing: FUITokens.gap8,
              runSpacing: FUITokens.gap8,
              children: [
                for (final action in availableActions)
                  _HomeQuickActionChip(
                    action: action,
                    selected: selected.contains(action),
                    onTap: () {
                      final message = controller.homeQuickActionLimitMessage(
                        action,
                      );
                      if (message != null) {
                        FUIToast.info(context, message: message);
                        return;
                      }
                      controller.toggleHomeQuickAction(action);
                    },
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _HomeQuickActionChip extends StatelessWidget {
  const _HomeQuickActionChip({
    required this.action,
    required this.selected,
    required this.onTap,
  });

  final HomeQuickActionPreference action;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? colors.primarySoft : colors.surfaceAlt,
          borderRadius: BorderRadius.circular(FUITokens.radiusSm),
          border: Border.all(
            color: selected ? colors.primarySubtle : colors.border,
          ),
        ),
        child: SizedBox(
          width: 104,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _homeQuickActionIcon(action),
                  size: 16,
                  color: selected ? colors.primary : colors.textSecondary,
                ),
                const SizedBox(width: FUITokens.gap6),
                Expanded(
                  child: Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected ? colors.primary : colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: FUITokens.gap4),
                  Icon(FUIIcons.checkmark, size: 14, color: colors.primary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _homeQuickActionIcon(HomeQuickActionPreference action) {
  switch (action) {
    case HomeQuickActionPreference.grades:
      return FUIIcons.grade;
    case HomeQuickActionPreference.exams:
      return FUIIcons.exam;
    case HomeQuickActionPreference.tasks:
      return FUIIcons.book;
    case HomeQuickActionPreference.attendance:
      return FUIIcons.check;
    case HomeQuickActionPreference.selectedCourses:
      return FUIIcons.list;
    case HomeQuickActionPreference.credit:
      return FUIIcons.credit;
    case HomeQuickActionPreference.progress:
      return FUIIcons.progress;
    case HomeQuickActionPreference.studentInfo:
      return FUIIcons.person;
    case HomeQuickActionPreference.time:
      return FUIIcons.schedule;
    case HomeQuickActionPreference.schoolCalendar:
      return FUIIcons.calendar;
    case HomeQuickActionPreference.classroom:
      return FUIIcons.classroom;
    case HomeQuickActionPreference.notifications:
      return FUIIcons.notification;
  }
}

class _AccountSettingsPage extends StatelessWidget {
  const _AccountSettingsPage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return _SettingsSubPage(
      title: '账号',
      subtitle: '查看当前登录与学期信息',
      children: [
        Obx(
          () => FUISection(
            title: '账号与安全',
            children: [
              FUITile(
                icon: FUIIcons.badge,
                title: '身份',
                subtitle: controller.studentName.value,
                showChevron: false,
              ),
              FUITile(
                icon: FUIIcons.location,
                title: '校区',
                subtitle: controller.campus.value,
                showChevron: false,
              ),
              FUITile(
                icon: FUIIcons.calendar,
                title: '当前学期',
                subtitle: controller.semester.value,
                showChevron: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SyncSettingsPage extends StatelessWidget {
  const _SyncSettingsPage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return _SettingsSubPage(
      title: '通知与同步',
      subtitle: '管理后台同步与课程提醒',
      children: [
        if (controller.supportsScheduledSync)
          Obx(
            () => FUISection(
              title: '通知与同步',
              children: [
                _ToggleTile(
                  icon: FUIIcons.schedule,
                  title: '自动同步',
                  subtitle: '每天早上 7 点后联网时自动刷新小组件',
                  description: '开启后由 Android 安排后台任务；省电策略或休眠可能使执行时间略晚于 7 点。',
                  value: controller.autoWidgetSyncEnabled.value,
                  onChanged: controller.changeAutoWidgetSync,
                ),
                _ToggleTile(
                  icon: FUIIcons.notificationActive,
                  title: '早安提醒',
                  subtitle: '同步成功后发送今日课程通知',
                  description: '通知会突出显示今天共有几节课，并给出第一节课的时间、教室和课程名。',
                  value: controller.morningBriefingEnabled.value,
                  onChanged: controller.changeMorningBriefing,
                ),
              ],
            ),
          )
        else
          FUISection(
            title: '平台支持说明',
            children: const [
              _NoticeTile(
                icon: FUIIcons.info,
                title: '当前平台不支持',
                subtitle: '自动同步、早安提醒和相关后台任务仅在 Android 端提供。',
              ),
            ],
          ),
      ],
    );
  }
}

class _GeneralSettingsPage extends StatelessWidget {
  const _GeneralSettingsPage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return _SettingsSubPage(
      title: '通用',
      subtitle: '更新和基础行为',
      children: [
        Obx(
          () => FUISection(
            title: '首页',
            children: [
              _ToggleTile(
                icon: FUIIcons.apps,
                title: '显示快捷操作',
                subtitle: controller.homeQuickActionsEnabled.value
                    ? '首页显示快捷入口'
                    : '首页隐藏快捷操作板块',
                description: '关闭后首页不再显示快捷操作；开启时显示 4 到 8 个入口。',
                value: controller.homeQuickActionsEnabled.value,
                onChanged: controller.changeHomeQuickActionsEnabled,
              ),
              _HomeQuickActionPicker(controller: controller),
            ],
          ),
        ),
        const SizedBox(height: FUITokens.gap16),
        Obx(
          () => FUISection(
            title: '功能入口',
            children: [
              _ToggleTile(
                icon: FUIIcons.book,
                title: '待办任务',
                subtitle: controller.todoFeatureEnabled.value
                    ? '功能页和快捷操作显示待办任务'
                    : '隐藏待办任务入口',
                description: '关闭后不会删除已有待办数据，只隐藏入口。',
                value: controller.todoFeatureEnabled.value,
                onChanged: controller.changeTodoFeatureEnabled,
              ),
              _ToggleTile(
                icon: FUIIcons.check,
                title: '统计',
                subtitle: controller.attendanceFeatureEnabled.value
                    ? '功能页和快捷操作显示统计'
                    : '隐藏统计入口',
                description: '关闭后不会删除已有名单和统计记录，只隐藏入口。',
                value: controller.attendanceFeatureEnabled.value,
                onChanged: controller.changeAttendanceFeatureEnabled,
              ),
              _SettingControlBlock(
                title: '课程详情打开方式',
                subtitle: '控制课表中点击课程后的展示形式',
                child: FUISegmentedControl<CourseDetailPresentation>(
                  value: controller.courseDetailPresentation.value,
                  items: const [
                    FUISegmentedItem(
                      value: CourseDetailPresentation.page,
                      label: '页面',
                      icon: FUIIcons.list,
                    ),
                    FUISegmentedItem(
                      value: CourseDetailPresentation.sheet,
                      label: '抽屉',
                      icon: FUIIcons.chevronDown,
                    ),
                  ],
                  onChanged: controller.changeCourseDetailPresentation,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: FUITokens.gap16),
        FUISection(
          title: '更新',
          children: [
            FUITile(
              icon: FUIIcons.update,
              title: '检查更新',
              subtitle: '从 GitHub Release 检查最新 APK',
              onTap: () => GithubUpdatePrompt.checkNow(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _DebugSettingsPage extends StatelessWidget {
  const _DebugSettingsPage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final showDiagnostics = kDebugMode || controller.developerModeEnabled.value;
    return _SettingsSubPage(
      title: '调试诊断',
      subtitle: '测试首页时间线和同步状态',
      children: [
        Obx(
          () => FUISection(
            title: '时间线调试',
            children: [
              FUITile(
                icon: FUIIcons.schedule,
                title: '客户端时间',
                subtitle: _formatDebugTime(
                  controller.debugClientTimeOverride.value,
                ),
                onTap: () => _pickDebugTime(context, controller),
              ),
              FUITile(
                icon: FUIIcons.close,
                title: '恢复真实时间',
                subtitle: controller.debugClientTimeOverride.value == null
                    ? '当前正在使用系统时间'
                    : '清除用于测试首页时间线的客户端时间',
                enabled: controller.debugClientTimeOverride.value != null,
                onTap: controller.clearDebugClientTime,
              ),
            ],
          ),
        ),
        const SizedBox(height: FUITokens.gap16),
        if (kDebugMode && controller.supportsScheduledSync)
          FUISection(
            title: '同步调试',
            children: [
              FUITile(
                icon: FUIIcons.bug,
                title: '立即同步小组件',
                subtitle: '在前台执行一次完整同步并显示结果',
                onTap: () => _runWidgetSyncNow(context, controller),
              ),
              FUITile(
                icon: FUIIcons.schedule,
                title: '25 秒后同步',
                subtitle: '额外安排一次后台任务，不影响每天 7 点的日程',
                onTap: () => _scheduleSoon(context, controller),
              ),
              FUITile(
                icon: FUIIcons.info,
                title: '小组件同步诊断',
                subtitle: '查看计划任务、同步结果和刷新错误',
                onTap: () => _showWidgetDiagnostics(context, controller),
              ),
            ],
          ),
        if (kDebugMode && controller.supportsScheduledSync)
          const SizedBox(height: FUITokens.gap16),
        if (showDiagnostics) _DiagnosticLogsSection(controller: controller),
      ],
    );
  }

  static String _formatDebugTime(DateTime? value) {
    if (value == null) {
      return '使用系统时间';
    }
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')} '
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  static Future<void> _pickDebugTime(
    BuildContext context,
    SettingsController controller,
  ) async {
    final initial = controller.effectiveClientTime;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 2),
      lastDate: DateTime(initial.year + 2),
    );
    if (date == null || !context.mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) {
      return;
    }
    await controller.setDebugClientTime(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  static Future<void> _scheduleSoon(
    BuildContext context,
    SettingsController controller,
  ) async {
    try {
      await controller.scheduleMorningSyncSoonDebug();
    } catch (e) {
      if (!context.mounted) return;
      await SharedDialog.showConfirmDialog(
        context,
        title: '安排测试同步失败',
        content: e.toString().split('\n').first,
        confirmText: '关闭',
        cancelText: '',
        variant: SharedDialogVariant.danger,
      );
      return;
    }
    if (!context.mounted) return;
    await SharedDialog.showConfirmDialog(
      context,
      title: '已安排测试同步',
      content: '已额外登记 25 秒后执行的小组件后台同步，正式的每日任务保持不变。执行结果可在“小组件同步诊断”里查看。',
      confirmText: '知道了',
      cancelText: '',
      variant: SharedDialogVariant.success,
    );
  }

  static Future<void> _runWidgetSyncNow(
    BuildContext context,
    SettingsController controller,
  ) async {
    try {
      final success = await controller.runMorningSyncDebug();
      if (!context.mounted) return;
      await SharedDialog.showConfirmDialog(
        context,
        title: success ? '小组件同步成功' : '小组件同步未完成',
        content: success ? '课表数据和桌面小组件已刷新。' : '已保留现有缓存，请在“小组件同步诊断”中查看失败原因。',
        confirmText: '知道了',
        cancelText: '',
        variant: success
            ? SharedDialogVariant.success
            : SharedDialogVariant.warning,
      );
    } catch (e) {
      if (!context.mounted) return;
      await SharedDialog.showConfirmDialog(
        context,
        title: '小组件同步失败',
        content: e.toString().split('\n').first,
        confirmText: '关闭',
        cancelText: '',
        variant: SharedDialogVariant.danger,
      );
    }
  }

  static Future<void> _showWidgetDiagnostics(
    BuildContext context,
    SettingsController controller,
  ) {
    return SharedDialog.showConfirmDialog(
      context,
      title: '小组件同步诊断',
      content: controller.widgetSyncDiagnosticText(),
      confirmText: '关闭',
      cancelText: '',
      variant: SharedDialogVariant.info,
    );
  }
}

class _DiagnosticLogsSection extends StatelessWidget {
  const _DiagnosticLogsSection({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FUISection(
          title: '诊断日志',
          children: [
            FUITile(
              icon: FUIIcons.bug,
              title: '日志文件路径',
              subtitle: controller.diagnosticLogPath(),
              showChevron: false,
              minHeight: 60,
            ),
            FUITile(
              icon: FUIIcons.copy,
              title: '导出数据库文件',
              subtitle: '复制 SQLite 数据库到诊断导出目录，并复制目录路径',
              minHeight: 60,
              onTap: () => _exportDatabase(context, controller),
            ),
            FUITile(
              icon: FUIIcons.copy,
              title: '导出日志文件',
              subtitle: '复制当前日志文件到诊断导出目录，并复制文件路径',
              minHeight: 60,
              onTap: () => _exportLog(context, controller),
            ),
            FUITile(
              icon: FUIIcons.copy,
              title: '复制诊断摘要',
              subtitle: '包含版本、平台、最近登录/同步 trace 和小组件诊断字段',
              minHeight: 60,
              onTap: () async {
                try {
                  await controller.copyDiagnosticSummary();
                } catch (e) {
                  if (!context.mounted) return;
                  await SharedDialog.showConfirmDialog(
                    context,
                    title: '复制失败',
                    content: e.toString().split('\n').first,
                    confirmText: '关闭',
                    cancelText: '',
                    variant: SharedDialogVariant.danger,
                  );
                  return;
                }
                if (!context.mounted) return;
                await SharedDialog.showConfirmDialog(
                  context,
                  title: '已复制诊断摘要',
                  content: '诊断摘要已复制到剪贴板。摘要不包含密码、Cookie value 或完整课程信息。',
                  confirmText: '知道了',
                  cancelText: '',
                  variant: SharedDialogVariant.success,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: FUITokens.gap16),
      ],
    );
  }

  Future<void> _exportDatabase(
    BuildContext context,
    SettingsController controller,
  ) async {
    try {
      final path = await controller.exportDatabaseFiles();
      if (!context.mounted) return;
      await SharedDialog.showConfirmDialog(
        context,
        title: '数据库已导出',
        content: '导出目录已复制到剪贴板：\n$path',
        confirmText: '知道了',
        cancelText: '',
        variant: SharedDialogVariant.success,
      );
    } catch (e) {
      if (!context.mounted) return;
      await SharedDialog.showConfirmDialog(
        context,
        title: '导出数据库失败',
        content: e.toString().split('\n').first,
        confirmText: '关闭',
        cancelText: '',
        variant: SharedDialogVariant.danger,
      );
    }
  }

  Future<void> _exportLog(
    BuildContext context,
    SettingsController controller,
  ) async {
    try {
      final path = await controller.exportLogFile();
      if (!context.mounted) return;
      await SharedDialog.showConfirmDialog(
        context,
        title: '日志已导出',
        content: '文件路径已复制到剪贴板：\n$path',
        confirmText: '知道了',
        cancelText: '',
        variant: SharedDialogVariant.success,
      );
    } catch (e) {
      if (!context.mounted) return;
      await SharedDialog.showConfirmDialog(
        context,
        title: '导出日志失败',
        content: e.toString().split('\n').first,
        confirmText: '关闭',
        cancelText: '',
        variant: SharedDialogVariant.danger,
      );
    }
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '设置',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: FUITokens.gap4),
        Text(
          '管理账号、外观和同步提醒',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: FUIInsets.tile,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: FUITokens.iconMd, color: colors.textTertiary),
          const SizedBox(width: FUITokens.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: FUITokens.gap4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
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

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FUITile(
      icon: icon,
      title: title,
      subtitle: '$subtitle\n$description',
      trailing: Switch(value: value, onChanged: onChanged),
      showChevron: false,
      onTap: () => onChanged(!value),
    );
  }
}
