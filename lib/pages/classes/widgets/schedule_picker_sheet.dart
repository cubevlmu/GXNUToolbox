import 'package:fin_ui/app_context.dart';
import 'package:fin_ui/app_icons.dart';
import 'package:fin_ui/app_tokens.dart';
import 'package:class_tool/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

class SelectionSheetItem {
  const SelectionSheetItem({required this.label, this.subtitle});

  final String label;
  final String? subtitle;
}

Future<void> showScheduleSelectionSheet({
  required BuildContext context,
  required String selectedValue,
  required List<SelectionSheetItem> items,
  required ValueChanged<String> onSelected,
}) {
  return showAppBottomSheet<void>(
    context: context,
    child: ScheduleSelectionSheetContent(
      selectedValue: selectedValue,
      items: items,
      onSelected: onSelected,
    ),
  );
}

class ScheduleSelectionSheetContent extends StatefulWidget {
  const ScheduleSelectionSheetContent({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.onSelected,
  });

  final String selectedValue;
  final List<SelectionSheetItem> items;
  final ValueChanged<String> onSelected;

  @override
  State<ScheduleSelectionSheetContent> createState() =>
      _ScheduleSelectionSheetContentState();
}

class _ScheduleSelectionSheetContentState
    extends State<ScheduleSelectionSheetContent> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = <int, GlobalKey>{};
  bool _scrolledToSelection = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scrolledToSelection) {
      return;
    }
    _scrolledToSelection = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final selectedIndex = widget.items.indexWhere(
        (item) => item.label == widget.selectedValue,
      );
      if (selectedIndex < 0) {
        return;
      }
      final key = _itemKeys[selectedIndex];
      final itemContext = key?.currentContext;
      if (itemContext == null) {
        return;
      }
      Scrollable.ensureVisible(
        itemContext,
        duration: Duration.zero,
        alignment: 0.35,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        primary: false,
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isSelected = item.label == widget.selectedValue;
          final key = _itemKeys.putIfAbsent(index, GlobalKey.new);
          return KeyedSubtree(
            key: key,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  widget.onSelected(item.label);
                  Navigator.of(context).pop();
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  color: isSelected ? colors.primarySoft : Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.label,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: isSelected
                                        ? colors.primary
                                        : colors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                            ),
                            if (item.subtitle != null) ...[
                              const SizedBox(height: FUITokens.gap2),
                              Text(
                                item.subtitle!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: colors.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          FUIIcons.check,
                          size: FUITokens.iconMd,
                          color: colors.primary,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
