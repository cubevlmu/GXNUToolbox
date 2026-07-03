/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: khfahqp khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';

import 'package:class_tool/class_tool_app.dart';
import 'package:class_tool/data/injector/injector.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/data/services/morning_briefing_service.dart';
import 'package:class_tool/data/services/course_note_reminder_service.dart';
import 'package:class_tool/navigation/session_expiry_coordinator.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageUtils.ensureInitialized();
  await LogUtil.init();
  if (Platform.isAndroid) {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  }
  Injector.injectRepos();
  Get.find<UserRepo>().onSessionExpiredUnrecoverable =
      SessionExpiryCoordinator.redirectToSplash;
  if (Platform.isAndroid) {
    await MorningBriefingService.initialize();
    await CourseNoteReminderService.initialize();
  }
  runApp(const ClassToolApp());
}
