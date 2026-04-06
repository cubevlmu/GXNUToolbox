import 'package:package_info_plus/package_info_plus.dart';

class AppInfoUtil {
  const AppInfoUtil._();

  static Future<String>? _versionTask;

  static Future<String> getVersionLabel() async {
    final cachedTask = _versionTask;
    if (cachedTask != null) {
      return cachedTask;
    }

    final task = _loadVersionLabel();
    _versionTask = task;
    return task;
  }

  static Future<String> _loadVersionLabel() async {
    final info = await PackageInfo.fromPlatform();
    final build = info.buildNumber.trim();
    if (build.isEmpty || build == '0') {
      return info.version;
    }
    return '${info.version}+$build';
  }
}
