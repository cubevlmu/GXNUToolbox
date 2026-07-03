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

    return Obx(
      () => GetMaterialApp(
        title: 'GXNU课程表',
        debugShowCheckedModeBanner: false,
        themeMode: settingsController.themeMode.value,
        theme: FuiTheme.light(
          accent: FuiAccent(
            primary: settingsController.accent.value.lightPrimary,
            hover: settingsController.accent.value.lightHover,
            pressed: settingsController.accent.value.lightPressed,
            soft: settingsController.accent.value.lightSoft,
            subtle: settingsController.accent.value.lightSubtle,
          ),
        ),
        darkTheme: FuiTheme.dark(
          accent: FuiAccent(
            primary: settingsController.accent.value.darkPrimary,
            hover: settingsController.accent.value.darkHover,
            pressed: settingsController.accent.value.darkPressed,
            soft: settingsController.accent.value.darkSoft,
            subtle: settingsController.accent.value.darkSubtle,
          ),
        ),
        scrollBehavior: FuiTheme.scrollBehavior,
        home: const SplashPage(),
      ),
    );
  }
}
