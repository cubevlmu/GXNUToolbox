import 'package:class_tool/widgets/sheet_util.dart';
import 'package:flutter/material.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = false,
  bool useSafeArea = true,
  bool showDragHandle = true,
  double? heightFactor,
}) {
  final mediaQuery = MediaQuery.of(context);

  Widget content = child;

  if (heightFactor != null) {
    content = SizedBox(
      height: mediaQuery.size.height * heightFactor,
      child: content,
    );
  }

  if (useSafeArea) {
    content = SafeArea(top: false, child: content);
  }

  return SheetUtil.newBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    showDragHandle: showDragHandle,
    widget: content,
  );
}
