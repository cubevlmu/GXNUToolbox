import 'package:class_tool/data/model/course_note.dart';
import 'package:class_tool/data/repo/course_note_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/pages/classes/controller.dart';
import 'package:class_tool/pages/course_notes/view.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:fin_ui/app_button.dart';
import 'package:fin_ui/app_context.dart';
import 'package:fin_ui/app_icon_button.dart';
import 'package:fin_ui/app_icons.dart';
import 'package:fin_ui/app_page.dart';
import 'package:fin_ui/app_surface.dart';
import 'package:fin_ui/app_tag.dart';
import 'package:fin_ui/app_tokens.dart';
import 'package:fin_ui/fui_navigation.dart';
import 'package:fin_ui/fui_page_head.dart';
import 'package:class_tool/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showConflictCoursesSheet({
  required BuildContext context,
  required List<CourseBlock> courses,
  required String weekdayLabel,
}) {
  return showAppBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    child: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '同时段冲突课程 (${courses.length}门)',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            FUIIconButton(
              icon: FUIIcons.close,
              tooltip: '关闭',
              variant: FUIIconButtonVariant.ghost,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
        const SizedBox(height: FUITokens.gap12),
        for (var i = 0; i < courses.length; i++) ...[
          _ConflictCourseOptionCard(
            course: courses[i],
            onTap: () {
              final navigator = Navigator.of(context);
              final rootContext = navigator.context;
              navigator.pop();
              showCourseDetailSheet(
                context: rootContext,
                course: courses[i],
                weekdayLabel: weekdayLabel,
              );
            },
          ),
          if (i != courses.length - 1) const SizedBox(height: FUITokens.gap10),
        ],
      ],
    ),
  );
}

class _ConflictCourseOptionCard extends StatelessWidget {
  const _ConflictCourseOptionCard({required this.course, required this.onTap});

  final CourseBlock course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final endSection = course.startSection + course.sectionSpan - 1;
    final sectionLabel = course.sectionSpan <= 1
        ? '第${course.startSection}节'
        : '第${course.startSection}-$endSection节';
    final metaParts = <String>[
      if (course.classroom.isNotEmpty) course.classroom,
      if (course.teacher.isNotEmpty) course.teacher,
      if (course.weeks.isNotEmpty) course.weeks,
    ];

    return FUISurface(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 36,
            decoration: BoxDecoration(
              color: course.color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: FUITokens.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (metaParts.isNotEmpty) ...[
                  const SizedBox(height: FUITokens.gap4),
                  Text(
                    metaParts.join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: FUITokens.gap8),
          FUITag(label: sectionLabel, variant: FUITagVariant.primary),
        ],
      ),
    );
  }
}

Future<void> showCourseDetailSheet({
  required BuildContext context,
  required CourseBlock course,
  required String weekdayLabel,
}) {
  final noteCourse = _courseDraft(course);
  final detailItems = _detailItems(course, weekdayLabel);
  final settings = Get.find<SettingsController>();
  final todoEnabled = settings.todoFeatureEnabled.value;
  if (settings.courseDetailPresentation.value ==
      CourseDetailPresentation.sheet) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      child: _CourseDetailSheetContent(
        course: noteCourse,
        detailItems: detailItems,
        showTodoAction: todoEnabled,
      ),
    );
  }
  return FuiNavigation.openDetail(
    context,
    title: noteCourse.courseName,
    builder: (_) => todoEnabled
        ? CourseNotesPage(course: noteCourse, detailItems: detailItems)
        : _CourseDetailOnlyPage(course: noteCourse, detailItems: detailItems),
  );
}

class _CourseDetailSheetContent extends StatelessWidget {
  const _CourseDetailSheetContent({
    required this.course,
    required this.detailItems,
    required this.showTodoAction,
  });

  final CourseNoteCourseDraft course;
  final List<CourseNoteDetailItem> detailItems;
  final bool showTodoAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                course.courseName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            FUIIconButton(
              icon: FUIIcons.close,
              tooltip: '关闭',
              variant: FUIIconButtonVariant.ghost,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
        const SizedBox(height: FUITokens.gap14),
        _CourseDetailCard(
          course: course,
          detailItems: detailItems,
          showTitle: false,
        ),
        if (showTodoAction) ...[
          const SizedBox(height: FUITokens.gap14),
          FUIButton(
            label: '打开待办任务',
            icon: FUIIcons.book,
            fullWidth: true,
            onPressed: () {
              Navigator.of(context).pop();
              FuiNavigation.openDetail(
                context,
                title: course.courseName,
                builder: (_) =>
                    CourseNotesPage(course: course, detailItems: detailItems),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _CourseDetailOnlyPage extends StatelessWidget {
  const _CourseDetailOnlyPage({
    required this.course,
    required this.detailItems,
  });

  final CourseNoteCourseDraft course;
  final List<CourseNoteDetailItem> detailItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FUIPage(
        children: [
          FuiPageHead(title: course.courseName),
          const SizedBox(height: FUITokens.gap14),
          _CourseDetailCard(
            course: course,
            detailItems: detailItems,
            showTitle: false,
          ),
        ],
      ),
    );
  }
}

class _CourseDetailCard extends StatelessWidget {
  const _CourseDetailCard({
    required this.course,
    required this.detailItems,
    this.showTitle = true,
  });

  final CourseNoteCourseDraft course;
  final List<CourseNoteDetailItem> detailItems;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final hasTags =
        course.semester.isNotEmpty ||
        course.teacherName.isNotEmpty ||
        course.classroom.isNotEmpty;

    return FUISurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Text(
              course.courseName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: FUITokens.gap8),
          ],
          if (hasTags) ...[
            Wrap(
              spacing: FUITokens.gap8,
              runSpacing: FUITokens.gap8,
              children: [
                if (course.semester.isNotEmpty) FUITag(label: course.semester),
                if (course.teacherName.isNotEmpty)
                  FUITag(label: course.teacherName),
                if (course.classroom.isNotEmpty)
                  FUITag(label: course.classroom),
              ],
            ),
            const SizedBox(height: FUITokens.gap12),
            Divider(height: 1, color: context.colors.border),
            const SizedBox(height: FUITokens.gap10),
          ],
          for (final item in detailItems)
            if (item.value.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: FUITokens.gap8),
                child: Row(
                  children: [
                    Icon(item.icon, size: 16, color: context.colors.primary),
                    const SizedBox(width: FUITokens.gap8),
                    SizedBox(
                      width: 58,
                      child: Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.colors.textTertiary,
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
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
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

CourseNoteCourseDraft _courseDraft(CourseBlock course) {
  final semester = Get.find<UserRepo>().selectedSemester;
  return CourseNoteRepo.courseDraftFromParts(
    semester: semester,
    courseName: course.title,
    teacherName: course.teacher,
    classroom: course.classroom,
  );
}

List<CourseNoteDetailItem> _detailItems(
  CourseBlock course,
  String weekdayLabel,
) {
  final campus = course.classroom.contains('雁山') ? '雁山' : '育才';
  return [
    const CourseNoteDetailItem(
      icon: FUIIcons.credit,
      label: '学分',
      value: '3.0',
    ),
    CourseNoteDetailItem(
      icon: FUIIcons.calendar,
      label: '周次',
      value: course.weeks,
    ),
    CourseNoteDetailItem(
      icon: FUIIcons.schedule,
      label: '星期',
      value: weekdayLabel,
    ),
    CourseNoteDetailItem(
      icon: FUIIcons.schedule,
      label: '节次',
      value: _buildSectionText(course.startSection, course.sectionSpan),
    ),
    CourseNoteDetailItem(
      icon: FUIIcons.person,
      label: '教师',
      value: course.teacher,
    ),
    CourseNoteDetailItem(
      icon: FUIIcons.location,
      label: '地点',
      value: course.classroom,
    ),
    CourseNoteDetailItem(icon: FUIIcons.building, label: '校区', value: campus),
  ];
}

String _buildSectionText(int startSection, int sectionSpan) {
  const chineseNumbers = [
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
    '七',
    '八',
    '九',
    '十',
    '十一',
    '十二',
  ];

  final sections = List<String>.generate(sectionSpan, (index) {
    final section = startSection + index;
    if (section < 1 || section > chineseNumbers.length) {
      return '第$section节';
    }
    return '第${chineseNumbers[section - 1]}节';
  });
  return sections.join('、');
}
