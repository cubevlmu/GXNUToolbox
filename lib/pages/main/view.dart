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
    const pages = [HomePage(), ClassesPage(), FeaturesPage(), SettingsPage()];
    const titles = ['首页', '课表', '功能', '设置'];

    return Obx(() {
      final selectedIndex = controller.selectedIndex.value;
      final hasOwnAppBar = selectedIndex == 1 || selectedIndex == 2;

      return Scaffold(
        appBar: hasOwnAppBar
            ? null
            : AppBar(title: Text(titles[selectedIndex])),
        body: RepaintBoundary(
          child: IndexedStack(index: selectedIndex, children: pages),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          onDestinationSelected: controller.onDestinationSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: '首页',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_view_week_outlined),
              selectedIcon: Icon(Icons.calendar_view_week_rounded),
              label: '课表',
            ),
            NavigationDestination(
              icon: Icon(Icons.apps_outlined),
              selectedIcon: Icon(Icons.apps_rounded),
              label: '功能',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: '设置',
            ),
          ],
        ),
      );
    });
  }
}
