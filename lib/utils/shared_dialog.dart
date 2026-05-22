import 'package:class_tool/ui/app_button.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:flutter/material.dart';

class SharedDialog {
  const SharedDialog._();

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String cancelText = '取消',
    String confirmText = '确定',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = context.colors;

        return Dialog(
          backgroundColor: colors.surface,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusXl),
            side: BorderSide(color: colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.gap20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.dangerSoft,
                        borderRadius: BorderRadius.circular(
                          AppTokens.radiusMd,
                        ),
                      ),
                      child: Icon(
                        AppIcons.logout,
                        size: AppTokens.iconMd,
                        color: colors.danger,
                      ),
                    ),
                    const SizedBox(width: AppTokens.gap12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.gap14),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppTokens.gap20),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: cancelText,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: AppTokens.gap10),
                    Expanded(
                      child: AppButton(
                        label: confirmText,
                        variant: AppButtonVariant.danger,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }
}
