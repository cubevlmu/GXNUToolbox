/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

class SimpleEasyRefresher extends StatefulWidget {
  const SimpleEasyRefresher({
    super.key,
    required this.easyRefreshController,
    this.onLoad,
    this.onRefresh,
    required this.childBuilder,
    this.indicatorPosition = IndicatorPosition.above,
    this.autoRefreshOnStart = true,
    this.refreshEnabled = true,
    this.loadEnabled = true,
  });
  final EasyRefreshController? easyRefreshController;
  final FutureOr<dynamic> Function()? onLoad;
  final FutureOr<dynamic> Function()? onRefresh;
  final Widget Function(BuildContext context, ScrollPhysics physics)?
  childBuilder;
  final bool autoRefreshOnStart;
  final IndicatorPosition indicatorPosition;
  final bool refreshEnabled;
  final bool loadEnabled;

  @override
  State<SimpleEasyRefresher> createState() => _SimpleEasyRefresherState();
}

class _SimpleEasyRefresherState extends State<SimpleEasyRefresher> {
  static const _pullToRefreshText = '下拉刷新';
  static const _releaseToRefreshText = '松开刷新';
  static const _refreshingText = '正在刷新...';
  static const _refreshSuccessText = '刷新成功';
  static const _refreshFailedText = '刷新失败';
  static const _pullToLoadText = '上拉加载更多';
  static const _releaseToLoadText = '松开加载更多';
  static const _loadingText = '正在加载...';
  static const _loadSuccessText = '加载成功';
  static const _loadFailedText = '加载失败';
  static const _noMoreText = '没有更多了';

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
      refreshOnStart: widget.autoRefreshOnStart,
      resetAfterRefresh: true,
      onLoad: widget.loadEnabled
          ? () async {
              await widget.onLoad?.call();
            }
          : null,
      onRefresh: widget.refreshEnabled
          ? () async {
              await widget.onRefresh?.call();
            }
          : null,
      header: ClassicHeader(
        hitOver: true,
        safeArea: true,
        processedDuration: Duration.zero,
        showMessage: false,
        showText: true,
        position: widget.indicatorPosition,
        processingText: _refreshingText,
        readyText: _refreshingText,
        armedText: _releaseToRefreshText,
        dragText: _pullToRefreshText,
        processedText: _refreshSuccessText,
        failedText: _refreshFailedText,
      ),
      footer: ClassicFooter(
        processedDuration: Duration.zero,
        safeArea: true,
        showMessage: false,
        showText: true,
        position: widget.indicatorPosition,
        processingText: _loadingText,
        processedText: _loadSuccessText,
        readyText: _loadingText,
        armedText: _releaseToLoadText,
        dragText: _pullToLoadText,
        failedText: _loadFailedText,
        noMoreText: _noMoreText,
      ),
      controller: widget.easyRefreshController,
      childBuilder: widget.childBuilder,
    );
  }
}
