/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;

enum ExamBatchCategory { beforeExamWeek, examWeek, makeup }

@immutable
class ExamBatchOption {
  const ExamBatchOption({
    required this.pcid,
    required this.label,
    required this.category,
  });

  final String pcid;
  final String label;
  final ExamBatchCategory category;
}

@immutable
class ExamSemesterOption {
  const ExamSemesterOption({
    required this.value,
    required this.label,
    this.selected = false,
  });

  final String value;
  final String label;
  final bool selected;
}

@immutable
class ExamFilterOptions {
  const ExamFilterOptions({required this.semesters, required this.batches});

  final List<ExamSemesterOption> semesters;
  final List<ExamBatchOption> batches;

  String? pcidFor(ExamBatchCategory category) {
    for (final batch in batches) {
      if (batch.category == category) {
        return batch.pcid;
      }
    }
    return null;
  }

  ExamBatchOption? batchFor(ExamBatchCategory category) {
    for (final batch in batches) {
      if (batch.category == category) {
        return batch;
      }
    }
    return null;
  }

  factory ExamFilterOptions.fromHtml(String html) {
    final document = html_parser.parse(html);

    final semesterOptions = <ExamSemesterOption>[];
    final semesterSelect = document.querySelector('#xnxq');
    if (semesterSelect != null) {
      for (final option in semesterSelect.querySelectorAll('option')) {
        final value = option.attributes['value']?.trim() ?? '';
        final label = option.text.trim();
        final selected = option.attributes.containsKey('selected');
        if (value.isNotEmpty) {
          semesterOptions.add(
            ExamSemesterOption(value: value, label: label, selected: selected),
          );
        }
      }
    }

    return ExamFilterOptions(
      semesters: List<ExamSemesterOption>.unmodifiable(semesterOptions),
      batches: const [],
    );
  }

  factory ExamFilterOptions.fromKspcJson(
    List<ExamSemesterOption> semesters,
    List<dynamic> jsonList,
  ) {
    final batchOptions = <ExamBatchOption>[];
    for (final item in jsonList) {
      if (item is Map) {
        final pcid = item['id']?.toString() ?? '';
        final label = item['kspcmc']?.toString() ?? '';
        if (pcid.isNotEmpty && label.isNotEmpty) {
          batchOptions.add(
            ExamBatchOption(
              pcid: pcid,
              label: label,
              category: batchCategoryFromLabel(label),
            ),
          );
        }
      }
    }

    return ExamFilterOptions(
      semesters: semesters,
      batches: List<ExamBatchOption>.unmodifiable(batchOptions),
    );
  }
}

ExamBatchCategory batchCategoryFromLabel(String label) {
  if (label.contains('补考')) {
    return ExamBatchCategory.makeup;
  }
  if (label.contains('考试周之前')) {
    return ExamBatchCategory.beforeExamWeek;
  }
  return ExamBatchCategory.examWeek;
}

@immutable
class ExamQueryResponse {
  const ExamQueryResponse({
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
  final List<ExamItem> results;

  factory ExamQueryResponse.fromJson(Map<String, dynamic> json) {
    return ExamQueryResponse(
      ret: _asInt(json['ret']),
      msg: json['msg']?.toString() ?? '',
      page: _asInt(json['page']),
      rows: _asInt(json['rows']),
      total: _asInt(json['total']),
      totalPages: _asInt(json['totalPages']),
      results: _asList(
        json['results'],
      ).map((item) => ExamItem.fromJson(_asMap(item))).toList(growable: false),
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
class ExamItem {
  const ExamItem({
    required this.id,
    required this.courseName,
    required this.location,
    required this.examTimeRange,
    required this.examDate,
    required this.startTime,
    required this.examType,
    required this.examBatchName,
    required this.seatNumber,
    required this.className,
    required this.studentName,
    required this.studentId,
    required this.makeupCount,
    required this.gradeYear,
    required this.college,
    required this.majorCode,
  });

  final String id;
  final String courseName;
  final String location;
  final String examTimeRange;
  final String examDate;
  final String startTime;
  final String examType;
  final String examBatchName;
  final String seatNumber;
  final String className;
  final String studentName;
  final String studentId;
  final int makeupCount;
  final String gradeYear;
  final String college;
  final String majorCode;

  String get examTypeLabel => _examTypeLabel(examType);

  factory ExamItem.fromJson(Map<String, dynamic> json) {
    return ExamItem(
      id: json['id']?.toString() ?? '',
      courseName: json['kcmc']?.toString() ?? '',
      location: json['jsmc']?.toString() ?? '',
      examTimeRange: json['kssj']?.toString() ?? '',
      examDate: json['ksrq']?.toString() ?? '',
      startTime: json['qssj']?.toString() ?? '',
      examType: json['ksxs']?.toString() ?? '',
      examBatchName: json['kspcmc']?.toString() ?? '',
      seatNumber: json['zwh']?.toString() ?? '',
      className: json['bjdm']?.toString() ?? '',
      studentName: json['xm']?.toString() ?? '',
      studentId: json['xh']?.toString() ?? '',
      makeupCount: _asInt(json['bkcs']),
      gradeYear: json['sznj']?.toString() ?? '',
      college: json['skyx']?.toString() ?? '',
      majorCode: json['zydm']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kcmc': courseName,
      'jsmc': location,
      'kssj': examTimeRange,
      'ksrq': examDate,
      'qssj': startTime,
      'ksxs': examType,
      'kspcmc': examBatchName,
      'zwh': seatNumber,
      'bjdm': className,
      'xm': studentName,
      'xh': studentId,
      'bkcs': makeupCount,
      'sznj': gradeYear,
      'skyx': college,
      'zydm': majorCode,
    };
  }
}

String _examTypeLabel(String value) {
  switch (value) {
    case '考试':
      return '考试';
    case '考查':
      return '考查';
    default:
      return value;
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
