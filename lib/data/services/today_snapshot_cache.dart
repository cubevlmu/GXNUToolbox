import 'dart:convert';

import 'package:class_tool/data/model/today_course_snapshot.dart';
import 'package:class_tool/utils/storage_utils.dart';

const String _todaySnapshotCachePrefix = 'today_course_snapshot_';
const String _latestSnapshotCacheKey = 'today_course_snapshot_latest';

class TodaySnapshotCacheEntry {
  const TodaySnapshotCacheEntry({
    required this.snapshot,
    required this.savedAt,
    required this.cacheDate,
    required this.isFromToday,
  });

  final TodayCourseSnapshot snapshot;
  final DateTime savedAt;
  final DateTime cacheDate;
  final bool isFromToday;
}

class TodaySnapshotCache {
  const TodaySnapshotCache._();

  static Future<void> save(TodayCourseSnapshot snapshot) async {
    final now = DateTime.now();
    final payload = jsonEncode(<String, Object?>{
      'savedAt': now.toIso8601String(),
      'cacheDate': _dateText(now),
      'snapshot': snapshot.toJson(),
    });
    await StorageUtils.cache.put(_todayKey(now), payload);
    await StorageUtils.cache.put(_latestSnapshotCacheKey, payload);
  }

  static TodayCourseSnapshot? load() {
    return loadEntry()?.snapshot;
  }

  static TodaySnapshotCacheEntry? loadEntry() {
    final today = DateTime.now();
    final todayRaw = StorageUtils.cache.get(_todayKey(today))?.toString();
    final todayEntry = _decodeEntry(todayRaw, fallbackDate: today);
    if (todayEntry != null) {
      return todayEntry;
    }

    final latestRaw = StorageUtils.cache
        .get(_latestSnapshotCacheKey)
        ?.toString();
    return _decodeEntry(latestRaw, fallbackDate: today);
  }

  static Future<void> clear() async {
    await StorageUtils.cache.delete(_todayKey(DateTime.now()));
    await StorageUtils.cache.delete(_latestSnapshotCacheKey);
  }

  static TodaySnapshotCacheEntry? _decodeEntry(
    String? raw, {
    required DateTime fallbackDate,
  }) {
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return null;
    }

    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    try {
      final savedAt = DateTime.tryParse(decoded['savedAt']?.toString() ?? '');
      final cacheDate =
          _parseDate(decoded['cacheDate']?.toString()) ??
          (savedAt == null ? fallbackDate : _dateOnly(savedAt));
      final snapshotJson = decoded['snapshot'];
      if (savedAt != null && snapshotJson is Map<String, dynamic>) {
        return TodaySnapshotCacheEntry(
          snapshot: TodayCourseSnapshot.fromJson(snapshotJson),
          savedAt: savedAt,
          cacheDate: cacheDate,
          isFromToday: _isSameDay(cacheDate, DateTime.now()),
        );
      }

      return TodaySnapshotCacheEntry(
        snapshot: TodayCourseSnapshot.fromJson(decoded),
        savedAt: DateTime.now(),
        cacheDate: cacheDate,
        isFromToday: _isSameDay(cacheDate, DateTime.now()),
      );
    } catch (_) {
      return null;
    }
  }

  static String _todayKey(DateTime date) {
    return '$_todaySnapshotCachePrefix${_dateText(date)}';
  }

  static String _dateText(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(raw);
    return parsed == null ? null : _dateOnly(parsed);
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
