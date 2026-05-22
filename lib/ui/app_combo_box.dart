/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:flutter/material.dart';

class AppComboBox<T> extends StatelessWidget {
  const AppComboBox({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    this.onChanged,
    this.hintText,
    this.enabled = true,
    this.label,
  });

  final T? value;
  final List<T> items;
  final String Function(T item) itemLabelBuilder;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final bool enabled;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayText = value != null ? itemLabelBuilder(value as T) : (hintText ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary)),
          const SizedBox(height: 6),
        ],
        InkWell(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          onTap: enabled ? () => _showPicker(context) : null,
          child: Container(
            height: AppTokens.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppTokens.radiusMd), border: Border.all(color: colors.border)),
            child: Row(
              children: [
                Expanded(child: Text(displayText, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: value != null ? colors.textPrimary : colors.textTertiary))),
                Icon(AppIcons.chevronDown, size: 18, color: colors.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    final colors = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: AppTokens.gap8),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.borderStrong,
                        borderRadius: BorderRadius.circular(
                          AppTokens.radiusFull,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: colors.border),
                      itemBuilder: (_, index) {
                        final item = items[index];
                        final isSelected = value == item;
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            onChanged?.call(item);
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            alignment: Alignment.centerLeft,
                            color: isSelected
                                ? colors.primarySoft
                                : Colors.transparent,
                            child: Text(
                              itemLabelBuilder(item),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? colors.primary
                                    : colors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
