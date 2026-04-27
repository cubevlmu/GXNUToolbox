/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';

import 'package:class_tool/class_tool_app.dart';
import 'package:class_tool/data/injector/injector.dart';
import 'package:class_tool/data/services/morning_briefing_service.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
  }
  await StorageUtils.ensureInitialized();
  await LogUtil.init();
  Injector.injectRepos();
  if (Platform.isAndroid) {
    await MorningBriefingService.initialize();
  }
  runApp(const ClassToolApp());
}
