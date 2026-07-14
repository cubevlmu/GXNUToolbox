class SchoolCalendarResponse {
  const SchoolCalendarResponse({required this.semester, required this.rows});

  factory SchoolCalendarResponse.fromList(
    List<dynamic> rawList, {
    required String semester,
  }) {
    final rows = <SchoolCalendarWeekRow>[];
    for (final item in rawList) {
      if (item is Map) {
        final row = SchoolCalendarWeekRow.fromJson(
          item.map((key, value) => MapEntry(key.toString(), value)),
        );
        if (row.days.isNotEmpty) {
          rows.add(row);
        }
      }
    }
    return SchoolCalendarResponse(
      semester: semester,
      rows: List<SchoolCalendarWeekRow>.unmodifiable(rows),
    );
  }

  final String semester;
  final List<SchoolCalendarWeekRow> rows;

  List<String> get monthTexts {
    final values = <String>[];
    for (final row in rows) {
      if (row.monthText.isNotEmpty && !values.contains(row.monthText)) {
        values.add(row.monthText);
      }
    }
    return List<String>.unmodifiable(values);
  }

  int get remarkCount {
    var count = 0;
    for (final row in rows) {
      count += row.days.where((day) => day.hasRemark).length;
    }
    return count;
  }
}

class SchoolCalendarWeekRow {
  const SchoolCalendarWeekRow({
    required this.semester,
    required this.monthText,
    required this.weekText,
    required this.days,
  });

  factory SchoolCalendarWeekRow.fromJson(Map<String, dynamic> json) {
    final semester = _asString(json['xnxqh']);
    final monthText = _asString(json['ny']);
    final weekText = _asString(json['zc']);
    final days = <SchoolCalendarDay>[];
    for (final spec in _weekdaySpecs) {
      final dayText = _asString(json[spec.dayKey]);
      if (dayText.isEmpty) {
        continue;
      }
      days.add(
        SchoolCalendarDay(
          weekdayIndex: spec.weekdayIndex,
          weekdayLabel: spec.weekdayLabel,
          dayText: dayText,
          remark: _normalizeRemark(_asString(json[spec.remarkKey])),
          date: _parseDate(monthText, dayText),
        ),
      );
    }

    return SchoolCalendarWeekRow(
      semester: semester,
      monthText: monthText,
      weekText: weekText,
      days: List<SchoolCalendarDay>.unmodifiable(days),
    );
  }

  final String semester;
  final String monthText;
  final String weekText;
  final List<SchoolCalendarDay> days;

  SchoolCalendarDay? dayAt(int weekdayIndex) {
    for (final day in days) {
      if (day.weekdayIndex == weekdayIndex) {
        return day;
      }
    }
    return null;
  }
}

class SchoolCalendarDay {
  const SchoolCalendarDay({
    required this.weekdayIndex,
    required this.weekdayLabel,
    required this.dayText,
    required this.remark,
    required this.date,
  });

  final int weekdayIndex;
  final String weekdayLabel;
  final String dayText;
  final String remark;
  final DateTime? date;

  bool get hasRemark => remark.isNotEmpty;
  bool get isToday {
    final value = date;
    if (value == null) return false;
    final now = DateTime.now();
    return value.year == now.year &&
        value.month == now.month &&
        value.day == now.day;
  }

  String get dateLabel {
    final value = date;
    if (value == null) return dayText;
    return '${value.year}-${_pad2(value.month)}-${_pad2(value.day)}';
  }
}

class _WeekdaySpec {
  const _WeekdaySpec({
    required this.weekdayIndex,
    required this.weekdayLabel,
    required this.dayKey,
    required this.remarkKey,
  });

  final int weekdayIndex;
  final String weekdayLabel;
  final String dayKey;
  final String remarkKey;
}

const List<_WeekdaySpec> _weekdaySpecs = [
  _WeekdaySpec(
    weekdayIndex: 1,
    weekdayLabel: '周一',
    dayKey: 'monday',
    remarkKey: 'mondayremark',
  ),
  _WeekdaySpec(
    weekdayIndex: 2,
    weekdayLabel: '周二',
    dayKey: 'tuesday',
    remarkKey: 'tuesdayremark',
  ),
  _WeekdaySpec(
    weekdayIndex: 3,
    weekdayLabel: '周三',
    dayKey: 'wednesday',
    remarkKey: 'wednesdayremark',
  ),
  _WeekdaySpec(
    weekdayIndex: 4,
    weekdayLabel: '周四',
    dayKey: 'thursday',
    remarkKey: 'thursdayremark',
  ),
  _WeekdaySpec(
    weekdayIndex: 5,
    weekdayLabel: '周五',
    dayKey: 'friday',
    remarkKey: 'fridayremark',
  ),
  _WeekdaySpec(
    weekdayIndex: 6,
    weekdayLabel: '周六',
    dayKey: 'saturday',
    remarkKey: 'saturdayremark',
  ),
  _WeekdaySpec(
    weekdayIndex: 7,
    weekdayLabel: '周日',
    dayKey: 'sunday',
    remarkKey: 'sundayremark',
  ),
];

String _asString(Object? value) => value?.toString().trim() ?? '';

String _normalizeRemark(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed == '无备注信息') {
    return '';
  }
  return trimmed;
}

DateTime? _parseDate(String monthText, String dayText) {
  final parts = monthText.split('-');
  if (parts.length != 2) return null;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(dayText);
  if (year == null || month == null || day == null) {
    return null;
  }
  if (month < 1 || month > 12 || day < 1 || day > 31) {
    return null;
  }
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}

String _pad2(int value) => value.toString().padLeft(2, '0');
