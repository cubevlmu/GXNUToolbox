import 'package:flutter/foundation.dart';

@immutable
class SelectedCourseQueryResponse {
  const SelectedCourseQueryResponse({
    required this.ret,
    required this.msg,
    required this.page,
    required this.rows,
    required this.total,
    required this.totalPages,
    required this.results,
  });

  factory SelectedCourseQueryResponse.fromJson(Map<String, dynamic> json) {
    return SelectedCourseQueryResponse(
      ret: _asInt(json['ret']),
      msg: json['msg']?.toString() ?? '',
      page: _asInt(json['page']),
      rows: _asInt(json['rows']),
      total: _asInt(json['total']),
      totalPages: _asInt(json['totalPages']),
      results: _asList(json['results'])
          .map((item) => SelectedCourseItem.fromJson(_asMap(item)))
          .toList(growable: false),
    );
  }

  final int ret;
  final String msg;
  final int page;
  final int rows;
  final int total;
  final int totalPages;
  final List<SelectedCourseItem> results;

  double get totalCredits {
    var total = 0.0;
    for (final item in results) {
      total += item.creditValue;
    }
    return total;
  }

  List<String> get semesters {
    final values = <String>[];
    for (final item in results) {
      if (item.semester.isNotEmpty && !values.contains(item.semester)) {
        values.add(item.semester);
      }
    }
    return List<String>.unmodifiable(values);
  }
}

@immutable
class SelectedCourseItem {
  const SelectedCourseItem({
    required this.id,
    required this.courseId,
    required this.semester,
    required this.courseCode,
    required this.courseName,
    required this.courseIntro,
    required this.courseRemark,
    required this.teachingClassName,
    required this.teachingClassCode,
    required this.totalHours,
    required this.theoryHours,
    required this.labHours,
    required this.computerHours,
    required this.practiceHours,
    required this.otherHours,
    required this.classRemark,
    required this.courseCategory,
    required this.courseNature,
    required this.courseType,
    required this.courseGroup,
    required this.teacher,
    required this.teachingMode,
    required this.scheduleText,
    required this.credits,
    required this.teachingMethod,
    required this.selectionMethod,
    required this.selectionType,
    required this.repeatFee,
  });

  factory SelectedCourseItem.fromJson(Map<String, dynamic> json) {
    return SelectedCourseItem(
      id: _asString(json['id']),
      courseId: _asString(json['kcid']),
      semester: _asString(json['xnxq']),
      courseCode: _asString(json['kcbh']),
      courseName: _asString(json['kcmc']),
      courseIntro: _asString(json['kcjj']),
      courseRemark: _asString(json['kcbz']),
      teachingClassName: _asString(json['jxbmc']),
      teachingClassCode: _asString(json['jxbbh']),
      totalHours: _asString(json['zxs']),
      theoryHours: _asString(json['llxs']),
      labHours: _asString(json['syxs']),
      computerHours: _asString(json['shangjxs']),
      practiceHours: _asString(json['shijianxs']),
      otherHours: _asString(json['qtxs']),
      classRemark: _asString(json['jxbzc']),
      courseCategory: _asString(json['kclb']),
      courseNature: _asString(json['kcxz']),
      courseType: _asString(json['kclx']),
      courseGroup: _asString(json['kcgs']),
      teacher: _asString(json['rkjs']),
      teachingMode: _asString(json['jxms']),
      scheduleText: _asString(json['sksjdd']),
      credits: _asString(json['xf']),
      teachingMethod: _asString(json['skfs']),
      selectionMethod: _asString(json['xkfs']),
      selectionType: _asString(json['xklx']),
      repeatFee: _asString(json['cxfy']),
    );
  }

  final String id;
  final String courseId;
  final String semester;
  final String courseCode;
  final String courseName;
  final String courseIntro;
  final String courseRemark;
  final String teachingClassName;
  final String teachingClassCode;
  final String totalHours;
  final String theoryHours;
  final String labHours;
  final String computerHours;
  final String practiceHours;
  final String otherHours;
  final String classRemark;
  final String courseCategory;
  final String courseNature;
  final String courseType;
  final String courseGroup;
  final String teacher;
  final String teachingMode;
  final String scheduleText;
  final String credits;
  final String teachingMethod;
  final String selectionMethod;
  final String selectionType;
  final String repeatFee;

  double get creditValue => double.tryParse(credits) ?? 0;
  String get displayName => courseName.isEmpty ? '未命名课程' : courseName;
  String get teacherLabel => teacher.isEmpty ? '未安排教师' : teacher;
}

String _asString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text == '--' ? '' : text;
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return const <String, dynamic>{};
}

List<dynamic> _asList(Object? value) {
  if (value is List) {
    return value;
  }
  return const <dynamic>[];
}
