import 'dart:async';

import 'package:class_tool/pages/classes/controller.dart';
import 'package:class_tool/pages/classes/view.dart';
import 'package:class_tool/pages/features/view.dart';
import 'package:class_tool/pages/home/controller.dart';
import 'package:class_tool/pages/home/view.dart';
import 'package:class_tool/pages/main/controller.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:class_tool/pages/settings/view.dart';
import 'package:flutter/material.dart';
import 'package:fui/fui.dart';
import 'package:get/get.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final MainController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MainController());
    final classesController = Get.put(ClassesController());
    Get.put(HomeController());
    if (!classesController.isLoading && !classesController.hasScheduleData) {
      unawaited(
        classesController.syncScheduleOverview(syncExternalOutputs: true),
      );
    }
    if (Get.isRegistered<SettingsController>()) {
      Get.find<SettingsController>().refreshUserInfo();
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<ClassesController>()) {
      Get.delete<ClassesController>();
    }
    if (Get.isRegistered<HomeController>()) {
      Get.delete<HomeController>();
    }
    if (Get.isRegistered<MainController>()) {
      Get.delete<MainController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.selectedIndex.value;

      return FuiNavigationShell(
        selectedIndex: selectedIndex,
        onSelected: controller.onDestinationSelected,
        enableRail: true,
        autoExtendRail: false,
        items: const [
          FuiNavigationItem(
            destination: FuiNavigationDestination(
              icon: FUIIcons.home,
              selectedIcon: FUIIcons.homeFilled,
              label: '首页',
            ),
            page: HomePage(),
          ),
          FuiNavigationItem(
            destination: FuiNavigationDestination(
              icon: FUIIcons.calendar,
              selectedIcon: FUIIcons.calendarFilled,
              label: '课表',
            ),
            page: ClassesPage(),
          ),
          FuiNavigationItem(
            destination: FuiNavigationDestination(
              icon: FUIIcons.apps,
              selectedIcon: FUIIcons.appsFilled,
              label: '功能',
            ),
            page: FeaturesPage(),
          ),
          FuiNavigationItem(
            destination: FuiNavigationDestination(
              icon: FUIIcons.settings,
              selectedIcon: FUIIcons.settingsFilled,
              label: '设置',
            ),
            page: SettingsPage(),
          ),
        ],
      );
    });
  }
}
