import 'package:flutter/material.dart';

import '../layout/app_spacing.dart';

class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.title,
    this.onClose,
    this.leading,
  });

  final String title;
  final VoidCallback? onClose;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        leading ?? const AppSpacing.width(24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        GestureDetector(
          onTap: onClose ?? () => Navigator.pop(context),
          child: const Icon(
            Icons.close,
            color: Colors.black,
            size: 24,
          ),
        ),
      ],
    );
  }
}
