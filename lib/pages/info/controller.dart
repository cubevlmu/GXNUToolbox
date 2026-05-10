/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/data/model/student_info.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:get/get.dart';

class InfoController extends GetxController {
  InfoController({UserRepo? userRepo})
    : _userRepo = userRepo ?? Get.find<UserRepo>();

  final UserRepo _userRepo;

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final Rx<StudentInfo?> _info = Rx<StudentInfo?>(null);

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  StudentInfo? get info => _info.value;

  @override
  void onInit() {
    super.onInit();
    Future<void>.microtask(refresh);
  }

  @override
  Future<void> refresh() async {
    if (_isLoading.value) return;

    _isLoading.value = true;
    _error.value = '';
    update(<Object>['info-content']);

    try {
      _info.value = await _fetchInfo();
      LogUtil.info('[InfoController] refresh success');
    } on ApiLoginExpiredException catch (e, s) {
      LogUtil.warnE('[InfoController] login expired', e, s);
      final recovered = await _userRepo.recoverFromExpiredLogin();
      if (recovered) {
        _info.value = await _fetchInfo();
      }
    } catch (e, s) {
      _error.value = e.toString();
      LogUtil.errorE('[InfoController] refresh failed', e, s);
    } finally {
      _isLoading.value = false;
      update(<Object>['info-content']);
    }
  }

  Future<StudentInfo> _fetchInfo() async {
    try {
      return Api.getStudentInfo();
    } on ApiLoginExpiredException catch (e, s) {
      LogUtil.warnE('[InfoController] login expired fetching info', e, s);
      final recovered = await _userRepo.recoverFromExpiredLogin();
      if (!recovered) rethrow;
      return Api.getStudentInfo();
    }
  }
}
