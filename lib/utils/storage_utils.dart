import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class StorageUtils {
  static bool _initialized = false;
  static late final Directory appSupportDirectory;
  static late final Box<dynamic> settings;
  static late final Box<dynamic> cache;

  static Future<void> ensureInitialized() async {
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
