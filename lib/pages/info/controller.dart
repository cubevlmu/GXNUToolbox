/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/student_info.dart';
import 'package:class_tool/data/repo/student_repo.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:get/get.dart';

class InfoController extends GetxController {
  InfoController({StudentRepo? studentRepo})
    : _studentRepo = studentRepo ?? Get.find<StudentRepo>();

  final StudentRepo _studentRepo;

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final Rx<StudentInfo?> _info = Rx<StudentInfo?>(null);
  final Rx<StudentPhoto?> _admissionPhoto = Rx<StudentPhoto?>(null);

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  StudentInfo? get info => _info.value;
  StudentPhoto? get admissionPhoto => _admissionPhoto.value;

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
      final infoTask = _fetchInfo();
      final photoTask = _fetchAdmissionPhotoSafely();
      _info.value = await infoTask;
      _admissionPhoto.value = await photoTask;
      LogUtil.info('[InfoController] refresh success');
    } catch (e, s) {
      _error.value = e.toString();
      LogUtil.errorE('[InfoController] refresh failed', e, s);
    } finally {
      _isLoading.value = false;
      update(<Object>['info-content']);
    }
  }

  Future<StudentInfo> _fetchInfo() async {
    return _studentRepo.fetchInfo();
  }

  Future<StudentPhoto?> _fetchAdmissionPhotoSafely() async {
    try {
      return await _studentRepo.fetchAdmissionPhoto();
    } catch (e, s) {
      LogUtil.warn('[InfoController] student admission photo unavailable: $e');
      LogUtil.debug('[InfoController] student admission photo stack: $s');
      return null;
    }
  }
}
