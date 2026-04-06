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
    heightFactor: 0.625,
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
    return SafeArea(
      top: false,
      child: ListView.builder(
        controller: _scrollController,
        primary: false,
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isSelected = item.label == widget.selectedValue;
          final key = _itemKeys.putIfAbsent(index, GlobalKey.new);
          return KeyedSubtree(
            key: key,
            child: ListTile(
              title: Text(item.label),
              subtitle: item.subtitle == null ? null : Text(item.subtitle!),
              trailing: isSelected ? const Icon(Icons.check_rounded) : null,
              onTap: () {
                widget.onSelected(item.label);
                Navigator.of(context).pop();
              },
            ),
          );
        },
      ),
    );
  }
}
