/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:flutter/material.dart';

enum AppIconButtonVariant { ghost, soft, outline }

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.variant = AppIconButtonVariant.ghost,
    this.selected = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final AppIconButtonVariant variant;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color? bg;
    Color fg;
    Color? borderCol;

    switch (variant) {
      case AppIconButtonVariant.ghost:
        bg = null;
        fg = selected ? colors.primary : colors.textSecondary;
        borderCol = null;
        break;
      case AppIconButtonVariant.soft:
        bg = colors.primarySoft;
        fg = colors.primary;
        borderCol = null;
        break;
      case AppIconButtonVariant.outline:
        bg = colors.surface;
        fg = colors.textPrimary;
        borderCol = colors.border;
        break;
    }

    final button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: AppTokens.iconMd),
      color: fg,
      tooltip: tooltip ?? '',
      style: IconButton.styleFrom(
        backgroundColor: bg,
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          side: borderCol != null ? BorderSide(color: borderCol) : BorderSide.none,
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
