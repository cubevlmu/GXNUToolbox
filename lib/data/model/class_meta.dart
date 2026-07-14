/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/cupertino.dart';

@immutable
class ClassMeta {
  const ClassMeta({
    required this.week,
    required this.dateTimeText,
    required this.weekdayIndex,
    required this.weekdayName,
    required this.dayText,
    required this.lunarCalendarText,
  });

  final int week;
  final String dateTimeText;
  final int weekdayIndex;
  final String weekdayName;
  final String dayText;
  final String lunarCalendarText;

  factory ClassMeta.fromJson(Map<String, dynamic> json) {
    return ClassMeta(
      week: _asInt(json['zc']),
      dateTimeText: json['rq']?.toString() ?? '',
      weekdayIndex: _asInt(json['xqbh']),
      weekdayName: json['xqmc']?.toString() ?? '',
      dayText: json['day']?.toString() ?? '',
      lunarCalendarText: json['lunarCalendar']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zc': week,
      'rq': dateTimeText,
      'xqbh': weekdayIndex,
      'xqmc': weekdayName,
      'day': dayText,
      'lunarCalendar': lunarCalendarText,
    };
  }
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
