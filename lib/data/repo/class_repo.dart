/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/data/model/class_meta.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:class_tool/data/model/class_table_context.dart';
import 'package:class_tool/data/model/class_table_course.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:get/get.dart';

class ClassRepo {
  ClassRepo({UserRepo? userRepo})
    : _userRepo = userRepo ?? Get.find<UserRepo>();

  final UserRepo _userRepo;

  ClassTablePageContext? _pageContext;
  ClassTableMetaResponse? _metaResponse;
  Future<ClassTablePageContext>? _syncBaseContextTask;
  String? _syncBaseContextTaskSemester;
  bool _syncBaseContextTaskForceRefresh = false;

  ClassTablePageContext? get pageContext =>
      _pageContext ?? _userRepo.pageContext;
  ClassTableUserContext? get userContext => _pageContext?.userContext;
  List<ClassTableSemester> get semesters => pageContext?.semesters ?? const [];
  ClassTableMetaResponse? get metaResponse => _metaResponse;
  ClassTableMeta? get meta => _metaResponse?.data;

  String get currentSemester => _userRepo.selectedSemester.isNotEmpty
      ? _userRepo.selectedSemester
      : (userContext?.selectedSemester ?? '');
  String get currentUserId => _userRepo.userId.isNotEmpty
      ? _userRepo.userId
      : (userContext?.userId ?? '');
  String get currentCampusId => _userRepo.campusId.isNotEmpty
      ? _userRepo.campusId
      : ((userContext?.campusId ?? '').isNotEmpty
            ? userContext!.campusId
            : currentSelectedCampusId);
  String get currentSelectedCampusId => _userRepo.selectedCampusId.isNotEmpty
      ? _userRepo.selectedCampusId
      : ((userContext?.selectedCampusId ?? '').isNotEmpty
            ? userContext!.selectedCampusId
            : currentCampusId);

  Future<ClassTablePageContext> syncBaseContext({
    String? semester,
    bool forceRefresh = false,
  }) async {
    final targetSemester = semester != null && semester.isNotEmpty
        ? semester
        : currentSemester;

    final cached = _resolveReusablePageContext(targetSemester);
    if (!forceRefresh && cached != null) {
      LogUtil.debug(
        '[ClassRepo] syncBaseContext reuse cached semester=$targetSemester userId=${cached.userContext.userId}',
      );
      _pageContext = cached;
      return cached;
    }

    final activeTask = _syncBaseContextTask;
    if (activeTask != null &&
        _syncBaseContextTaskSemester == targetSemester &&
        (_syncBaseContextTaskForceRefresh || !forceRefresh)) {
      LogUtil.debug(
        '[ClassRepo] syncBaseContext join in-flight request semester=$targetSemester',
      );
      return activeTask;
    }

    final task = _runWithLoginRetry(() async {
      LogUtil.info(
        '[ClassRepo] syncBaseContext start semester=$targetSemester userId=$currentUserId',
      );
      final context = await Api.getClassTableContext(
        semester: targetSemester,
        userId: currentUserId,
        campusId: currentCampusId,
        selectedCampusId: currentSelectedCampusId,
      );
      _pageContext = context;
      LogUtil.info(
        '[ClassRepo] syncBaseContext success semesters=${context.semesters.length} userId=${context.userContext.userId} xqid=${context.userContext.campusId} xqid1=${context.userContext.selectedCampusId}',
      );
      return context;
    });

    _syncBaseContextTask = task;
    _syncBaseContextTaskSemester = targetSemester;
    _syncBaseContextTaskForceRefresh = forceRefresh;
    try {
      return await task;
    } finally {
      if (identical(_syncBaseContextTask, task)) {
        _syncBaseContextTask = null;
        _syncBaseContextTaskSemester = null;
        _syncBaseContextTaskForceRefresh = false;
      }
    }
  }

  Future<ClassTableMetaResponse> fetchMeta({
    String? semester,
    bool forceRefresh = false,
  }) async {
    final targetSemester = semester != null && semester.isNotEmpty
        ? semester
        : currentSemester;
    await syncBaseContext(semester: targetSemester, forceRefresh: false);
    return _runWithLoginRetry(() async {
      LogUtil.info(
        '[ClassRepo] fetchMeta start semester=$targetSemester userId=$currentUserId xqid=$currentCampusId',
      );
      final response = await Api.getClassTableMeta(
        semester: targetSemester,
        userId: currentUserId,
        campusId: currentCampusId,
      );
      _metaResponse = response;
      LogUtil.info(
        '[ClassRepo] fetchMeta success currentWeek=${response.data.currentWeek}',
      );
      return response;
    });
  }

  Future<List<ClassMeta>> fetchWeekMeta(
    int week, {
    String? semester,
    bool forceRefresh = false,
  }) async {
    final targetSemester = semester != null && semester.isNotEmpty
        ? semester
        : currentSemester;
    await syncBaseContext(semester: targetSemester, forceRefresh: false);
    return _runWithLoginRetry(() async {
      LogUtil.info(
        '[ClassRepo] fetchWeekMeta start semester=$targetSemester week=$week',
      );
      final list = await Api.getWeekMeta(semester: targetSemester, week: week);
      LogUtil.info('[ClassRepo] fetchWeekMeta success count=${list.length}');
      return list;
    });
  }

  Future<ClassTableCourseResponse> fetchCourses(
    int week, {
    String? semester,
    bool forceRefresh = false,
  }) async {
    final targetSemester = semester != null && semester.isNotEmpty
        ? semester
        : currentSemester;
    await syncBaseContext(semester: targetSemester, forceRefresh: false);
    return _runWithLoginRetry(() async {
      LogUtil.info(
        '[ClassRepo] fetchCourses start semester=$targetSemester week=$week userId=$currentUserId xqid=$currentCampusId',
      );
      final response = await Api.getClassTableCourses(
        semester: targetSemester,
        userId: currentUserId,
        week: week,
        campusId: currentCampusId,
      );
      LogUtil.info(
        '[ClassRepo] fetchCourses success count=${response.data.courses.length}',
      );
      return response;
    });
  }

  void clearCaches() {
    _pageContext = null;
    _metaResponse = null;
    _syncBaseContextTask = null;
    _syncBaseContextTaskSemester = null;
    _syncBaseContextTaskForceRefresh = false;
    LogUtil.debug('[ClassRepo] clearCaches');
  }

  ClassTablePageContext? _resolveReusablePageContext(String targetSemester) {
    final context = _pageContext ?? _userRepo.pageContext;
    if (context == null) {
      return null;
    }

    final userContext = context.userContext;
    if (userContext.userId.isEmpty || userContext.selectedSemester.isEmpty) {
      return null;
    }

    if (targetSemester.isNotEmpty &&
        userContext.selectedSemester != targetSemester) {
      return null;
    }

    return context;
  }

  Future<T> _runWithLoginRetry<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiLoginExpiredException catch (e, s) {
      LogUtil.warnE('[ClassRepo] login expired, trying recover', e, s);
      final recovered = await _userRepo.recoverFromExpiredLogin();
      if (!recovered) {
        LogUtil.warn('[ClassRepo] recover failed after login expired');
        rethrow;
      }

      LogUtil.info('[ClassRepo] recover success, retrying request');
      return action();
    }
  }
}
