import 'package:flutter/material.dart';
import 'package:class_tool/widgets/sheet_util.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = false,
  bool useSafeArea = true,
  bool showDragHandle = true,
  double? heightFactor,
}) {
  final mediaQuery = MediaQuery.of(context);
  final theme = Theme.of(context);
  final content = Material(
    color: Colors.transparent,
    child: Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: heightFactor == null
          ? child
          : SizedBox(
              height: mediaQuery.size.height * heightFactor,
              child: child,
            ),
    ),
  );

  return SheetUtil.newBottomSheet<T>(context: context, widget: content);
}
