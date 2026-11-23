import 'dart:async';
import 'dart:io';

import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart' as package_info;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class GithubReleaseAsset {
  const GithubReleaseAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
  });

  final String name;
  final String downloadUrl;
  final int size;
}

class GithubReleaseInfo {
  const GithubReleaseInfo({
    required this.tagName,
    required this.version,
    required this.title,
    required this.changelog,
    required this.htmlUrl,
    required this.apkAsset,
  });

  final String tagName;
  final String version;
  final String title;
  final String changelog;
  final String htmlUrl;
  final GithubReleaseAsset? apkAsset;
}

class GithubUpdateCheckResult {
  const GithubUpdateCheckResult({
    required this.currentVersion,
    required this.hasUpdate,
    required this.release,
  });

  final String currentVersion;
  final bool hasUpdate;
  final GithubReleaseInfo release;
}

class GithubUpdateService {
  const GithubUpdateService._();

  static const String latestReleaseApiUrl =
      'https://api.github.com/repos/cubevlmu/GXNUToolbox/releases/latest';
  static const String _lastCheckAtKey = 'github_update_last_check_at';
  static const String _ignoredVersionKey = 'github_update_ignored_version';
  static const Duration _autoCheckCooldown = Duration(hours: 6);
  static const MethodChannel _nativeChannel = MethodChannel(
    'me.cubevlmu.gxnutool/native',
  );

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(seconds: 8),
      headers: const <String, String>{
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    ),
  );

  static Future<bool> shouldRunAutoCheck() async {
    final raw = StorageUtils.settings.get(_lastCheckAtKey)?.toString();
    if (raw == null || raw.isEmpty) {
      return true;
    }
    final last = DateTime.tryParse(raw);
    if (last == null) {
      return true;
    }
    return DateTime.now().difference(last) >= _autoCheckCooldown;
  }

  static bool isVersionIgnored(String version) {
    final ignored =
        StorageUtils.settings.get(_ignoredVersionKey)?.toString() ?? '';
    return ignored.isNotEmpty &&
        normalizeVersion(ignored) == normalizeVersion(version);
  }

  static Future<void> ignoreVersion(String version) async {
    await StorageUtils.settings.put(
      _ignoredVersionKey,
      normalizeVersion(version),
    );
  }

  static Future<GithubUpdateCheckResult?> checkInBackground({
    bool respectCooldown = true,
  }) async {
    if (respectCooldown && !await shouldRunAutoCheck()) {
      return null;
    }
    try {
      await StorageUtils.settings.put(
        _lastCheckAtKey,
        DateTime.now().toIso8601String(),
      );
      return await checkLatestRelease().timeout(const Duration(seconds: 15));
    } catch (e) {
      LogUtil.info('[GithubUpdate] background check skipped/failed: $e');
      return null;
    }
  }

  static Future<GithubUpdateCheckResult> checkLatestRelease() async {
    final info = await package_info.PackageInfo.fromPlatform();
    final currentVersion = normalizeVersion(info.version);

    final response = await _dio.get<Map<String, dynamic>>(latestReleaseApiUrl);
    final payload = response.data;
    if (payload == null) {
      throw StateError('GitHub Release 响应为空');
    }

    final release = parseReleaseJson(payload);
    final hasUpdate =
        release.apkAsset != null &&
        isNewerVersion(release.version, currentVersion);

    return GithubUpdateCheckResult(
      currentVersion: currentVersion,
      hasUpdate: hasUpdate,
      release: release,
    );
  }

  static GithubReleaseInfo parseReleaseJson(Map<String, dynamic> json) {
    final tagName = json['tag_name']?.toString().trim() ?? '';
    final version = normalizeVersion(tagName);
    final rawTitle = json['name']?.toString().trim() ?? '';
    final title = rawTitle.isEmpty ? 'v$version' : rawTitle;
    final changelog = json['body']?.toString().trim() ?? '';
    final htmlUrl = json['html_url']?.toString().trim() ?? '';
    final apkAsset = selectApkAsset(json['assets']);

    return GithubReleaseInfo(
      tagName: tagName,
      version: version,
      title: title,
      changelog: changelog,
      htmlUrl: htmlUrl,
      apkAsset: apkAsset,
    );
  }

  static GithubReleaseAsset? selectApkAsset(Object? rawAssets) {
    if (rawAssets is! List) {
      return null;
    }

    final candidates = <GithubReleaseAsset>[];
    for (final item in rawAssets) {
      if (item is! Map) {
        continue;
      }
      final name = item['name']?.toString().trim() ?? '';
      final url = item['browser_download_url']?.toString().trim() ?? '';
      if (!name.toLowerCase().endsWith('.apk') || url.isEmpty) {
        continue;
      }
      final sizeRaw = item['size'];
      final size = sizeRaw is int
          ? sizeRaw
          : int.tryParse(sizeRaw?.toString() ?? '') ?? 0;
      candidates.add(
        GithubReleaseAsset(name: name, downloadUrl: url, size: size),
      );
    }

    if (candidates.isEmpty) {
      return null;
    }

    for (final asset in candidates) {
      if (asset.name.toLowerCase().contains('arm64')) {
        return asset;
      }
    }
    for (final asset in candidates) {
      if (asset.name.toLowerCase().contains('release')) {
        return asset;
      }
    }
    return candidates.first;
  }

  static String normalizeVersion(String raw) {
    var value = raw.trim();
    if (value.startsWith('v') || value.startsWith('V')) {
      value = value.substring(1);
    }
    final plusIndex = value.indexOf('+');
    if (plusIndex >= 0) {
      value = value.substring(0, plusIndex);
    }
    return value.trim();
  }

  static bool isNewerVersion(String remoteRaw, String currentRaw) {
    final remoteParts = _parseVersionParts(remoteRaw);
    final currentParts = _parseVersionParts(currentRaw);
    if (remoteParts.isEmpty || currentParts.isEmpty) {
      return false;
    }

    final length = remoteParts.length > currentParts.length
        ? remoteParts.length
        : currentParts.length;
    for (var i = 0; i < length; i++) {
      final remoteVal = i < remoteParts.length ? remoteParts[i] : 0;
      final currentVal = i < currentParts.length ? currentParts[i] : 0;
      if (remoteVal > currentVal) {
        return true;
      }
      if (remoteVal < currentVal) {
        return false;
      }
    }
    return false;
  }

  static List<int> _parseVersionParts(String raw) {
    final clean = normalizeVersion(raw).split('-').first;
    if (clean.isEmpty) {
      return const <int>[];
    }
    final parts = <int>[];
    for (final segment in clean.split('.')) {
      final parsed = int.tryParse(segment.trim());
      if (parsed == null) {
        return const <int>[];
      }
      parts.add(parsed);
    }
    return parts;
  }

  static Future<bool> canRequestPackageInstalls() async {
    if (!Platform.isAndroid) {
      return true;
    }
    try {
      return await _nativeChannel.invokeMethod<bool>(
            'canRequestPackageInstalls',
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openInstallPermissionSettings() async {
    if (!Platform.isAndroid) {
      return;
    }
    await _nativeChannel.invokeMethod<void>('openInstallPermissionSettings');
  }

  static Future<String> downloadApk(
    GithubReleaseAsset asset, {
    required void Function(double? progress) onProgress,
    CancelToken? cancelToken,
  }) async {
    final cacheDir = await getTemporaryDirectory();
    final updateDir = Directory(p.join(cacheDir.path, 'github_updates'));
    if (!await updateDir.exists()) {
      await updateDir.create(recursive: true);
    }

    final safeName = asset.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final targetPath = p.join(updateDir.path, safeName);
    final file = File(targetPath);
    if (await file.exists()) {
      await file.delete();
    }

    final downloadDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );

    await downloadDio.download(
      asset.downloadUrl,
      targetPath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        final effectiveTotal = total > 0 ? total : asset.size;
        if (effectiveTotal <= 0) {
          onProgress(null);
          return;
        }
        onProgress((received / effectiveTotal).clamp(0.0, 1.0));
      },
    );

    return targetPath;
  }

  static Future<void> installApk(String filePath) async {
    if (!Platform.isAndroid) {
      return;
    }
    await _nativeChannel.invokeMethod<void>('installApk', <String, String>{
      'filePath': filePath,
    });
  }
}
