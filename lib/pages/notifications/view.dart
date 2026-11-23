import 'dart:async';

import 'package:class_tool/data/model/school_notification.dart';
import 'package:class_tool/pages/notifications/controller.dart';
import 'package:fin_ui/app_button.dart';
import 'package:fin_ui/app_context.dart';
import 'package:fin_ui/app_dialog.dart';
import 'package:fin_ui/app_empty_state.dart';
import 'package:fin_ui/app_icon_button.dart';
import 'package:fin_ui/app_icons.dart';
import 'package:fin_ui/app_page.dart';
import 'package:fin_ui/app_refresh.dart';
import 'package:fin_ui/app_surface.dart';
import 'package:fin_ui/app_tag.dart';
import 'package:fin_ui/app_toast.dart';
import 'package:fin_ui/app_tokens.dart';
import 'package:fin_ui/fui_page_head.dart';
import 'package:class_tool/widgets/app_bottom_sheet.dart';
import 'package:class_tool/widgets/skeleton_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' as html_parser;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsController controller;
  final String _controllerTag = UniqueKey().toString();

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      NotificationsController(),
      tag: _controllerTag,
      permanent: false,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<NotificationsController>(tag: _controllerTag)) {
      Get.delete<NotificationsController>(tag: _controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: GetBuilder<NotificationsController>(
        tag: _controllerTag,
        id: 'notification-content',
        builder: (controller) {
          final canInteract =
              !controller.isLoading && !controller.isLoadingMore;

          if (controller.isLoading && !controller.hasData) {
            return const _NotificationSkeletonView();
          }

          if (controller.error.isNotEmpty && !controller.hasData) {
            return _FeedbackState(
              title: '通知加载失败',
              message: controller.error,
              onRefresh: canInteract ? controller.refreshNotifications : null,
            );
          }

          if (!controller.hasData) {
            return _FeedbackState(
              title: '暂无通知',
              message: '点击刷新后重试',
              onRefresh: canInteract ? controller.refreshNotifications : null,
            );
          }

          return FUIRefresh(
            onRefresh: controller.refreshNotifications,
            onLoad: controller.loadMoreNotifications,
            refreshOnStart: false,
            refreshEnabled: canInteract,
            loadEnabled: controller.hasMore && canInteract,
            childBuilder: (context, physics) => FUIPage(
              physics: canInteract
                  ? physics
                  : const NeverScrollableScrollPhysics(),
              children: [
                _NotificationHeader(
                  onRefresh: canInteract
                      ? controller.refreshNotifications
                      : null,
                ),
                const SizedBox(height: FUITokens.gap16),
                _ListHeader(
                  total: controller.total,
                  canMarkAllRead: canInteract && controller.hasUnread,
                  canClearAll: canInteract && controller.hasData,
                  onMarkAllRead: () => _markAllAsRead(context, controller),
                  onClearAll: () => _confirmClearAll(context, controller),
                ),
                const SizedBox(height: FUITokens.gap8),
                for (final item in controller.items) ...[
                  _NotificationCard(
                    item: item,
                    onTap: () => _openDetailSheet(context, controller, item),
                    onDelete: () => controller.deleteNotification(item),
                  ),
                  const SizedBox(height: FUITokens.gap12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openDetailSheet(
    BuildContext context,
    NotificationsController controller,
    SchoolNotificationItem item,
  ) async {
    final displayItem = item.isRead ? item : item.markRead();
    unawaited(controller.markAsRead(item));
    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      child: _NotificationDetailSheet(item: displayItem),
    );
  }

  Future<void> _markAllAsRead(
    BuildContext context,
    NotificationsController controller,
  ) async {
    final ok = await controller.markAllAsRead();
    if (!context.mounted) return;
    if (ok) {
      FUIToast.success(context, message: '已全部标为已读');
    } else {
      FUIToast.error(context, message: '一键已读失败，请稍后重试');
    }
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    NotificationsController controller,
  ) async {
    final count = controller.items.length;
    if (count == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return FUIDialog(
          title: '一键清理通知',
          icon: FUIIcons.delete,
          content: Text('确定删除当前列表中的 $count 条通知吗？删除后无法恢复。'),
          actions: [
            FUIButton(
              label: '取消',
              variant: FUIButtonVariant.secondary,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            FUIButton(
              label: '清理',
              variant: FUIButtonVariant.danger,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final ok = await controller.clearAllNotifications();
    if (!context.mounted) return;
    if (ok) {
      FUIToast.success(context, message: '已清理通知');
    } else {
      FUIToast.error(context, message: '清理失败，请稍后重试');
    }
  }
}

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader({required this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return FuiPageHead(
      title: '通知公告',
      subtitle: '查看教务工作台消息',
      actions: [
        FUIIconButton(
          icon: FUIIcons.refresh,
          tooltip: '刷新',
          variant: FUIIconButtonVariant.ghost,
          onPressed: onRefresh,
        ),
      ],
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({
    required this.total,
    required this.canMarkAllRead,
    required this.canClearAll,
    required this.onMarkAllRead,
    required this.onClearAll,
  });

  final int total;
  final bool canMarkAllRead;
  final bool canClearAll;
  final VoidCallback onMarkAllRead;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                '通知列表',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: FUITokens.gap8),
              Text(
                '共 $total 条',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        FUIButton(
          label: '一键已读',
          small: true,
          variant: FUIButtonVariant.secondary,
          onPressed: canMarkAllRead ? onMarkAllRead : null,
        ),
        const SizedBox(width: FUITokens.gap8),
        FUIButton(
          label: '一键清理',
          small: true,
          variant: FUIButtonVariant.danger,
          onPressed: canClearAll ? onClearAll : null,
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final SchoolNotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final contentText = _plainText(item.content);

    return FUISurface(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBox(
                icon: item.isRead
                    ? FUIIcons.notification
                    : FUIIcons.notificationActive,
              ),
              const SizedBox(width: FUITokens.gap12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isEmpty ? '未命名通知' : item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: FUITokens.gap8),
                    Wrap(
                      spacing: FUITokens.gap8,
                      runSpacing: FUITokens.gap8,
                      children: [
                        FUITag(
                          label: item.readStatusLabel,
                          variant: item.isRead
                              ? FUITagVariant.neutral
                              : FUITagVariant.primary,
                        ),
                        if (item.noticeType.isNotEmpty)
                          FUITag(label: item.noticeType),
                        if (item.isPinned)
                          const FUITag(
                            label: '置顶',
                            variant: FUITagVariant.warning,
                          ),
                        if (item.isNew)
                          const FUITag(
                            label: '新',
                            variant: FUITagVariant.success,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: FUITokens.gap6),
              FUIIconButton(
                icon: FUIIcons.delete,
                tooltip: '删除',
                variant: FUIIconButtonVariant.ghost,
                onPressed: onDelete,
              ),
            ],
          ),
          if (contentText.isNotEmpty) ...[
            const SizedBox(height: FUITokens.gap12),
            Text(
              contentText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
          if (item.releaseDate.isNotEmpty) ...[
            const SizedBox(height: FUITokens.gap12),
            Row(
              children: [
                Icon(
                  FUIIcons.calendar,
                  size: FUITokens.iconSm,
                  color: colors.textTertiary,
                ),
                const SizedBox(width: FUITokens.gap6),
                Expanded(
                  child: Text(
                    item.releaseDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationDetailSheet extends StatelessWidget {
  const _NotificationDetailSheet({required this.item});

  final SchoolNotificationItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final contentText = _plainText(item.content);

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        Row(
          children: [
            _IconBox(icon: FUIIcons.notification),
            const SizedBox(width: FUITokens.gap10),
            Expanded(
              child: Text(
                '通知详情',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: FUITokens.gap16),
        Text(
          item.title.isEmpty ? '未命名通知' : item.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: FUITokens.gap10),
        Wrap(
          spacing: FUITokens.gap8,
          runSpacing: FUITokens.gap8,
          children: [
            FUITag(
              label: item.readStatusLabel,
              variant: item.isRead
                  ? FUITagVariant.neutral
                  : FUITagVariant.primary,
            ),
            if (item.noticeType.isNotEmpty) FUITag(label: item.noticeType),
            if (item.releaseDate.isNotEmpty) FUITag(label: item.releaseDate),
            if (item.isPinned)
              const FUITag(label: '置顶', variant: FUITagVariant.warning),
          ],
        ),
        const SizedBox(height: FUITokens.gap16),
        FUISurface(
          padding: const EdgeInsets.all(14),
          child: Text(
            contentText.isEmpty ? '暂无正文内容' : contentText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: contentText.isEmpty
                  ? colors.textTertiary
                  : colors.textPrimary,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(FUITokens.radiusSm),
      ),
      child: Icon(icon, size: FUITokens.iconMd, color: colors.primary),
    );
  }
}

class _NotificationSkeletonView extends StatelessWidget {
  const _NotificationSkeletonView();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => FUIPage(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _NotificationHeader(onRefresh: null),
          const SizedBox(height: FUITokens.gap16),
          SkeletonBar(
            decoration: palette.line(radius: FUITokens.radiusMd),
            widthFactor: 1,
            height: 52,
          ),
          const SizedBox(height: FUITokens.gap16),
          SkeletonBar(
            decoration: palette.line(radius: FUITokens.radiusMd),
            widthFactor: 1,
            height: 70,
          ),
          const SizedBox(height: FUITokens.gap16),
          for (int i = 0; i < 6; i++) ...[
            SkeletonBar(
              decoration: palette.line(radius: FUITokens.radiusLg),
              widthFactor: 1,
              height: 112,
            ),
            const SizedBox(height: FUITokens.gap12),
          ],
        ],
      ),
    );
  }
}

class _FeedbackState extends StatelessWidget {
  const _FeedbackState({
    required this.title,
    required this.message,
    required this.onRefresh,
  });

  final String title;
  final String message;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return FUIPage(
      children: [
        _NotificationHeader(onRefresh: onRefresh),
        const SizedBox(height: FUITokens.gap16),
        FUISurface(
          child: SizedBox(
            height: 320,
            child: FUIEmptyState(
              title: title,
              message: message,
              icon: FUIIcons.notification,
              actionLabel: '重试',
              onAction: onRefresh,
            ),
          ),
        ),
      ],
    );
  }
}

String _plainText(String raw) {
  if (raw.isEmpty) {
    return '';
  }
  final document = html_parser.parse(raw);
  final text = document.body?.text ?? raw;
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}
