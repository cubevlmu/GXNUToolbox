import 'dart:async';

import 'package:class_tool/ui/app_button.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:flutter/material.dart';

// ignore_for_file: use_build_context_synchronously

class SharedDialog {
  const SharedDialog._();

  static BuildContext? _activeContext;
  static SharedProgressController? _activeProgressController;

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String cancelText = '取消',
    String confirmText = '确定',
    Function()? cancelAction,
    Function()? confirmAction,
  }) async {
    _dismissPrevious();
    _activeContext = context;

    final isSingleAction = cancelText.isEmpty;

    final result = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (ctx) {
        final colors = ctx.colors;

        return PopScope(
          canPop: false,
          child: Dialog(
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
                            style: Theme.of(ctx).textTheme.titleMedium
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
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppTokens.gap20),
                  Row(
                    children: [
                      if (!isSingleAction) ...[
                        Expanded(
                          child: AppButton(
                            label: cancelText,
                            variant: AppButtonVariant.secondary,
                            onPressed: () {
                              if (cancelAction != null) cancelAction();
                              Navigator.of(ctx).pop(false);
                            },
                          ),
                        ),
                        const SizedBox(width: AppTokens.gap10),
                      ],
                      Expanded(
                        child: AppButton(
                          label: confirmText,
                          variant: AppButtonVariant.danger,
                          onPressed: () {
                            if (confirmAction != null) confirmAction();
                            Navigator.of(ctx).pop(true);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (identical(_activeContext, context)) {
      _activeContext = null;
    }

    return result ?? false;
  }

  static Future<bool> showProgressDialog({
    required BuildContext context,
    required String title,
    required String loadingMessage,
    String cancelText = '取消',
    String completeMessage = '',
    String completeButtonText = '打开',
    bool barrierDismissible = false,
    required Future<bool> Function(SharedProgressController controller) task,
  }) async {
    _dismissPrevious();
    _activeContext = context;

    final controller = SharedProgressController();
    _activeProgressController = controller;

    unawaited(() async {
      try {
        final done = await task(controller);
        if (controller._cancelled || controller._disposed) return;
        controller._complete = true;
        controller._success = done;
        controller._notify();
      } catch (e) {
        if (controller._cancelled || controller._disposed) return;
        controller._complete = true;
        controller._success = false;
        controller._message ??= e.toString().split('\n').first;
        controller._notify();
      }
    }());

    final result = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: barrierDismissible,
      builder: (ctx) {
        final colors = ctx.colors;

        return PopScope(
          canPop: false,
          child: Dialog(
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
              child: ValueListenableBuilder<int>(
                valueListenable: controller._notifier,
                builder: (ctx, _, _) {
                  final colors = ctx.colors;
                  final isDone = controller._complete;
                  final success = controller._success;
                  final failed = isDone && !success;
                  final cancelled = controller._cancelled;
                  final progress = controller._progress.clamp(0.0, 1.0);
                  final message = controller._message ?? loadingMessage;
                  final iconColor = cancelled || failed
                      ? colors.danger
                      : isDone
                      ? colors.success
                      : colors.primary;
                  final iconBackground = cancelled || failed
                      ? colors.dangerSoft
                      : isDone
                      ? colors.successSoft
                      : colors.primarySoft;
                  final icon = cancelled || failed
                      ? AppIcons.close
                      : isDone
                      ? AppIcons.check
                      : AppIcons.update;

                  return Column(
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
                              color: iconBackground,
                              borderRadius: BorderRadius.circular(
                                AppTokens.radiusMd,
                              ),
                            ),
                            child: Icon(
                              icon,
                              size: AppTokens.iconMd,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(width: AppTokens.gap12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                title,
                                style: Theme.of(ctx).textTheme.titleMedium
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
                      if (isDone || cancelled)
                        Text(
                          cancelled
                              ? '已取消'
                              : success && completeMessage.isNotEmpty
                              ? completeMessage
                              : success
                              ? '操作已完成'
                              : message,
                          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                            height: 1.45,
                          ),
                        )
                      else ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppTokens.radiusXs,
                          ),
                          child: LinearProgressIndicator(
                            value: progress > 0 ? progress : null,
                            minHeight: 6,
                            color: colors.primary,
                            backgroundColor: colors.surfacePressed,
                          ),
                        ),
                        const SizedBox(height: AppTokens.gap12),
                        Text(
                          message,
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppTokens.gap20),
                      if (isDone)
                        AppButton(
                          label: success ? completeButtonText : '关闭',
                          variant: success
                              ? AppButtonVariant.primary
                              : AppButtonVariant.secondary,
                          fullWidth: true,
                          onPressed: () => Navigator.of(ctx).pop(success),
                        )
                      else if (cancelled)
                        AppButton(
                          label: '关闭',
                          variant: AppButtonVariant.secondary,
                          fullWidth: true,
                          onPressed: () => Navigator.of(ctx).pop(false),
                        )
                      else
                        AppButton(
                          label: cancelText,
                          variant: AppButtonVariant.secondary,
                          fullWidth: true,
                          onPressed: () {
                            controller.cancel();
                            Navigator.of(ctx).pop(false);
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (result == null && !controller._complete && !controller._cancelled) {
      controller.cancel();
    }
    if (identical(_activeContext, context)) {
      _activeContext = null;
    }
    if (identical(_activeProgressController, controller)) {
      _activeProgressController = null;
    }
    controller.dispose();

    return result ?? false;
  }

  static void _dismissPrevious() {
    _activeProgressController?.cancel();
    _activeProgressController = null;
    final prev = _activeContext;
    if (prev != null) {
      try {
        Navigator.of(prev, rootNavigator: true).pop();
      } catch (_) {}
    }
  }
}

class SharedProgressController {
  final ValueNotifier<int> _notifier = ValueNotifier<int>(0);
  double _progress = 0;
  String? _message;
  bool _complete = false;
  bool _success = false;
  bool _cancelled = false;
  bool _disposed = false;

  bool get isCancelled => _cancelled;

  void updateProgress(double progress, {String? message}) {
    if (_cancelled || _complete || _disposed) return;
    _progress = progress;
    if (message != null) _message = message;
    _notify();
  }

  void cancel({String message = '已取消'}) {
    if (_complete || _disposed) return;
    _cancelled = true;
    _message = message;
    _notify();
  }

  void dispose() {
    _disposed = true;
    _notifier.dispose();
  }

  void _notify() {
    if (_disposed) return;
    _notifier.value++;
  }
}
