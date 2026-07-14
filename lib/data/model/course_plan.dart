/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/foundation.dart';

@immutable
class CoursePlanItem {
  const CoursePlanItem({
    required this.courseCode,
    required this.courseName,
    required this.credits,
    required this.studyNature,
    required this.isCreditEarned,
    required this.scoreText,
    required this.categoryLabel,
    required this.semester,
    required this.gradePoint,
    required this.platform,
    required this.college,
    required this.examType,
    required this.courseType,
    required this.specialStatus,
  });

  final String courseCode;
  final String courseName;
  final String credits;
  final String studyNature;
  final String isCreditEarned;
  final String scoreText;
  final String categoryLabel;
  final String semester;
  final double gradePoint;
  final String platform;
  final String college;
  final String examType;
  final String courseType;
  final String specialStatus;

  bool get isCompleted => isCreditEarned == '是';
  bool get isInProgress => scoreText == '修读中';
  String get displayResult {
    if (specialStatus.isNotEmpty && specialStatus != '正常') {
      return specialStatus;
    }
    return scoreText.isEmpty ? '待修读' : scoreText;
  }

  factory CoursePlanItem.fromJson(Map<String, dynamic> json) {
    return CoursePlanItem(
      courseCode: json['kcbh']?.toString() ?? '',
      courseName: json['kcmc']?.toString() ?? '',
      credits: json['xf']?.toString() ?? '',
      studyNature: json['xdxz']?.toString() ?? '',
      isCreditEarned: json['sfhdxf']?.toString() ?? '',
      scoreText: json['cjxx']?.toString() ?? '',
      categoryLabel: json['kclbmc']?.toString() ?? '',
      semester: json['xnxq']?.toString() ?? '',
      gradePoint: double.tryParse(json['jd']?.toString() ?? '') ?? 0,
      platform: json['kcxzmc']?.toString() ?? '',
      college: json['kkyxmc']?.toString() ?? '',
      examType: json['ksxsmc']?.toString() ?? '',
      courseType: json['kcsxmc']?.toString() ?? '',
      specialStatus: json['tscjbz']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'kcbh': courseCode,
    'kcmc': courseName,
    'xf': credits,
    'xdxz': studyNature,
    'sfhdxf': isCreditEarned,
    'cjxx': scoreText,
    'kclbmc': categoryLabel,
    'xnxq': semester,
    'jd': gradePoint,
    'kcxzmc': platform,
    'kkyxmc': college,
    'ksxsmc': examType,
    'kcsxmc': courseType,
    'tscjbz': specialStatus,
  };
}

@immutable
class CoursePlanGroup {
  const CoursePlanGroup({required this.name, required this.items});

  final String name;
  final List<CoursePlanItem> items;

  factory CoursePlanGroup.fromJson(Map<String, dynamic> json) {
    final list = _asList(json['wdList']);
    return CoursePlanGroup(
      name: json['wdmc']?.toString() ?? '',
      items: list
          .map((e) => CoursePlanItem.fromJson(_asMap(e)))
          .toList(growable: false),
    );
  }
}

@immutable
class CoursePlanSection {
  const CoursePlanSection({required this.name, required this.groups});

  final String name;
  final List<CoursePlanGroup> groups;

  factory CoursePlanSection.fromJson(
    Map<String, dynamic> json, {
    required int index,
  }) {
    final list = _asList(json['wdList']);
    return CoursePlanSection(
      name: _sectionName(json['wdmc']?.toString() ?? '', index),
      groups: list
          .map((e) => CoursePlanGroup.fromJson(_asMap(e)))
          .toList(growable: false),
    );
  }
}

@immutable
class CoursePlanResponse {
  const CoursePlanResponse({
    required this.ret,
    required this.msg,
    required this.sections,
  });

  final int ret;
  final String msg;
  final List<CoursePlanSection> sections;

  List<CoursePlanItem> get allItems =>
      sections.expand((s) => s.groups.expand((g) => g.items)).toList();

  int get completedCount => allItems.where((i) => i.isCompleted).length;
  int get totalCount => allItems.length;

  factory CoursePlanResponse.fromJson(Map<String, dynamic> json) {
    final data = _asList(json['data']);
    return CoursePlanResponse(
      ret: int.tryParse(json['ret']?.toString() ?? '') ?? 0,
      msg: json['msg']?.toString() ?? '',
      sections: <CoursePlanSection>[
        for (var index = 0; index < data.length; index++)
          CoursePlanSection.fromJson(_asMap(data[index]), index: index),
      ],
    );
  }
}

String _sectionName(String raw, int index) {
  if (raw.trim().isNotEmpty) return raw.trim();
  return index == 0 ? '培养方案内课程' : '计划外课程';
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
