import 'dart:io';

import 'package:class_tool/data/api/api_diagnostics.dart';
import 'package:class_tool/data/model/home_quick_action.dart';
import 'package:class_tool/data/services/morning_briefing_service.dart';
import 'package:class_tool/data/services/app_update_service.dart';
import 'package:class_tool/data/services/debug_time_service.dart';
import 'package:class_tool/data/repo/today_courses_widget_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/utils/app_info_util.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

const Map<String, String> _campusNameMap = <String, String>{
  '1': '王城',
  '2': '育才',
  '3': '雁山',
};

enum AppAccentPreference { blue, green, purple, orange, red }

enum CourseDetailPresentation { page, sheet }

extension CourseDetailPresentationX on CourseDetailPresentation {
  String get label {
    switch (this) {
      case CourseDetailPresentation.page:
        return '页面';
      case CourseDetailPresentation.sheet:
        return '抽屉';
    }
  }
}

extension AppAccentPreferenceX on AppAccentPreference {
  String get label {
    switch (this) {
      case AppAccentPreference.blue:
        return '蓝';
      case AppAccentPreference.green:
        return '绿';
      case AppAccentPreference.purple:
        return '紫';
      case AppAccentPreference.orange:
        return '橙';
      case AppAccentPreference.red:
        return '红';
    }
  }

  Color get lightPrimary {
    switch (this) {
      case AppAccentPreference.blue:
        return const Color(0xFF3F63D8);
      case AppAccentPreference.green:
        return const Color(0xFF168A5B);
      case AppAccentPreference.purple:
        return const Color(0xFF7A3FF2);
      case AppAccentPreference.orange:
        return const Color(0xFFC65300);
      case AppAccentPreference.red:
        return const Color(0xFFD92D20);
    }
  }

  Color get lightHover {
    switch (this) {
      case AppAccentPreference.blue:
        return const Color(0xFF3451C0);
      case AppAccentPreference.green:
        return const Color(0xFF127247);
      case AppAccentPreference.purple:
        return const Color(0xFF6630D8);
      case AppAccentPreference.orange:
        return const Color(0xFFA84500);
      case AppAccentPreference.red:
        return const Color(0xFFB42318);
    }
  }

  Color get lightPressed {
    switch (this) {
      case AppAccentPreference.blue:
        return const Color(0xFF2A41A0);
      case AppAccentPreference.green:
        return const Color(0xFF0E5E39);
      case AppAccentPreference.purple:
        return const Color(0xFF5424B8);
      case AppAccentPreference.orange:
        return const Color(0xFF873800);
      case AppAccentPreference.red:
        return const Color(0xFF912018);
    }
  }

  Color get lightSoft {
    switch (this) {
      case AppAccentPreference.blue:
        return const Color(0xFFEEF2FF);
      case AppAccentPreference.green:
        return const Color(0xFFECFDF5);
      case AppAccentPreference.purple:
        return const Color(0xFFF1ECFF);
      case AppAccentPreference.orange:
        return const Color(0xFFFFF1E4);
      case AppAccentPreference.red:
        return const Color(0xFFFEF3F2);
    }
  }

  Color get lightSubtle {
    switch (this) {
      case AppAccentPreference.blue:
        return const Color(0xFFDCE3FF);
      case AppAccentPreference.green:
        return const Color(0xFFD1FADF);
      case AppAccentPreference.purple:
        return const Color(0xFFE3D8FF);
      case AppAccentPreference.orange:
        return const Color(0xFFFFDFC2);
      case AppAccentPreference.red:
        return const Color(0xFFFEE4E2);
    }
  }

  Color get darkPrimary {
    switch (this) {
      case AppAccentPreference.blue:
        return const Color(0xFF8EA8FF);
      case AppAccentPreference.green:
        return const Color(0xFF63D489);
      case AppAccentPreference.purple:
        return const Color(0xFFB497FF);
      case AppAccentPreference.orange:
        return const Color(0xFFFFB86B);
      case AppAccentPreference.red:
        return const Color(0xFFF97066);
    }
  }

  Color get darkHover {
    switch (this) {
      case AppAccentPreference.blue:
        return const Color(0xFFA3BAFF);
      case AppAccentPreference.green:
        return const Color(0xFF7BE0A0);
      case AppAccentPreference.purple:
        return const Color(0xFFC4AAFF);
      case AppAccentPreference.orange:
        return const Color(0xFFFFC884);
      case AppAccentPreference.red:
        return const Color(0xFFFF8A80);
    }
  }

  Color get darkPressed {
    switch (this) {
      case AppAccentPreference.blue:
        return const Color(0xFF7A97F0);
      case AppAccentPreference.green:
        return const Color(0xFF4FC477);
      case AppAccentPreference.purple:
        return const Color(0xFFA282F5);
      case AppAccentPreference.orange:
        return const Color(0xFFF2A24D);
      case AppAccentPreference.red:
        return const Color(0xFFEF4444);
    }
  }

  Color get darkSoft {
    switch (this) {
      case AppAccentPreference.blue:
        return const Color(0xFF1A2240);
      case AppAccentPreference.green:
        return const Color(0xFF12351F);
      case AppAccentPreference.purple:
        return const Color(0xFF281C45);
      case AppAccentPreference.orange:
        return const Color(0xFF3B2412);
      case AppAccentPreference.red:
        return const Color(0xFF2E1414);
    }
  }

  Color get darkSubtle {
    switch (this) {
      case AppAccentPreference.blue:
        return const Color(0xFF1E2D5C);
      case AppAccentPreference.green:
        return const Color(0xFF16452A);
      case AppAccentPreference.purple:
        return const Color(0xFF34245E);
      case AppAccentPreference.orange:
        return const Color(0xFF4A2E16);
      case AppAccentPreference.red:
        return const Color(0xFF3B1717);
    }
  }
}

class SettingsController extends GetxController {
  SettingsController({UserRepo? userRepo})
    : _userRepo = userRepo ?? Get.find<UserRepo>(),
      _todayCoursesWidgetRepo = Get.find<TodayCoursesWidgetRepo>(),
      _debugTimeService = Get.find<DebugTimeService>();

  static const String _themeModeKey = 'theme_mode';
  static const String _accentKey = 'accent_color';
  static const String _homeQuickActionsEnabledKey =
      'home_quick_actions_enabled';
  static const String _homeQuickActionsKey = 'home_quick_actions';
  static const String _todoFeatureEnabledKey = 'todo_feature_enabled';
  static const String _attendanceFeatureEnabledKey =
      'attendance_feature_enabled';
  static const String _courseDetailPresentationKey =
      'course_detail_presentation';
  static const String _developerModeKey = 'developer_mode_enabled';
  static const int _developerModeTapThreshold = 7;
  static const List<HomeQuickActionPreference> defaultHomeQuickActions =
      <HomeQuickActionPreference>[
        HomeQuickActionPreference.grades,
        HomeQuickActionPreference.exams,
        HomeQuickActionPreference.tasks,
        HomeQuickActionPreference.selectedCourses,
      ];

  final UserRepo _userRepo;
  final TodayCoursesWidgetRepo _todayCoursesWidgetRepo;
  final DebugTimeService _debugTimeService;

  final RxString studentName = ''.obs;
  final RxString campus = ''.obs;
  final RxString semester = ''.obs;
  final Rx<ThemeMode> themeMode = _loadThemeMode().obs;
  final Rx<AppAccentPreference> accent = _loadAccent().obs;
  final RxBool homeQuickActionsEnabled = _loadHomeQuickActionsEnabled().obs;
  final RxList<HomeQuickActionPreference> homeQuickActions =
      _loadHomeQuickActions().obs;
  final RxBool todoFeatureEnabled = _loadTodoFeatureEnabled().obs;
  final RxBool attendanceFeatureEnabled = _loadAttendanceFeatureEnabled().obs;
  final Rx<CourseDetailPresentation> courseDetailPresentation =
      _loadCourseDetailPresentation().obs;
  final RxBool autoWidgetSyncEnabled =
      Get.find<TodayCoursesWidgetRepo>().isAutoSyncEnabled.obs;
  final RxBool morningBriefingEnabled = MorningBriefingService.isEnabled.obs;
  final RxBool startupUpdatePromptEnabled =
      AppUpdateService.startupOptionalUpdatePromptEnabled.obs;
  final RxBool developerModeEnabled = _loadDeveloperModeEnabled().obs;
  late final Rxn<DateTime> debugClientTimeOverride =
      _debugTimeService.clientTimeOverride;
  int _developerModeTapCount = 0;

  bool get supportsScheduledSync => Platform.isAndroid;
  bool get supportsMorningBriefing => Platform.isAndroid;
  bool get showDiagnosticLogs => kDebugMode || developerModeEnabled.value;

  @override
  void onInit() {
    super.onInit();
    refreshUserInfo();
    if (!supportsScheduledSync) {
      autoWidgetSyncEnabled.value = false;
      morningBriefingEnabled.value = false;
      _normalizePlatformSpecificSettings();
    }
  }

  void refreshUserInfo() {
    studentName.value = _userRepo.username.isEmpty ? '未登录' : _userRepo.username;
    final campusId = _userRepo.campusId;
    campus.value = campusId.isEmpty
        ? '-'
        : (_campusNameMap[campusId] ?? campusId);
    semester.value = _userRepo.selectedSemester.isEmpty
        ? '-'
        : '${_userRepo.selectedSemester}学期';
  }

  Future<void> changeThemeMode(ThemeMode nextMode) async {
    if (themeMode.value == nextMode) {
      return;
    }
    themeMode.value = nextMode;
    await StorageUtils.settings.put(_themeModeKey, nextMode.name);
    Get.changeThemeMode(nextMode);
  }

  Future<void> changeAccent(AppAccentPreference nextAccent) async {
    if (accent.value == nextAccent) {
      return;
    }
    accent.value = nextAccent;
    await StorageUtils.settings.put(_accentKey, nextAccent.name);
  }

  Future<void> changeHomeQuickActionsEnabled(bool enabled) async {
    if (homeQuickActionsEnabled.value == enabled) {
      return;
    }
    homeQuickActionsEnabled.value = enabled;
    await StorageUtils.settings.put(_homeQuickActionsEnabledKey, enabled);
  }

  Future<void> changeTodoFeatureEnabled(bool enabled) async {
    if (todoFeatureEnabled.value == enabled) {
      return;
    }
    todoFeatureEnabled.value = enabled;
    await StorageUtils.settings.put(_todoFeatureEnabledKey, enabled);
  }

  Future<void> changeAttendanceFeatureEnabled(bool enabled) async {
    if (attendanceFeatureEnabled.value == enabled) {
      return;
    }
    attendanceFeatureEnabled.value = enabled;
    await StorageUtils.settings.put(_attendanceFeatureEnabledKey, enabled);
  }

  Future<void> changeCourseDetailPresentation(
    CourseDetailPresentation presentation,
  ) async {
    if (courseDetailPresentation.value == presentation) {
      return;
    }
    courseDetailPresentation.value = presentation;
    await StorageUtils.settings.put(
      _courseDetailPresentationKey,
      presentation.name,
    );
  }

  bool isHomeQuickActionAvailable(HomeQuickActionPreference action) {
    switch (action) {
      case HomeQuickActionPreference.tasks:
        return todoFeatureEnabled.value;
      case HomeQuickActionPreference.attendance:
        return attendanceFeatureEnabled.value;
      case HomeQuickActionPreference.grades:
      case HomeQuickActionPreference.exams:
      case HomeQuickActionPreference.selectedCourses:
      case HomeQuickActionPreference.credit:
      case HomeQuickActionPreference.progress:
      case HomeQuickActionPreference.studentInfo:
      case HomeQuickActionPreference.time:
      case HomeQuickActionPreference.schoolCalendar:
      case HomeQuickActionPreference.classroom:
      case HomeQuickActionPreference.notifications:
        return true;
    }
  }

  Future<void> toggleHomeQuickAction(HomeQuickActionPreference action) async {
    final current = homeQuickActions.toList(growable: true);
    if (current.contains(action)) {
      current.remove(action);
    } else {
      if (current.length >= 8) {
        return;
      }
      current.add(action);
    }
    homeQuickActions.assignAll(current);
    await _saveHomeQuickActions();
  }

  String? homeQuickActionLimitMessage(HomeQuickActionPreference action) {
    final selected = homeQuickActions.contains(action);
    final visibleCount = homeQuickActions
        .where(isHomeQuickActionAvailable)
        .length;
    if (!selected && visibleCount >= 8) {
      return '快捷操作最多显示 8 个入口';
    }
    return null;
  }

  Future<void> resetHomeQuickActions() async {
    homeQuickActions.assignAll(defaultHomeQuickActions);
    homeQuickActionsEnabled.value = true;
    await StorageUtils.settings.put(_homeQuickActionsEnabledKey, true);
    await _saveHomeQuickActions();
  }

  Future<void> changeAutoWidgetSync(bool enabled) async {
    if (!supportsScheduledSync) {
      autoWidgetSyncEnabled.value = false;
      return;
    }
    if (autoWidgetSyncEnabled.value == enabled) {
      return;
    }
    autoWidgetSyncEnabled.value = enabled;
    await _todayCoursesWidgetRepo.setAutoSyncEnabled(enabled);
    if (!enabled && morningBriefingEnabled.value) {
      morningBriefingEnabled.value = false;
      await MorningBriefingService.setEnabled(false);
    }
  }

  Future<void> changeMorningBriefing(bool enabled) async {
    if (!supportsMorningBriefing) {
      morningBriefingEnabled.value = false;
      return;
    }
    if (!autoWidgetSyncEnabled.value && enabled) {
      return;
    }
    if (morningBriefingEnabled.value == enabled) {
      return;
    }
    final actual = await MorningBriefingService.setEnabled(enabled);
    morningBriefingEnabled.value = actual;
  }

  Future<void> changeStartupUpdatePrompt(bool enabled) async {
    if (startupUpdatePromptEnabled.value == enabled) {
      return;
    }
    startupUpdatePromptEnabled.value = enabled;
    await AppUpdateService.setStartupOptionalUpdatePromptEnabled(enabled);
  }

  bool registerDeveloperModeTap() {
    if (showDiagnosticLogs) {
      return false;
    }
    _developerModeTapCount += 1;
    if (_developerModeTapCount < _developerModeTapThreshold) {
      return false;
    }
    _developerModeTapCount = 0;
    return true;
  }

  Future<void> enableDeveloperMode() async {
    if (developerModeEnabled.value) {
      return;
    }
    developerModeEnabled.value = true;
    await StorageUtils.settings.put(_developerModeKey, true);
  }

  Future<void> runMorningSyncDebug() async {
    if (!supportsScheduledSync) {
      return;
    }
    await _todayCoursesWidgetRepo.debugRunScheduledSync();
  }

  Future<void> scheduleMorningSyncSoonDebug() async {
    if (!supportsScheduledSync) {
      return;
    }
    await _todayCoursesWidgetRepo.debugScheduleDailyRefreshSoon();
  }

  String widgetSyncDiagnosticText() {
    final data = _todayCoursesWidgetRepo.diagnosticSnapshot();
    String value(String key) {
      final text = data[key]?.trim() ?? '';
      return text.isEmpty ? '-' : text;
    }

    return [
      '自动同步: ${value('autoSyncEnabled')}',
      '等待重试: ${value('pendingSync')}',
      '计划任务: ${value('scheduledDailyWorkName')}',
      '计划时间: ${value('lastScheduledRunAt')}',
      '上次安排: ${value('lastScheduledAt')}',
      '重试安排: ${value('lastRetryScheduledRunAt')}',
      '上次重试安排: ${value('lastRetryScheduledAt')}',
      '上次开始: ${value('lastSyncStartedAt')}',
      '上次成功: ${value('lastSyncSuccessAt')}',
      '上次失败: ${value('lastSyncFailureAt')}',
      '失败原因: ${value('lastSyncFailureReason')}',
      '回调执行: ${value('taskCallbackExecuted')}',
      '任务回调: ${value('lastTaskCallbackAt')}',
      '回调名称: ${value('lastTaskCallbackName')}',
      '登记错误: ${value('lastTaskRegisterFailure')}',
      '缓存日期: ${value('cacheDate')}',
      '缓存保存: ${value('cacheSavedAt')}',
      '缓存过期: ${value('cacheStale')}',
      '显示状态: ${value('widgetState')}',
      '状态文案: ${value('widgetStatusText')}',
      'Provider刷新: ${value('lastProviderUpdateAt')}',
      'Provider错误: ${value('lastProviderUpdateFailure')}',
    ].join('\n');
  }

  String diagnosticLogPath() {
    return LogUtil.logFile.path;
  }

  DateTime get effectiveClientTime => _debugTimeService.now;

  Future<void> setDebugClientTime(DateTime value) async {
    await _debugTimeService.setClientTimeOverride(value);
  }

  Future<void> clearDebugClientTime() async {
    await _debugTimeService.clearClientTimeOverride();
  }

  Future<String> buildDiagnosticSummary() async {
    final version = await AppInfoUtil.getVersionLabel();
    return [
      'App version: $version',
      'Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      'Log file: ${diagnosticLogPath()}',
      ApiDiagnostics.diagnosticSummary(),
      'Widget diagnostics:',
      widgetSyncDiagnosticText(),
    ].join('\n');
  }

  Future<void> copyDiagnosticSummary() async {
    final text = await buildDiagnosticSummary();
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<String> exportDatabaseFiles() async {
    final dbFile = File(
      '${StorageUtils.appSupportDirectory.path}/database/class_tool.sqlite',
    );
    if (!dbFile.existsSync()) {
      throw StateError('数据库文件不存在');
    }
    final outputDir = await _diagnosticExportDirectory(
      'database_${_timestamp()}',
    );
    for (final suffix in const ['', '-wal', '-shm']) {
      final source = File('${dbFile.path}$suffix');
      if (!source.existsSync()) {
        continue;
      }
      await source.copy('${outputDir.path}/${source.uri.pathSegments.last}');
    }
    await Clipboard.setData(ClipboardData(text: outputDir.path));
    return outputDir.path;
  }

  Future<String> exportLogFile() async {
    final source = LogUtil.logFile;
    if (!source.existsSync()) {
      throw StateError('日志文件不存在');
    }
    final outputDir = await _diagnosticExportDirectory();
    final target = File(
      '${outputDir.path}/${source.uri.pathSegments.last.replaceFirst('.txt', '_${_timestamp()}.txt')}',
    );
    await source.copy(target.path);
    await Clipboard.setData(ClipboardData(text: target.path));
    return target.path;
  }

  Future<void> logout() async {
    await _userRepo.logout();
    refreshUserInfo();
    await _todayCoursesWidgetRepo.clearAndUpdate();
  }

  static Future<Directory> _diagnosticExportDirectory([String? child]) async {
    final base = await getApplicationDocumentsDirectory();
    final directory = Directory(
      child == null
          ? '${base.path}/diagnostic_exports'
          : '${base.path}/diagnostic_exports/$child',
    );
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static String _timestamp() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}_'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }

  static ThemeMode _loadThemeMode() {
    final raw = StorageUtils.settings.get(_themeModeKey)?.toString();
    switch (raw) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  static AppAccentPreference _loadAccent() {
    final raw = StorageUtils.settings.get(_accentKey)?.toString();
    for (final item in AppAccentPreference.values) {
      if (item.name == raw) {
        return item;
      }
    }
    return AppAccentPreference.blue;
  }

  static bool _loadHomeQuickActionsEnabled() {
    return StorageUtils.settings.get(_homeQuickActionsEnabledKey) != false;
  }

  static bool _loadTodoFeatureEnabled() {
    return StorageUtils.settings.get(_todoFeatureEnabledKey) != false;
  }

  static bool _loadAttendanceFeatureEnabled() {
    return StorageUtils.settings.get(_attendanceFeatureEnabledKey) != false;
  }

  static CourseDetailPresentation _loadCourseDetailPresentation() {
    final raw = StorageUtils.settings
        .get(_courseDetailPresentationKey)
        ?.toString();
    for (final item in CourseDetailPresentation.values) {
      if (item.name == raw) {
        return item;
      }
    }
    return CourseDetailPresentation.page;
  }

  static List<HomeQuickActionPreference> _loadHomeQuickActions() {
    final raw = StorageUtils.settings.get(_homeQuickActionsKey);
    if (raw is Iterable) {
      final parsed = raw
          .map((item) => homeQuickActionPreferenceFromName(item.toString()))
          .whereType<HomeQuickActionPreference>()
          .toList();
      final deduped = <HomeQuickActionPreference>[];
      for (final item in parsed) {
        if (!deduped.contains(item)) {
          deduped.add(item);
        }
      }
      if (deduped.length >= 4) {
        return deduped.take(8).toList(growable: false);
      }
    }
    return defaultHomeQuickActions;
  }

  static bool _loadDeveloperModeEnabled() {
    return kDebugMode || StorageUtils.settings.get(_developerModeKey) == true;
  }

  Future<void> _saveHomeQuickActions() {
    return StorageUtils.settings.put(
      _homeQuickActionsKey,
      homeQuickActions.map((item) => item.name).toList(growable: false),
    );
  }

  Future<void> _normalizePlatformSpecificSettings() async {
    await _todayCoursesWidgetRepo.setAutoSyncEnabled(false);
    await MorningBriefingService.setEnabled(false);
  }
}
