/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/foundation.dart';

@immutable
class ClassTableMetaResponse {
  const ClassTableMetaResponse({
    required this.ret,
    required this.msg,
    required this.data,
  });

  final int ret;
  final String msg;
  final ClassTableMeta data;

  factory ClassTableMetaResponse.fromJson(Map<String, dynamic> json) {
    return ClassTableMetaResponse(
      ret: _asInt(json['ret']),
      msg: json['msg']?.toString() ?? '',
      data: ClassTableMeta.fromJson(_asMap(json['data'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {'ret': ret, 'msg': msg, 'data': data.toJson()};
  }
}

@immutable
class ClassTableMeta {
  const ClassTableMeta({
    required this.periodSettings,
    required this.weekRanges,
    required this.currentWeekText,
    required this.scheduleStructure,
  });

  final List<ClassPeriodSetting> periodSettings;
  final List<ClassWeekRange> weekRanges;
  final String currentWeekText;
  final ClassTableStructure scheduleStructure;

  int get currentWeek => int.tryParse(currentWeekText) ?? 0;

  factory ClassTableMeta.fromJson(Map<String, dynamic> json) {
    return ClassTableMeta(
      periodSettings: _asList(json['jcsjszList'])
          .map((item) => ClassPeriodSetting.fromJson(_asMap(item)))
          .toList(growable: false),
      weekRanges: _asList(json['zclist'])
          .map((item) => ClassWeekRange.fromJson(_asMap(item)))
          .toList(growable: false),
      currentWeekText: json['dqzc']?.toString() ?? '',
      scheduleStructure: ClassTableStructure.fromJson(_asMap(json['jsxq'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jcsjszList': periodSettings.map((item) => item.toJson()).toList(),
      'zclist': weekRanges.map((item) => item.toJson()).toList(),
      'dqzc': currentWeekText,
      'jsxq': scheduleStructure.toJson(),
    };
  }
}

@immutable
class ClassPeriodSetting {
  const ClassPeriodSetting({
    required this.startTime,
    required this.endTime,
    required this.sectionText,
    required this.sectionName,
  });

  final String startTime;
  final String endTime;
  final String sectionText;
  final String sectionName;

  int get section => int.tryParse(sectionText) ?? 0;
  String get timeRange => '$startTime-$endTime';

  factory ClassPeriodSetting.fromJson(Map<String, dynamic> json) {
    return ClassPeriodSetting(
      startTime: json['kssj']?.toString() ?? '',
      endTime: json['jssj']?.toString() ?? '',
      sectionText: json['jc']?.toString() ?? '',
      sectionName: json['jcbm']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kssj': startTime,
      'jssj': endTime,
      'jc': sectionText,
      'jcbm': sectionName,
    };
  }
}

@immutable
class ClassWeekRange {
  const ClassWeekRange({required this.weekText, required this.dateRangeText});

  final String weekText;
  final String dateRangeText;

  int get week => int.tryParse(weekText) ?? 0;
  String get label => '第$weekText周';

  factory ClassWeekRange.fromJson(Map<String, dynamic> json) {
    return ClassWeekRange(
      weekText: json['zc']?.toString() ?? '',
      dateRangeText: json['rqfw']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'zc': weekText, 'rqfw': dateRangeText};
  }
}

@immutable
class ClassTableStructure {
  const ClassTableStructure({
    required this.morningSectionCountText,
    required this.afternoonSectionCountText,
    required this.eveningSectionCountText,
    required this.startWeekText,
    required this.endWeekText,
  });

  final String morningSectionCountText;
  final String afternoonSectionCountText;
  final String eveningSectionCountText;
  final String startWeekText;
  final String endWeekText;

  int get morningSectionCount => int.tryParse(morningSectionCountText) ?? 0;
  int get afternoonSectionCount => int.tryParse(afternoonSectionCountText) ?? 0;
  int get eveningSectionCount => int.tryParse(eveningSectionCountText) ?? 0;
  int get startWeek => int.tryParse(startWeekText) ?? 0;
  int get endWeek => int.tryParse(endWeekText) ?? 0;

  factory ClassTableStructure.fromJson(Map<String, dynamic> json) {
    return ClassTableStructure(
      morningSectionCountText: json['swbhxjs']?.toString() ?? '',
      afternoonSectionCountText: json['xwbhxjs']?.toString() ?? '',
      eveningSectionCountText: json['wsbhxjs']?.toString() ?? '',
      startWeekText: json['pkzxzc']?.toString() ?? '',
      endWeekText: json['pkzdzc']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'swbhxjs': morningSectionCountText,
      'xwbhxjs': afternoonSectionCountText,
      'wsbhxjs': eveningSectionCountText,
      'pkzxzc': startWeekText,
      'pkzdzc': endWeekText,
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
