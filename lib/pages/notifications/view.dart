import 'package:class_tool/data/model/school_notification.dart';
import 'package:class_tool/pages/notifications/controller.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_empty_state.dart';
import 'package:class_tool/ui/app_icon_button.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_page.dart';
import 'package:class_tool/ui/app_surface.dart';
import 'package:class_tool/ui/app_tag.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:class_tool/widgets/app_bottom_sheet.dart';
import 'package:class_tool/widgets/simple_easy_refresher.dart';
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

  @override
  void initState() {
    super.initState();
    controller = Get.put(NotificationsController(), permanent: false);
  }

  @override
  void dispose() {
    if (Get.isRegistered<NotificationsController>()) {
      Get.delete<NotificationsController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: GetBuilder<NotificationsController>(
        id: 'notification-content',
        builder: (controller) {
          final canInteract =
              !controller.isLoading && !controller.isLoadingMore;

          if (controller.isLoading && !controller.hasData) {
            return _NotificationSkeletonView(
              onBack: () => Navigator.of(context).maybePop(),
            );
          }

          if (controller.error.isNotEmpty && !controller.hasData) {
            return _FeedbackState(
              title: '通知加载失败',
              message: controller.error,
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: canInteract ? controller.refreshNotifications : null,
            );
          }

          if (!controller.hasData) {
            return _FeedbackState(
              title: '暂无通知',
              message: '点击刷新后重试',
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: canInteract ? controller.refreshNotifications : null,
            );
          }

          return SimpleEasyRefresher(
            easyRefreshController: controller.easyRefreshController,
            onRefresh: controller.refreshNotifications,
            onLoad: controller.loadMoreNotifications,
            autoRefreshOnStart: false,
            refreshEnabled: canInteract,
            loadEnabled: controller.hasMore && canInteract,
            childBuilder: (context, physics) => AppPage(
              physics: canInteract
                  ? physics
                  : const NeverScrollableScrollPhysics(),
              children: [
                _NotificationHeader(
                  onBack: () => Navigator.of(context).maybePop(),
                  onRefresh: canInteract
                      ? controller.refreshNotifications
                      : null,
                ),
                const SizedBox(height: AppTokens.gap16),
                _ListHeader(total: controller.total),
                const SizedBox(height: AppTokens.gap8),
                for (final item in controller.items) ...[
                  _NotificationCard(
                    item: item,
                    onTap: () => _openDetailSheet(context, item),
                  ),
                  const SizedBox(height: AppTokens.gap12),
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
    SchoolNotificationItem item,
  ) async {
    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      heightFactor: 0.58,
      child: _NotificationDetailSheet(item: item),
    );
  }
}

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader({required this.onBack, required this.onRefresh});

  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        AppIconButton(
          icon: AppIcons.chevronLeft,
          tooltip: '返回',
          variant: AppIconButtonVariant.outline,
          onPressed: onBack,
        ),
        const SizedBox(width: AppTokens.gap12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '通知公告',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppTokens.gap4),
              Text(
                '查看教务工作台消息',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        AppIconButton(
          icon: AppIcons.refresh,
          tooltip: '刷新',
          variant: AppIconButtonVariant.ghost,
          onPressed: onRefresh,
        ),
      ],
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Text(
            '通知列表',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          '共 $total 条',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final SchoolNotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final contentText = _plainText(item.content);

    return AppSurface(
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
                    ? AppIcons.notification
                    : AppIcons.notificationActive,
              ),
              const SizedBox(width: AppTokens.gap12),
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
                    const SizedBox(height: AppTokens.gap8),
                    Wrap(
                      spacing: AppTokens.gap8,
                      runSpacing: AppTokens.gap8,
                      children: [
                        AppTag(
                          label: item.readStatusLabel,
                          variant: item.isRead
                              ? AppTagVariant.neutral
                              : AppTagVariant.primary,
                        ),
                        if (item.noticeType.isNotEmpty)
                          AppTag(label: item.noticeType),
                        if (item.isPinned)
                          const AppTag(
                            label: '置顶',
                            variant: AppTagVariant.warning,
                          ),
                        if (item.isNew)
                          const AppTag(
                            label: '新',
                            variant: AppTagVariant.success,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (contentText.isNotEmpty) ...[
            const SizedBox(height: AppTokens.gap12),
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
            const SizedBox(height: AppTokens.gap12),
            Row(
              children: [
                Icon(
                  AppIcons.calendar,
                  size: AppTokens.iconSm,
                  color: colors.textTertiary,
                ),
                const SizedBox(width: AppTokens.gap6),
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
            _IconBox(icon: AppIcons.notification),
            const SizedBox(width: AppTokens.gap10),
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
        const SizedBox(height: AppTokens.gap16),
        Text(
          item.title.isEmpty ? '未命名通知' : item.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppTokens.gap10),
        Wrap(
          spacing: AppTokens.gap8,
          runSpacing: AppTokens.gap8,
          children: [
            AppTag(
              label: item.readStatusLabel,
              variant: item.isRead
                  ? AppTagVariant.neutral
                  : AppTagVariant.primary,
            ),
            if (item.noticeType.isNotEmpty) AppTag(label: item.noticeType),
            if (item.releaseDate.isNotEmpty) AppTag(label: item.releaseDate),
            if (item.isPinned)
              const AppTag(label: '置顶', variant: AppTagVariant.warning),
          ],
        ),
        const SizedBox(height: AppTokens.gap16),
        AppSurface(
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
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Icon(icon, size: AppTokens.iconMd, color: colors.primary),
    );
  }
}

class _NotificationSkeletonView extends StatelessWidget {
  const _NotificationSkeletonView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => AppPage(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _NotificationHeader(onBack: onBack, onRefresh: null),
          const SizedBox(height: AppTokens.gap16),
          SkeletonBar(
            decoration: palette.line(radius: AppTokens.radiusMd),
            widthFactor: 1,
            height: 52,
          ),
          const SizedBox(height: AppTokens.gap16),
          SkeletonBar(
            decoration: palette.line(radius: AppTokens.radiusMd),
            widthFactor: 1,
            height: 70,
          ),
          const SizedBox(height: AppTokens.gap16),
          for (int i = 0; i < 6; i++) ...[
            SkeletonBar(
              decoration: palette.line(radius: AppTokens.radiusLg),
              widthFactor: 1,
              height: 112,
            ),
            const SizedBox(height: AppTokens.gap12),
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
    required this.onBack,
    required this.onRefresh,
  });

  final String title;
  final String message;
  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        _NotificationHeader(onBack: onBack, onRefresh: onRefresh),
        const SizedBox(height: AppTokens.gap16),
        AppSurface(
          child: SizedBox(
            height: 320,
            child: AppEmptyState(
              title: title,
              message: message,
              icon: AppIcons.notification,
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
