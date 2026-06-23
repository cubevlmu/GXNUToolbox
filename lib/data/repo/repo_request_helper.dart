import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/utils/log_util.dart';

class RepoRequestHelper {
  const RepoRequestHelper({
    required this._userRepo,
    required this._logTag,
  });

  final UserRepo _userRepo;
  final String _logTag;

  Future<T> dedupe<T>(
    Map<String, Future<T>> tasks,
    String key,
    Future<T> Function() taskBuilder,
  ) {
    final activeTask = tasks[key];
    if (activeTask != null) {
      return activeTask;
    }

    final task = taskBuilder();
    tasks[key] = task;
    return task.whenComplete(() {
      if (identical(tasks[key], task)) {
        tasks.remove(key);
      }
    });
  }

  Future<T> runWithLoginRetry<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    try {
      return await action();
    } on ApiLoginExpiredException catch (e, s) {
      LogUtil.warnE('[$_logTag] login expired while $operation', e, s);
      final recovered = await _userRepo.recoverFromExpiredLogin();
      if (!recovered) {
        rethrow;
      }
      return action();
    }
  }
}
