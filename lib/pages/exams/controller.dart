/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/data/model/exam.dart';
import 'package:class_tool/data/repo/exam_repo.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

class ExamsController extends GetxController {
  ExamsController({ExamRepo? examRepo})
    : _examRepo = examRepo ?? Get.find<ExamRepo>();

  final ExamRepo _examRepo;
  final EasyRefreshController easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _error = ''.obs;
  final RxList<ExamItem> _exams = <ExamItem>[].obs;
  final RxInt _page = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _total = 0.obs;

  final RxList<ExamSemesterOption> _semesters = <ExamSemesterOption>[].obs;
  final RxList<ExamBatchOption> _batches = <ExamBatchOption>[].obs;
  final RxString _selectedSemester = ''.obs;
  final RxString _selectedPcid = ''.obs;
  int _requestVersion = 0;
  int _batchRequestVersion = 0;

  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get error => _error.value;
  List<ExamItem> get exams => _exams;
  int get page => _page.value;
  int get totalPages => _totalPages.value;
  int get total => _total.value;
  List<ExamSemesterOption> get semesters => _semesters;
  List<ExamBatchOption> get batches => _batches;
  String get selectedSemester => _selectedSemester.value;
  String get selectedPcid => _selectedPcid.value;
  bool get hasMore => page < totalPages;
  bool get hasData => _exams.isNotEmpty;
  bool get canSearch => _selectedSemester.value.isNotEmpty;
  bool get hasBatches => _batches.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    Future<void>.microtask(_initFilters);
  }

  Future<void> _initFilters() async {
    try {
      _isLoading.value = true;
      update(<Object>['exam-content']);
      final options = await _fetchFilterOptions();
      _semesters.assignAll(options.semesters);
      if (_semesters.isNotEmpty) {
        final defaultSemester =
            _semesters.firstWhereOrNull((s) => s.selected) ?? _semesters.first;
        _selectedSemester.value = defaultSemester.value;
      }
    } catch (e, s) {
      _error.value = e.toString();
      LogUtil.errorE('[ExamsController] init filters failed', e, s);
    } finally {
      _isLoading.value = false;
      update(<Object>['exam-content']);
    }

    if (canSearch) {
      await refreshExams();
    }
  }

  Future<void> changeSemester(String semester) async {
    if (_selectedSemester.value == semester) return;
    _batchRequestVersion++;
    _selectedSemester.value = semester;
    _exams.clear();
    _error.value = '';
    _batches.clear();
    _selectedPcid.value = '';
    await refreshExams();
    update(<Object>['exam-content']);
  }

  Future<void> _loadBatches(String semester) async {
    final version = ++_batchRequestVersion;
    _selectedPcid.value = '';
    _batches.clear();
    final batches = await _fetchBatches(semester);
    if (!_isActiveBatchRequest(version, semester)) {
      return;
    }
    _batches.assignAll(batches);
  }

  Future<void> changeBatch(String pcid) async {
    if (_selectedPcid.value == pcid) return;
    _selectedPcid.value = pcid;
    await refreshExams();
  }

  Future<void> ensureBatches() async {
    if (_batches.isNotEmpty) return;
    await _loadBatches(_selectedSemester.value);
  }

  Future<void> refreshExams() async {
    if (!canSearch) return;

    final version = ++_requestVersion;
    _isLoading.value = true;
    _isLoadingMore.value = false;
    _error.value = '';
    _page.value = 1;
    update(<Object>['exam-content']);

    try {
      final response = await _fetchPage(1);
      if (!_isActiveRequest(version)) {
        return;
      }
      _exams.assignAll(response.results);
      _page.value = response.page <= 0 ? 1 : response.page;
      _totalPages.value = response.totalPages <= 0 ? 1 : response.totalPages;
      _total.value = response.total;
      _error.value = '';
      LogUtil.info('[ExamsController] refresh exams success total=$total');
    } catch (e, s) {
      if (!_isActiveRequest(version)) {
        return;
      }
      _error.value = e.toString();
      LogUtil.errorE('[ExamsController] refresh exams failed', e, s);
    } finally {
      if (!_isActiveRequest(version)) {
        return;
      }
      _isLoading.value = false;
      easyRefreshController.finishRefresh();
      easyRefreshController.resetFooter();
      update(<Object>['exam-content']);
    }
  }

  Future<void> loadMoreExams() async {
    if (_isLoading.value || _isLoadingMore.value || !hasMore) {
      easyRefreshController.finishLoad(
        hasMore ? IndicatorResult.none : IndicatorResult.noMore,
      );
      return;
    }

    final version = ++_requestVersion;
    _isLoadingMore.value = true;
    update(<Object>['exam-content']);

    try {
      final nextPage = page + 1;
      final response = await _fetchPage(nextPage);
      if (!_isActiveRequest(version)) {
        return;
      }
      _exams.addAll(response.results);
      _page.value = response.page <= 0 ? nextPage : response.page;
      _totalPages.value =
          response.totalPages <= 0 ? totalPages : response.totalPages;
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
      LogUtil.errorE('[ExamsController] load more exams failed', e, s);
    } finally {
      if (!_isActiveRequest(version)) {
        return;
      }
      _isLoadingMore.value = false;
      update(<Object>['exam-content']);
    }
  }

  Future<ExamQueryResponse> _fetchPage(int targetPage) async {
    return _examRepo.fetchPage(
      semester: _selectedSemester.value,
      pcid: _selectedPcid.value,
      page: targetPage,
    );
  }

  Future<ExamFilterOptions> _fetchFilterOptions() async {
    return _examRepo.fetchFilterOptions();
  }

  Future<List<ExamBatchOption>> _fetchBatches(String semester) async {
    return _examRepo.fetchBatches(semester: semester);
  }

  bool _isActiveRequest(int version) {
    return !isClosed && version == _requestVersion;
  }

  bool _isActiveBatchRequest(int version, String semester) {
    return !isClosed &&
        version == _batchRequestVersion &&
        semester == _selectedSemester.value;
  }

  @override
  void onClose() {
    easyRefreshController.dispose();
    super.onClose();
  }
}
