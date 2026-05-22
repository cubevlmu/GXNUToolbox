/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:flutter/material.dart';

class AppSegmentedItem<T> {
  const AppSegmentedItem({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({super.key, required this.value, required this.items, required this.onChanged});

  final T value;
  final List<AppSegmentedItem<T>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(child: _SegmentOption(item: items[i], selected: value == items[i].value, onTap: () => onChanged(items[i].value))),
        ],
      ],
    );
  }
}

class _SegmentOption<T> extends StatelessWidget {
  const _SegmentOption({required this.item, required this.selected, required this.onTap});

  final AppSegmentedItem<T> item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderColor = selected ? colors.primary.withValues(alpha: 0.45) : colors.border;
    final bg = selected ? colors.primarySoft : colors.surface;
    final fg = selected ? colors.primary : colors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppTokens.radiusSm), border: Border.all(color: borderColor)),
          child: Column(
            children: [
              if (item.icon != null) ...[Icon(item.icon, size: 18, color: fg), const SizedBox(height: 4)],
              Text(item.label, style: TextStyle(fontSize: item.icon != null ? 11 : 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
