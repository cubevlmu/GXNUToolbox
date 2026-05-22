/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.children,
    this.padding,
    this.physics,
    this.bottomPadding = AppTokens.gap24,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ColoredBox(
      color: colors.background,
      child: SafeArea(
        child: ListView(
          physics: physics,
          padding: padding ??
              const EdgeInsets.fromLTRB(
                AppTokens.pagePadding,
                AppTokens.gap12,
                AppTokens.pagePadding,
                AppTokens.gap24,
              ),
          children: [
            ...children,
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}
