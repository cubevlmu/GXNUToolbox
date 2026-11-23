/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;

@immutable
class ClassTablePageContext {
  const ClassTablePageContext({
    required this.userContext,
    required this.semesters,
  });

  final ClassTableUserContext userContext;
  final List<ClassTableSemester> semesters;

  factory ClassTablePageContext.fromHtml(String html) {
    final document = html_parser.parse(html);

    final userContext = ClassTableUserContext(
      selectedSemester: _firstNonEmpty(
        _inputValue(document, 'xnxq'),
        _selectedOptionValue(document, '#xnxq1'),
        _elementText(document, '#xnxq'),
      ),
      userId: _firstNonEmpty(
        _inputValue(document, 'userId'),
        _inputValue(document, 'xhid'),
      ),
      campusId: _firstNonEmpty(
        _inputValue(document, 'xqid'),
        _inputValue(document, 'xqdm'),
      ),
      selectedCampusId: _firstNonEmpty(
        _inputValue(document, 'xqid1'),
        _selectedOptionValue(document, '#xqSelect'),
        _inputValue(document, 'xqdm'),
        _inputValue(document, 'xqid'),
      ),
    );

    final semesters = _parseSemesterList(document);

    return ClassTablePageContext(
      userContext: userContext,
      semesters: semesters,
    );
  }

  factory ClassTablePageContext.fromJson(Map<String, dynamic> json) {
    final rawUser = json['userContext'];
    final rawSemesters = json['semesters'];
    return ClassTablePageContext(
      userContext: rawUser is Map<String, dynamic>
          ? ClassTableUserContext.fromJson(rawUser)
          : const ClassTableUserContext(
              selectedSemester: '',
              userId: '',
              campusId: '',
              selectedCampusId: '',
            ),
      semesters: rawSemesters is List
          ? rawSemesters
                .whereType<Map<String, dynamic>>()
                .map(ClassTableSemester.fromJson)
                .toList(growable: false)
          : const <ClassTableSemester>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userContext': userContext.toJson(),
      'semesters': semesters.map((item) => item.toJson()).toList(),
    };
  }
}

class ClassTableUserContext {
  const ClassTableUserContext({
    required this.selectedSemester,
    required this.userId,
    required this.campusId,
    required this.selectedCampusId,
  });

  final String selectedSemester;
  final String userId;
  final String campusId;
  final String selectedCampusId;

  factory ClassTableUserContext.fromJson(Map<String, dynamic> json) {
    return ClassTableUserContext(
      selectedSemester: json['selectedSemester']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      campusId: json['campusId']?.toString() ?? '',
      selectedCampusId: json['selectedCampusId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'selectedSemester': selectedSemester,
      'userId': userId,
      'campusId': campusId,
      'selectedCampusId': selectedCampusId,
    };
  }
}

class ClassTableSemester {
  const ClassTableSemester({
    required this.value,
    required this.label,
    required this.isActive,
  });

  final String value;
  final String label;
  final bool isActive;

  factory ClassTableSemester.fromJson(Map<String, dynamic> json) {
    return ClassTableSemester(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      isActive: json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'value': value,
      'label': label,
      'isActive': isActive,
    };
  }
}

String _inputValue(dynamic document, String id) {
  return document.querySelector('#$id')?.attributes['value']?.trim() ?? '';
}

String _elementText(dynamic document, String selector) {
  return document.querySelector(selector)?.text.trim() ?? '';
}

String _selectedOptionValue(dynamic document, String selector) {
  final select = document.querySelector(selector);
  if (select == null) {
    return '';
  }

  final options = select.querySelectorAll('option');
  for (final option in options) {
    if (option.attributes.containsKey('selected')) {
      return option.attributes['value']?.trim() ?? '';
    }
  }

  for (final option in options) {
    final value = option.attributes['value']?.trim() ?? '';
    if (value.isNotEmpty) {
      return value;
    }
  }

  return '';
}

List<ClassTableSemester> _parseSemesterList(dynamic document) {
  final mobileSemesters = <ClassTableSemester>[];
  for (final element in document.querySelectorAll('#xnxqList li p')) {
    final semester = ClassTableSemester(
      value: _extractQuotedValue(
        element.attributes['onclick'],
        "changeXnxq(this,'",
      ),
      label: element.text.trim(),
      isActive: element.classes.contains('active'),
    );
    if (semester.value.isNotEmpty || semester.label.isNotEmpty) {
      mobileSemesters.add(semester);
    }
  }
  if (mobileSemesters.isNotEmpty) {
    return mobileSemesters;
  }

  final desktopSemesters = <ClassTableSemester>[];
  for (final element in document.querySelectorAll('#xnxq1 option')) {
    final semester = ClassTableSemester(
      value: element.attributes['value']?.trim() ?? '',
      label: element.text.trim(),
      isActive: element.attributes.containsKey('selected'),
    );
    if (semester.value.isNotEmpty) {
      desktopSemesters.add(semester);
    }
  }
  return desktopSemesters;
}

String _extractQuotedValue(String? raw, String prefix) {
  if (raw == null || raw.isEmpty) {
    return '';
  }

  final start = raw.indexOf(prefix);
  if (start < 0) {
    return '';
  }

  final valueStart = start + prefix.length;
  final valueEnd = raw.indexOf("'", valueStart);
  if (valueEnd < 0) {
    return '';
  }

  return raw.substring(valueStart, valueEnd);
}

String _firstNonEmpty(String a, String b, [String c = '', String d = '']) {
  if (a.isNotEmpty) {
    return a;
  }
  if (b.isNotEmpty) {
    return b;
  }
  if (c.isNotEmpty) {
    return c;
  }
  return d;
}
