/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/pages/splash/view.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:flutter/material.dart';
import 'package:fin_ui/fui.dart';
import 'package:get/get.dart';

@immutable
class ClassToolApp extends StatelessWidget {
  const ClassToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put<SettingsController>(SettingsController(), permanent: true);

    return Obx(() {
      final accent = settingsController.accent.value;
      final lightAccent = accent.usesSystemColor
          ? null
          : FuiAccent.fromColorScheme(
              ColorScheme.fromSeed(
                seedColor: accent.seedColor,
                brightness: Brightness.light,
              ),
            );
      final darkAccent = accent.usesSystemColor
          ? null
          : FuiAccent.fromColorScheme(
              ColorScheme.fromSeed(
                seedColor: accent.seedColor,
                brightness: Brightness.dark,
              ),
            );
      return FuiDynamicThemeBuilder(
        useSystemAccent: accent.usesSystemColor,
        lightAccent: lightAccent,
        darkAccent: darkAccent,
        builder: (context, lightTheme, darkTheme) => GetMaterialApp(
          title: 'GXNU课程表',
          debugShowCheckedModeBanner: false,
          themeMode: settingsController.themeMode.value,
          theme: lightTheme,
          darkTheme: darkTheme,
          scrollBehavior: FuiTheme.scrollBehavior,
          home: const SplashPage(),
        ),
      );
    });
  }
}
