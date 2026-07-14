import 'package:class_tool/data/model/class_table.dart';

class AcademicTermWeek {
  const AcademicTermWeek._({required this.week, required this.isHoliday});

  const AcademicTermWeek.inTerm(int week)
    : this._(week: week, isHoliday: false);

  const AcademicTermWeek.holiday() : this._(week: 0, isHoliday: true);

  final int week;
  final bool isHoliday;
}

class AcademicTermService {
  const AcademicTermService._();

  /// Resolves the week from the dated week ranges instead of trusting `dqzc`.
  ///
  /// Some school responses reset `dqzc` to 1 outside the teaching period. If
  /// at least one range can be parsed and [date] is outside all of them, the
  /// user is on holiday. We only fall back to `dqzc` for legacy/unparseable
  /// responses so an API formatting change does not blank a valid schedule.
  static AcademicTermWeek resolveWeek(ClassTableMeta meta, {DateTime? date}) {
    final target = _dateOnly(date ?? DateTime.now());
    var parsedRange = false;

    for (final item in meta.weekRanges) {
      final range = _parseRange(item.dateRangeText, target.year);
      if (range == null) continue;
      parsedRange = true;
      if (_contains(target, range.$1, range.$2) && item.week > 0) {
        return AcademicTermWeek.inTerm(item.week);
      }
    }

    if (parsedRange) {
      return const AcademicTermWeek.holiday();
    }

    if (meta.currentWeek > 0) {
      return AcademicTermWeek.inTerm(meta.currentWeek);
    }
    for (final item in meta.weekRanges) {
      if (item.week > 0) return AcademicTermWeek.inTerm(item.week);
    }
    return const AcademicTermWeek.inTerm(1);
  }

  static (DateTime, DateTime)? _parseRange(String raw, int referenceYear) {
    final fullDatePattern = RegExp(r'(20\d{2})\D+(\d{1,2})\D+(\d{1,2})');
    final fullDateMatches = fullDatePattern.allMatches(raw).toList();
    final fullDates = fullDateMatches
        .map((match) {
          return _tryDate(
            int.parse(match.group(1)!),
            int.parse(match.group(2)!),
            int.parse(match.group(3)!),
          );
        })
        .whereType<DateTime>()
        .toList(growable: false);

    if (fullDates.length >= 2) {
      return (fullDates[0], fullDates[1]);
    }

    if (fullDates.length == 1) {
      final start = fullDates.single;
      final tail = raw.substring(fullDateMatches.single.end);
      final tailMatch = RegExp(
        r'(\d{1,2})\s*[月./-]\s*(\d{1,2})\s*日?',
      ).firstMatch(tail);
      if (tailMatch != null) {
        final endMonth = int.parse(tailMatch.group(1)!);
        final endDay = int.parse(tailMatch.group(2)!);
        final endYear = endMonth < start.month ? start.year + 1 : start.year;
        final end = _tryDate(endYear, endMonth, endDay);
        if (end != null) return (start, end);
      }
    }

    final monthDays = RegExp(r'(\d{1,2})\s*[月./-]\s*(\d{1,2})\s*日?')
        .allMatches(raw)
        .map((match) {
          return (int.parse(match.group(1)!), int.parse(match.group(2)!));
        })
        .toList(growable: false);
    if (monthDays.length < 2) return null;

    for (final year in <int>[
      referenceYear - 1,
      referenceYear,
      referenceYear + 1,
    ]) {
      final start = _tryDate(year, monthDays[0].$1, monthDays[0].$2);
      if (start == null) continue;
      var endYear = year;
      if (monthDays[1].$1 < monthDays[0].$1) endYear += 1;
      final end = _tryDate(endYear, monthDays[1].$1, monthDays[1].$2);
      if (end != null &&
          _contains(_dateOnly(DateTime(referenceYear)), start, end)) {
        return (start, end);
      }
      if (end != null && (year == referenceYear || endYear == referenceYear)) {
        return (start, end);
      }
    }
    return null;
  }

  static bool _contains(DateTime value, DateTime start, DateTime end) {
    return !value.isBefore(_dateOnly(start)) && !value.isAfter(_dateOnly(end));
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime? _tryDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final value = DateTime(year, month, day);
    return value.year == year && value.month == month && value.day == day
        ? value
        : null;
  }
}
