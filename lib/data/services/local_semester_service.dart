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
