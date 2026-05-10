/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/data/model/course_plan.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:get/get.dart';

class ProgressController extends GetxController {
  ProgressController({UserRepo? userRepo})
    : _userRepo = userRepo ?? Get.find<UserRepo>();

  final UserRepo _userRepo;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<CoursePlanResponse?> response = Rx<CoursePlanResponse?>(null);
  final RxString selectedSemester = ''.obs;
  final RxList<String> semesterOptions = <String>[].obs;

  List<CoursePlanSection> get sections => response.value?.sections ?? const [];
  int get completedCount => response.value?.completedCount ?? 0;
  int get totalCount => response.value?.totalCount ?? 0;

  @override
  void onInit() {
    super.onInit();
    _buildSemesterOptions();
    selectedSemester.value = '';
    Future<void>.microtask(loadData);
  }

  void _buildSemesterOptions() {
    final now = DateTime.now();
    final currentYear = now.year;
    final semesters = <String>[];
    for (int y = currentYear - 5; y <= currentYear; y++) {
      semesters.add('$y-${y + 1}-1');
      semesters.add('$y-${y + 1}-2');
    }
    semesterOptions.assignAll(semesters.reversed);
  }

  Future<void> changeSemester(String semester) async {
    if (selectedSemester.value == semester) return;
    selectedSemester.value = semester;
    await loadData();
  }

  Future<void> loadData() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';
    update(<Object>['progress-content']);

    try {
      response.value = await _fetch();
      LogUtil.info(
        '[ProgressController] loaded ${response.value?.totalCount} courses',
      );
    } on ApiLoginExpiredException catch (e, s) {
      LogUtil.warnE('[ProgressController] login expired', e, s);
      final recovered = await _userRepo.recoverFromExpiredLogin();
      if (recovered) {
        response.value = await _fetch();
      }
    } catch (e, s) {
      error.value = e.toString();
      LogUtil.errorE('[ProgressController] load failed', e, s);
    } finally {
      isLoading.value = false;
      update(<Object>['progress-content']);
    }
  }

  Future<CoursePlanResponse> _fetch() async {
    try {
      return Api.getCoursePlanList(semester: selectedSemester.value);
    } on ApiLoginExpiredException catch (e, s) {
      LogUtil.warnE('[ProgressController] login expired fetching', e, s);
      final recovered = await _userRepo.recoverFromExpiredLogin();
      if (!recovered) rethrow;
      return Api.getCoursePlanList(semester: selectedSemester.value);
    }
  }
}
