import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class StorageUtils {
  static bool _initialized = false;
  static Future<void>? _initTask;
  static late final Directory appSupportDirectory;
  static late final Box<dynamic> settings;
  static late final Box<dynamic> cache;

  static Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    final activeTask = _initTask;
    if (activeTask != null) {
      await activeTask;
      return;
    }

    final task = _doEnsureInitialized();
    _initTask = task;
    try {
      await task;
    } finally {
      if (identical(_initTask, task)) {
        _initTask = null;
      }
    }
  }

  static Future<void> _doEnsureInitialized() async {
    if (_initialized) {
      return;
    }

    appSupportDirectory = await getApplicationSupportDirectory();
    Hive.init('${appSupportDirectory.path}/hive');
    final boxes = await Future.wait<Box<dynamic>>([
      Hive.openBox<dynamic>('settings'),
      Hive.openBox<dynamic>('cache'),
    ]);
    settings = boxes[0];
    cache = boxes[1];
    _initialized = true;
  }
}
