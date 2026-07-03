import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/data/model/school_notification.dart';
import 'package:class_tool/data/repo/repo_request_helper.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:get/get.dart';

class NotificationRepo {
  NotificationRepo({UserRepo? userRepo})
    : _helper = RepoRequestHelper(
        userRepo: userRepo ?? Get.find<UserRepo>(),
        logTag: 'NotificationRepo',
      );

  final RepoRequestHelper _helper;
  final Map<String, Future<SchoolNotificationQueryResponse>> _pageTasks = {};

  Future<SchoolNotificationQueryResponse> fetchPage({
    int page = 1,
    int pageSize = 50,
    String title = '',
    String type = '',
  }) {
    final key = [page, pageSize, title, type].join('|');
    return _helper.dedupe(_pageTasks, key, () {
      return _helper.runWithLoginRetry(
        'fetch notification page',
        () => Api.getNotificationList(
          page: page,
          pageSize: pageSize,
          title: title,
          type: type,
        ),
      );
    });
  }

  Future<void> markRead(List<String> ids) {
    return _helper.runWithLoginRetry(
      'mark notifications read',
      () => Api.markNotificationsRead(ids: ids),
    );
  }

  Future<void> delete(List<String> ids) {
    return _helper.runWithLoginRetry(
      'delete notifications',
      () => Api.deleteNotifications(ids: ids),
    );
  }
}
