import 'package:flutter/material.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = false,
}) {
  final colors = Theme.of(context).colorScheme;
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: isScrollControlled,
    isDismissible: true,
    enableDrag: true,
    showDragHandle: true,
    backgroundColor: colors.surface,
    elevation: 8,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    clipBehavior: Clip.antiAlias,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 180),
      reverseDuration: Duration(milliseconds: 130),
    ),
    builder: (sheetContext) {
      final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
      final availableHeight = MediaQuery.sizeOf(sheetContext).height;
      return RepaintBoundary(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: availableHeight * 0.88),
            child: SafeArea(top: false, child: child),
          ),
        ),
      );
    },
  );
}
