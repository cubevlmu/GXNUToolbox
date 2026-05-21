/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:class_tool/pages/splash/view.dart';
import 'package:class_tool/pages/settings/controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const fontFamilyFallback = <String>['Microsoft YaHei', 'PingFang SC'];
const _brandPrimary = Color(0xFF6750A4);
const _brandSecondary = Color(0xFF7E57C2);
const _brandTertiary = Color(0xFFB39DDB);

@immutable
class ClassToolApp extends StatelessWidget {
  const ClassToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put<SettingsController>(SettingsController(), permanent: true);
    final lightScheme = _buildBrandColorScheme(Brightness.light);
    final darkScheme = _buildBrandColorScheme(Brightness.dark);

    return Obx(
      () => GetMaterialApp(
        title: 'GXNU课程表',
        debugShowCheckedModeBanner: false,
        themeMode: settingsController.themeMode.value,
        theme: _buildTheme(
          colorScheme: lightScheme,
          fontFamilyFallback: fontFamilyFallback,
        ),
        darkTheme: _buildTheme(
          colorScheme: darkScheme,
          fontFamilyFallback: fontFamilyFallback,
        ),
        scrollBehavior: const _AppScrollBehavior(),
        home: const SplashPage(),
      ),
    );
  }
}

ThemeData _buildTheme({
  required ColorScheme colorScheme,
  required List<String> fontFamilyFallback,
}) {
  final isDark = colorScheme.brightness == Brightness.dark;
  final scaffoldColor = isDark
      ? colorScheme.surfaceContainerLowest
      : colorScheme.surfaceContainerLowest;
  final cardColor = colorScheme.surface;
  final outlineColor = colorScheme.outlineVariant.withValues(alpha: 0.68);
  final textTheme = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamilyFallback: fontFamilyFallback,
  ).textTheme;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldColor,
    canvasColor: scaffoldColor,
    fontFamilyFallback: fontFamilyFallback,
    splashFactory: InkSparkle.splashFactory,
    textTheme: textTheme.copyWith(
      displaySmall: textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(height: 1.35),
      bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.35),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      systemOverlayStyle: _overlayStyleForBrightness(colorScheme.brightness),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: outlineColor.withValues(alpha: 0.4)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.28)
          : colorScheme.surface.withValues(alpha: 0.96),
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.78),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: outlineColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: outlineColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: outlineColor),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.92),
      indicatorColor: colorScheme.secondaryContainer,
      elevation: 0,
      height: 72,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          size: 24,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        );
      }),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

ColorScheme _buildBrandColorScheme(Brightness brightness) {
  final base = ColorScheme.fromSeed(
    seedColor: _brandPrimary,
    brightness: brightness,
  );

  if (brightness == Brightness.light) {
    return base.copyWith(
      primary: _brandPrimary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE9DDFF),
      onPrimaryContainer: const Color(0xFF4F378B),
      secondary: _brandSecondary,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFEEE4FF),
      onSecondaryContainer: const Color(0xFF5B43A0),
      tertiary: _brandTertiary,
      onTertiary: const Color(0xFF2F1B52),
      tertiaryContainer: const Color(0xFFF1E8FF),
      onTertiaryContainer: const Color(0xFF49346F),
      surfaceTint: _brandPrimary,
    );
  }

  return base.copyWith(
    primary: const Color(0xFFD0BCFF),
    onPrimary: const Color(0xFF381E72),
    primaryContainer: const Color(0xFF4F378B),
    onPrimaryContainer: const Color(0xFFEADDFF),
    secondary: const Color(0xFFD6C5FF),
    onSecondary: const Color(0xFF36275B),
    secondaryContainer: const Color(0xFF52407A),
    onSecondaryContainer: const Color(0xFFEEE4FF),
    tertiary: const Color(0xFFE5D7FF),
    onTertiary: const Color(0xFF33204F),
    tertiaryContainer: const Color(0xFF4B3868),
    onTertiaryContainer: const Color(0xFFF1E8FF),
    surfaceTint: _brandPrimary,
  );
}

SystemUiOverlayStyle _overlayStyleForBrightness(Brightness brightness) {
  final darkIcons = brightness == Brightness.light;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: darkIcons ? Brightness.dark : Brightness.light,
    statusBarBrightness: darkIcons ? Brightness.light : Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: darkIcons
        ? Brightness.dark
        : Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  );
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
