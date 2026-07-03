import 'dart:async';

import 'package:class_tool/data/model/course_note.dart';
import 'package:class_tool/data/repo/course_note_repo.dart';
import 'package:class_tool/data/services/debug_time_service.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:get/get.dart';

class CourseNotesController extends GetxController {
  CourseNotesController({
    required this.initialCourse,
    CourseNoteRepo? courseNoteRepo,
    DebugTimeService? debugTimeService,
  }) : _courseNoteRepo = courseNoteRepo ?? Get.find<CourseNoteRepo>(),
       _debugTimeService = debugTimeService ?? Get.find<DebugTimeService>();

  final CourseNoteCourseDraft? initialCourse;
  final CourseNoteRepo _courseNoteRepo;
  final DebugTimeService _debugTimeService;

  final RxList<CourseNoteEntry> _items = <CourseNoteEntry>[].obs;
  final RxString _error = ''.obs;
  final RxBool _pendingOnly = false.obs;
  StreamSubscription<List<CourseNoteEntry>>? _subscription;

  List<CourseNoteEntry> get items => _items;
  String get error => _error.value;
  bool get pendingOnly => _pendingOnly.value;
  bool get hasData => _items.isNotEmpty;
  bool get canCreate => true;
  CourseNoteCourseDraft get createCourse =>
      initialCourse ?? CourseNoteRepo.generalTaskCourseDraft();

  @override
  void onInit() {
    super.onInit();
    _subscribe();
  }

  void togglePendingOnly() {
    _pendingOnly.value = !_pendingOnly.value;
    _subscribe();
  }

  Future<void> save(CourseNoteDraft draft) async {
    await _courseNoteRepo.save(draft);
  }

  Future<void> setDone(CourseNoteEntry entry, bool isDone) async {
    await _courseNoteRepo.setDone(entry.note.id, isDone);
  }

  Future<void> addToToday(CourseNoteEntry entry) async {
    if (entry.isExam) {
      return;
    }
    final now = _debugTimeService.now;
    final dueAt = DateTime(now.year, now.month, now.day, 23, 59);
    final dayMarker = DateTime(now.year, now.month, now.day);
    await _courseNoteRepo.addToToday(
      noteId: entry.note.id,
      dueAt: dueAt,
      dayMarker: dayMarker,
    );
  }

  Future<void> removeFromToday(CourseNoteEntry entry) async {
    if (entry.isExam) {
      return;
    }
    await _courseNoteRepo.removeFromToday(entry.note.id);
  }

  bool isManualTodayTask(CourseNoteEntry entry) {
    if (entry.isExam) {
      return false;
    }
    final marker = entry.note.linkedClassDate;
    if (marker == null) {
      return false;
    }
    final now = _debugTimeService.now;
    return marker.year == now.year &&
        marker.month == now.month &&
        marker.day == now.day;
  }

  Future<void> delete(CourseNoteEntry entry) async {
    await _courseNoteRepo.delete(entry.note.id);
  }

  Future<void> deleteMany(Iterable<int> noteIds) async {
    await _courseNoteRepo.deleteMany(noteIds);
  }

  Future<bool> exportToCalendar(CourseNoteEntry entry) async {
    return _courseNoteRepo.exportToCalendar(entry.note.id);
  }

  Future<CourseNoteCalendarBatchResult> exportManyToCalendar(
    Iterable<int> noteIds,
  ) {
    return _courseNoteRepo.exportManyToCalendar(noteIds);
  }

  void _subscribe() {
    unawaited(_subscription?.cancel());
    final course = initialCourse;
    final stream = course == null
        ? _courseNoteRepo.watchAllNotes(pendingOnly: _pendingOnly.value)
        : _courseNoteRepo.watchCourseNotes(course.courseKey);
    _subscription = stream.listen(
      (items) {
        _items.assignAll(
          _pendingOnly.value ? items.where((item) => !item.note.isDone) : items,
        );
        _error.value = '';
        update(<Object>['course-notes-content']);
      },
      onError: (Object e, StackTrace s) {
        _error.value = e.toString();
        LogUtil.errorE('[CourseNotesController] watch failed', e, s);
        update(<Object>['course-notes-content']);
      },
    );
    update(<Object>['course-notes-content']);
  }

  @override
  void onClose() {
    unawaited(_subscription?.cancel());
    super.onClose();
  }
}
