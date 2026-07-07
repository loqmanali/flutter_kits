import 'package:flutter/material.dart';

import '../../layout/app_spacing.dart';

class DobPickerSelectionOverlay extends StatelessWidget {
  const DobPickerSelectionOverlay({
    required this.itemExtent,
    super.key,
  });

  final double itemExtent;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 1,
              color: Colors.black.withValues(alpha: 0.15),
            ),
            AppSpacing.height(itemExtent - 2),
            Container(
              height: 1,
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ],
        ),
      ),
    );
  }
}
