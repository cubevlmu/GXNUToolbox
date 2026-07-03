/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';

import 'package:class_tool/constant.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:gx_update_client/gx_update_client.dart';
import 'package:package_info_plus/package_info_plus.dart' as package_info;

class AppUpdateService {
  AppUpdateService._();

  static const String _startupOptionalUpdatePromptKey =
      'startup_optional_update_prompt_enabled';

  static final GxUpdateClient _client = GxUpdateClient(
    config: AppConstants.updateConfig,
  );

  static bool get isSupported {
    return AppConstants.updateCheckEnabled &&
        AppConstants.updateBaseUrl.isNotEmpty &&
        AppConstants.updateAppId.isNotEmpty &&
        AppConstants.updateClientSecret.isNotEmpty &&
        AppConstants.updateEd25519PublicKey.isNotEmpty;
  }

  static bool get startupOptionalUpdatePromptEnabled {
    return StorageUtils.settings.get(_startupOptionalUpdatePromptKey) != false;
  }

  static Future<void> setStartupOptionalUpdatePromptEnabled(
    bool enabled,
  ) async {
    await StorageUtils.settings.put(_startupOptionalUpdatePromptKey, enabled);
  }

  static Future<CheckUpdateResponse> check() async {
    if (!isSupported) {
      throw const AppUpdateCheckUnavailableException();
    }

    final installId = await GxUpdateIdentity.getOrCreateInstallId(
      key: 'class_tool_update_install_id',
    );
    final packageInfo = await package_info.PackageInfo.fromPlatform();
    final version = packageInfo.version.trim();

    return _client.check(
      version: version,
      versionCode: versionCodeFromVersion(version),
      clientId: installId,
      installId: installId,
    );
  }

  static Future<DownloadedUpdatePackage> downloadAndInstall(
    UpdateInfo update, {
    void Function(DownloadProgress progress)? onProgress,
    bool Function()? shouldCancel,
  }) async {
    void checkCancelled() {
      if (shouldCancel?.call() ?? false) {
        throw const GxUpdateCancelledException();
      }
    }

    if (Platform.isAndroid) {
      final allowed = await GxUpdateInstaller.canRequestPackageInstalls();
      checkCancelled();
      if (!allowed) {
        await GxUpdateInstaller.openInstallPermissionSettings();
        throw const AppUpdateInstallPermissionRequiredException();
      }
    }

    final package = await _client.downloadAndVerify(
      update,
      onProgress: onProgress,
      shouldCancel: shouldCancel,
    );
    checkCancelled();

    if (Platform.isAndroid) {
      await GxUpdateInstaller.installApk(package.filePath);
      return package;
    }

    if (Platform.isWindows) {
      checkCancelled();
      await _openWindowsUpdatePackage(package.filePath);
      return package;
    }

    return package;
  }

  static Future<void> _openWindowsUpdatePackage(String filePath) async {
    final lower = filePath.toLowerCase();

    if (lower.endsWith('.exe') || lower.endsWith('.msi')) {
      await Process.start(
        filePath,
        const <String>[],
        mode: ProcessStartMode.detached,
      );
      return;
    }

    await Process.start('explorer.exe', <String>[
      '/select,',
      filePath,
    ], mode: ProcessStartMode.detached);
  }
}

class AppUpdateCheckUnavailableException implements Exception {
  const AppUpdateCheckUnavailableException();

  @override
  String toString() {
    return 'AppUpdateCheckUnavailableException: update check is disabled or not configured.';
  }
}

class AppUpdateInstallPermissionRequiredException implements Exception {
  const AppUpdateInstallPermissionRequiredException();

  @override
  String toString() {
    return 'AppUpdateInstallPermissionRequiredException: Android install permission required.';
  }
}
