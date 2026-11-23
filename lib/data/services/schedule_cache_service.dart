import 'dart:convert';

import 'package:class_tool/data/model/class_meta.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:class_tool/data/model/class_table_context.dart';
import 'package:class_tool/data/model/class_table_course.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/storage_utils.dart';

class ScheduleCachePointer {
  const ScheduleCachePointer({
    required this.semester,
    required this.week,
    required this.isHoliday,
    required this.savedAt,
  });

  final String semester;
  final int week;
  final bool isHoliday;
  final DateTime savedAt;
}

class ScheduleCacheService {
  const ScheduleCacheService._();

  static const String _ctxPrefix = 'schedule_ctx_v1|';
  static const String _metaPrefix = 'schedule_meta_v1|';
  static const String _weekMetaPrefix = 'schedule_week_meta_v1|';
  static const String _coursesPrefix = 'schedule_courses_v1|';
  static const String _latestPointerPrefix = 'schedule_latest_v1|';

  static Future<void> savePageContext(
    ClassTablePageContext context, {
    String? userId,
    String? semester,
  }) async {
    final uid = (userId != null && userId.isNotEmpty)
        ? userId
        : context.userContext.userId;
    final sem = (semester != null && semester.isNotEmpty)
        ? semester
        : context.userContext.selectedSemester;
    if (uid.isEmpty || sem.isEmpty) {
      return;
    }
    await _putJson('$_ctxPrefix$uid|$sem', context.toJson());
  }

  static ClassTablePageContext? loadPageContext({
    required String userId,
    required String semester,
  }) {
    if (userId.isEmpty || semester.isEmpty) {
      return null;
    }
    final map = _getJsonMap('$_ctxPrefix$userId|$semester');
    if (map == null) {
      return null;
    }
    try {
      return ClassTablePageContext.fromJson(map);
    } catch (e) {
      LogUtil.warn('[ScheduleCache] decode pageContext failed: $e');
      return null;
    }
  }

  static Future<void> saveMeta({
    required String userId,
    required String semester,
    required ClassTableMetaResponse response,
  }) async {
    if (userId.isEmpty || semester.isEmpty) {
      return;
    }
    await _putJson('$_metaPrefix$userId|$semester', response.toJson());
  }

  static ClassTableMetaResponse? loadMeta({
    required String userId,
    required String semester,
  }) {
    if (userId.isEmpty || semester.isEmpty) {
      return null;
    }
    final map = _getJsonMap('$_metaPrefix$userId|$semester');
    if (map == null) {
      return null;
    }
    try {
      return ClassTableMetaResponse.fromJson(map);
    } catch (e) {
      LogUtil.warn('[ScheduleCache] decode meta failed: $e');
      return null;
    }
  }

  static Future<void> saveWeekMeta({
    required String userId,
    required String semester,
    required int week,
    required List<ClassMeta> items,
  }) async {
    if (userId.isEmpty || semester.isEmpty || week <= 0) {
      return;
    }
    await _putJson(
      '$_weekMetaPrefix$userId|$semester|$week',
      items.map((item) => item.toJson()).toList(growable: false),
    );
  }

  static List<ClassMeta>? loadWeekMeta({
    required String userId,
    required String semester,
    required int week,
  }) {
    if (userId.isEmpty || semester.isEmpty || week <= 0) {
      return null;
    }
    final raw = StorageUtils.cache
        .get('$_weekMetaPrefix$userId|$semester|$week')
        ?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return null;
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ClassMeta.fromJson)
          .toList(growable: false);
    } catch (e) {
      LogUtil.warn('[ScheduleCache] decode weekMeta failed: $e');
      return null;
    }
  }

  static Future<void> saveCourses({
    required String userId,
    required String semester,
    required int week,
    required ClassTableCourseResponse response,
  }) async {
    if (userId.isEmpty || semester.isEmpty || week <= 0) {
      return;
    }
    await _putJson('$_coursesPrefix$userId|$semester|$week', response.toJson());
  }

  static ClassTableCourseResponse? loadCourses({
    required String userId,
    required String semester,
    required int week,
  }) {
    if (userId.isEmpty || semester.isEmpty || week <= 0) {
      return null;
    }
    final map = _getJsonMap('$_coursesPrefix$userId|$semester|$week');
    if (map == null) {
      return null;
    }
    try {
      return ClassTableCourseResponse.fromJson(map);
    } catch (e) {
      LogUtil.warn('[ScheduleCache] decode courses failed: $e');
      return null;
    }
  }

  static Future<void> saveLatestPointer({
    required String userId,
    required String semester,
    required int week,
    required bool isHoliday,
  }) async {
    if (userId.isEmpty || semester.isEmpty) {
      return;
    }
    await _putJson('$_latestPointerPrefix$userId', <String, Object?>{
      'semester': semester,
      'week': week,
      'isHoliday': isHoliday,
      'savedAt': DateTime.now().toIso8601String(),
    });
  }

  static ScheduleCachePointer? loadLatestPointer(String userId) {
    if (userId.isEmpty) {
      return null;
    }
    final map = _getJsonMap('$_latestPointerPrefix$userId');
    if (map == null) {
      return null;
    }
    final semester = map['semester']?.toString() ?? '';
    if (semester.isEmpty) {
      return null;
    }
    final weekRaw = map['week'];
    final week = weekRaw is int
        ? weekRaw
        : int.tryParse(weekRaw?.toString() ?? '') ?? 0;
    final savedAt =
        DateTime.tryParse(map['savedAt']?.toString() ?? '') ?? DateTime.now();
    return ScheduleCachePointer(
      semester: semester,
      week: week,
      isHoliday: map['isHoliday'] == true,
      savedAt: savedAt,
    );
  }

  static Future<void> _putJson(String key, Object value) async {
    try {
      await StorageUtils.cache.put(key, jsonEncode(value));
    } catch (e) {
      LogUtil.warn('[ScheduleCache] write failed for key=$key: $e');
    }
  }

  static Map<String, dynamic>? _getJsonMap(String key) {
    try {
      final raw = StorageUtils.cache.get(key)?.toString();
      if (raw == null || raw.isEmpty) {
        return null;
      }
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}
