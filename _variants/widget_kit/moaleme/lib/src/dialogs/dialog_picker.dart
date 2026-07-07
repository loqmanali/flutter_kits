import 'package:flutter/material.dart';

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
    return Dialog(
      clipBehavior: Clip.hardEdge,
      insetPadding: insetPadding,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: child,
      ),
    );
  }
}
