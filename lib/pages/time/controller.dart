/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/bell_schedule.dart';
import 'package:class_tool/data/repo/bell_schedule_repo.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:get/get.dart';

class TimeController extends GetxController {
  TimeController({BellScheduleRepo? repo})
    : _repo = repo ?? Get.find<BellScheduleRepo>();

  final BellScheduleRepo _repo;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<CampusSchedule> campuses = <CampusSchedule>[].obs;
  final RxInt selectedCampusIndex = 0.obs;
  final RxString semester = ''.obs;

  CampusSchedule? get selectedCampus =>
      campuses.isEmpty ? null : campuses[selectedCampusIndex.value];

  @override
  void onInit() {
    super.onInit();
    semester.value = _repo.computeSemester();
    Future<void>.microtask(refresh);
  }

  @override
  void refresh() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';
    update(<Object>['time-content']);

    try {
      final response = await _repo.ensureLoaded(forceRefresh: true);
      campuses.assignAll(response.campuses);
      semester.value = _repo.computeSemester();
      LogUtil.info('[TimeController] loaded ${campuses.length} campuses');
    } catch (e, s) {
      error.value = e.toString();
      LogUtil.errorE('[TimeController] load failed', e, s);
    } finally {
      isLoading.value = false;
      update(<Object>['time-content']);
    }
  }
}
