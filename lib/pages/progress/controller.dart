/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/course_plan.dart';
import 'package:class_tool/data/repo/course_plan_repo.dart';
import 'package:class_tool/data/services/local_semester_service.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:get/get.dart';

class ProgressController extends GetxController {
  ProgressController({CoursePlanRepo? coursePlanRepo})
    : _coursePlanRepo = coursePlanRepo ?? Get.find<CoursePlanRepo>();

  final CoursePlanRepo _coursePlanRepo;

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
    selectedSemester.value = LocalSemesterService.currentSemester();
    Future<void>.microtask(loadData);
  }

  void _buildSemesterOptions() {
    semesterOptions.assignAll(LocalSemesterService.recentSemesters());
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
    } catch (e, s) {
      error.value = e.toString();
      LogUtil.errorE('[ProgressController] load failed', e, s);
    } finally {
      isLoading.value = false;
      update(<Object>['progress-content']);
    }
  }

  Future<CoursePlanResponse> _fetch() async {
    return _coursePlanRepo.fetchPlan(semester: selectedSemester.value);
  }
}
