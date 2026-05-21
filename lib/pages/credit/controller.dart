/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/credit_progress.dart';
import 'package:class_tool/data/repo/credit_repo.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:get/get.dart';

class CreditController extends GetxController {
  CreditController({CreditRepo? creditRepo})
    : _creditRepo = creditRepo ?? Get.find<CreditRepo>();

  final CreditRepo _creditRepo;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<CreditProgressResponse?> response = Rx<CreditProgressResponse?>(null);
  final RxString selectedSemester = ''.obs;
  final RxList<String> semesterOptions = <String>[].obs;

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
    for (int y = currentYear - 5; y <= currentYear + 5; y++) {
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
    update(<Object>['credit-content']);

    try {
      response.value = await _fetch();
      LogUtil.info('[CreditController] loaded');
    } catch (e, s) {
      error.value = e.toString();
      LogUtil.errorE('[CreditController] load failed', e, s);
    } finally {
      isLoading.value = false;
      update(<Object>['credit-content']);
    }
  }

  Future<CreditProgressResponse> _fetch() async {
    return _creditRepo.fetchProgress(semester: selectedSemester.value);
  }
}
