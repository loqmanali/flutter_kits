import 'package:flutter/material.dart';

import '../theme/widget_kit_theme.dart';

class DialogPicker extends StatelessWidget {
  const DialogPicker({
    super.key,
    required this.child,
    this.insetPadding,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsets? insetPadding;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) {
    final kit = WidgetKitTheme.of(context);
    return Dialog(
      clipBehavior: Clip.hardEdge,
      insetPadding: insetPadding,
      backgroundColor: backgroundColor ?? kit.dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kit.dialogBorderRadius ?? 16),
      ),
      child: SingleChildScrollView(
        child: child,
      ),
    );
  }
}
