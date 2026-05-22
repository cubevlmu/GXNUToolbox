/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_surface.dart';
import 'package:flutter/material.dart';

class AppSection extends StatelessWidget {
  const AppSection({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final content = AppSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) Divider(height: 1, thickness: 1, color: colors.border),
          ],
        ],
      ),
    );

    if (title == null || title!.isEmpty) return content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
          child: Text(title!, style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        content,
      ],
    );
  }
}
