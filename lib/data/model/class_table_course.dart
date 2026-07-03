/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/foundation.dart';

@immutable
class ClassTableCourseResponse {
  const ClassTableCourseResponse({
    required this.ret,
    required this.msg,
    required this.data,
  });

  final int ret;
  final String msg;
  final ClassTableCourseData data;

  factory ClassTableCourseResponse.fromJson(Map<String, dynamic> json) {
    return ClassTableCourseResponse(
      ret: _asInt(json['ret']),
      msg: json['msg']?.toString() ?? '',
      data: ClassTableCourseData.fromJson(_asMap(json['data'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {'ret': ret, 'msg': msg, 'data': data.toJson()};
  }
}

@immutable
class ClassTableCourseData {
  const ClassTableCourseData({required this.courses});

  final List<ClassTableCourse> courses;

  factory ClassTableCourseData.fromJson(Map<String, dynamic> json) {
    return ClassTableCourseData(
      courses: _asList(json['kckbData'])
          .map((item) => ClassTableCourse.fromJson(_asMap(item)))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {'kckbData': courses.map((item) => item.toJson()).toList()};
  }
}

@immutable
class ClassTableCourse {
  const ClassTableCourse({
    required this.id,
    required this.teachingClassId,
    required this.scheduleId,
    required this.courseName,
    required this.teachingClassName,
    required this.teacherName,
    required this.classroomName,
    required this.campusId,
    required this.campusName,
    required this.weekday,
    required this.section,
    required this.weekRangeText,
    required this.weekListText,
    required this.weekTypeText,
    required this.sourceTypeText,
    required this.courseCode,
    required this.teachingClassCode,
    required this.courseNature,
    required this.creditText,
    required this.totalHoursText,
    required this.examType,
    required this.buildingName,
    required this.classRangeText,
    required this.selectedCount,
    required this.classCountText,
    required this.hourTypeText,
  });

  final String id;
  final String teachingClassId;
  final String scheduleId;
  final String courseName;
  final String teachingClassName;
  final String teacherName;
  final String classroomName;
  final String campusId;
  final String campusName;
  final int weekday;
  final int section;
  final String weekRangeText;
  final String weekListText;
  final String weekTypeText;
  final String sourceTypeText;

  final String courseCode;
  final String teachingClassCode;
  final String courseNature;
  final String creditText;
  final String totalHoursText;
  final String examType;
  final String buildingName;
  final String classRangeText;
  final int selectedCount;
  final String classCountText;
  final String hourTypeText;

  bool get isOddWeekOnly => weekTypeText == '1';
  bool get isEvenWeekOnly => weekTypeText == '2';

  factory ClassTableCourse.fromJson(Map<String, dynamic> json) {
    return ClassTableCourse(
      id: json['id']?.toString() ?? '',
      teachingClassId: json['jxbid']?.toString() ?? '',
      scheduleId: json['pkid']?.toString() ?? '',
      courseName: json['kcmc']?.toString() ?? '',
      teachingClassName: json['jxbmc']?.toString() ?? '',
      teacherName: json['tmc']?.toString() ?? '',
      classroomName: json['croommc']?.toString() ?? '',
      campusId: json['xqid']?.toString() ?? '',
      campusName: json['xqmc']?.toString() ?? '',
      weekday: _asInt(json['xingqi']),
      section: _asInt(json['djc']),
      weekRangeText: json['zc']?.toString() ?? '',
      weekListText: json['zcstr']?.toString() ?? '',
      weekTypeText: json['zctype']?.toString() ?? '',
      sourceTypeText: json['source']?.toString() ?? '',
      courseCode: json['kcbh']?.toString() ?? '',
      teachingClassCode: json['jxbbh']?.toString() ?? '',
      courseNature: json['kcxz']?.toString() ?? '',
      creditText: json['xf']?.toString() ?? '',
      totalHoursText: json['zongxs']?.toString() ?? '',
      examType: json['ksxs']?.toString() ?? '',
      buildingName: json['jxlmc']?.toString() ?? '',
      classRangeText: json['jxbzc']?.toString() ?? '',
      selectedCount: _asInt(json['xkrs']),
      classCountText: json['bjrs']?.toString() ?? '',
      hourTypeText: json['xslx']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jxbid': teachingClassId,
      'pkid': scheduleId,
      'kcmc': courseName,
      'jxbmc': teachingClassName,
      'tmc': teacherName,
      'croommc': classroomName,
      'xqid': campusId,
      'xqmc': campusName,
      'xingqi': weekday,
      'djc': section,
      'zc': weekRangeText,
      'zcstr': weekListText,
      'zctype': weekTypeText,
      'source': sourceTypeText,
      'kcbh': courseCode,
      'jxbbh': teachingClassCode,
      'kcxz': courseNature,
      'xf': creditText,
      'zongxs': totalHoursText,
      'ksxs': examType,
      'jxlmc': buildingName,
      'jxbzc': classRangeText,
      'xkrs': selectedCount,
      'bjrs': classCountText,
      'xslx': hourTypeText,
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
