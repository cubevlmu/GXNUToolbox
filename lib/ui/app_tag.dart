/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:flutter/material.dart';

enum AppTagVariant { neutral, primary, success, warning, danger }

class AppTag extends StatelessWidget {
  const AppTag({super.key, required this.label, this.icon, this.variant = AppTagVariant.neutral});

  final String label;
  final IconData? icon;
  final AppTagVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (bg, fg) = switch (variant) {
      AppTagVariant.primary => (colors.primarySoft, colors.primary),
      AppTagVariant.success => (colors.successSoft, colors.success),
      AppTagVariant.warning => (colors.warningSoft, colors.warning),
      AppTagVariant.danger => (colors.dangerSoft, colors.danger),
      AppTagVariant.neutral => (colors.surfaceAlt, colors.textSecondary),
    };

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppTokens.radiusFull)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: fg), const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
