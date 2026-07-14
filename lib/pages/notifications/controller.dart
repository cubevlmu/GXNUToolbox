import 'package:class_tool/data/model/school_notification.dart';
import 'package:class_tool/data/repo/notification_repo.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  NotificationsController({NotificationRepo? notificationRepo})
    : _notificationRepo = notificationRepo ?? Get.find<NotificationRepo>();

  static const int pageSize = 20;

  final NotificationRepo _notificationRepo;

  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _error = ''.obs;
  final RxString _keyword = ''.obs;
  final RxList<SchoolNotificationItem> _items = <SchoolNotificationItem>[].obs;
  final RxInt _page = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _total = 0.obs;
  int _requestVersion = 0;

  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get error => _error.value;
  String get keyword => _keyword.value;
  List<SchoolNotificationItem> get items => _items;
  int get page => _page.value;
  int get totalPages => _totalPages.value;
  int get total => _total.value;
  bool get hasData => _items.isNotEmpty;
  bool get hasMore => page < totalPages;

  @override
  void onInit() {
    super.onInit();
    Future<void>.microtask(refreshNotifications);
  }

  Future<void> search(String value) async {
    final normalized = value.trim();
    if (_keyword.value == normalized && hasData) {
      return;
    }
    _keyword.value = normalized;
    await refreshNotifications();
  }

  Future<void> clearSearch() async {
    if (_keyword.value.isEmpty) {
      return;
    }
    _keyword.value = '';
    await refreshNotifications();
  }

  Future<void> refreshNotifications() async {
    final version = ++_requestVersion;
    _isLoading.value = true;
    _isLoadingMore.value = false;
    _error.value = '';
    _page.value = 1;
    update(<Object>['notification-content']);

    try {
      final response = await _fetchPage(1);
      if (!_isActiveRequest(version)) {
        return;
      }
      _items.assignAll(response.results);
      _page.value = response.page <= 0 ? 1 : response.page;
      _totalPages.value = response.totalPages <= 0 ? 1 : response.totalPages;
      _total.value = response.total;
      _error.value = '';
      LogUtil.info(
        '[NotificationsController] refresh success total=${response.total}',
      );
    } catch (e, s) {
      if (!_isActiveRequest(version)) {
        return;
      }
      _error.value = e.toString();
      LogUtil.errorE('[NotificationsController] refresh failed', e, s);
    } finally {
      if (_isActiveRequest(version)) {
        _isLoading.value = false;
        update(<Object>['notification-content']);
      }
    }
  }

  Future<void> loadMoreNotifications() async {
    if (_isLoading.value || _isLoadingMore.value || !hasMore) {
      return;
    }

    final version = ++_requestVersion;
    _isLoadingMore.value = true;
    update(<Object>['notification-content']);

    try {
      final nextPage = page + 1;
      final response = await _fetchPage(nextPage);
      if (!_isActiveRequest(version)) {
        return;
      }
      _items.addAll(response.results);
      _page.value = response.page <= 0 ? nextPage : response.page;
      _totalPages.value = response.totalPages <= 0
          ? totalPages
          : response.totalPages;
      _total.value = response.total;
    } catch (e, s) {
      if (!_isActiveRequest(version)) {
        return;
      }
      _error.value = e.toString();
      LogUtil.errorE('[NotificationsController] load more failed', e, s);
    } finally {
      if (_isActiveRequest(version)) {
        _isLoadingMore.value = false;
        update(<Object>['notification-content']);
      }
    }
  }

  Future<void> markAsRead(SchoolNotificationItem item) async {
    if (item.id.isEmpty || item.isRead) {
      return;
    }

    final index = _items.indexWhere((candidate) => candidate.id == item.id);
    if (index < 0) {
      return;
    }

    final previous = _items[index];
    _items[index] = previous.markRead();
    update(<Object>['notification-content']);

    try {
      await _notificationRepo.markRead([item.id]);
      LogUtil.info('[NotificationsController] mark read success');
    } catch (e, s) {
      if (isClosed) {
        return;
      }
      final currentIndex = _items.indexWhere(
        (candidate) => candidate.id == item.id,
      );
      if (currentIndex >= 0) {
        _items[currentIndex] = previous;
      }
      _error.value = e.toString();
      update(<Object>['notification-content']);
      LogUtil.errorE('[NotificationsController] mark read failed', e, s);
    }
  }

  Future<void> deleteNotification(SchoolNotificationItem item) async {
    if (item.id.isEmpty) {
      return;
    }

    final index = _items.indexWhere((candidate) => candidate.id == item.id);
    if (index < 0) {
      return;
    }

    final previous = _items[index];
    _items.removeAt(index);
    if (_total.value > 0) {
      _total.value -= 1;
    }
    update(<Object>['notification-content']);

    try {
      await _notificationRepo.delete([item.id]);
      LogUtil.info('[NotificationsController] delete success');
    } catch (e, s) {
      if (isClosed) {
        return;
      }
      final insertIndex = index.clamp(0, _items.length).toInt();
      _items.insert(insertIndex, previous);
      _total.value += 1;
      _error.value = e.toString();
      update(<Object>['notification-content']);
      LogUtil.errorE('[NotificationsController] delete failed', e, s);
    }
  }

  Future<SchoolNotificationQueryResponse> _fetchPage(int targetPage) {
    return _notificationRepo.fetchPage(
      page: targetPage,
      pageSize: pageSize,
      title: _keyword.value,
    );
  }

  bool _isActiveRequest(int version) {
    return !isClosed && version == _requestVersion;
  }
}
