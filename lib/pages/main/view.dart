import 'dart:async';

import 'package:class_tool/data/repo/bell_schedule_repo.dart';
import 'package:class_tool/data/repo/user_repo.dart';
import 'package:class_tool/pages/classes/controller.dart';
import 'package:class_tool/pages/classes/view.dart';
import 'package:class_tool/pages/features/view.dart';
import 'package:class_tool/pages/home/controller.dart';
import 'package:class_tool/pages/home/view.dart';
import 'package:class_tool/pages/main/controller.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:class_tool/pages/settings/view.dart';
import 'package:class_tool/ui/app_bottom_tab_bar.dart';
import 'package:class_tool/ui/app_icons.dart';
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
    final userRepo = Get.find<UserRepo>();
    if (userRepo.isLogin && !userRepo.isOfflineMode) {
      unawaited(Get.find<BellScheduleRepo>().ensureLoaded());
    }
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

    return Obx(() {
      final selectedIndex = controller.selectedIndex.value;

      return Scaffold(
        body: RepaintBoundary(
          child: IndexedStack(index: selectedIndex, children: pages),
        ),
        bottomNavigationBar: AppBottomTabBar(
          selectedIndex: selectedIndex,
          onSelected: controller.onDestinationSelected,
          items: const [
            AppBottomTabItem(
              icon: AppIcons.home,
              selectedIcon: AppIcons.homeFilled,
              label: '首页',
            ),
            AppBottomTabItem(
              icon: AppIcons.calendar,
              selectedIcon: AppIcons.calendarFilled,
              label: '课表',
            ),
            AppBottomTabItem(
              icon: AppIcons.apps,
              selectedIcon: AppIcons.appsFilled,
              label: '功能',
            ),
            AppBottomTabItem(
              icon: AppIcons.settings,
              selectedIcon: AppIcons.settingsFilled,
              label: '设置',
            ),
          ],
        ),
      );
    });
  }
}
