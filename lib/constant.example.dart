/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

/*
 * Example build constants.
 *
 * Copy this file to lib/constant.dart and fill the update service credentials
 * for local builds. Do not commit lib/constant.dart.
 */

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gx_update_client/gx_update_client.dart';

abstract final class AppConstants {
  const AppConstants._();

  static const bool updateCheckEnabled = true;
  static const bool updateBlockOnCheckFailure = false;

  static const String updateBaseUrl = 'http://127.0.0.1:8080';
  static const String updateAppId = 'me.cubevlmu.class_tool';
  static const String updateClientSecret = 'replace-with-client-secret';
  static const String updateEd25519PublicKey =
      'replace-with-ed25519-public-key';

  static String get updateChannel => kDebugMode ? 'dev' : 'stable';
  static const String archAndroid = 'arm64-v8a';
  static const String archWindows = 'x64';

  static String get updatePlatform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isWindows) return 'windows';
    return GxUpdateConfig.detectPlatform();
  }

  static String get updateArch {
    if (Platform.isAndroid) return archAndroid;
    if (Platform.isWindows) return archWindows;
    return 'universal';
  }

  static GxUpdateConfig get updateConfig {
    return GxUpdateConfig(
      baseUrl: updateBaseUrl,
      appId: updateAppId,
      clientSecret: updateClientSecret,
      ed25519PublicKey: updateEd25519PublicKey,
      platform: updatePlatform,
      channel: updateChannel,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      downloadDirName: 'class_tool_update',
      arch: updateArch,
    );
  }
}
