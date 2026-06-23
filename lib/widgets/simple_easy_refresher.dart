import 'dart:async';

import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

typedef SimpleRefreshChildBuilder =
    Widget Function(BuildContext context, ScrollPhysics physics);

class SimpleEasyRefresher extends StatelessWidget {
  const SimpleEasyRefresher({
    super.key,
    this.easyRefreshController,
    this.onLoad,
    this.onRefresh,
    required this.childBuilder,
    this.autoRefreshOnStart = true,
    this.refreshEnabled = true,
    this.loadEnabled = true,
  });

  final Object? easyRefreshController;
  final FutureOr<dynamic> Function()? onLoad;
  final FutureOr<dynamic> Function()? onRefresh;
  final SimpleRefreshChildBuilder childBuilder;
  final bool autoRefreshOnStart;
  final bool refreshEnabled;
  final bool loadEnabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w700,
    );

    return EasyRefresh.builder(
      controller: easyRefreshController is EasyRefreshController
          ? easyRefreshController as EasyRefreshController
          : null,
      header: null,
      onRefresh: null,
      refreshOnStart: false,
      footer: _buildFooter(context, textStyle),
      onLoad: loadEnabled ? onLoad : null,
      childBuilder: childBuilder,
    );
  }

  ClassicFooter _buildFooter(BuildContext context, TextStyle? textStyle) {
    final colors = context.colors;
    return ClassicFooter(
      triggerOffset: 70,
      mainAxisAlignment: MainAxisAlignment.center,
      dragText: '上拉加载',
      armedText: '松开加载',
      readyText: '正在加载',
      processingText: '正在加载',
      processedText: '加载完成',
      noMoreText: '没有更多了',
      failedText: '加载失败',
      messageText: ' ',
      showMessage: false,
      spacing: AppTokens.gap8,
      iconDimension: AppTokens.iconMd,
      textStyle: textStyle,
      iconTheme: IconThemeData(size: AppTokens.iconSm, color: colors.primary),
      pullIconBuilder: (context, state, animation) {
        return Transform.rotate(
          angle: animation * 3.1415926,
          child: Icon(AppIcons.chevronDown, color: colors.primary),
        );
      },
      succeededIcon: Icon(AppIcons.check, color: colors.primary),
      failedIcon: Icon(AppIcons.warning, color: colors.danger),
      noMoreIcon: Icon(AppIcons.checkmark, color: colors.textTertiary),
      progressIndicatorSize: AppTokens.iconSm,
      progressIndicatorStrokeWidth: 2,
    );
  }
}
