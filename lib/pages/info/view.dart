/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/pages/info/controller.dart';
import 'package:class_tool/data/model/student_info.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_empty_state.dart';
import 'package:class_tool/ui/app_icon_button.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_page.dart';
import 'package:class_tool/ui/app_surface.dart';
import 'package:class_tool/ui/app_tag.dart';
import 'package:class_tool/ui/app_tokens.dart';
import 'package:class_tool/widgets/skeleton_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  late final InfoController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(InfoController(), permanent: false);
  }

  @override
  void dispose() {
    if (Get.isRegistered<InfoController>()) {
      Get.delete<InfoController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: GetBuilder<InfoController>(
        id: 'info-content',
        builder: (controller) {
          if (controller.isLoading && controller.info == null) {
            return _InfoSkeletonView(
              onBack: () => Navigator.of(context).maybePop(),
            );
          }

          if (controller.error.isNotEmpty && controller.info == null) {
            return _FeedbackState(
              title: '学生信息加载失败',
              message: controller.error,
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: controller.refresh,
            );
          }

          final info = controller.info;
          if (info == null) {
            return _FeedbackState(
              title: '暂无学生信息',
              message: '点击刷新后重试',
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: controller.refresh,
            );
          }

          return AppPage(
            children: [
              _InfoHeader(
                onBack: () => Navigator.of(context).maybePop(),
                onRefresh: controller.isLoading ? null : controller.refresh,
              ),
              const SizedBox(height: AppTokens.gap16),
              if (info.basic.name != null) ...[
                _ProfileSummary(
                  name: info.basic.name ?? '',
                  studentId: info.basic.studentId ?? '',
                  subtitle:
                      '${info.basic.gender ?? ''} · ${info.basic.birthDate ?? ''}',
                  admissionPhoto: controller.admissionPhoto,
                ),
                const SizedBox(height: AppTokens.gap16),
                _InfoSection(
                  title: '基本信息',
                  icon: AppIcons.person,
                  fields: info.basic.displayFields,
                  highlightKeys: const {'学号', '姓名', '性别', '出生日期'},
                ),
                const SizedBox(height: AppTokens.gap12),
              ],
              _InfoSection(
                title: '学籍信息',
                icon: AppIcons.school,
                fields: info.enrollment.displayFields,
              ),
              if (info.household.displayFields.isNotEmpty) ...[
                const SizedBox(height: AppTokens.gap12),
                _InfoSection(
                  title: '户籍信息',
                  icon: AppIcons.location,
                  fields: info.household.displayFields,
                ),
              ],
              if (info.preschool.displayFields.isNotEmpty) ...[
                const SizedBox(height: AppTokens.gap12),
                _InfoSection(
                  title: '学前信息',
                  icon: AppIcons.book,
                  fields: info.preschool.displayFields,
                ),
              ],
              if (info.contact.displayFields.isNotEmpty) ...[
                const SizedBox(height: AppTokens.gap12),
                _InfoSection(
                  title: '联系方式',
                  icon: AppIcons.info,
                  fields: info.contact.displayFields,
                ),
              ],
              if (info.family.isNotEmpty) ...[
                const SizedBox(height: AppTokens.gap12),
                for (int i = 0; i < info.family.length; i++) ...[
                  _InfoSection(
                    title: info.family[i].title ?? '家庭成员${i + 1}',
                    icon: AppIcons.person,
                    fields: info.family[i].displayFields,
                    compact: true,
                  ),
                  if (i < info.family.length - 1)
                    const SizedBox(height: AppTokens.gap8),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _InfoHeader extends StatelessWidget {
  const _InfoHeader({required this.onBack, required this.onRefresh});

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
                '学生信息',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppTokens.gap4),
              Text(
                '查看学籍、基本信息与联系方式',
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

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({
    required this.name,
    required this.studentId,
    required this.subtitle,
    required this.admissionPhoto,
  });

  final String name;
  final String studentId;
  final String subtitle;
  final StudentPhoto? admissionPhoto;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppSurface(
      padding: const EdgeInsets.all(12),
      backgroundColor: colors.primarySoft,
      borderColor: colors.primary.withValues(alpha: 0.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StudentPhotoFrame(photo: admissionPhoto),
          const SizedBox(width: AppTokens.gap12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? '学生' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppTokens.gap6),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  if (studentId.isNotEmpty) ...[
                    const SizedBox(height: AppTokens.gap8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppTag(
                        label: studentId,
                        variant: AppTagVariant.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentPhotoFrame extends StatelessWidget {
  const _StudentPhotoFrame({required this.photo});

  final StudentPhoto? photo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final image = photo;
    return Container(
      width: 72,
      height: 92,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: image != null && image.isNotEmpty
          ? Image.memory(image.bytes, fit: BoxFit.cover, gaplessPlayback: true)
          : Center(
              child: Icon(
                AppIcons.person,
                color: colors.textSecondary,
                size: AppTokens.iconLg,
              ),
            ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.fields,
    this.highlightKeys = const {},
    this.compact = false,
  });

  final String title;
  final IconData icon;
  final Map<String, String> fields;
  final Set<String> highlightKeys;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) return const SizedBox.shrink();

    return AppSurface(
      padding: EdgeInsets.all(compact ? 12 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: icon),
              const SizedBox(width: AppTokens.gap10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.gap12),
          ...fields.entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: compact ? 6 : 8),
              child: _InfoRow(
                label: entry.key,
                value: entry.value,
                highlighted: highlightKeys.contains(entry.key),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.highlighted,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: highlighted ? colors.primary : colors.textSecondary,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: AppTokens.gap10),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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

class _InfoSkeletonView extends StatelessWidget {
  const _InfoSkeletonView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => AppPage(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _InfoHeader(onBack: onBack, onRefresh: null),
          const SizedBox(height: AppTokens.gap16),
          for (int section = 0; section < 4; section++) ...[
            AppSurface(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBar(
                    decoration: palette.line(radius: 8),
                    widthFactor: 0.36,
                    height: 18,
                  ),
                  const SizedBox(height: AppTokens.gap14),
                  for (int row = 0; row < 5; row++) ...[
                    Row(
                      children: [
                        SizedBox(
                          width: 88,
                          child: SkeletonBar(
                            decoration: palette.line(radius: 6),
                            widthFactor: 0.58,
                            height: 12,
                          ),
                        ),
                        const SizedBox(width: AppTokens.gap10),
                        Expanded(
                          child: SkeletonBar(
                            decoration: palette.line(radius: 6),
                            widthFactor: 0.62,
                            height: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.gap8),
                  ],
                ],
              ),
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
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        _InfoHeader(onBack: onBack, onRefresh: onRefresh),
        const SizedBox(height: AppTokens.gap16),
        AppSurface(
          child: SizedBox(
            height: 320,
            child: AppEmptyState(
              title: title,
              message: message,
              icon: AppIcons.person,
              actionLabel: '重试',
              onAction: onRefresh,
            ),
          ),
        ),
      ],
    );
  }
}
