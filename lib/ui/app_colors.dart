/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.primaryHover,
    required this.primaryPressed,
    required this.primarySoft,
    required this.primarySubtle,
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceAlt,
    required this.surfacePressed,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textInverse,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerHover,
    required this.dangerSoft,
    required this.info,
    required this.infoSoft,
  });

  final Color primary;
  final Color primaryHover;
  final Color primaryPressed;
  final Color primarySoft;
  final Color primarySubtle;
  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceAlt;
  final Color surfacePressed;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color textInverse;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerHover;
  final Color dangerSoft;
  final Color info;
  final Color infoSoft;

  static AppPalette of(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>();
    assert(palette != null, 'AppPalette not registered in ThemeData.extensions');
    return palette!;
  }

  @override
  AppPalette copyWith({
    Color? primary,
    Color? primaryHover,
    Color? primaryPressed,
    Color? primarySoft,
    Color? primarySubtle,
    Color? background,
    Color? backgroundAlt,
    Color? surface,
    Color? surfaceAlt,
    Color? surfacePressed,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textInverse,
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? danger,
    Color? dangerHover,
    Color? dangerSoft,
    Color? info,
    Color? infoSoft,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      primarySoft: primarySoft ?? this.primarySoft,
      primarySubtle: primarySubtle ?? this.primarySubtle,
      background: background ?? this.background,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfacePressed: surfacePressed ?? this.surfacePressed,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textInverse: textInverse ?? this.textInverse,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      danger: danger ?? this.danger,
      dangerHover: dangerHover ?? this.dangerHover,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      primarySubtle: Color.lerp(primarySubtle, other.primarySubtle, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundAlt: Color.lerp(backgroundAlt, other.backgroundAlt, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      surfacePressed: Color.lerp(surfacePressed, other.surfacePressed, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerHover: Color.lerp(dangerHover, other.dangerHover, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
    );
  }
}

abstract final class AppColors {
  AppColors._();

  static const light = AppPalette(
    primary: Color(0xFF3F63D8),
    primaryHover: Color(0xFF3451C0),
    primaryPressed: Color(0xFF2A41A0),
    primarySoft: Color(0xFFEEF2FF),
    primarySubtle: Color(0xFFDCE3FF),
    background: Color(0xFFF6F7F9),
    backgroundAlt: Color(0xFFF0F3F8),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF8FAFC),
    surfacePressed: Color(0xFFF1F5F9),
    border: Color(0xFFE1E4EA),
    borderStrong: Color(0xFFCCD2DC),
    textPrimary: Color(0xFF171A1F),
    textSecondary: Color(0xFF68707D),
    textTertiary: Color(0xFF8A93A3),
    textDisabled: Color(0xFFA8B1BF),
    textInverse: Color(0xFFFFFFFF),
    success: Color(0xFF168A5B),
    successSoft: Color(0xFFECFDF5),
    warning: Color(0xFFD68D00),
    warningSoft: Color(0xFFFFFBEB),
    danger: Color(0xFFD92D20),
    dangerHover: Color(0xFFB42318),
    dangerSoft: Color(0xFFFEF3F2),
    info: Color(0xFF2E90FA),
    infoSoft: Color(0xFFEFF8FF),
  );

  static const dark = AppPalette(
    primary: Color(0xFF8EA8FF),
    primaryHover: Color(0xFFA3BAFF),
    primaryPressed: Color(0xFF7A97F0),
    primarySoft: Color(0xFF1A2240),
    primarySubtle: Color(0xFF1E2D5C),
    background: Color(0xFF0F1115),
    backgroundAlt: Color(0xFF141720),
    surface: Color(0xFF171A20),
    surfaceAlt: Color(0xFF1D2029),
    surfacePressed: Color(0xFF242833),
    border: Color(0xFF2A303A),
    borderStrong: Color(0xFF37404D),
    textPrimary: Color(0xFFEEF0F4),
    textSecondary: Color(0xFFA6ACB8),
    textTertiary: Color(0xFF8A909D),
    textDisabled: Color(0xFF58606D),
    textInverse: Color(0xFF141720),
    success: Color(0xFF34D399),
    successSoft: Color(0xFF0C2E22),
    warning: Color(0xFFFBBF24),
    warningSoft: Color(0xFF2E2306),
    danger: Color(0xFFF97066),
    dangerHover: Color(0xFFEF4444),
    dangerSoft: Color(0xFF2E1414),
    info: Color(0xFF38BDF8),
    infoSoft: Color(0xFF0A2330),
  );

  static ColorScheme applyTo(ColorScheme base, AppPalette palette) {
    return base.copyWith(
      primary: palette.primary,
      onPrimary: palette.textInverse,
      secondary: palette.info,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      surfaceContainerLowest: palette.background,
      surfaceContainerHighest: palette.surfaceAlt,
      outlineVariant: palette.border,
      onSurfaceVariant: palette.textSecondary,
      error: palette.danger,
      onError: palette.textInverse,
    );
  }
}
