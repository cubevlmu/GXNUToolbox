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
    : _userRepo = userRepo ?? Get.find<UserRepo>();

  static const String _themeModeKey = 'theme_mode';

  final UserRepo _userRepo;

  final RxString studentName = ''.obs;
  final RxString campus = ''.obs;
  final RxString semester = ''.obs;
  final Rx<ThemeMode> themeMode = _loadThemeMode().obs;

  @override
  void onInit() {
    super.onInit();
    refreshUserInfo();
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

  Future<void> logout() async {
    await _userRepo.logout();
    refreshUserInfo();
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
}
