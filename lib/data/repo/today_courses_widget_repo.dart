// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:class_tool/data/injector/injector.dart';
import 'package:class_tool/data/model/class_meta.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:class_tool/data/model/class_table_course.dart';
import 'package:class_tool/data/model/today_course_snapshot.dart';
import 'package:class_tool/data/repo/class_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/data/services/morning_briefing_service.dart';
import 'package:class_tool/data/services/today_snapshot_cache.dart';
import 'package:class_tool/utils/http_utils.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

const String _widgetProviderName = 'TodayCoursesWidgetProvider';
const String _widgetQualifiedProviderName =
    'me.cubevlmu.gxnutool.TodayCoursesWidgetProvider';
const String _dailyRefreshUniqueName = 'today_courses_widget_daily_refresh';
const String _dailyRefreshTaskName = 'todayCoursesWidgetDailyRefresh';
const String _autoSyncEnabledKey = 'today_courses_widget_auto_sync_enabled';
const String _pendingSyncKey = 'today_courses_widget_pending_sync';

enum TodayCoursesWidgetState { idle, loading, ready, error, loggedOut }

class TodayCoursesWidgetRepo {
  TodayCoursesWidgetRepo({UserRepo? userRepo, ClassRepo? classRepo})
    : _userRepo = userRepo ?? Get.find<UserRepo>(),
      _classRepo = classRepo ?? Get.find<ClassRepo>();

  final UserRepo _userRepo;
  final ClassRepo _classRepo;

  bool _initialized = false;
  Future<void>? _syncTask;
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  bool get isAutoSyncEnabled =>
      StorageUtils.settings.get(_autoSyncEnabledKey) == true;

  Future<void> initialize() async {
    if (!Platform.isAndroid || _initialized) {
      return;
    }

    await HomeWidget.registerInteractivityCallback(
      todayCoursesWidgetInteractivityCallback,
    );
    await Workmanager().initialize(todayCoursesWidgetCallbackDispatcher);
    await restoreFromCache();
    if (isAutoSyncEnabled) {
      await scheduleNextDailyRefresh();
    }

    _connectivitySub = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      if (result != ConnectivityResult.none) {
        _retryPendingSyncIfNeeded();
      }
    });

    Future<void>.microtask(_retryPendingSyncIfNeeded);
    _initialized = true;
  }

  Future<void> _retryPendingSyncIfNeeded() async {
    if (!isAutoSyncEnabled) return;
    final pending =
        StorageUtils.settings.get(_pendingSyncKey) as bool? ?? false;
    if (!pending) return;
    if (!await _hasNetworkConnection()) return;

    LogUtil.info('[TodayCoursesWidget] retrying pending sync');
    await StorageUtils.settings.put(_pendingSyncKey, false);
    await syncAndUpdate(showLoading: true, reason: 'pending_retry');
  }

  Future<void> setAutoSyncEnabled(bool enabled) async {
    if (!Platform.isAndroid) {
      return;
    }

    await StorageUtils.settings.put(_autoSyncEnabledKey, enabled);
    if (enabled) {
      await scheduleNextDailyRefresh();
      return;
    }
    await cancelAutoSync();
  }

  Future<void> scheduleNextDailyRefresh() async {
    if (!Platform.isAndroid) {
      return;
    }

    if (!isAutoSyncEnabled) {
      await cancelAutoSync();
      return;
    }

    final now = DateTime.now();
    var nextRun = DateTime(now.year, now.month, now.day, 7);
    if (!nextRun.isAfter(now)) {
      nextRun = nextRun.add(const Duration(days: 1));
    }

    await Workmanager().registerOneOffTask(
      _dailyRefreshUniqueName,
      _dailyRefreshTaskName,
      initialDelay: nextRun.difference(now),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  Future<void> cancelAutoSync() async {
    if (!Platform.isAndroid) {
      return;
    }
    await Workmanager().cancelByUniqueName(_dailyRefreshUniqueName);
  }

  Future<void> syncAndUpdate({
    bool showLoading = false,
    String reason = 'manual',
  }) async {
    if (!Platform.isAndroid) {
      return;
    }

    final activeTask = _syncTask;
    if (activeTask != null) {
      LogUtil.info(
        '[TodayCoursesWidget] sync joined existing task reason=$reason',
      );
      await activeTask;
      return;
    }

    final task = _performSyncAndUpdate(
      showLoading: showLoading,
      reason: reason,
    );
    _syncTask = task;
    try {
      await task;
    } finally {
      if (identical(_syncTask, task)) {
        _syncTask = null;
      }
    }
  }

  Future<void> _performSyncAndUpdate({
    required bool showLoading,
    required String reason,
  }) async {
    LogUtil.info('[TodayCoursesWidget] sync start reason=$reason');
    await StorageUtils.ensureInitialized();

    if (showLoading) {
      await _writeState(
        state: TodayCoursesWidgetState.loading,
        statusText: '正在刷新',
      );
      await _updateWidget();
    }

    try {
      if (!await _hasNetworkConnection()) {
        LogUtil.warn('[TodayCoursesWidget] sync skipped because network is unavailable');
        if (reason == _dailyRefreshTaskName) {
          await StorageUtils.settings.put(_pendingSyncKey, true);
        }
        await _showCachedOrError(
          cachedStatusText: '当前无网络，已显示上次结果',
          emptyStatusText: '当前无网络，暂无课程缓存',
          fallbackState: TodayCoursesWidgetState.error,
        );
        return;
      }

      await StorageUtils.settings.put(_pendingSyncKey, false);

      await HttpUtils().init();
      await _userRepo.setup();
      if (!_userRepo.isLogin) {
        if (!_userRepo.storage.hasLogin) {
          LogUtil.warn('[TodayCoursesWidget] sync aborted because user is not logged in');
          await clearAndUpdate(statusText: '登录后可查看今日课程');
        } else {
          LogUtil.warn(
            '[TodayCoursesWidget] sync aborted because stored login exists but current session is invalid',
          );
          await _showCachedOrError(
            cachedStatusText: '登录状态失效，请打开 App 重新登录',
            emptyStatusText: '登录状态失效，请打开 App 重新登录',
            fallbackState: TodayCoursesWidgetState.error,
          );
        }
        return;
      }

      final snapshot = await _syncTodaySnapshot();
      await updateFromSnapshot(snapshot);
      await StorageUtils.settings.put(_pendingSyncKey, false);
      if (reason == _dailyRefreshTaskName) {
        await MorningBriefingService.show(snapshot);
      }
      LogUtil.info(
        '[TodayCoursesWidget] sync success week=${snapshot.currentWeekText} courses=${snapshot.items.length}',
      );
    } catch (e, s) {
      LogUtil.errorE('[TodayCoursesWidget] sync failed', e, s);
      final hasNetwork = await _hasNetworkConnection();
      await _showCachedOrError(
        cachedStatusText: hasNetwork ? '刷新失败，已显示上次结果' : '当前无网络，已显示上次结果',
        emptyStatusText: hasNetwork ? '刷新失败，请稍后重试' : '当前无网络，暂无课程缓存',
        fallbackState: TodayCoursesWidgetState.error,
      );
    } finally {
      await scheduleNextDailyRefresh();
    }
  }

  Future<void> updateFromCurrentSchedule({
    required String semester,
    required int currentWeek,
    required List<ClassMeta> weekMeta,
    required List<ClassTableCourse> weekCourses,
    required ClassTableMeta? meta,
  }) async {
    if (!Platform.isAndroid) {
      return;
    }

    final snapshot = buildTodayCourseSnapshot(
      semester: semester,
      currentWeek: currentWeek,
      weekMeta: weekMeta,
      weekCourses: weekCourses,
      meta: meta,
    );
    await updateFromSnapshot(snapshot);
  }

  Future<void> updateFromSnapshot(TodayCourseSnapshot snapshot) async {
    if (!Platform.isAndroid) {
      return;
    }

    await saveSnapshot(snapshot);
    await _saveCoreData(snapshot);
    await _writeState(
      state: TodayCoursesWidgetState.ready,
      statusText: snapshot.items.isEmpty ? '今天没有课程安排' : snapshot.headlineText,
    );
    await _updateWidget();
  }

  Future<void> clearAndUpdate({String statusText = '登录后可查看今日课程'}) async {
    if (!Platform.isAndroid) {
      return;
    }

    await clearSnapshot();
    await _clearItems();
    await _saveString('semesterText', '当前学期');
    await _saveString('weekText', '--');
    await _saveString('headlineText', '今日课程');
    await _saveString('updatedAtText', '');
    await _writeState(
      state: TodayCoursesWidgetState.loggedOut,
      statusText: statusText,
    );
    await _updateWidget();
  }

  Future<void> restoreFromCache() async {
    if (!Platform.isAndroid) {
      return;
    }

    final entry = loadCachedTodaySnapshotEntry();
    if (entry == null) {
      return;
    }
    await _saveCoreData(entry.snapshot, updatedAt: entry.savedAt);
    await _writeState(
      state: TodayCoursesWidgetState.ready,
      statusText: entry.snapshot.items.isEmpty
          ? '今天没有课程安排'
          : entry.snapshot.headlineText,
    );
    await _updateWidget();
  }

  Future<void> debugRunScheduledSync() {
    return syncAndUpdate(showLoading: true, reason: _dailyRefreshTaskName);
  }

  TodayCourseSnapshot? loadCachedTodaySnapshot() {
    return TodaySnapshotCache.load();
  }

  TodaySnapshotCacheEntry? loadCachedTodaySnapshotEntry() {
    return TodaySnapshotCache.loadEntry();
  }

  Future<void> saveSnapshot(TodayCourseSnapshot snapshot) async {
    await TodaySnapshotCache.save(snapshot);
  }

  Future<void> clearSnapshot() async {
    await TodaySnapshotCache.clear();
  }

  Future<TodayCourseSnapshot> _syncTodaySnapshot() async {
    final context = await _classRepo.syncBaseContext(forceRefresh: true);
    final effectiveSemester = context.userContext.selectedSemester;
    final metaResponse = await _classRepo.fetchMeta(
      semester: effectiveSemester,
      forceRefresh: true,
    );
    final meta = metaResponse.data;
    final resolvedWeek = meta.currentWeek > 0
        ? meta.currentWeek
        : (meta.weekRanges.isNotEmpty ? meta.weekRanges.first.week : 1);
    final weekMetaTask = _classRepo.fetchWeekMeta(
      resolvedWeek,
      semester: effectiveSemester,
      forceRefresh: true,
    );
    final courseResponseTask = _classRepo.fetchCourses(
      resolvedWeek,
      semester: effectiveSemester,
      forceRefresh: true,
    );
    final weekMeta = await weekMetaTask;
    final courseResponse = await courseResponseTask;

    return buildTodayCourseSnapshot(
      semester: effectiveSemester,
      currentWeek: resolvedWeek,
      weekMeta: weekMeta,
      weekCourses: courseResponse.data.courses,
      meta: meta,
    );
  }

  Future<bool> _hasNetworkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _showCachedOrError({
    required String cachedStatusText,
    required String emptyStatusText,
    required TodayCoursesWidgetState fallbackState,
  }) async {
    final entry = loadCachedTodaySnapshotEntry();
    if (entry != null) {
      await _saveCoreData(entry.snapshot, updatedAt: entry.savedAt);
      await _writeState(
        state: TodayCoursesWidgetState.ready,
        statusText: cachedStatusText,
      );
      await _updateWidget();
      return;
    }

    await _clearItems();
    await _saveString('semesterText', '当前学期');
    await _saveString('weekText', '--');
    await _saveString('headlineText', '今日课程');
    await _saveString('updatedAtText', '');
    await _writeState(state: fallbackState, statusText: emptyStatusText);
    await _updateWidget();
  }

  Future<void> _saveCoreData(
    TodayCourseSnapshot snapshot, {
    DateTime? updatedAt,
  }) async {
    await _saveString('semesterText', snapshot.semesterText);
    await _saveString('weekText', snapshot.currentWeekText);
    await _saveString('headlineText', snapshot.headlineText);
    await _saveString(
      'updatedAtText',
      _buildUpdateTimeText(updatedAt ?? DateTime.now()),
    );
    await _saveInt('courseCount', snapshot.items.length);
    await _saveString(
      'coursesJson',
      jsonEncode(
        snapshot.items
            .map(
              (item) => <String, String>{
                'time': item.timeText,
                'title': item.titleText,
                'room': item.roomText,
              },
            )
            .toList(growable: false),
      ),
    );
  }

  Future<void> _clearItems() async {
    await _saveInt('courseCount', 0);
    await _saveString('coursesJson', '[]');
  }

  Future<void> _writeState({
    required TodayCoursesWidgetState state,
    required String statusText,
  }) async {
    await _saveString('state', state.name);
    await _saveString('statusText', statusText);
  }

  Future<void> _saveString(String key, String value) async {
    await HomeWidget.saveWidgetData<String>(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    await HomeWidget.saveWidgetData<int>(key, value);
  }

  Future<void> _updateWidget() async {
    await HomeWidget.updateWidget(
      name: _widgetProviderName,
      qualifiedAndroidName: _widgetQualifiedProviderName,
    );
  }

  String _buildUpdateTimeText(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '更新于 $hour:$minute';
  }
}

@pragma('vm:entry-point')
void todayCoursesWidgetCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    DartPluginRegistrant.ensureInitialized();
    await StorageUtils.ensureInitialized();
    await LogUtil.init();
    Injector.injectRepos();
    await MorningBriefingService.initialize();
    await Get.find<TodayCoursesWidgetRepo>().syncAndUpdate(reason: taskName);
    return true;
  });
}

@pragma('vm:entry-point')
Future<void> todayCoursesWidgetInteractivityCallback(Uri? data) async {
  DartPluginRegistrant.ensureInitialized();
  await StorageUtils.ensureInitialized();
  await LogUtil.init();
  Injector.injectRepos();

  if (data?.host == 'refresh') {
    await Get.find<TodayCoursesWidgetRepo>().syncAndUpdate(
      showLoading: true,
      reason: 'widget_button',
    );
  }
}
