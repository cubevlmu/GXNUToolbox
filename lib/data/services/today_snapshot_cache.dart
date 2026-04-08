import 'dart:convert';

import 'package:class_tool/data/model/today_course_snapshot.dart';
import 'package:class_tool/utils/storage_utils.dart';

const String _todaySnapshotCachePrefix = 'today_course_snapshot_';

class TodaySnapshotCache {
  const TodaySnapshotCache._();

  static Future<void> save(TodayCourseSnapshot snapshot) {
    return StorageUtils.cache.put(_todayKey(), jsonEncode(snapshot.toJson()));
  }

  static TodayCourseSnapshot? load() {
    final raw = StorageUtils.cache.get(_todayKey())?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return TodayCourseSnapshot.fromJson(decoded);
  }

  static Future<void> clear() {
    return StorageUtils.cache.delete(_todayKey());
  }

  static String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$_todaySnapshotCachePrefix${now.year}-$month-$day';
  }
}
