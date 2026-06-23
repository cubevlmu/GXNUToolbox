import 'package:class_tool/data/model/selected_course.dart';
import 'package:class_tool/pages/selected_courses/controller.dart';
import 'package:class_tool/ui/app_combo_box.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_empty_state.dart';
import 'package:class_tool/ui/app_icon_button.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_page.dart';
import 'package:class_tool/ui/app_surface.dart';
import 'package:class_tool/ui/app_tag.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:class_tool/widgets/app_bottom_sheet.dart';
import 'package:class_tool/widgets/simple_easy_refresher.dart';
import 'package:class_tool/widgets/skeleton_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectedCoursesPage extends StatefulWidget {
  const SelectedCoursesPage({super.key});

  @override
  State<SelectedCoursesPage> createState() => _SelectedCoursesPageState();
}

class _SelectedCoursesPageState extends State<SelectedCoursesPage> {
  late final SelectedCoursesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SelectedCoursesController(), permanent: false);
  }

  @override
  void dispose() {
    if (Get.isRegistered<SelectedCoursesController>()) {
      Get.delete<SelectedCoursesController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: GetBuilder<SelectedCoursesController>(
        id: 'selected-courses-content',
        builder: (controller) {
          final canInteract =
              !controller.isLoading && !controller.isLoadingMore;

          if (controller.isLoading && !controller.hasData) {
            return _SelectedCoursesSkeletonView(
              onBack: () => Navigator.of(context).maybePop(),
            );
          }

          if (controller.error.isNotEmpty && !controller.hasData) {
            return _FeedbackState(
              title: '已选课程加载失败',
              message: controller.error,
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: canInteract ? controller.refresh : null,
              selector: _SemesterSelector(
                controller: controller,
                enabled: canInteract,
              ),
            );
          }

          if (!controller.hasData) {
            return _FeedbackState(
              title: '暂无已选课程',
              message: '${controller.selectedSemester} 学期暂无已选课程',
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: canInteract ? controller.refresh : null,
              selector: _SemesterSelector(
                controller: controller,
                enabled: canInteract,
              ),
            );
          }

          return SimpleEasyRefresher(
            easyRefreshController: controller.easyRefreshController,
            onRefresh: controller.refresh,
            onLoad: controller.loadMore,
            autoRefreshOnStart: false,
            refreshEnabled: canInteract,
            loadEnabled: controller.hasMore && canInteract,
            childBuilder: (context, physics) => AppPage(
              physics: canInteract
                  ? physics
                  : const NeverScrollableScrollPhysics(),
              children: [
                _SelectedCoursesHeader(
                  onBack: () => Navigator.of(context).maybePop(),
                  onRefresh: canInteract ? controller.refresh : null,
                ),
                const SizedBox(height: AppTokens.gap16),
                _SemesterSelector(controller: controller, enabled: canInteract),
                const SizedBox(height: AppTokens.gap16),
                _OverviewCard(
                  loaded: controller.courses.length,
                  total: controller.total,
                  totalCredits: controller.totalCredits,
                  semesters: controller.semesters,
                ),
                const SizedBox(height: AppTokens.gap16),
                _ListHeader(
                  loaded: controller.courses.length,
                  total: controller.total,
                ),
                const SizedBox(height: AppTokens.gap8),
                for (final item in controller.courses) ...[
                  _SelectedCourseCard(
                    item: item,
                    onTap: () => _openDetailSheet(context, item),
                  ),
                  const SizedBox(height: AppTokens.gap12),
                ],
                if (controller.error.isNotEmpty) ...[
                  const SizedBox(height: AppTokens.gap4),
                  _InlineError(message: controller.error),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openDetailSheet(
    BuildContext context,
    SelectedCourseItem item,
  ) async {
    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      heightFactor: 0.62,
      child: _SelectedCourseDetailSheet(item: item),
    );
  }
}

class _SemesterSelector extends StatelessWidget {
  const _SemesterSelector({required this.controller, required this.enabled});

  final SelectedCoursesController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: AppComboBox<String>(
        label: '学年学期',
        value: controller.selectedSemester,
        items: controller.semesterOptions,
        itemLabelBuilder: (item) => '$item 学期',
        enabled: enabled,
        onChanged: (value) {
          if (value == null) return;
          controller.changeSemester(value);
        },
      ),
    );
  }
}

class _SelectedCoursesHeader extends StatelessWidget {
  const _SelectedCoursesHeader({required this.onBack, required this.onRefresh});

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
                '已选课程',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppTokens.gap4),
              Text(
                '查看当前账号已选课程和上课安排',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        AppIconButton(
          icon: AppIcons.refresh,
          tooltip: '刷新',
          variant: AppIconButtonVariant.ghost,
          onPressed: onRefresh,
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.loaded,
    required this.total,
    required this.totalCredits,
    required this.semesters,
  });

  final int loaded;
  final int total;
  final double totalCredits;
  final List<String> semesters;

  @override
  Widget build(BuildContext context) {
    final semesterText = semesters.isEmpty
        ? '未知学期'
        : semesters.length == 1
        ? '${semesters.first} 学期'
        : '${semesters.length} 个学期';

    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _IconBox(icon: AppIcons.book),
          const SizedBox(width: AppTokens.gap10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  semesterText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppTokens.gap4),
                Text(
                  loaded < total
                      ? '已加载 $loaded / $total 门 · ${_formatCredits(totalCredits)} 学分'
                      : '$total 门课程 · ${_formatCredits(totalCredits)} 学分',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AppTag(label: '$total 门', variant: AppTagVariant.primary),
        ],
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.loaded, required this.total});

  final int loaded;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            '课程列表',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          loaded < total ? '$loaded / $total 条' : '$total 条',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SelectedCourseCard extends StatelessWidget {
  const _SelectedCourseCard({required this.item, required this.onTap});

  final SelectedCourseItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppSurface(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.gap10),
              if (item.credits.isNotEmpty)
                AppTag(
                  label: '${item.credits} 学分',
                  variant: AppTagVariant.primary,
                ),
            ],
          ),
          const SizedBox(height: AppTokens.gap8),
          _MetaRow(icon: AppIcons.person, text: item.teacherLabel),
          if (item.scheduleText.isNotEmpty) ...[
            const SizedBox(height: AppTokens.gap6),
            _MetaRow(icon: AppIcons.calendar, text: item.scheduleText),
          ],
          const SizedBox(height: AppTokens.gap10),
          Wrap(
            spacing: AppTokens.gap8,
            runSpacing: AppTokens.gap6,
            children: [
              if (item.semester.isNotEmpty) AppTag(label: item.semester),
              if (item.courseCategory.isNotEmpty)
                AppTag(label: item.courseCategory),
              if (item.selectionType.isNotEmpty)
                AppTag(label: item.selectionType),
              if (item.selectionMethod.isNotEmpty)
                AppTag(label: item.selectionMethod),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppTokens.iconSm, color: context.colors.textTertiary),
        const SizedBox(width: AppTokens.gap6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedCourseDetailSheet extends StatelessWidget {
  const _SelectedCourseDetailSheet({required this.item});

  final SelectedCourseItem item;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        Text(
          item.displayName,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppTokens.gap10),
        Wrap(
          spacing: AppTokens.gap8,
          runSpacing: AppTokens.gap8,
          children: [
            if (item.credits.isNotEmpty)
              AppTag(
                label: '${item.credits} 学分',
                variant: AppTagVariant.primary,
              ),
            if (item.semester.isNotEmpty) AppTag(label: item.semester),
            if (item.courseCategory.isNotEmpty)
              AppTag(label: item.courseCategory),
            if (item.selectionType.isNotEmpty)
              AppTag(label: item.selectionType),
            if (item.selectionMethod.isNotEmpty)
              AppTag(label: item.selectionMethod),
          ],
        ),
        const SizedBox(height: AppTokens.gap16),
        _DetailSection(
          title: '上课安排',
          children: [
            _DetailRow(label: '教师', value: item.teacherLabel),
            _DetailRow(label: '时间地点', value: item.scheduleText),
            _DetailRow(label: '教学班', value: item.teachingClassName),
            _DetailRow(label: '教学班号', value: item.teachingClassCode),
            _DetailRow(label: '教学班备注', value: item.classRemark),
          ],
        ),
        const SizedBox(height: AppTokens.gap12),
        _DetailSection(
          title: '课程信息',
          children: [
            _DetailRow(label: '课程编号', value: item.courseCode),
            _DetailRow(label: '课程 ID', value: item.courseId),
            _DetailRow(label: '课程性质', value: item.courseNature),
            _DetailRow(label: '课程类别', value: item.courseCategory),
            _DetailRow(label: '课程类型', value: item.courseType),
            _DetailRow(label: '课程归属', value: item.courseGroup),
            _DetailRow(label: '授课方式', value: item.teachingMethod),
          ],
        ),
        const SizedBox(height: AppTokens.gap12),
        _DetailSection(
          title: '学时',
          children: [
            _DetailRow(label: '总学时', value: item.totalHours),
            _DetailRow(label: '理论学时', value: item.theoryHours),
            _DetailRow(label: '实验学时', value: item.labHours),
            _DetailRow(label: '上机学时', value: item.computerHours),
            _DetailRow(label: '实践学时', value: item.practiceHours),
            _DetailRow(label: '其他学时', value: item.otherHours),
          ],
        ),
        if (item.courseIntro.isNotEmpty || item.courseRemark.isNotEmpty) ...[
          const SizedBox(height: AppTokens.gap12),
          _DetailSection(
            title: '说明',
            children: [
              _DetailRow(label: '课程简介', value: item.courseIntro),
              _DetailRow(label: '课程备注', value: item.courseRemark),
            ],
          ),
        ],
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppTokens.gap10),
          for (final child in children) child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.gap8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppTokens.gap10),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
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
    return AppSurface(
      padding: const EdgeInsets.all(12),
      backgroundColor: context.colors.dangerSoft,
      borderColor: context.colors.danger.withValues(alpha: 0.24),
      child: Row(
        children: [
          Icon(
            AppIcons.warning,
            size: AppTokens.iconMd,
            color: context.colors.danger,
          ),
          const SizedBox(width: AppTokens.gap8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.danger,
                fontWeight: FontWeight.w600,
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
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Icon(icon, size: AppTokens.iconMd, color: colors.primary),
    );
  }
}

class _SelectedCoursesSkeletonView extends StatelessWidget {
  const _SelectedCoursesSkeletonView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => AppPage(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _SelectedCoursesHeader(onBack: onBack, onRefresh: null),
          const SizedBox(height: AppTokens.gap16),
          SkeletonBar(
            decoration: palette.line(radius: AppTokens.radiusMd),
            widthFactor: 1,
            height: 70,
          ),
          const SizedBox(height: AppTokens.gap16),
          for (var i = 0; i < 6; i++) ...[
            SkeletonBar(
              decoration: palette.line(radius: AppTokens.radiusLg),
              widthFactor: 1,
              height: 118,
            ),
            const SizedBox(height: AppTokens.gap12),
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
    this.selector,
  });

  final String title;
  final String message;
  final VoidCallback onBack;
  final VoidCallback? onRefresh;
  final Widget? selector;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        _SelectedCoursesHeader(onBack: onBack, onRefresh: onRefresh),
        const SizedBox(height: AppTokens.gap16),
        if (selector != null) ...[
          selector!,
          const SizedBox(height: AppTokens.gap16),
        ],
        AppSurface(
          child: SizedBox(
            height: 320,
            child: AppEmptyState(
              title: title,
              message: message,
              icon: AppIcons.book,
              actionLabel: onRefresh == null ? null : '重试',
              onAction: onRefresh,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatCredits(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}
