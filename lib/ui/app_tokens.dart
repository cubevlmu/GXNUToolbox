/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';

abstract final class AppTokens {
  const AppTokens._();

  static const double radiusXs = 6;
  static const double radiusSm = 10;
  static const double radiusMd = 12;
  static const double radiusLg = 14;
  static const double radiusXl = 18;
  static const double radiusFull = 999;

  static const double gap2 = 2;
  static const double gap4 = 4;
  static const double gap6 = 6;
  static const double gap8 = 8;
  static const double gap10 = 10;
  static const double gap12 = 12;
  static const double gap14 = 14;
  static const double gap16 = 16;
  static const double gap20 = 20;
  static const double gap24 = 24;
  static const double gap32 = 32;

  static const double pagePadding = 16;
  static const double sectionGap = 16;
  static const double tileGap = 8;

  static const double inputHeight = 44;
  static const double buttonHeight = 42;
  static const double smallButtonHeight = 34;
  static const double tileMinHeight = 52;
  static const double bottomTabHeight = 58;

  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;

  static const double borderWidth = 1;

  static const Duration durationFast = Duration(milliseconds: 120);
  static const Duration durationNormal = Duration(milliseconds: 180);
}

abstract final class AppInsets {
  const AppInsets._();

  static const EdgeInsets page = EdgeInsets.fromLTRB(16, 10, 16, 24);
  static const EdgeInsets card = EdgeInsets.all(14);
  static const EdgeInsets tile = EdgeInsets.symmetric(horizontal: 14, vertical: 10);
}
