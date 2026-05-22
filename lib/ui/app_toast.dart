import 'dart:async';

import 'package:class_tool/ui/app_colors.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppToastType { info, success, warning, error }

class AppToast {
  const AppToast._();

  static OverlayEntry? _entry;
  static VoidCallback? _dismissCurrent;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    _removeCurrent(immediate: true);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _AppToastOverlay(
        duration: duration,
        message: message,
        title: title,
        type: type,
        onDismissReady: (dismiss) {
          if (_entry == entry) {
            _dismissCurrent = dismiss;
          }
        },
        onDismissed: () {
          if (_entry == entry) {
            _entry = null;
            _dismissCurrent = null;
          }
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );

    _entry = entry;
    overlay.insert(entry);
  }

  static void showGlobal({
    required String message,
    String? title,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final context = Get.overlayContext ?? Get.context;
    if (context == null) {
      return;
    }
    show(
      context,
      message: message,
      title: title,
      type: type,
      duration: duration,
    );
  }

  static void success(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    show(context, message: message, title: title, type: AppToastType.success);
  }

  static void error(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    show(context, message: message, title: title, type: AppToastType.error);
  }

  static void warning(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    show(context, message: message, title: title, type: AppToastType.warning);
  }

  static void info(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    show(context, message: message, title: title, type: AppToastType.info);
  }

  static void successGlobal({required String message, String? title}) {
    showGlobal(message: message, title: title, type: AppToastType.success);
  }

  static void errorGlobal({required String message, String? title}) {
    showGlobal(message: message, title: title, type: AppToastType.error);
  }

  static void warningGlobal({required String message, String? title}) {
    showGlobal(message: message, title: title, type: AppToastType.warning);
  }

  static void infoGlobal({required String message, String? title}) {
    showGlobal(message: message, title: title, type: AppToastType.info);
  }

  static void _removeCurrent({bool immediate = false}) {
    if (!immediate) {
      final dismiss = _dismissCurrent;
      if (dismiss != null) {
        dismiss();
        return;
      }
    }

    final current = _entry;
    if (current != null && current.mounted) {
      current.remove();
    }
    _entry = null;
    _dismissCurrent = null;
  }
}

class _AppToastOverlay extends StatefulWidget {
  const _AppToastOverlay({
    required this.duration,
    required this.message,
    required this.type,
    required this.onDismissReady,
    required this.onDismissed,
    this.title,
  });

  final Duration duration;
  final String message;
  final String? title;
  final AppToastType type;
  final ValueChanged<VoidCallback> onDismissReady;
  final VoidCallback onDismissed;

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTokens.durationNormal,
      reverseDuration: AppTokens.durationFast,
    );
    widget.onDismissReady(_dismiss);
    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_closing) {
      return;
    }
    _closing = true;
    _timer?.cancel();
    _timer = null;
    _controller.reverse().whenComplete(widget.onDismissed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolved = _resolveStyle(colors);
    final bottom = MediaQuery.paddingOf(context).bottom + 76;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = widget.title == null || widget.title!.trim().isEmpty
        ? widget.message
        : '${widget.title!.trim()}  ${widget.message}';

    return Positioned(
      bottom: bottom,
      left: AppTokens.pagePadding,
      right: AppTokens.pagePadding,
      child: SafeArea(
        top: false,
        bottom: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value = Curves.easeOutCubic.transform(_controller.value);
            return Transform.translate(
              offset: Offset(0, 26 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Material(
                color: Colors.transparent,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(
                      AppTokens.radiusFull,
                    ),
                    border: Border.all(color: colors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.30 : 0.10,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: resolved.background,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            resolved.icon,
                            color: resolved.foreground,
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: AppTokens.gap8),
                        Flexible(
                          child: Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ),
                        const SizedBox(width: AppTokens.gap8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _dismiss,
                          child: Padding(
                            padding: const EdgeInsets.all(AppTokens.gap4),
                            child: Icon(
                              AppIcons.close,
                              size: 16,
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ToastStyle _resolveStyle(AppPalette colors) {
    return switch (widget.type) {
      AppToastType.success => _ToastStyle(
          icon: AppIcons.check,
          foreground: colors.success,
          background: colors.successSoft,
        ),
      AppToastType.warning => _ToastStyle(
          icon: AppIcons.warning,
          foreground: colors.warning,
          background: colors.warningSoft,
        ),
      AppToastType.error => _ToastStyle(
          icon: AppIcons.error,
          foreground: colors.danger,
          background: colors.dangerSoft,
        ),
      AppToastType.info => _ToastStyle(
          icon: AppIcons.info,
          foreground: colors.primary,
          background: colors.primarySoft,
        ),
    };
  }
}

class _ToastStyle {
  const _ToastStyle({
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
}
