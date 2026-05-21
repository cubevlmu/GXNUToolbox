/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/grade.dart';
import 'package:class_tool/data/repo/grade_repo.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

@immutable
class GradeFilter {
  const GradeFilter({
    this.startSemester = '001',
    this.endSemester = '001',
    this.passStatus = '',
    this.courseNature = '',
    this.makeup = '',
    this.seal = '1',
    this.courseAttribution = '',
  });

  final String startSemester;
  final String endSemester;
  final String passStatus;
  final String courseNature;
  final String makeup;
  final String seal;
  final String courseAttribution;

  GradeFilter copyWith({
    String? startSemester,
    String? endSemester,
    String? passStatus,
    String? courseNature,
    String? makeup,
    String? seal,
    String? courseAttribution,
  }) {
    return GradeFilter(
      startSemester: startSemester ?? this.startSemester,
      endSemester: endSemester ?? this.endSemester,
      passStatus: passStatus ?? this.passStatus,
      courseNature: courseNature ?? this.courseNature,
      makeup: makeup ?? this.makeup,
      seal: seal ?? this.seal,
      courseAttribution: courseAttribution ?? this.courseAttribution,
    );
  }
}

class QueryController extends GetxController {
  QueryController({GradeRepo? gradeRepo})
    : _gradeRepo = gradeRepo ?? Get.find<GradeRepo>();

  final GradeRepo _gradeRepo;
  final EasyRefreshController easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _error = ''.obs;
  final Rx<GradeFilter> _filter = const GradeFilter().obs;
  final RxList<CourseGrade> _grades = <CourseGrade>[].obs;
  final RxInt _page = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _total = 0.obs;
  final RxString _majorRank = ''.obs;
  final Rx<GradeFilterOptions> _filterOptions = GradeFilterOptions.empty.obs;
  int _requestVersion = 0;

  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get error => _error.value;
  GradeFilter get filter => _filter.value;
  List<CourseGrade> get grades => _grades;
  int get page => _page.value;
  int get totalPages => _totalPages.value;
  int get total => _total.value;
  String get majorRank => _majorRank.value;
  GradeFilterOptions get filterOptions => _filterOptions.value;
  bool get hasMore => page < totalPages;
  bool get hasData => _grades.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    Future<void>.microtask(refreshGrades);
  }

  Future<void> applyFilter(GradeFilter nextFilter) async {
    if (_isLoading.value || _isLoadingMore.value) {
      return;
    }
    _filter.value = nextFilter;
    await refreshGrades();
  }

  Future<void> refreshGrades() async {
    if (_isLoading.value) {
      return;
    }

    final version = ++_requestVersion;
    _isLoading.value = true;
    _isLoadingMore.value = false;
    _error.value = '';
    _page.value = 1;
    update(<Object>['query-content']);

    try {
      final filterOptions = await _fetchFilterOptionsIfNeeded();
      if (!_isActiveRequest(version)) {
        return;
      }
      if (filterOptions != null) {
        _filterOptions.value = filterOptions;
      }
      final response = await _fetchPage(1);
      final rank = await _fetchGradeRank();
      if (!_isActiveRequest(version)) {
        return;
      }
      _grades.assignAll(response.results);
      _page.value = response.page <= 0 ? 1 : response.page;
      _totalPages.value = response.totalPages <= 0 ? 1 : response.totalPages;
      _total.value = response.total;
      _majorRank.value = rank;
      _error.value = '';
      LogUtil.info('[QueryController] refresh grades success total=$total');
    } catch (e, s) {
      if (!_isActiveRequest(version)) {
        return;
      }
      _error.value = e.toString();
      LogUtil.errorE('[QueryController] refresh grades failed', e, s);
    } finally {
      if (!_isActiveRequest(version)) {
        return;
      }
      _isLoading.value = false;
      easyRefreshController.finishRefresh();
      easyRefreshController.resetFooter();
      update(<Object>['query-content']);
    }
  }

  Future<void> loadMoreGrades() async {
    if (_isLoading.value || _isLoadingMore.value || !hasMore) {
      easyRefreshController.finishLoad(
        hasMore ? IndicatorResult.none : IndicatorResult.noMore,
      );
      return;
    }

    final version = ++_requestVersion;
    _isLoadingMore.value = true;
    update(<Object>['query-content']);

    try {
      final nextPage = page + 1;
      final response = await _fetchPage(nextPage);
      if (!_isActiveRequest(version)) {
        return;
      }
      _grades.addAll(response.results);
      _page.value = response.page <= 0 ? nextPage : response.page;
      _totalPages.value = response.totalPages <= 0
          ? totalPages
          : response.totalPages;
      _total.value = response.total;
      easyRefreshController.finishLoad(
        hasMore ? IndicatorResult.success : IndicatorResult.noMore,
      );
    } catch (e, s) {
      if (!_isActiveRequest(version)) {
        return;
      }
      _error.value = e.toString();
      easyRefreshController.finishLoad(IndicatorResult.fail);
      LogUtil.errorE('[QueryController] load more grades failed', e, s);
    } finally {
      if (!_isActiveRequest(version)) {
        return;
      }
      _isLoadingMore.value = false;
      update(<Object>['query-content']);
    }
  }

  Future<GradeQueryResponse> _fetchPage(int targetPage) async {
    return _requestGrades(targetPage);
  }

  Future<GradeFilterOptions?> _fetchFilterOptionsIfNeeded() async {
    if (_filterOptions.value.startSemesters.isNotEmpty ||
        _filterOptions.value.endSemesters.isNotEmpty) {
      return null;
    }

    return _requestFilterOptions();
  }

  Future<String> _fetchGradeRank() async {
    try {
      return (await _requestGradeRank()).rankText;
    } catch (e, s) {
      LogUtil.warnE('[QueryController] fetch grade rank failed', e, s);
      return '';
    }
  }

  Future<GradeQueryResponse> _requestGrades(int targetPage) {
    final currentFilter = filter;
    return _gradeRepo.fetchPage(
      startSemester: currentFilter.startSemester,
      endSemester: currentFilter.endSemester,
      page: targetPage,
      passStatus: currentFilter.passStatus,
      courseNature: currentFilter.courseNature,
      retakeFlag: currentFilter.makeup,
      showFollowed: currentFilter.seal,
      courseAttribution: currentFilter.courseAttribution,
    );
  }

  Future<GradeRankResponse> _requestGradeRank() {
    return _gradeRepo.fetchRank();
  }

  Future<GradeFilterOptions> _requestFilterOptions() {
    return _gradeRepo.fetchFilterOptions();
  }

  bool _isActiveRequest(int version) {
    return !isClosed && version == _requestVersion;
  }

  @override
  void onClose() {
    easyRefreshController.dispose();
    super.onClose();
  }
}
