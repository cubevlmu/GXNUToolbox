import 'dart:async';

import 'package:fin_ui/app_button.dart';
import 'package:fin_ui/app_context.dart';
import 'package:fin_ui/app_dialog.dart';
import 'package:fin_ui/app_icons.dart';
import 'package:fin_ui/app_progress_bar.dart';
import 'package:fin_ui/app_tokens.dart';
import 'package:flutter/material.dart';

// ignore_for_file: use_build_context_synchronously

enum SharedDialogVariant { info, success, warning, danger }

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
    SharedDialogVariant variant = SharedDialogVariant.info,
    IconData? icon,
    FUIButtonVariant? cancelButtonVariant,
    FUIButtonVariant? confirmButtonVariant,
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
        return PopScope(
          canPop: false,
          child: FUIDialog(
            title: title,
            icon: icon ?? _variantIcon(variant),
            scrollable: true,
            content: Text(
              content,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                color: ctx.colors.textSecondary,
                height: 1.45,
              ),
            ),
            actions: [
              if (!isSingleAction)
                FUIButton(
                  label: cancelText,
                  variant: cancelButtonVariant ?? FUIButtonVariant.secondary,
                  onPressed: () {
                    cancelAction?.call();
                    Navigator.of(ctx).pop(false);
                  },
                ),
              FUIButton(
                label: confirmText,
                variant:
                    confirmButtonVariant ??
                    _defaultConfirmButtonVariant(variant),
                onPressed: () {
                  confirmAction?.call();
                  Navigator.of(ctx).pop(true);
                },
              ),
            ],
          ),
        );
      },
    );

    if (identical(_activeContext, context)) {
      _activeContext = null;
    }

    return result ?? false;
  }

  static FUIButtonVariant _defaultConfirmButtonVariant(
    SharedDialogVariant variant,
  ) {
    return switch (variant) {
      SharedDialogVariant.danger => FUIButtonVariant.danger,
      SharedDialogVariant.info ||
      SharedDialogVariant.success ||
      SharedDialogVariant.warning => FUIButtonVariant.primary,
    };
  }

  static IconData _variantIcon(SharedDialogVariant variant) {
    return switch (variant) {
      SharedDialogVariant.info => FUIIcons.info,
      SharedDialogVariant.success => FUIIcons.check,
      SharedDialogVariant.warning => FUIIcons.warning,
      SharedDialogVariant.danger => FUIIcons.error,
    };
  }

  static Future<bool> showProgressDialog({
    required BuildContext context,
    required String title,
    required String loadingMessage,
    String cancelText = '取消',
    String completeMessage = '',
    String completeButtonText = '打开',
    bool barrierDismissible = false,
    FutureOr<void> Function()? onCancel,
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
              borderRadius: BorderRadius.circular(FUITokens.radiusXl),
              side: BorderSide(color: colors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(FUITokens.gap20),
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
                      ? FUIIcons.close
                      : isDone
                      ? FUIIcons.check
                      : FUIIcons.update;

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
                                FUITokens.radiusMd,
                              ),
                            ),
                            child: Icon(
                              icon,
                              size: FUITokens.iconMd,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(width: FUITokens.gap12),
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
                      const SizedBox(height: FUITokens.gap14),
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
                        FUIProgressBar(value: progress > 0 ? progress : null),
                        const SizedBox(height: FUITokens.gap12),
                        Text(
                          message,
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                      const SizedBox(height: FUITokens.gap20),
                      if (isDone)
                        FUIButton(
                          label: success ? completeButtonText : '关闭',
                          variant: success
                              ? FUIButtonVariant.primary
                              : FUIButtonVariant.secondary,
                          fullWidth: true,
                          onPressed: () => Navigator.of(ctx).pop(success),
                        )
                      else if (cancelled)
                        FUIButton(
                          label: '关闭',
                          variant: FUIButtonVariant.secondary,
                          fullWidth: true,
                          onPressed: () => Navigator.of(ctx).pop(false),
                        )
                      else
                        FUIButton(
                          label: cancelText,
                          variant: FUIButtonVariant.secondary,
                          fullWidth: true,
                          onPressed: () {
                            controller.cancel();
                            Navigator.of(ctx).pop(false);
                            if (onCancel != null) {
                              unawaited(Future<void>.sync(onCancel));
                            }
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
