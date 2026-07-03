import 'dart:async';

import 'package:class_tool/data/model/attendance.dart';
import 'package:class_tool/data/repo/attendance_repo.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:get/get.dart';

class AttendanceController extends GetxController {
  AttendanceController({AttendanceRepo? attendanceRepo})
    : _attendanceRepo = attendanceRepo ?? Get.find<AttendanceRepo>();

  final AttendanceRepo _attendanceRepo;
  final RxList<AttendanceGroupSummary> groups = <AttendanceGroupSummary>[].obs;
  final RxList<AttendanceSessionSummary> sessions =
      <AttendanceSessionSummary>[].obs;
  final RxString error = ''.obs;
  StreamSubscription<List<AttendanceGroupSummary>>? _groupSubscription;
  StreamSubscription<List<AttendanceSessionSummary>>? _sessionSubscription;

  @override
  void onInit() {
    super.onInit();
    _groupSubscription = _attendanceRepo.watchGroups().listen(
      (items) {
        groups.assignAll(items);
        error.value = '';
        update(<Object>['attendance-content']);
      },
      onError: (Object e, StackTrace s) {
        error.value = e.toString();
        LogUtil.errorE('[AttendanceController] watch groups failed', e, s);
        update(<Object>['attendance-content']);
      },
    );
    _sessionSubscription = _attendanceRepo.watchSessions().listen(
      (items) {
        sessions.assignAll(items);
        update(<Object>['attendance-content']);
      },
      onError: (Object e, StackTrace s) {
        error.value = e.toString();
        LogUtil.errorE('[AttendanceController] watch sessions failed', e, s);
        update(<Object>['attendance-content']);
      },
    );
  }

  Future<int> createGroup({
    required String name,
    required String rosterText,
    String description = '',
  }) {
    return _attendanceRepo.createGroup(
      name: name,
      rosterText: rosterText,
      description: description,
    );
  }

  Future<int> createSession({
    required int groupId,
    required String title,
    required DateTime sessionDate,
    String remark = '',
  }) {
    return _attendanceRepo.createSession(
      groupId: groupId,
      title: title,
      sessionDate: sessionDate,
      remark: remark,
    );
  }

  Future<void> deleteGroup(int groupId) => _attendanceRepo.deleteGroup(groupId);

  Future<void> deleteSession(int sessionId) =>
      _attendanceRepo.deleteSession(sessionId);

  Future<AttendanceMatrix> buildMatrix(
    int groupId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _attendanceRepo.buildMatrix(
      groupId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  void onClose() {
    unawaited(_groupSubscription?.cancel());
    unawaited(_sessionSubscription?.cancel());
    super.onClose();
  }
}

class AttendanceSessionController extends GetxController {
  AttendanceSessionController({
    required this.sessionId,
    AttendanceRepo? attendanceRepo,
  }) : _attendanceRepo = attendanceRepo ?? Get.find<AttendanceRepo>();

  final int sessionId;
  final AttendanceRepo _attendanceRepo;
  final Rxn<AttendanceSessionSummary> summary = Rxn<AttendanceSessionSummary>();
  final RxList<AttendanceRecordEntry> records = <AttendanceRecordEntry>[].obs;
  final RxBool tableMode = false.obs;
  StreamSubscription<List<AttendanceRecordEntry>>? _recordSubscription;

  @override
  void onInit() {
    super.onInit();
    refreshSummary();
    _recordSubscription = _attendanceRepo.watchRecords(sessionId).listen((
      items,
    ) {
      records.assignAll(items);
      refreshSummary();
      update(<Object>['attendance-session-content']);
    });
  }

  Future<void> refreshSummary() async {
    summary.value = await _attendanceRepo.getSessionSummary(sessionId);
    update(<Object>['attendance-session-content']);
  }

  Future<void> setPresent(AttendanceRecordEntry entry, bool present) {
    return _attendanceRepo.updateRecord(
      recordId: entry.record.id,
      present: present,
    );
  }

  Future<void> setRemark(AttendanceRecordEntry entry, String remark) {
    return _attendanceRepo.updateRecord(
      recordId: entry.record.id,
      present: entry.record.present,
      remark: remark,
    );
  }

  void toggleTableMode() {
    tableMode.value = !tableMode.value;
    update(<Object>['attendance-session-content']);
  }

  String buildTableText() {
    final lines = <String>['序号\t姓名\t状态\t备注'];
    for (var i = 0; i < records.length; i++) {
      final entry = records[i];
      lines.add(
        [
          '${i + 1}',
          entry.student.name,
          entry.record.present ? '已到' : '未到',
          entry.record.remark,
        ].join('\t'),
      );
    }
    return lines.join('\n');
  }

  @override
  void onClose() {
    unawaited(_recordSubscription?.cancel());
    super.onClose();
  }
}
