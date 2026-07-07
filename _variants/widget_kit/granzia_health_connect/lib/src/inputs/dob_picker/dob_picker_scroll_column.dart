import 'package:flutter/cupertino.dart';

import 'dob_picker_selection_overlay.dart';

typedef DobPickerItemBuilder = Widget Function(BuildContext context, int index);

typedef DobPickerOnSelected = void Function(int index);

class DobPickerScrollColumn extends StatelessWidget {
  const DobPickerScrollColumn({
    required this.controller,
    required this.itemExtent,
    required this.childCount,
    required this.onSelectedItemChanged,
    required this.itemBuilder,
    this.flex = 1,
    super.key,
  });

  final FixedExtentScrollController controller;
  final double itemExtent;
  final int childCount;
  final DobPickerOnSelected onSelectedItemChanged;
  final DobPickerItemBuilder itemBuilder;
  final int flex;

  @override
  Widget build(BuildContext context) {
    final Widget picker = Stack(
      children: [
        CupertinoPicker.builder(
          scrollController: controller,
          itemExtent: itemExtent,
          selectionOverlay: const SizedBox.shrink(),
          childCount: childCount,
          onSelectedItemChanged: onSelectedItemChanged,
          itemBuilder: itemBuilder,
        ),
        DobPickerSelectionOverlay(itemExtent: itemExtent),
      ],
    );

    if (flex == 1) {
      return Expanded(child: picker);
    }

    return Expanded(flex: flex, child: picker);
  }
}
