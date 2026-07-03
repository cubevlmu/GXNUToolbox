/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/foundation.dart';

@immutable
class PeriodItem {
  const PeriodItem({
    required this.periodNumber,
    required this.periodName,
    required this.startTime,
    required this.endTime,
  });

  final int periodNumber;
  final String periodName;
  final String startTime;
  final String endTime;

  String get timeText => '$startTime-$endTime';

  factory PeriodItem.fromJson(Map<String, dynamic> json) {
    return PeriodItem(
      periodNumber: int.tryParse(json['jc']?.toString() ?? '') ?? 0,
      periodName: json['jcbm']?.toString() ?? '',
      startTime: json['kssj']?.toString() ?? '',
      endTime: json['jssj']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'jc': periodNumber,
    'jcbm': periodName,
    'kssj': startTime,
    'jssj': endTime,
  };
}

@immutable
class CampusSchedule {
  const CampusSchedule({required this.campusName, required this.periods});

  final String campusName;
  final List<PeriodItem> periods;

  factory CampusSchedule.fromJson(Map<String, dynamic> json) {
    final list = _asList(json['list']);
    final campusInfo = _asMap(json['xqsj']);
    return CampusSchedule(
      campusName: campusInfo['xqmc']?.toString() ?? '',
      periods: list
          .map((e) => PeriodItem.fromJson(_asMap(e)))
          .toList(growable: false),
    );
  }
}

@immutable
class BellScheduleResponse {
  const BellScheduleResponse({required this.campuses});

  final List<CampusSchedule> campuses;

  factory BellScheduleResponse.fromJson(Map<String, dynamic> json) {
    final xqList = _asList(json['xqList']);
    return BellScheduleResponse(
      campuses: xqList
          .map((e) => CampusSchedule.fromJson(_asMap(e)))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
    'xqList': campuses
        .map(
          (c) => {
            'xqsj': {'xqmc': c.campusName},
            'list': c.periods.map((p) => p.toJson()).toList(),
          },
        )
        .toList(),
  };
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
