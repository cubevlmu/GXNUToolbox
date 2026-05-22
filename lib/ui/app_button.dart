/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = false,
    this.small = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool fullWidth;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final height = small ? AppTokens.smallButtonHeight : AppTokens.buttonHeight;
    final iconSize = small ? AppTokens.iconSm : AppTokens.iconMd;

    Color bg;
    Color fg;
    Color? borderCol;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = colors.primary;
        fg = colors.textInverse;
        borderCol = null;
        break;
      case AppButtonVariant.secondary:
        bg = colors.primarySoft;
        fg = colors.primary;
        borderCol = colors.primary.withValues(alpha: 0.25);
        break;
      case AppButtonVariant.danger:
        bg = colors.dangerSoft;
        fg = colors.danger;
        borderCol = colors.danger.withValues(alpha: 0.35);
        break;
    }

    final style = TextButton.styleFrom(
      minimumSize: Size(fullWidth ? double.infinity : 0, height),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      backgroundColor: bg,
      foregroundColor: fg,
      disabledBackgroundColor: colors.border,
      disabledForegroundColor: colors.textDisabled,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        side: borderCol != null ? BorderSide(color: borderCol, width: 1) : BorderSide.none,
      ),
      textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: small ? 13 : 15),
    );

    final child = icon != null
        ? Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: iconSize), const SizedBox(width: 6), Text(label)])
        : Text(label);

    return TextButton(onPressed: onPressed, style: style, child: child);
  }
}
