import 'dart:async';
import 'dart:io';

import 'package:class_tool/data/services/github_update_service.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/shared_dialog.dart';
import 'package:dio/dio.dart';
import 'package:fin_ui/app_button.dart';
import 'package:fin_ui/app_context.dart';
import 'package:fin_ui/app_dialog.dart';
import 'package:fin_ui/app_icons.dart';
import 'package:fin_ui/app_toast.dart';
import 'package:fin_ui/app_tokens.dart';
import 'package:flutter/material.dart';

class GithubUpdatePrompt {
  const GithubUpdatePrompt._();

  static bool _autoCheckTriggered = false;
  static bool _dialogVisible = false;

  static Future<void> checkInBackgroundIfNeeded(BuildContext context) async {
    if (!Platform.isAndroid || _autoCheckTriggered) {
      return;
    }
    _autoCheckTriggered = true;

    final result = await GithubUpdateService.checkInBackground(
      respectCooldown: true,
    );
    if (result == null || !result.hasUpdate) {
      return;
    }
    if (GithubUpdateService.isVersionIgnored(result.release.version)) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    await _showUpdateDialog(context, result, allowIgnore: true);
  }

  static Future<void> checkNow(BuildContext context) async {
    FUIToast.info(context, message: '正在检查更新...');
    try {
      final result = await GithubUpdateService.checkLatestRelease().timeout(
        const Duration(seconds: 15),
      );
      if (!context.mounted) {
        return;
      }
      if (!result.hasUpdate) {
        FUIToast.success(
          context,
          message: '当前已是最新版本 v${result.currentVersion}',
        );
        return;
      }
      await _showUpdateDialog(context, result, allowIgnore: false);
    } catch (e, s) {
      LogUtil.warnE('[GithubUpdatePrompt] manual check failed', e, s);
      if (!context.mounted) {
        return;
      }
      FUIToast.error(context, message: '检查更新失败或超时，请稍后再试');
    }
  }

  static Future<void> _showUpdateDialog(
    BuildContext context,
    GithubUpdateCheckResult result, {
    required bool allowIgnore,
  }) async {
    if (_dialogVisible) {
      return;
    }
    final asset = result.release.apkAsset;
    if (asset == null) {
      return;
    }

    _dialogVisible = true;
    try {
      final action = await showDialog<_UpdateDialogAction>(
        context: context,
        useRootNavigator: true,
        builder: (ctx) {
          final changelog = result.release.changelog.isEmpty
              ? '包含常规问题修复与体验优化。'
              : result.release.changelog;
          return FUIDialog(
            title: '发现新版本 v${result.release.version}',
            icon: FUIIcons.update,
            scrollable: true,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '当前版本 v${result.currentVersion}',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: ctx.colors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: FUITokens.gap10),
                Text(
                  changelog,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: ctx.colors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
            actions: [
              if (allowIgnore)
                FUIButton(
                  label: '忽略此版本',
                  variant: FUIButtonVariant.secondary,
                  onPressed: () =>
                      Navigator.of(ctx).pop(_UpdateDialogAction.ignore),
                ),
              FUIButton(
                label: '暂不更新',
                variant: FUIButtonVariant.secondary,
                onPressed: () =>
                    Navigator.of(ctx).pop(_UpdateDialogAction.later),
              ),
              FUIButton(
                label: '立即更新',
                icon: FUIIcons.update,
                onPressed: () =>
                    Navigator.of(ctx).pop(_UpdateDialogAction.update),
              ),
            ],
          );
        },
      );

      if (!context.mounted) {
        return;
      }

      if (action == _UpdateDialogAction.ignore) {
        await GithubUpdateService.ignoreVersion(result.release.version);
        return;
      }

      if (action == _UpdateDialogAction.update) {
        await _downloadAndInstall(context, result.release, asset);
      }
    } finally {
      _dialogVisible = false;
    }
  }

  static Future<void> _downloadAndInstall(
    BuildContext context,
    GithubReleaseInfo release,
    GithubReleaseAsset asset,
  ) async {
    if (!Platform.isAndroid) {
      FUIToast.info(context, message: '请前往 GitHub Release 下载安装包');
      return;
    }

    final allowed = await GithubUpdateService.canRequestPackageInstalls();
    if (!context.mounted) {
      return;
    }
    if (!allowed) {
      final openSettings = await SharedDialog.showConfirmDialog(
        context,
        title: '需要安装权限',
        content: '请先在系统设置中允许本应用安装未知来源应用，授权后再点击立即更新。',
        confirmText: '前往设置',
        cancelText: '取消',
      );
      if (openSettings) {
        await GithubUpdateService.openInstallPermissionSettings();
      }
      return;
    }

    final cancelToken = CancelToken();
    String? downloadedPath;
    final confirmedInstall = await SharedDialog.showProgressDialog(
      context: context,
      title: '正在下载 v${release.version}',
      loadingMessage: '正在连接下载...',
      cancelText: '取消',
      completeMessage: '下载完成，点击安装',
      completeButtonText: '立即安装',
      onCancel: () {
        if (!cancelToken.isCancelled) {
          cancelToken.cancel('user cancelled');
        }
      },
      task: (controller) async {
        downloadedPath = await GithubUpdateService.downloadApk(
          asset,
          cancelToken: cancelToken,
          onProgress: (progress) {
            if (progress == null) {
              controller.updateProgress(0, message: '正在下载更新包...');
              return;
            }
            final percent = (progress * 100).toStringAsFixed(0);
            controller.updateProgress(progress, message: '已下载 $percent%');
          },
        );
        return true;
      },
    );

    if (!context.mounted) {
      return;
    }
    if (confirmedInstall && downloadedPath != null) {
      try {
        await GithubUpdateService.installApk(downloadedPath!);
      } catch (e, s) {
        LogUtil.warnE('[GithubUpdatePrompt] install failed', e, s);
        if (!context.mounted) return;
        FUIToast.error(context, message: '拉起安装程序失败，请稍后重试');
      }
    }
  }
}

enum _UpdateDialogAction { ignore, later, update }
