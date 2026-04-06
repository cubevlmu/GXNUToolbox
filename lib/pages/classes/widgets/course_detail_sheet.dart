import 'package:class_tool/pages/classes/controller.dart';
import 'package:class_tool/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

Future<void> showCourseDetailSheet({
  required BuildContext context,
  required CourseBlock course,
  required String weekdayLabel,
}) {
  return showAppBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    heightFactor: 0.625,
    child: CourseDetailSheetContent(course: course, weekdayLabel: weekdayLabel),
  );
}

class CourseDetailSheetContent extends StatelessWidget {
  const CourseDetailSheetContent({
    super.key,
    required this.course,
    required this.weekdayLabel,
  });

  final CourseBlock course;
  final String weekdayLabel;

  @override
  Widget build(BuildContext context) {
    final campus = course.classroom.contains('雁山') ? '雁山' : '育才';
    final sectionText = _buildSectionText(
      course.startSection,
      course.sectionSpan,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          course.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        _DetailRow(icon: Icons.stars_rounded, label: '学分', value: '3.0'),
        _DetailRow(
          icon: Icons.calendar_month_rounded,
          label: '周次',
          value: course.weeks,
        ),
        _DetailRow(icon: Icons.today_rounded, label: '星期', value: weekdayLabel),
        _DetailRow(
          icon: Icons.schedule_rounded,
          label: '节次',
          value: sectionText,
        ),
        _DetailRow(
          icon: Icons.person_rounded,
          label: '教师',
          value: course.teacher,
        ),
        _DetailRow(
          icon: Icons.place_rounded,
          label: '地点',
          value: course.classroom,
          isLink: true,
        ),
        _DetailRow(
          icon: Icons.location_city_rounded,
          label: '开课校区',
          value: campus,
        ),
      ],
    );
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
      return '第${chineseNumbers[section - 1]}节';
    });
    return sections.join('、');
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLink = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLink;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 76,
            child: Text(
              '$label：',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isLink ? colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
