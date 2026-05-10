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
  const CampusSchedule({
    required this.campusName,
    required this.periods,
  });

  final String campusName;
  final List<PeriodItem> periods;

  factory CampusSchedule.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List<dynamic>? ?? const [];
    return CampusSchedule(
      campusName: (json['xqsj'] as Map<String, dynamic>?)?['xqmc']?.toString() ?? '',
      periods: list
          .map((e) => PeriodItem.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

@immutable
class BellScheduleResponse {
  const BellScheduleResponse({required this.campuses});

  final List<CampusSchedule> campuses;

  factory BellScheduleResponse.fromJson(Map<String, dynamic> json) {
    final xqList = json['xqList'] as List<dynamic>? ?? const [];
    return BellScheduleResponse(
      campuses: xqList
          .map((e) => CampusSchedule.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
    'xqList': campuses
        .map((c) => {
          'xqsj': {'xqmc': c.campusName},
          'list': c.periods.map((p) => p.toJson()).toList(),
        })
        .toList(),
  };
}
