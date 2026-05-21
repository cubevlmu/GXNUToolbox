/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/foundation.dart';

@immutable
class CreditItem {
  const CreditItem({
    required this.natureName,
    required this.categoryName,
    required this.requiredCredits,
    required this.earnedCredits,
    required this.remainingCredits,
    required this.inProgressCredits,
    required this.allEarnedCredits,
    required this.thisSemesterCredits,
  });

  final String natureName;
  final String categoryName;
  final double requiredCredits;
  final double earnedCredits;
  final double remainingCredits;
  final double inProgressCredits;
  final double allEarnedCredits;
  final double thisSemesterCredits;

  factory CreditItem.fromJson(Map<String, dynamic> json) {
    return CreditItem(
      natureName: json['kcxzname']?.toString() ?? '',
      categoryName: json['kclbname']?.toString() ?? '',
      requiredCredits: double.tryParse(json['yxxf']?.toString() ?? '') ?? 0,
      earnedCredits: double.tryParse(json['yixxf']?.toString() ?? '') ?? 0,
      remainingCredits: double.tryParse(json['wxxf']?.toString() ?? '') ?? 0,
      inProgressCredits: double.tryParse(json['xdxf']?.toString() ?? '') ?? 0,
      allEarnedCredits: double.tryParse(json['qbyxxf']?.toString() ?? '') ?? 0,
      thisSemesterCredits: double.tryParse(json['xqhdxf']?.toString() ?? '') ?? 0,
    );
  }
}

@immutable
class CreditSection {
  const CreditSection({
    required this.totalRequired,
    required this.totalEarned,
    required this.totalRemaining,
    required this.totalInProgress,
    required this.totalAllEarned,
    required this.totalThisSemester,
    required this.items,
  });

  final double totalRequired;
  final double totalEarned;
  final double totalRemaining;
  final double totalInProgress;
  final double totalAllEarned;
  final double totalThisSemester;
  final List<CreditItem> items;

  factory CreditSection.fromJson(Map<String, dynamic> json) {
    final list = _asList(json['wdList']);
    return CreditSection(
      totalRequired: double.tryParse(json['yxxf']?.toString() ?? '') ?? 0,
      totalEarned: double.tryParse(json['yixxf']?.toString() ?? '') ?? 0,
      totalRemaining: double.tryParse(json['wxxf']?.toString() ?? '') ?? 0,
      totalInProgress: double.tryParse(json['xdxf']?.toString() ?? '') ?? 0,
      totalAllEarned: double.tryParse(json['qbyxxf']?.toString() ?? '') ?? 0,
      totalThisSemester: double.tryParse(json['xqhdxf']?.toString() ?? '') ?? 0,
      items: list
          .map((e) => CreditItem.fromJson(_asMap(e)))
          .toList(growable: false),
    );
  }
}

@immutable
class CreditProgressResponse {
  const CreditProgressResponse({
    required this.ret,
    required this.msg,
    required this.totalRequired,
    required this.totalEarned,
    required this.totalRemaining,
    required this.totalInProgress,
    required this.totalAllEarned,
    required this.totalThisSemester,
    required this.sections,
  });

  final int ret;
  final String msg;
  final double totalRequired;
  final double totalEarned;
  final double totalRemaining;
  final double totalInProgress;
  final double totalAllEarned;
  final double totalThisSemester;
  final List<CreditSection> sections;

  factory CreditProgressResponse.fromJson(Map<String, dynamic> json) {
    final data = _asList(json['data']);
    final sections = <CreditSection>[];
    for (final item in data) {
      final m = _asMap(item);
      final details = _asList(m['details']);
      for (final d in details) {
        sections.add(CreditSection.fromJson(_asMap(d)));
      }
    }

    final first = data.isNotEmpty ? _asMap(data[0]) : null;
    return CreditProgressResponse(
      ret: int.tryParse(json['ret']?.toString() ?? '') ?? 0,
      msg: json['msg']?.toString() ?? '',
      totalRequired: first != null
          ? (double.tryParse(first['yxxf']?.toString() ?? '') ?? 0)
          : 0,
      totalEarned: first != null
          ? (double.tryParse(first['yixxf']?.toString() ?? '') ?? 0)
          : 0,
      totalRemaining: first != null
          ? (double.tryParse(first['wxxf']?.toString() ?? '') ?? 0)
          : 0,
      totalInProgress: first != null
          ? (double.tryParse(first['xdxf']?.toString() ?? '') ?? 0)
          : 0,
      totalAllEarned: first != null
          ? (double.tryParse(first['qbyxxf']?.toString() ?? '') ?? 0)
          : 0,
      totalThisSemester: first != null
          ? (double.tryParse(first['xqhdxf']?.toString() ?? '') ?? 0)
          : 0,
      sections: sections,
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
