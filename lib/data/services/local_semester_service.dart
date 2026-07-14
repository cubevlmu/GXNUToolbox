class LocalSemesterService {
  const LocalSemesterService._();

  static String currentSemester({DateTime? now}) {
    final date = now ?? DateTime.now();
    final year = date.year;
    if (date.month <= 6) {
      return '${year - 1}-$year-2';
    }
    return '$year-${year + 1}-1';
  }

  static String previousSemester({DateTime? now}) {
    final current = currentSemester(now: now);
    final parts = current.split('-');
    if (parts.length != 3) return current;
    final startYear = int.tryParse(parts[0]);
    final term = int.tryParse(parts[2]);
    if (startYear == null || term == null) return current;
    if (term == 2) {
      return '$startYear-${startYear + 1}-1';
    }
    return '${startYear - 1}-$startYear-2';
  }

  static List<String> recentSemesters({
    DateTime? now,
    bool includeAll = false,
  }) {
    final date = now ?? DateTime.now();
    final currentYear = date.year;
    final semesters = <String>[];
    if (includeAll) {
      semesters.add('');
    }
    for (var year = currentYear; year >= currentYear - 5; year--) {
      semesters.add('$year-${year + 1}-1');
      semesters.add('${year - 1}-$year-2');
    }
    return semesters;
  }
}
