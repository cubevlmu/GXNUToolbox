import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_tokens.dart';
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

  Widget content = Builder(
    builder: (context) {
      final colors = context.colors;

      return Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(18),
            ),
            border: Border(top: BorderSide(color: colors.border)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDragHandle)
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
              Flexible(fit: FlexFit.loose, child: child),
            ],
          ),
        ),
      );
    },
  );

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
    widget: content,
  );
}
