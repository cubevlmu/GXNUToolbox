import 'package:class_tool/data/model/course_note.dart';
import 'package:class_tool/data/repo/course_note_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/pages/classes/controller.dart';
import 'package:class_tool/pages/course_notes/view.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:fui/app_button.dart';
import 'package:fui/app_context.dart';
import 'package:fui/app_icon_button.dart';
import 'package:fui/app_icons.dart';
import 'package:fui/app_page.dart';
import 'package:fui/app_surface.dart';
import 'package:fui/app_tag.dart';
import 'package:fui/app_tokens.dart';
import 'package:fui/fui_navigation.dart';
import 'package:fui/fui_page_head.dart';
import 'package:class_tool/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
