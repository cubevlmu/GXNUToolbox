/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/ui/app_colors.dart';
import 'package:flutter/material.dart';

extension AppContextX on BuildContext {
  AppPalette get colors => AppPalette.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
}
