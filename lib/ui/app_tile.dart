/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:flutter/material.dart';

class AppTile extends StatelessWidget {
  const AppTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.showChevron = true,
    this.minHeight = AppTokens.tileMinHeight,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final bool showChevron;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleColor = enabled ? colors.textPrimary : colors.textDisabled;
    final subtitleColor = enabled ? colors.textTertiary : colors.textDisabled;

    final resolvedLeading = leading ??
        (icon != null
            ? Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primarySoft,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                child: Icon(icon, size: AppTokens.iconMd, color: colors.primary),
              )
            : null);

    Widget? resolvedTrailing = trailing;
    if (resolvedTrailing == null && showChevron && onTap != null) {
      resolvedTrailing = Icon(AppIcons.chevronRight, size: AppTokens.iconMd, color: subtitleColor);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Padding(
            padding: AppInsets.tile,
            child: Row(
              children: [
                if (resolvedLeading != null) ...[
                  resolvedLeading,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: titleColor, fontWeight: FontWeight.w600, fontSize: 14)),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: subtitleColor, fontSize: 12, height: 1.3)),
                      ],
                    ],
                  ),
                ),
                if (resolvedTrailing != null) ...[
                  const SizedBox(width: 12),
                  resolvedTrailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
