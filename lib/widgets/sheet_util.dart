/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SheetUtil {
  static Future<T?> newBottomSheet<T>({
    required Widget widget,
    BuildContext? context,
  }) {
    final currentContext = context ?? Get.context;
    if (currentContext == null) {
      return Future<T?>.value();
    }
    final theme = Theme.of(currentContext);

    return showModalBottomSheet<T>(
      context: currentContext,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 180),
        reverseDuration: Duration(milliseconds: 130),
      ),
      builder: (context) {
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
        final maxHeight = MediaQuery.sizeOf(context).height * 0.88;
        return RepaintBoundary(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: bottomInset),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Flexible(fit: FlexFit.loose, child: widget)],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
