import 'dart:io';

import 'package:class_tool/data/services/app_update_service.dart';
import 'package:fui/app_button.dart';
import 'package:fui/app_toast.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/shared_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gx_update_client/gx_update_client.dart';

// ignore_for_file: use_build_context_synchronously

class AppUpdatePrompt {
  const AppUpdatePrompt._();

  static Future<void> checkNow(
    BuildContext context, {
    bool showLatestToast = true,
    String logTag = 'AppUpdatePrompt',
  }) async {
    try {
      final response = await AppUpdateService.check();
      if (!context.mounted) return;
      await showResponse(
        context,
        response,
        showLatestToast: showLatestToast,
        allowOptionalPrompt: true,
      );
    } on AppUpdateCheckUnavailableException {
      if (context.mounted) {
        FUIToast.error(context, message: '更新服务未配置，无法检查更新');
      }
    } catch (e, s) {
      LogUtil.errorE('[$logTag] check update failed', e, s);
      if (context.mounted) {
        FUIToast.error(
          context,
          message: '检查更新失败: ${e.toString().split('\n').first}',
        );
      }
    }
  }

  static Future<void> showResponse(
    BuildContext context,
    CheckUpdateResponse response, {
    bool showLatestToast = false,
    bool allowOptionalPrompt = true,
  }) async {
    if (!response.legal.allowed) {
      await _showBlockedDialog(context, response);
      return;
    }

    if (response.update.available) {
      if (response.update.isForce) {
        await _showForceUpdateDialog(context, response.update);
        return;
      }

      if (allowOptionalPrompt) {
        await _showOptionalUpdateDialog(context, response.update);
      }
      return;
    }

    if (showLatestToast) {
      FUIToast.info(context, message: '已是最新版本');
    }
  }

  static Future<void> downloadAndInstall(
    BuildContext context,
    UpdateInfo update, {
    bool closeOnCancel = false,
  }) async {
    await SharedDialog.showProgressDialog(
      context: context,
      title: '正在下载更新包',
      loadingMessage: '正在准备下载...',
      cancelText: '取消',
      onCancel: closeOnCancel ? closeApp : null,
      completeMessage: Platform.isWindows
          ? '更新包已下载，请按提示完成安装'
          : '安装界面已打开，请按系统提示完成安装',
      completeButtonText: '完成',
      task: (controller) async {
        try {
          await AppUpdateService.downloadAndInstall(
            update,
            shouldCancel: () => controller.isCancelled,
            onProgress: (progress) {
              if (controller.isCancelled) return;
              final fraction = progress.fraction;
              if (fraction == null) return;
              final percent = (fraction.clamp(0.0, 1.0) * 100).toStringAsFixed(
                0,
              );
              controller.updateProgress(fraction, message: '正在下载更新包 $percent%');
            },
          );
          if (controller.isCancelled) return false;
          return true;
        } on GxUpdateCancelledException {
          return false;
        } on AppUpdateInstallPermissionRequiredException {
          controller.updateProgress(1, message: '请先允许安装未知来源应用，然后重新点击立即更新');
          return false;
        } catch (e, s) {
          LogUtil.errorE(
            '[AppUpdatePrompt] update download/install failed',
            e,
            s,
          );
          controller.updateProgress(
            1,
            message: '下载或安装更新失败: ${e.toString().split('\n').first}',
          );
          return false;
        }
      },
    );
  }

  static Future<void> closeApp() async {
    if (Platform.isAndroid) {
      await SystemNavigator.pop(animated: true);
      return;
    }

    exit(0);
  }

  static Future<void> _showBlockedDialog(
    BuildContext context,
    CheckUpdateResponse response,
  ) async {
    final message = response.legal.message.trim().isEmpty
        ? '当前版本已停止支持，请更新后继续使用。'
        : response.legal.message.trim();

    if (!response.update.available) {
      await SharedDialog.showConfirmDialog(
        context,
        title: '版本已停止支持',
        content: '$message\n\n服务端暂未配置可下载的新版安装包，请稍后重试。',
        confirmText: '退出应用',
        cancelText: '',
        variant: SharedDialogVariant.danger,
      );
      await closeApp();
      return;
    }

    final confirmed = await SharedDialog.showConfirmDialog(
      context,
      title: '版本已停止支持',
      content: _buildUpdateContent(
        response.update,
        prefix: message,
        versionPrefix: '可更新到',
      ),
      confirmText: '立即更新',
      cancelText: '退出应用',
      variant: SharedDialogVariant.warning,
      cancelButtonVariant: FUIButtonVariant.danger,
    );

    if (!context.mounted) return;

    if (confirmed) {
      await downloadAndInstall(context, response.update, closeOnCancel: true);
    } else {
      await closeApp();
    }
  }

  static Future<void> _showForceUpdateDialog(
    BuildContext context,
    UpdateInfo update,
  ) async {
    final confirmed = await SharedDialog.showConfirmDialog(
      context,
      title: '需要更新后继续使用',
      content: _buildUpdateContent(update, prefix: '当前版本需要更新后才能继续使用。'),
      confirmText: '立即更新',
      cancelText: '退出应用',
      variant: SharedDialogVariant.warning,
      cancelButtonVariant: FUIButtonVariant.danger,
    );

    if (!context.mounted) return;

    if (confirmed) {
      await downloadAndInstall(context, update, closeOnCancel: true);
    } else {
      await closeApp();
    }
  }

  static Future<void> _showOptionalUpdateDialog(
    BuildContext context,
    UpdateInfo update,
  ) async {
    final download = await SharedDialog.showConfirmDialog(
      context,
      title: '发现新版本',
      content: _buildUpdateContent(
        update,
        prefix: '版本 ${update.version} 已发布，是否下载更新？',
      ),
      confirmText: '下载',
      cancelText: '稍后',
      variant: SharedDialogVariant.info,
    );

    if (!context.mounted) return;

    if (download) {
      await downloadAndInstall(context, update);
    }
  }

  static String _buildUpdateContent(
    UpdateInfo update, {
    required String prefix,
    String versionPrefix = '版本',
  }) {
    final changelog = update.changelog.trim();
    final content = StringBuffer()
      ..writeln(prefix)
      ..writeln()
      ..writeln(
        '$versionPrefix: v${update.version} (build ${update.versionCode})',
      );

    if (changelog.isNotEmpty) {
      content
        ..writeln()
        ..writeln('更新内容：')
        ..write(changelog);
    }

    return content.toString();
  }
}
