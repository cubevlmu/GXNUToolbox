import 'package:class_tool/data/model/class_table_course.dart';
import 'package:class_tool/pages/classes/controller.dart';
import 'package:class_tool/pages/classes/widgets/schedule_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ClassTableCourse _makeCourse({
  required String id,
  required String courseCode,
  required String teachingClassId,
  required String name,
  required int weekday,
  required int section,
  String teacher = '张老师',
  String classroom = 'A101',
  String weekRange = '1-16周',
}) {
  return ClassTableCourse(
    id: id,
    teachingClassId: teachingClassId,
    scheduleId: 'pk_$id',
    courseName: name,
    teachingClassName: '',
    teacherName: teacher,
    classroomName: classroom,
    campusId: '3',
    campusName: '雁山',
    weekday: weekday,
    section: section,
    weekRangeText: weekRange,
    weekListText: '',
    weekTypeText: '',
    sourceTypeText: '',
    courseCode: courseCode,
    teachingClassCode: '',
    courseNature: '',
    creditText: '',
    totalHoursText: '',
    examType: '',
    buildingName: '',
    classRangeText: '',
    selectedCount: 0,
    classCountText: '',
    hourTypeText: '',
  );
}

void main() {
  test(
    'merges same courseCode across multiple sections even when overlapping or split with different weekRangeText',
    () {
      final rawCourses = <ClassTableCourse>[
        _makeCourse(
          id: '1',
          courseCode: 'CS101',
          teachingClassId: 'jxb_a1',
          name: '操作系统',
          weekday: 1,
          section: 3,
          weekRange: '1-16周',
        ),
        _makeCourse(
          id: '2',
          courseCode: 'MATH201',
          teachingClassId: 'jxb_b1',
          name: '概率论',
          weekday: 1,
          section: 3,
          classroom: 'B202',
        ),
        _makeCourse(
          id: '3',
          courseCode: 'CS101',
          teachingClassId: 'jxb_a2',
          name: '操作系统',
          weekday: 1,
          section: 4,
          weekRange: '',
        ),
        _makeCourse(
          id: '4',
          courseCode: 'MATH201',
          teachingClassId: 'jxb_b2',
          name: '概率论',
          weekday: 1,
          section: 4,
          classroom: 'B202',
        ),
        _makeCourse(
          id: '5',
          courseCode: 'CS101',
          teachingClassId: 'jxb_a3',
          name: '操作系统',
          weekday: 1,
          section: 5,
          weekRange: '1-16',
        ),
        _makeCourse(
          id: '6',
          courseCode: 'MATH201',
          teachingClassId: 'jxb_b3',
          name: '概率论',
          weekday: 1,
          section: 5,
          classroom: 'B202',
        ),
      ];

      final blocks = ClassesController.buildCourseBlocks(rawCourses);
      expect(blocks.length, 2);

      expect(blocks[0].title, '操作系统');
      expect(blocks[0].startSection, 3);
      expect(blocks[0].sectionSpan, 3);

      expect(blocks[1].title, '概率论');
      expect(blocks[1].startSection, 3);
      expect(blocks[1].sectionSpan, 3);
    },
  );

  test(
    'groups overlapping courses into full-width conflict clusters and keeps non-overlapping slots single',
    () {
      const blocks = <CourseBlock>[
        CourseBlock(
          dayIndex: 0,
          startSection: 1,
          sectionSpan: 2,
          title: '早课',
          teacher: '王老师',
          classroom: 'C101',
          weeks: '1-16周',
          color: Color(0xFFDAF3E4),
        ),
        CourseBlock(
          dayIndex: 0,
          startSection: 3,
          sectionSpan: 3,
          title: '操作系统',
          teacher: '张老师',
          classroom: 'A101',
          weeks: '1-16周',
          color: Color(0xFFE8F5D4),
        ),
        CourseBlock(
          dayIndex: 0,
          startSection: 3,
          sectionSpan: 3,
          title: '概率论',
          teacher: '李老师',
          classroom: 'B202',
          weeks: '1-16周',
          color: Color(0xFFF8E5C0),
        ),
      ];

      final clusters = computeCourseSlotClusters(blocks);
      expect(clusters.length, 2);

      expect(clusters[0].hasConflict, isFalse);
      expect(clusters[0].primaryCourse.title, '早课');
      expect(clusters[0].startSection, 1);
      expect(clusters[0].sectionSpan, 2);

      expect(clusters[1].hasConflict, isTrue);
      expect(clusters[1].courses.length, 2);
      expect(clusters[1].startSection, 3);
      expect(clusters[1].sectionSpan, 3);
    },
  );
}
