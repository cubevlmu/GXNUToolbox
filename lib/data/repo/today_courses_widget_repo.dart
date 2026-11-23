// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:class_tool/data/model/class_meta.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:class_tool/data/model/class_table_course.dart';
import 'package:class_tool/data/model/today_course_snapshot.dart';
import 'package:class_tool/data/repo/bell_schedule_repo.dart';
import 'package:class_tool/data/repo/class_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/data/services/academic_term_service.dart';
import 'package:class_tool/data/services/morning_briefing_service.dart';
import 'package:class_tool/data/services/today_snapshot_cache.dart';
import 'package:class_tool/utils/http_utils.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

const String _legacyDailyRefreshUniqueName =
    'today_courses_widget_daily_refresh';
const String _dailyRefreshUniquePrefix = 'today_courses_widget_daily_refresh_';
const String _debugDailyRefreshUniqueName =
    'today_courses_widget_daily_refresh_debug';
const String _pendingRetryUniqueName = 'today_courses_widget_pending_retry';
const String _periodicRefreshUniqueName =
    'today_courses_widget_periodic_refresh';
const String _dailyRefreshTaskName = 'todayCoursesWidgetDailyRefresh';
const String _pendingRetryTaskName = 'todayCoursesWidgetPendingRetry';
const String _periodicRefreshTaskName = 'todayCoursesWidgetPeriodicRefresh';
const String _manualDebugReason = 'manual_debug';
const String _scheduledDebugReason = 'scheduled_debug';
const String _autoSyncEnabledKey = 'today_courses_widget_auto_sync_enabled';
const String _pendingSyncKey = 'today_courses_widget_pending_sync';
const String _scheduledDailyWorkNameKey =
    'today_courses_widget_scheduled_daily_work_name';
const String _lastScheduledAtKey = 'today_courses_widget_last_scheduled_at';
const String _lastScheduledRunAtKey =
    'today_courses_widget_last_scheduled_run_at';
const String _lastSyncStartedAtKey =
    'today_courses_widget_last_sync_started_at';
const String _lastSyncSuccessAtKey =
    'today_courses_widget_last_sync_success_at';
const String _lastSyncFailureAtKey =
    'today_courses_widget_last_sync_failure_at';
const String _lastSyncFailureReasonKey =
    'today_courses_widget_last_sync_failure_reason';
const String _lastTaskCallbackAtKey =
    'today_courses_widget_last_task_callback_at';
const String _lastTaskCallbackNameKey =
    'today_courses_widget_last_task_callback_name';
const String _lastTaskRegisterFailureKey =
    'today_courses_widget_last_task_register_failure';
const String _lastRetryScheduledAtKey =
    'today_courses_widget_last_retry_scheduled_at';
const String _lastRetryScheduledRunAtKey =
    'today_courses_widget_last_retry_scheduled_run_at';
const String _lastDebugScheduledAtKey =
    'today_courses_widget_last_debug_scheduled_at';
const String _lastDebugScheduledRunAtKey =
    'today_courses_widget_last_debug_scheduled_run_at';
const String _lastProviderUpdateAtKey =
    'today_courses_widget_last_provider_update_at';
const String _lastProviderUpdateFailureKey =
    'today_courses_widget_last_provider_update_failure';
const String _diagnosticStateKey = 'today_courses_widget_diagnostic_state';
const String _diagnosticStatusTextKey =
    'today_courses_widget_diagnostic_status_text';
const String _androidPackageName = 'me.cubevlmu.gxnutool';
const Duration _debugDailyRefreshDelay = Duration(seconds: 25);
const Duration _pendingRetryDelay = Duration(minutes: 30);
const Duration _workRetryBackoffDelay = Duration(minutes: 15);
const Duration _backgroundBootstrapTimeout = Duration(seconds: 20);

enum TodayCoursesWidgetState {
  idle,
  loading,
  ready,
  readyStale,
  error,
  loggedOut,
}

class TodayCoursesWidgetRepo {
  TodayCoursesWidgetRepo({
    UserRepo? userRepo,
    ClassRepo? classRepo,
    BellScheduleRepo? bellScheduleRepo,
  }) : _userRepo = userRepo ?? Get.find<UserRepo>(),
       _classRepo = classRepo ?? Get.find<ClassRepo>(),
       _bellScheduleRepo = bellScheduleRepo ?? Get.find<BellScheduleRepo>();

  final UserRepo _userRepo;
  final ClassRepo _classRepo;
  final BellScheduleRepo _bellScheduleRepo;

  bool _initialized = false;
  bool _workmanagerInitialized = false;
  Future<void>? _initializeTask;
  Future<bool>? _syncTask;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  bool get isAutoSyncEnabled =>
      StorageUtils.settings.get(_autoSyncEnabledKey) == true;

  Future<void> initialize() async {
    if (!Platform.isAndroid || _initialized) {
      return;
    }
    final activeTask = _initializeTask;
    if (activeTask != null) {
      return activeTask;
    }

    final task = _doInitialize();
    _initializeTask = task;
    return task.whenComplete(() {
      if (identical(_initializeTask, task)) {
        _initializeTask = null;
      }
    });
  }

  Future<void> _doInitialize() async {
    if (!Platform.isAndroid || _initialized) {
      return;
    }

    await StorageUtils.ensureInitialized();

    try {
      await HomeWidget.registerInteractivityCallback(
        todayCoursesWidgetInteractivityCallback,
      );
    } catch (e, s) {
      LogUtil.warnE(
        '[TodayCoursesWidget] register interactivity callback failed',
        e,
        s,
      );
    }

    try {
      await _ensureWorkmanagerInitialized();
    } catch (e, s) {
      await _recordTaskRegisterFailure(e);
      LogUtil.warnE('[TodayCoursesWidget] initialize Workmanager failed', e, s);
    }

    try {
      await restoreFromCache();
    } catch (e, s) {
      LogUtil.warnE('[TodayCoursesWidget] restore widget cache failed', e, s);
    }

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        _retryPendingSyncIfNeeded();
      }
    });

    _initialized = true;
    if (isAutoSyncEnabled) {
      await _scheduleNextDailyRefreshBestEffort();
      unawaited(_retryPendingSyncIfNeeded());
    }
  }

  Future<void> _ensureWorkmanagerInitialized() async {
    if (_workmanagerInitialized) {
      return;
    }
    await Workmanager().initialize(todayCoursesWidgetCallbackDispatcher);
    _workmanagerInitialized = true;
  }

  Future<void> _retryPendingSyncIfNeeded() async {
    if (!isAutoSyncEnabled) return;
    if (_syncTask != null) return;
    final pending =
        StorageUtils.settings.get(_pendingSyncKey) as bool? ?? false;
    if (!pending) return;
    if (!await _hasNetworkConnection()) return;

    LogUtil.info('[TodayCoursesWidget] retrying pending sync');
    await syncAndUpdate(showLoading: true, reason: 'pending_retry');
  }

  Future<void> _schedulePendingRetry() async {
    if (!Platform.isAndroid || !isAutoSyncEnabled) {
      return;
    }

    final nextRun = DateTime.now().add(_pendingRetryDelay);
    try {
      await Workmanager().registerOneOffTask(
        _pendingRetryUniqueName,
        _pendingRetryTaskName,
        initialDelay: _pendingRetryDelay,
        constraints: Constraints(networkType: NetworkType.connected),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: _workRetryBackoffDelay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      await StorageUtils.settings.put(_lastRetryScheduledAtKey, _nowIso());
      await StorageUtils.settings.put(
        _lastRetryScheduledRunAtKey,
        nextRun.toIso8601String(),
      );
      await StorageUtils.settings.delete(_lastTaskRegisterFailureKey);
      LogUtil.info(
        '[TodayCoursesWidget] schedule pending retry nextRun=$nextRun',
      );
    } catch (e) {
      await _recordTaskRegisterFailure(e);
      LogUtil.warn('[TodayCoursesWidget] schedule pending retry failed: $e');
    }
  }

  Future<void> setAutoSyncEnabled(bool enabled) async {
    if (!Platform.isAndroid) {
      return;
    }

    await initialize();
    await StorageUtils.settings.put(_autoSyncEnabledKey, enabled);
    if (enabled) {
      await _ensureWorkmanagerInitialized();
      await scheduleNextDailyRefresh();
      unawaited(() async {
        await syncAndUpdate(showLoading: true, reason: 'auto_sync_enabled');
      }());
      return;
    }
    await cancelAutoSync();
  }

  Future<void> scheduleNextDailyRefresh({
    bool cancelPrevious = true,
    bool forceNextDay = false,
  }) async {
    if (!Platform.isAndroid) {
      return;
    }

    if (!isAutoSyncEnabled) {
      return;
    }

    final now = DateTime.now();
    var nextRun = DateTime(now.year, now.month, now.day, 7);
    if (forceNextDay || !nextRun.isAfter(now)) {
      nextRun = DateTime(
        now.year,
        now.month,
        now.day,
        7,
      ).add(const Duration(days: 1));
    }

    final workName = _dailyWorkNameFor(nextRun);
    final delay = nextRun.difference(now);

    final previousWorkName = StorageUtils.settings
        .get(_scheduledDailyWorkNameKey)
        ?.toString();

    if (cancelPrevious &&
        previousWorkName != null &&
        previousWorkName.isNotEmpty &&
        previousWorkName != workName) {
      await Workmanager().cancelByUniqueName(previousWorkName);
    }

    if (cancelPrevious) {
      await Workmanager().cancelByUniqueName(_legacyDailyRefreshUniqueName);
    }

    LogUtil.info(
      '[TodayCoursesWidget] schedule daily sync '
      'workName=$workName nextRun=$nextRun delay=${delay.inMinutes}min',
    );

    try {
      await Workmanager().registerOneOffTask(
        workName,
        _dailyRefreshTaskName,
        initialDelay: delay,
        inputData: <String, dynamic>{'scheduledFor': nextRun.toIso8601String()},
        constraints: Constraints(networkType: NetworkType.connected),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: _workRetryBackoffDelay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      await Workmanager().registerPeriodicTask(
        _periodicRefreshUniqueName,
        _periodicRefreshTaskName,
        frequency: const Duration(hours: 6),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
      await StorageUtils.settings.put(_scheduledDailyWorkNameKey, workName);
      await StorageUtils.settings.put(_lastScheduledAtKey, _nowIso());
      await StorageUtils.settings.put(
        _lastScheduledRunAtKey,
        nextRun.toIso8601String(),
      );
      await StorageUtils.settings.delete(_lastTaskRegisterFailureKey);
    } catch (e) {
      await _recordTaskRegisterFailure(e);
      rethrow;
    }
  }

  Future<void> _scheduleNextDailyRefreshBestEffort({
    bool cancelPrevious = true,
    bool forceNextDay = false,
  }) async {
    try {
      await scheduleNextDailyRefresh(
        cancelPrevious: cancelPrevious,
        forceNextDay: forceNextDay,
      );
    } catch (e, s) {
      LogUtil.warnE('[TodayCoursesWidget] schedule next daily failed', e, s);
    }
  }

  Future<void> debugScheduleDailyRefreshSoon() async {
    if (!Platform.isAndroid) {
      return;
    }

    await initialize();
    await _ensureWorkmanagerInitialized();

    await Workmanager().cancelByUniqueName(_debugDailyRefreshUniqueName);

    final nextRun = DateTime.now().add(_debugDailyRefreshDelay);
    LogUtil.info(
      '[TodayCoursesWidget] schedule debug daily sync '
      'workName=$_debugDailyRefreshUniqueName '
      'nextRun=$nextRun delay=${_debugDailyRefreshDelay.inSeconds}s',
    );

    try {
      await Workmanager().registerOneOffTask(
        _debugDailyRefreshUniqueName,
        _dailyRefreshTaskName,
        initialDelay: _debugDailyRefreshDelay,
        inputData: <String, dynamic>{
          'debug': true,
          'scheduledFor': nextRun.toIso8601String(),
        },
        constraints: Constraints(networkType: NetworkType.connected),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: _workRetryBackoffDelay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      await StorageUtils.settings.put(_lastDebugScheduledAtKey, _nowIso());
      await StorageUtils.settings.put(
        _lastDebugScheduledRunAtKey,
        nextRun.toIso8601String(),
      );
      await StorageUtils.settings.delete(_lastTaskRegisterFailureKey);
    } catch (e) {
      await _recordTaskRegisterFailure(e);
      rethrow;
    }
  }

  String _dailyWorkNameFor(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$_dailyRefreshUniquePrefix$year$month$day';
  }

  Future<void> cancelAutoSync() async {
    if (!Platform.isAndroid) {
      return;
    }

    final previousWorkName = StorageUtils.settings
        .get(_scheduledDailyWorkNameKey)
        ?.toString();

    if (previousWorkName != null && previousWorkName.isNotEmpty) {
      await Workmanager().cancelByUniqueName(previousWorkName);
    }

    await Workmanager().cancelByUniqueName(_legacyDailyRefreshUniqueName);
    await Workmanager().cancelByUniqueName(_debugDailyRefreshUniqueName);
    await Workmanager().cancelByUniqueName(_pendingRetryUniqueName);
    await Workmanager().cancelByUniqueName(_periodicRefreshUniqueName);
    await StorageUtils.settings.delete(_scheduledDailyWorkNameKey);
    await StorageUtils.settings.delete(_lastScheduledAtKey);
    await StorageUtils.settings.delete(_lastScheduledRunAtKey);
    await StorageUtils.settings.delete(_lastRetryScheduledAtKey);
    await StorageUtils.settings.delete(_lastRetryScheduledRunAtKey);
    await StorageUtils.settings.delete(_lastDebugScheduledAtKey);
    await StorageUtils.settings.delete(_lastDebugScheduledRunAtKey);
    LogUtil.info('[TodayCoursesWidget] cancel daily sync');
  }

  Future<bool> syncAndUpdate({
    bool showLoading = false,
    String reason = 'manual',
  }) async {
    if (!Platform.isAndroid) {
      return false;
    }

    final activeTask = _syncTask;
    if (activeTask != null) {
      LogUtil.info(
        '[TodayCoursesWidget] sync joined existing task reason=$reason',
      );
      return await activeTask;
    }

    final task = _performSyncAndUpdate(
      showLoading: showLoading,
      reason: reason,
    );
    _syncTask = task;
    try {
      return await task;
    } finally {
      if (identical(_syncTask, task)) {
        _syncTask = null;
      }
    }
  }

  Future<bool> _performSyncAndUpdate({
    required bool showLoading,
    required String reason,
  }) async {
    LogUtil.info('[TodayCoursesWidget] sync start reason=$reason');
    await StorageUtils.ensureInitialized();
    await _recordSyncStarted(reason);

    if (showLoading) {
      await _writeState(
        state: TodayCoursesWidgetState.loading,
        statusText: '正在刷新',
      );
      await _updateWidget();
    }

    try {
      if (!await _hasNetworkConnection()) {
        LogUtil.warn(
          '[TodayCoursesWidget] sync skipped because network is unavailable',
        );
        if (_shouldMarkPendingSync(reason)) {
          await StorageUtils.settings.put(_pendingSyncKey, true);
          await _schedulePendingRetry();
        }
        await _showCachedOrError(
          cachedStatusText: '数据过期，当前无网络，已显示上次结果，请打开 App 手动同步',
          emptyStatusText: '当前无网络，暂无课程缓存',
          fallbackState: TodayCoursesWidgetState.error,
        );
        await _recordSyncFailure('network unavailable');
        return false;
      }

      await StorageUtils.settings.put(_pendingSyncKey, false);

      await HttpUtils().init();
      await _userRepo.setup();
      if (!_userRepo.isLogin) {
        if (!_userRepo.storage.hasLogin) {
          LogUtil.warn(
            '[TodayCoursesWidget] sync aborted because user is not logged in',
          );
          await _showCachedOrError(
            cachedStatusText: '登录后可查看今日课程',
            emptyStatusText: '登录后可查看今日课程',
            fallbackState: TodayCoursesWidgetState.loggedOut,
          );
          await _recordSyncFailure('not logged in');
        } else {
          LogUtil.warn(
            '[TodayCoursesWidget] sync aborted because stored login exists '
            'but current session is invalid',
          );
          await _showCachedOrError(
            cachedStatusText: '登录状态失效，请打开 App 重新登录',
            emptyStatusText: '登录状态失效，请打开 App 重新登录',
            fallbackState: TodayCoursesWidgetState.error,
          );
          await _recordSyncFailure(
            'stored login exists but session is invalid',
          );
        }
        return false;
      }

      final snapshot = await _syncTodaySnapshot();
      await updateFromSnapshot(snapshot);
      await StorageUtils.settings.put(_pendingSyncKey, false);
      await Workmanager().cancelByUniqueName(_pendingRetryUniqueName);
      await _recordSyncSuccess();
      if (_shouldShowMorningBriefingForReason(reason)) {
        try {
          await MorningBriefingService.show(snapshot);
        } catch (e, s) {
          LogUtil.warnE(
            '[TodayCoursesWidget] morning briefing failed after sync',
            e,
            s,
          );
        }
      }
      LogUtil.info(
        '[TodayCoursesWidget] sync success '
        'week=${snapshot.currentWeekText} courses=${snapshot.items.length}',
      );
      return true;
    } catch (e, s) {
      LogUtil.errorE('[TodayCoursesWidget] sync failed', e, s);
      if (_userRepo.lastLoginRateLimited) {
        await StorageUtils.settings.put(_pendingSyncKey, true);
        await _schedulePendingRetry();
        await _showCachedOrError(
          cachedStatusText: '学校服务器请求频繁，稍后将自动重试，当前显示上次结果',
          emptyStatusText: '学校服务器请求频繁，稍后将自动重试',
          fallbackState: TodayCoursesWidgetState.error,
        );
        await _recordSyncFailure(_userRepo.lastLoginError);
        return false;
      }
      final hasNetwork = await _hasNetworkConnection();
      if (!hasNetwork && _shouldMarkPendingSync(reason)) {
        await StorageUtils.settings.put(_pendingSyncKey, true);
        await _schedulePendingRetry();
      }
      await _showCachedOrError(
        cachedStatusText: hasNetwork
            ? '数据过期，刷新失败，已显示上次结果，请打开 App 手动同步'
            : '数据过期，当前无网络，已显示上次结果，请打开 App 手动同步',
        emptyStatusText: hasNetwork ? '刷新失败，请稍后重试' : '当前无网络，暂无课程缓存',
        fallbackState: TodayCoursesWidgetState.error,
      );
      await _recordSyncFailure(e.toString());
      return false;
    } finally {
      await _scheduleNextDailyRefreshBestEffort(
        cancelPrevious: reason != _dailyRefreshTaskName,
        forceNextDay: reason == _dailyRefreshTaskName,
      );
    }
  }

  bool _shouldShowMorningBriefingForReason(String reason) {
    if (reason == _dailyRefreshTaskName || reason == _scheduledDebugReason) {
      return true;
    }
    if (reason == 'pending_retry' ||
        reason == _pendingRetryTaskName ||
        reason == _periodicRefreshTaskName) {
      return DateTime.now().hour >= 7 &&
          !MorningBriefingService.hasShownToday();
    }
    return false;
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

    await _loadBellScheduleQuietly();
    final snapshot = buildTodayCourseSnapshot(
      semester: semester,
      currentWeek: currentWeek,
      weekMeta: weekMeta,
      weekCourses: weekCourses,
      meta: meta,
      periodSettings: _effectivePeriodSettings(meta),
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
      statusText: snapshot.currentWeekText == '假期'
          ? '当前为假期'
          : (snapshot.items.isEmpty ? '今天没有课程安排' : snapshot.headlineText),
    );
    await _updateWidget();
    if (MorningBriefingService.isEnabled) {
      unawaited(MorningBriefingService.scheduleDaily(snapshot: snapshot));
    }
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
      await _clearItems();
      await _saveString('semesterText', '当前学期');
      await _saveString('weekText', '--');
      await _saveString('headlineText', '今日课程');
      await _saveString('updatedAtText', '');
      await _writeState(
        state: TodayCoursesWidgetState.idle,
        statusText: '等待同步',
      );
      await _updateWidget();
      return;
    }
    await _saveCoreData(entry.snapshot, updatedAt: entry.savedAt);
    final state = entry.isFromToday
        ? TodayCoursesWidgetState.ready
        : TodayCoursesWidgetState.readyStale;
    await _writeState(
      state: state,
      statusText: entry.isFromToday
          ? (entry.snapshot.currentWeekText == '假期'
                ? '当前为假期'
                : (entry.snapshot.items.isEmpty
                      ? '今天没有课程安排'
                      : entry.snapshot.headlineText))
          : '数据过期，显示上次缓存，请打开 App 手动同步',
    );
    await _updateWidget();
  }

  Future<bool> debugRunScheduledSync() {
    return syncAndUpdate(showLoading: true, reason: _manualDebugReason);
  }

  Map<String, String> diagnosticSnapshot() {
    String read(String key) => StorageUtils.settings.get(key)?.toString() ?? '';
    final entry = loadCachedTodaySnapshotEntry();
    return {
      'autoSyncEnabled': isAutoSyncEnabled.toString(),
      'pendingSync': (StorageUtils.settings.get(_pendingSyncKey) == true)
          .toString(),
      'scheduledDailyWorkName': read(_scheduledDailyWorkNameKey),
      'lastScheduledAt': read(_lastScheduledAtKey),
      'lastScheduledRunAt': read(_lastScheduledRunAtKey),
      'lastRetryScheduledAt': read(_lastRetryScheduledAtKey),
      'lastRetryScheduledRunAt': read(_lastRetryScheduledRunAtKey),
      'lastDebugScheduledAt': read(_lastDebugScheduledAtKey),
      'lastDebugScheduledRunAt': read(_lastDebugScheduledRunAtKey),
      'lastSyncStartedAt': read(_lastSyncStartedAtKey),
      'lastSyncSuccessAt': read(_lastSyncSuccessAtKey),
      'lastSyncFailureAt': read(_lastSyncFailureAtKey),
      'lastSyncFailureReason': read(_lastSyncFailureReasonKey),
      'taskCallbackExecuted': read(
        _lastTaskCallbackAtKey,
      ).isNotEmpty.toString(),
      'lastTaskCallbackAt': read(_lastTaskCallbackAtKey),
      'lastTaskCallbackName': read(_lastTaskCallbackNameKey),
      'lastTaskRegisterFailure': read(_lastTaskRegisterFailureKey),
      'cacheDate': _formatCacheDate(entry?.cacheDate),
      'cacheSavedAt': entry?.savedAt.toIso8601String() ?? '',
      'cacheStale': entry == null ? '' : (!entry.isFromToday).toString(),
      'widgetState': read(_diagnosticStateKey),
      'widgetStatusText': read(_diagnosticStatusTextKey),
      'lastProviderUpdateAt': read(_lastProviderUpdateAtKey),
      'lastProviderUpdateFailure': read(_lastProviderUpdateFailureKey),
    };
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
    final termWeek = AcademicTermService.resolveWeek(meta);
    final resolvedWeek = termWeek.week;
    List<ClassMeta> weekMeta = const <ClassMeta>[];
    List<ClassTableCourse> weekCourses = const <ClassTableCourse>[];
    if (!termWeek.isHoliday) {
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
      weekMeta = await weekMetaTask;
      weekCourses = (await courseResponseTask).data.courses;
    }
    await _loadBellScheduleQuietly();

    return buildTodayCourseSnapshot(
      semester: effectiveSemester,
      currentWeek: resolvedWeek,
      weekMeta: weekMeta,
      weekCourses: weekCourses,
      meta: meta,
      periodSettings: _effectivePeriodSettings(meta),
    );
  }

  List<ClassPeriodSetting> _effectivePeriodSettings(ClassTableMeta? meta) {
    final bellSettings = _bellScheduleRepo.periodSettingsFor(
      _classRepo.currentCampusId,
    );
    if (bellSettings.isNotEmpty) {
      return bellSettings;
    }
    return meta?.periodSettings ?? const [];
  }

  Future<void> _loadBellScheduleQuietly() async {
    try {
      await _bellScheduleRepo.ensureLoaded(forceRefresh: false);
    } catch (e, s) {
      LogUtil.warnE('[TodayCoursesWidget] bell schedule preload failed', e, s);
    }
  }

  Future<bool> _hasNetworkConnection() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    return connectivityResults.any((r) => r != ConnectivityResult.none);
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
        state: TodayCoursesWidgetState.readyStale,
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
    await _saveString(
      'nextCourseJson',
      snapshot.nextItem == null
          ? '{}'
          : jsonEncode(<String, String>{
              'time': snapshot.nextItem!.timeText,
              'title': snapshot.nextItem!.titleText,
              'room': snapshot.nextItem!.roomText,
            }),
    );
  }

  Future<void> _clearItems() async {
    await _saveInt('courseCount', 0);
    await _saveString('coursesJson', '[]');
    await _saveString('nextCourseJson', '{}');
  }

  Future<void> _writeState({
    required TodayCoursesWidgetState state,
    required String statusText,
  }) async {
    await _saveString('state', state.name);
    await _saveString('statusText', statusText);
    await StorageUtils.settings.put(_diagnosticStateKey, state.name);
    await StorageUtils.settings.put(_diagnosticStatusTextKey, statusText);
  }

  Future<void> _saveString(String key, String value) async {
    await HomeWidget.saveWidgetData<String>(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    await HomeWidget.saveWidgetData<int>(key, value);
  }

  Future<void> _updateWidget() async {
    const providers = [
      'TodayCoursesWidgetProvider',
      'TodayCoursesLargeWidgetProvider',
    ];
    var hasFailure = false;
    for (final name in providers) {
      try {
        await HomeWidget.updateWidget(
          name: name,
          qualifiedAndroidName: '$_androidPackageName.$name',
        );
        LogUtil.info(
          '[TodayCoursesWidget] updateWidget success provider=$name',
        );
      } catch (e, s) {
        hasFailure = true;
        final reason = 'provider=$name error=${e.toString()}';
        await StorageUtils.settings.put(
          _lastProviderUpdateFailureKey,
          _compactReason(reason),
        );
        LogUtil.errorE(
          '[TodayCoursesWidget] updateWidget failed provider=$name',
          e,
          s,
        );
      }
    }
    await StorageUtils.settings.put(_lastProviderUpdateAtKey, _nowIso());
    if (!hasFailure) {
      await StorageUtils.settings.delete(_lastProviderUpdateFailureKey);
    }
  }

  String _buildUpdateTimeText(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '更新于 $year-$month-$day $hour:$minute';
  }

  String _formatCacheDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '${dateTime.year}-$month-$day';
  }

  bool _shouldMarkPendingSync(String reason) {
    return reason == _dailyRefreshTaskName ||
        reason == _pendingRetryTaskName ||
        reason == 'auto_sync_enabled' ||
        reason == 'pending_retry' ||
        reason == _scheduledDebugReason ||
        reason == 'widget_button';
  }

  Future<void> _recordSyncStarted(String reason) async {
    await StorageUtils.settings.put(_lastSyncStartedAtKey, _nowIso());
    LogUtil.info('[TodayCoursesWidget] sync diagnostic start reason=$reason');
  }

  Future<void> _recordSyncSuccess() async {
    await StorageUtils.settings.put(_lastSyncSuccessAtKey, _nowIso());
    await StorageUtils.settings.delete(_lastSyncFailureReasonKey);
  }

  Future<void> _recordSyncFailure(String reason) async {
    await StorageUtils.settings.put(_lastSyncFailureAtKey, _nowIso());
    await StorageUtils.settings.put(
      _lastSyncFailureReasonKey,
      _compactReason(reason),
    );
  }

  Future<void> _recordTaskRegisterFailure(Object error) async {
    await StorageUtils.settings.put(
      _lastTaskRegisterFailureKey,
      _compactReason(error.toString()),
    );
  }

  String _nowIso() => DateTime.now().toIso8601String();

  static String _compactReason(String reason) {
    final normalized = reason.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 240) {
      return normalized;
    }
    return '${normalized.substring(0, 240)}...';
  }
}

@pragma('vm:entry-point')
void todayCoursesWidgetCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      DartPluginRegistrant.ensureInitialized();
      await LogUtil.init();
      await StorageUtils.ensureInitialized().timeout(
        _backgroundBootstrapTimeout,
      );
      final repo = _createBackgroundWidgetRepo();

      await StorageUtils.settings.put(
        _lastTaskCallbackAtKey,
        DateTime.now().toIso8601String(),
      );
      await StorageUtils.settings.put(_lastTaskCallbackNameKey, taskName);

      LogUtil.info(
        '[TodayCoursesWidget] background task start taskName=$taskName',
      );

      final reason = inputData?['debug'] == true
          ? _scheduledDebugReason
          : taskName == _pendingRetryTaskName
          ? 'pending_retry'
          : taskName;
      final success = await repo.syncAndUpdate(reason: reason);

      LogUtil.info(
        '[TodayCoursesWidget] background task finish taskName=$taskName',
      );
      return success;
    } catch (e, s) {
      try {
        await StorageUtils.settings.put(
          _lastSyncFailureAtKey,
          DateTime.now().toIso8601String(),
        );
        await StorageUtils.settings.put(
          _lastSyncFailureReasonKey,
          TodayCoursesWidgetRepo._compactReason(
            'background bootstrap failed: $e',
          ),
        );
      } catch (_) {}
      try {
        LogUtil.errorE(
          '[TodayCoursesWidget] background task failed taskName=$taskName',
          e,
          s,
        );
      } catch (_) {}
      return false;
    }
  });
}

@pragma('vm:entry-point')
Future<void> todayCoursesWidgetInteractivityCallback(Uri? data) async {
  try {
    DartPluginRegistrant.ensureInitialized();
    await LogUtil.init();
    await StorageUtils.ensureInitialized().timeout(_backgroundBootstrapTimeout);

    if (data?.host == 'refresh') {
      await _createBackgroundWidgetRepo().syncAndUpdate(
        showLoading: true,
        reason: 'widget_button',
      );
    }
  } catch (e, s) {
    try {
      LogUtil.errorE('[TodayCoursesWidget] widget refresh button failed', e, s);
    } catch (_) {}
  }
}

TodayCoursesWidgetRepo _createBackgroundWidgetRepo() {
  final userRepo = UserRepo();
  return TodayCoursesWidgetRepo(
    userRepo: userRepo,
    classRepo: ClassRepo(userRepo: userRepo),
    bellScheduleRepo: BellScheduleRepo(userRepo: userRepo),
  );
}
