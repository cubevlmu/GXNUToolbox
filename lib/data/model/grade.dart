/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;

@immutable
class GradeFilterOption {
  const GradeFilterOption({
    required this.value,
    required this.label,
    this.selected = false,
  });

  final String value;
  final String label;
  final bool selected;
}

@immutable
class GradeFilterOptions {
  const GradeFilterOptions({
    required this.startSemesters,
    required this.endSemesters,
    required this.passStatuses,
    required this.courseNatures,
    required this.makeupTypes,
    required this.sealOptions,
    required this.courseAttributions,
  });

  final List<GradeFilterOption> startSemesters;
  final List<GradeFilterOption> endSemesters;
  final List<GradeFilterOption> passStatuses;
  final List<GradeFilterOption> courseNatures;
  final List<GradeFilterOption> makeupTypes;
  final List<GradeFilterOption> sealOptions;
  final List<GradeFilterOption> courseAttributions;

  static const empty = GradeFilterOptions(
    startSemesters: <GradeFilterOption>[],
    endSemesters: <GradeFilterOption>[],
    passStatuses: passStatusOptions,
    courseNatures: <GradeFilterOption>[],
    makeupTypes: makeupTypeOptions,
    sealOptions: sealFilterOptions,
    courseAttributions: <GradeFilterOption>[],
  );

  static const passStatusOptions = <GradeFilterOption>[
    GradeFilterOption(value: '', label: '全部'),
    GradeFilterOption(value: '1', label: '是'),
    GradeFilterOption(value: '0', label: '否'),
  ];

  static const makeupTypeOptions = <GradeFilterOption>[
    GradeFilterOption(value: '', label: '全部'),
    GradeFilterOption(value: '0', label: '正考'),
    GradeFilterOption(value: '1', label: '补考'),
    GradeFilterOption(value: '2', label: '缓考'),
  ];

  static const sealFilterOptions = <GradeFilterOption>[
    GradeFilterOption(value: '1', label: '显示'),
    GradeFilterOption(value: '2', label: '不显示'),
  ];

  static const courseAttributionOptions = <GradeFilterOption>[
    GradeFilterOption(value: '', label: '全部'),
    GradeFilterOption(value: '2', label: '语言类'),
    GradeFilterOption(value: '3', label: '实验（实训）类'),
    GradeFilterOption(value: '4', label: '体育类'),
    GradeFilterOption(value: '5', label: '实践类'),
    GradeFilterOption(value: '6', label: '艺术类'),
    GradeFilterOption(value: '9', label: '其他类'),
  ];

  factory GradeFilterOptions.fromHtml(String html) {
    final document = html_parser.parse(html);
    return GradeFilterOptions(
      startSemesters: _selectOptions(
        document,
        '#startXnxq',
        name: 'startXnxq',
      ),
      endSemesters: _selectOptions(document, '#endXnxq', name: 'endXnxq'),
      passStatuses: passStatusOptions,
      courseNatures: _selectOptions(document, '#kcxz', name: 'kcxz'),
      makeupTypes: makeupTypeOptions,
      sealOptions: sealFilterOptions,
      courseAttributions: _selectOptions(
        document,
        '#kcgs',
        name: 'kcgs',
        fallback: courseAttributionOptions,
      ),
    );
  }
}

@immutable
class GradeRankResponse {
  const GradeRankResponse({
    required this.ret,
    required this.msg,
    required this.rawData,
    required this.rankText,
  });

  final int ret;
  final String msg;
  final String rawData;
  final String rankText;

  factory GradeRankResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data']?.toString() ?? '';
    return GradeRankResponse(
      ret: _asInt(json['ret']),
      msg: json['msg']?.toString() ?? '',
      rawData: rawData,
      rankText: _extractRankText(rawData),
    );
  }

  Map<String, dynamic> toJson() {
    return {'ret': ret, 'msg': msg, 'data': rawData, 'rankText': rankText};
  }
}

@immutable
class GradeQueryResponse {
  const GradeQueryResponse({
    required this.ret,
    required this.msg,
    required this.page,
    required this.rows,
    required this.total,
    required this.totalPages,
    required this.results,
  });

  final int ret;
  final String msg;
  final int page;
  final int rows;
  final int total;
  final int totalPages;
  final List<CourseGrade> results;

  factory GradeQueryResponse.fromJson(Map<String, dynamic> json) {
    return GradeQueryResponse(
      ret: _asInt(json['ret']),
      msg: json['msg']?.toString() ?? '',
      page: _asInt(json['page']),
      rows: _asInt(json['rows']),
      total: _asInt(json['total']),
      totalPages: _asInt(json['totalPages']),
      results: _asList(json['results'])
          .map((item) => CourseGrade.fromJson(_asMap(item)))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ret': ret,
      'msg': msg,
      'page': page,
      'rows': rows,
      'total': total,
      'totalPages': totalPages,
      'results': results.map((item) => item.toJson()).toList(),
    };
  }
}

@immutable
class CourseGrade {
  const CourseGrade({
    required this.id,
    required this.studentId,
    required this.semester,
    required this.retakeFlag,
    required this.gradeBreakdown,
    required this.creditText,
    required this.courseCode,
    required this.courseName,
    required this.courseNature,
    required this.gradeMode,
    required this.finalGrade,
    required this.earnedCredit,
    required this.gradePointText,
    required this.rank,
    required this.retakeGrade,
    required this.gradePoint,
    required this.specialGradeName,
    required this.studyNature,
    required this.examType,
    required this.courseId,
    required this.courseCategory,
    required this.isHandled,
    required this.specialGradeRemarkId,
    required this.makeupGrade,
    required this.rebuildGrade,
    required this.secondRetakeGrade,
    required this.courseOfferingUnitName,
  });

  final String id;
  final String studentId;
  final String semester;
  final String retakeFlag;
  final String gradeBreakdown;
  final String creditText;
  final String courseCode;
  final String courseName;
  final String courseNature;
  final String gradeMode;
  final String finalGrade;
  final double earnedCredit;
  final String gradePointText;
  final int rank;
  final String retakeGrade;
  final double gradePoint;
  final String specialGradeName;
  final String studyNature;
  final String examType;
  final String courseId;
  final String courseCategory;
  final String isHandled;
  final String specialGradeRemarkId;
  final String makeupGrade;
  final String rebuildGrade;
  final String secondRetakeGrade;
  final String courseOfferingUnitName;

  double get credit => double.tryParse(creditText) ?? earnedCredit;
  double get creditPoint => double.tryParse(gradePointText) ?? 0;
  int get score => int.tryParse(finalGrade) ?? 0;
  int get firstScore => int.tryParse(retakeGrade) ?? score;
  String get studyNatureLabel => _studyNatureLabel(studyNature);
  String get examTypeLabel => _examTypeLabel(examType);
  String get courseNatureLabel => _courseNatureLabel(courseNature);
  String get specialGradeLabel =>
      specialGradeName.isEmpty ? '正常' : specialGradeName;

  factory CourseGrade.fromJson(Map<String, dynamic> json) {
    return CourseGrade(
      id: json['id']?.toString() ?? '',
      studentId: json['xhid']?.toString() ?? '',
      semester: json['xnxq']?.toString() ?? '',
      retakeFlag: json['fxbz']?.toString() ?? '',
      gradeBreakdown: json['fxcj']?.toString() ?? '',
      creditText: json['xf']?.toString() ?? '',
      courseCode: json['kcbh']?.toString() ?? '',
      courseName: json['kcmc']?.toString() ?? '',
      courseNature: json['kcxz']?.toString() ?? '',
      gradeMode: json['cjfxms']?.toString() ?? '',
      finalGrade: json['zhcj']?.toString() ?? '',
      earnedCredit: _asDouble(json['hdxf']),
      gradePointText: json['xfjd']?.toString() ?? '',
      rank: _asInt(json['mingci']),
      retakeGrade: json['cxzkcj']?.toString() ?? '',
      gradePoint: _asDouble(json['jd']),
      specialGradeName: json['tscjzwmc']?.toString() ?? '',
      studyNature: json['xdxz']?.toString() ?? '',
      examType: json['ksxs']?.toString() ?? '',
      courseId: json['kcid']?.toString() ?? '',
      courseCategory: json['kclb']?.toString() ?? '',
      isHandled: json['sfbl']?.toString() ?? '',
      specialGradeRemarkId: json['tscjbzid']?.toString() ?? '',
      makeupGrade: json['bkcj']?.toString() ?? '',
      rebuildGrade: json['cxcj']?.toString() ?? '',
      secondRetakeGrade: json['glcj']?.toString() ?? '',
      courseOfferingUnitName: json['kkyxmc']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'xhid': studentId,
      'xnxq': semester,
      'fxbz': retakeFlag,
      'fxcj': gradeBreakdown,
      'xf': creditText,
      'kcbh': courseCode,
      'kcmc': courseName,
      'kcxz': courseNature,
      'cjfxms': gradeMode,
      'zhcj': finalGrade,
      'hdxf': earnedCredit,
      'xfjd': gradePointText,
      'mingci': rank,
      'cxzkcj': retakeGrade,
      'jd': gradePoint,
      'tscjzwmc': specialGradeName,
      'xdxz': studyNature,
      'ksxs': examType,
      'kcid': courseId,
      'kclb': courseCategory,
      'sfbl': isHandled,
      'tscjbzid': specialGradeRemarkId,
      'bkcj': makeupGrade,
      'cxcj': rebuildGrade,
      'glcj': secondRetakeGrade,
      'kkyxmc': courseOfferingUnitName,
    };
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) {
    return value;
  }
  return const [];
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

List<GradeFilterOption> _selectOptions(
  dynamic document,
  String selector, {
  String? name,
  List<GradeFilterOption> fallback = const <GradeFilterOption>[],
}) {
  final select =
      document.querySelector(selector) ??
      (name == null ? null : document.querySelector('select[name="$name"]'));
  if (select == null) {
    return fallback;
  }

  final result = <GradeFilterOption>[];
  for (final option in select.querySelectorAll('option')) {
    final item = GradeFilterOption(
      value: option.attributes['value']?.trim() ?? '',
      label: _normalizeOptionLabel(option.text),
      selected: option.attributes.containsKey('selected'),
    );
    if (item.value.isNotEmpty || item.label.isNotEmpty) {
      result.add(item);
    }
  }
  if (result.isEmpty) {
    return fallback;
  }
  return List<GradeFilterOption>.unmodifiable(result);
}

String _normalizeOptionLabel(String text) {
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _extractRankText(String raw) {
  final separatorIndex = raw.indexOf('-');
  if (separatorIndex < 0 || separatorIndex + 1 >= raw.length) {
    return raw.trim();
  }
  return raw.substring(separatorIndex + 1).trim();
}

String _studyNatureLabel(String value) {
  switch (value) {
    case '1':
      return '初修';
    case '2':
      return '重修';
    default:
      return value;
  }
}

String _examTypeLabel(String value) {
  switch (value) {
    case '1':
      return '考试';
    case '2':
      return '考查';
    default:
      return value;
  }
}

String _courseNatureLabel(String value) {
  switch (value) {
    case 'JX':
      return 'J教师教育选修';
    case 'SX':
      return 'S实践教学选修';
    case 'J':
      return 'J教师教育';
    case 'K':
      return 'K专业基础课程';
    case 'S':
      return 'S实践教学';
    case 'ZX':
      return 'Z专业拓展课程';
    case '130':
      return 'T通识教育';
    case 'Z':
      return 'Z专业核心课程';
    case '99':
      return '公共选修课';
    default:
      return value;
  }
}
