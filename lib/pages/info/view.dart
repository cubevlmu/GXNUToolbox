/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:class_tool/pages/info/controller.dart';
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
      appBar: AppBar(
        title: const Text('学生信息'),
        actions: [
          GetBuilder<InfoController>(
            id: 'info-content',
            builder: (c) => IconButton(
              icon: const Icon(Icons.refresh_outlined),
              tooltip: '刷新',
              onPressed: c.isLoading ? null : c.refresh,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: GetBuilder<InfoController>(
          id: 'info-content',
          builder: (c) {
            if (c.isLoading && c.info == null) {
              return const _InfoSkeletonView();
            }
            if (c.error.isNotEmpty && c.info == null) {
              return _FeedbackState(
                title: '加载失败',
                subtitle: c.error,
                onRetry: c.refresh,
              );
            }
            final info = c.info;
            if (info == null) {
              return _FeedbackState(
                title: '暂无数据',
                subtitle: '点击刷新重试',
                onRetry: c.refresh,
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                if (info.basic.name != null)
                  _SectionCard(
                    title: '基本信息',
                    subtitle: '${info.basic.studentId ?? ""} · ${info.basic.gender ?? ""} · ${info.basic.birthDate ?? ""}',
                    fields: info.basic.displayFields,
                    highlightKeys: const {'学号', '姓名', '性别', '出生日期'},
                  ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: '学籍信息',
                  fields: info.enrollment.displayFields,
                ),
                if (info.household.displayFields.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: '户籍信息',
                    fields: info.household.displayFields,
                  ),
                ],
                if (info.preschool.displayFields.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: '学前信息',
                    fields: info.preschool.displayFields,
                  ),
                ],
                if (info.contact.displayFields.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: '联系方式',
                    fields: info.contact.displayFields,
                  ),
                ],
                if (info.family.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  for (int i = 0; i < info.family.length; i++) ...[
                    _SectionCard(
                      title: info.family[i].title ?? "家庭成员${i + 1}",
                      fields: info.family[i].displayFields,
                      compact: true,
                    ),
                    if (i < info.family.length - 1)
                      const SizedBox(height: 8),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.fields,
    this.subtitle,
    this.highlightKeys = const {},
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final Map<String, String> fields;
  final Set<String> highlightKeys;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (fields.isEmpty) return const SizedBox.shrink();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 10),
            ...fields.entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(bottom: compact ? 4 : 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: compact ? 72 : 88,
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: highlightKeys.contains(entry.key)
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: highlightKeys.contains(entry.key)
                              ? FontWeight.w600
                              : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSkeletonView extends StatelessWidget {
  const _InfoSkeletonView();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      builder: (context, palette) => ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          for (int s = 0; s < 4; s++) ...[
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBar(
                      decoration: palette.line(radius: 8),
                      widthFactor: 0.3,
                      height: 16,
                    ),
                    const SizedBox(height: 14),
                    for (int r = 0; r < 5; r++) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 72,
                              child: SkeletonBar(
                                decoration: palette.line(radius: 4),
                                widthFactor: 0.6,
                                height: 12,
                              ),
                            ),
                            Expanded(
                              child: SkeletonBar(
                                decoration: palette.line(radius: 4),
                                widthFactor: 0.55,
                                height: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _FeedbackState extends StatelessWidget {
  const _FeedbackState({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              size: 56,
              color: colorScheme.onSurfaceVariant.withAlpha(120),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
