import 'dart:io';

import 'package:class_tool/data/services/morning_briefing_service.dart';
import 'package:class_tool/data/repo/today_courses_widget_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:flutter/material.dart';
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

  final UserRepo _userRepo;
  final TodayCoursesWidgetRepo _todayCoursesWidgetRepo;

  final RxString studentName = ''.obs;
  final RxString campus = ''.obs;
  final RxString semester = ''.obs;
  final Rx<ThemeMode> themeMode = _loadThemeMode().obs;
  final RxBool autoWidgetSyncEnabled =
      Get.find<TodayCoursesWidgetRepo>().isAutoSyncEnabled.obs;
  final RxBool morningBriefingEnabled = MorningBriefingService.isEnabled.obs;

  bool get supportsScheduledSync => Platform.isAndroid;
  bool get supportsMorningBriefing => Platform.isAndroid;

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

  Future<void> runMorningSyncDebug() async {
    if (!supportsScheduledSync) {
      return;
    }
    await _todayCoursesWidgetRepo.debugRunScheduledSync();
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

  Future<void> _normalizePlatformSpecificSettings() async {
    await _todayCoursesWidgetRepo.setAutoSyncEnabled(false);
    await MorningBriefingService.setEnabled(false);
  }
}
