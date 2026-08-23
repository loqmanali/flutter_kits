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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        GestureDetector(
          onTap: onClose ?? () => Navigator.pop(context),
          child: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
        ),
      ],
    );
  }
}
