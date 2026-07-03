/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'dart:convert';

import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/data/model/bell_schedule.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:get/get.dart';

class BellScheduleRepo {
  BellScheduleRepo({UserRepo? userRepo})
    : _userRepo = userRepo ?? Get.find<UserRepo>();

  final UserRepo _userRepo;
  Future<BellScheduleResponse>? _fetchTask;
  String? _cachedSemester;

  static const String _cacheKey = 'bell_schedule';

  String computeSemester() {
    final now = DateTime.now();
    final year = now.year;
    if (now.month <= 6) {
      return '${year - 1}-$year-2';
    }
    return '$year-${year + 1}-1';
  }

  BellScheduleResponse? loadCached() {
    final raw = StorageUtils.cache.get(_cacheKey);
    if (raw is! String || raw.isEmpty) return null;

    final savedSemester = StorageUtils.cache.get('bell_schedule_semester');
    if (savedSemester is! String || savedSemester != computeSemester()) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return BellScheduleResponse.fromJson(decoded);
      }
      if (decoded is Map) {
        return BellScheduleResponse.fromJson(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
      return null;
    } catch (e) {
      LogUtil.warn('[BellScheduleRepo] failed to decode cached schedule');
      return null;
    }
  }

  Future<void> saveCache(BellScheduleResponse response) async {
    final semester = computeSemester();
    await StorageUtils.cache.put('bell_schedule_semester', semester);
    await StorageUtils.cache.put(_cacheKey, jsonEncode(response.toJson()));
    _cachedSemester = semester;
  }

  Future<BellScheduleResponse> ensureLoaded({bool forceRefresh = false}) async {
    final semester = computeSemester();

    if (!forceRefresh && _cachedSemester == semester) {
      final cached = loadCached();
      if (cached != null) {
        LogUtil.debug(
          '[BellScheduleRepo] reuse cached schedule semester=$semester',
        );
        return cached;
      }
    }

    final cached = loadCached();
    if (!forceRefresh && cached != null) {
      _cachedSemester = semester;
      return cached;
    }

    final activeTask = _fetchTask;
    if (activeTask != null) {
      LogUtil.debug('[BellScheduleRepo] join in-flight fetch');
      return activeTask;
    }

    final task = _fetch(semester);
    _fetchTask = task;
    try {
      return await task;
    } finally {
      if (identical(_fetchTask, task)) {
        _fetchTask = null;
      }
    }
  }

  Future<BellScheduleResponse> _fetch(String semester) async {
    try {
      LogUtil.info('[BellScheduleRepo] fetch start semester=$semester');
      final response = await Api.getBellSchedule(semester: semester);
      await saveCache(response);
      _cachedSemester = semester;
      LogUtil.info(
        '[BellScheduleRepo] fetch success campuses=${response.campuses.length}',
      );
      return response;
    } on ApiLoginExpiredException catch (e, s) {
      LogUtil.warnE('[BellScheduleRepo] login expired', e, s);
      final recovered = await _userRepo.recoverFromExpiredLogin();
      if (!recovered) rethrow;
      final response = await Api.getBellSchedule(semester: semester);
      await saveCache(response);
      _cachedSemester = semester;
      return response;
    }
  }

  PeriodItem? periodFor(String campusId, int periodNumber) {
    final cached = loadCached();
    if (cached == null) return null;

    for (final campus in cached.campuses) {
      if (_campusNameMatches(campus.campusName, campusId)) {
        for (final period in campus.periods) {
          if (period.periodNumber == periodNumber) return period;
        }
      }
    }
    return null;
  }

  List<ClassPeriodSetting> periodSettingsFor(String campusId) {
    final cached = loadCached();
    if (cached == null) return const [];

    for (final campus in cached.campuses) {
      if (_campusNameMatches(campus.campusName, campusId)) {
        return campus.periods
            .map(
              (period) => ClassPeriodSetting(
                startTime: period.startTime,
                endTime: period.endTime,
                sectionText: period.periodNumber.toString(),
                sectionName: period.periodName,
              ),
            )
            .toList(growable: false);
      }
    }
    return const [];
  }

  bool _campusNameMatches(String campusName, String campusId) {
    final normalizedName = campusName.trim();
    final normalizedId = campusId.trim();
    final idMap = {
      '1': '王城',
      '01': '王城',
      '2': '育才',
      '02': '育才',
      '3': '雁山',
      '03': '雁山',
    };
    final mappedName = idMap[normalizedId];
    if (mappedName != null) {
      return normalizedName.contains(mappedName);
    }
    return normalizedId.isNotEmpty &&
        (normalizedName.contains(normalizedId) ||
            normalizedId.contains(normalizedName));
  }
}
