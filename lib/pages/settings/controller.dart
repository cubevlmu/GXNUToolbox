import 'dart:io';

import 'package:class_tool/data/api/api_diagnostics.dart';
import 'package:class_tool/data/services/morning_briefing_service.dart';
import 'package:class_tool/data/services/app_update_service.dart';
import 'package:class_tool/data/repo/today_courses_widget_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/utils/app_info_util.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const Map<String, String> _campusNameMap = <String, String>{
  '1': '王城',
  '2': '育才',
  '3': '雁山',
};

class SettingsController extends GetxController {
  SettingsController({UserRepo? userRepo})
    : _userRepo = userRepo ?? Get.find<UserRepo>(),
      _todayCoursesWidgetRepo = Get.find<TodayCoursesWidgetRepo>();

  static const String _themeModeKey = 'theme_mode';
  static const String _developerModeKey = 'developer_mode_enabled';
  static const int _developerModeTapThreshold = 7;

  final UserRepo _userRepo;
  final TodayCoursesWidgetRepo _todayCoursesWidgetRepo;

  final RxString studentName = ''.obs;
  final RxString campus = ''.obs;
  final RxString semester = ''.obs;
  final Rx<ThemeMode> themeMode = _loadThemeMode().obs;
  final RxBool autoWidgetSyncEnabled =
      Get.find<TodayCoursesWidgetRepo>().isAutoSyncEnabled.obs;
  final RxBool morningBriefingEnabled = MorningBriefingService.isEnabled.obs;
  final RxBool startupUpdatePromptEnabled =
      AppUpdateService.startupOptionalUpdatePromptEnabled.obs;
  final RxBool developerModeEnabled = _loadDeveloperModeEnabled().obs;
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

  Future<void> logout() async {
    await _userRepo.logout();
    refreshUserInfo();
    await _todayCoursesWidgetRepo.clearAndUpdate();
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

  static bool _loadDeveloperModeEnabled() {
    return kDebugMode || StorageUtils.settings.get(_developerModeKey) == true;
  }

  Future<void> _normalizePlatformSpecificSettings() async {
    await _todayCoursesWidgetRepo.setAutoSyncEnabled(false);
    await MorningBriefingService.setEnabled(false);
  }
}
