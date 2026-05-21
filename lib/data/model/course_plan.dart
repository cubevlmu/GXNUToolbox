/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/foundation.dart';

@immutable
class CoursePlanItem {
  const CoursePlanItem({
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
  });

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

  bool get isCompleted => !['待修读', '修读中'].contains(scoreText);

  factory CoursePlanItem.fromJson(Map<String, dynamic> json) {
    return CoursePlanItem(
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
    );
  }

  Map<String, dynamic> toJson() => {
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
  };
}

@immutable
class CoursePlanGroup {
  const CoursePlanGroup({
    required this.name,
    required this.items,
  });

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
  const CoursePlanSection({
    required this.groups,
  });

  final List<CoursePlanGroup> groups;

  factory CoursePlanSection.fromJson(Map<String, dynamic> json) {
    final list = _asList(json['wdList']);
    return CoursePlanSection(
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
      sections: data
          .map((e) => CoursePlanSection.fromJson(_asMap(e)))
          .toList(growable: false),
    );
  }
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
