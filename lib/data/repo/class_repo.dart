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
import 'package:class_tool/data/repo/repo_request_helper.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:get/get.dart';

class ClassRepo {
  ClassRepo({UserRepo? userRepo}) : this._(userRepo ?? Get.find<UserRepo>());

  ClassRepo._(this._userRepo)
    : _helper = RepoRequestHelper(userRepo: _userRepo, logTag: 'ClassRepo');

  final UserRepo _userRepo;
  final RepoRequestHelper _helper;

  ClassTablePageContext? _pageContext;
  ClassTableMetaResponse? _metaResponse;
  final Map<String, ClassTableMetaResponse> _metaCache = {};
  final Map<String, List<ClassMeta>> _weekMetaCache = {};
  final Map<String, ClassTableCourseResponse> _courseCache = {};
  final Map<String, Future<ClassTableMetaResponse>> _metaTasks = {};
  final Map<String, Future<List<ClassMeta>>> _weekMetaTasks = {};
  final Map<String, Future<ClassTableCourseResponse>> _courseTasks = {};
  Future<ClassTablePageContext>? _syncBaseContextTask;
  String? _syncBaseContextTaskSemester;

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
    if (activeTask != null && _syncBaseContextTaskSemester == targetSemester) {
      LogUtil.debug(
        '[ClassRepo] syncBaseContext join in-flight request semester=$targetSemester',
      );
      return activeTask;
    }

    final task = _helper.runWithLoginRetry('sync class table context', () async {
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
    try {
      return await task;
    } finally {
      if (identical(_syncBaseContextTask, task)) {
        _syncBaseContextTask = null;
        _syncBaseContextTaskSemester = null;
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
    final effectiveSemester = targetSemester.isNotEmpty
        ? targetSemester
        : currentSemester;
    final key = _cacheKey('meta', effectiveSemester);
    if (!forceRefresh) {
      final cached = _metaCache[key];
      if (cached != null) {
        LogUtil.debug('[ClassRepo] fetchMeta reuse cached key=$key');
        _metaResponse = cached;
        return cached;
      }
    }

    return _helper.dedupe(_metaTasks, key, () {
      return _helper.runWithLoginRetry('fetch class table meta', () async {
        LogUtil.info(
          '[ClassRepo] fetchMeta start semester=$effectiveSemester userId=$currentUserId xqid=$currentCampusId',
        );
        final response = await Api.getClassTableMeta(
          semester: effectiveSemester,
          userId: currentUserId,
          campusId: currentCampusId,
        );
        _metaCache[key] = response;
        _metaResponse = response;
        LogUtil.info(
          '[ClassRepo] fetchMeta success currentWeek=${response.data.currentWeek}',
        );
        return response;
      });
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
    final effectiveSemester = targetSemester.isNotEmpty
        ? targetSemester
        : currentSemester;
    final key = _cacheKey('weekMeta', effectiveSemester, week: week);
    if (!forceRefresh) {
      final cached = _weekMetaCache[key];
      if (cached != null) {
        LogUtil.debug('[ClassRepo] fetchWeekMeta reuse cached key=$key');
        return cached;
      }
    }

    return _helper.dedupe(_weekMetaTasks, key, () {
      return _helper.runWithLoginRetry('fetch class week metadata', () async {
        LogUtil.info(
          '[ClassRepo] fetchWeekMeta start semester=$effectiveSemester week=$week',
        );
        final list = await Api.getWeekMeta(
          semester: effectiveSemester,
          week: week,
        );
        _weekMetaCache[key] = list;
        LogUtil.info('[ClassRepo] fetchWeekMeta success count=${list.length}');
        return list;
      });
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
    final effectiveSemester = targetSemester.isNotEmpty
        ? targetSemester
        : currentSemester;
    final key = _cacheKey('courses', effectiveSemester, week: week);
    if (!forceRefresh) {
      final cached = _courseCache[key];
      if (cached != null) {
        LogUtil.debug('[ClassRepo] fetchCourses reuse cached key=$key');
        return cached;
      }
    }

    return _helper.dedupe(_courseTasks, key, () {
      return _helper.runWithLoginRetry('fetch class table courses', () async {
        LogUtil.info(
          '[ClassRepo] fetchCourses start semester=$effectiveSemester week=$week userId=$currentUserId xqid=$currentCampusId',
        );
        final response = await Api.getClassTableCourses(
          semester: effectiveSemester,
          userId: currentUserId,
          week: week,
          campusId: currentCampusId,
        );
        _courseCache[key] = response;
        LogUtil.info(
          '[ClassRepo] fetchCourses success count=${response.data.courses.length}',
        );
        return response;
      });
    });
  }

  void clearCaches() {
    _pageContext = null;
    _metaResponse = null;
    _metaCache.clear();
    _weekMetaCache.clear();
    _courseCache.clear();
    _metaTasks.clear();
    _weekMetaTasks.clear();
    _courseTasks.clear();
    _syncBaseContextTask = null;
    _syncBaseContextTaskSemester = null;
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

    if (context.semesters.isEmpty) {
      return null;
    }

    if (targetSemester.isNotEmpty &&
        userContext.selectedSemester != targetSemester) {
      return null;
    }

    return context;
  }

  String _cacheKey(String type, String semester, {int? week}) {
    return [
      type,
      semester,
      if (week != null) week.toString(),
      currentUserId,
      currentCampusId,
      currentSelectedCampusId,
    ].join('|');
  }
}
