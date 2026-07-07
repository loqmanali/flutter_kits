import 'package:flutter/material.dart';

import '../buttons/app_back_button.dart';

class PageTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final List<Widget>? actions;
  final TextStyle? titleStyle;

  const PageTopBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.leading,
    this.actions,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        titleStyle ?? Theme.of(context).textTheme.bodyLarge;
    return Row(
      children: [
        leading ??
            AppBackButton(
              onTap: onBackPressed ?? () => Navigator.of(context).maybePop(),
            ),
        const SizedBox(width: 16),
        Text(title, style: effectiveStyle),
        if (actions != null) ...[
          const Spacer(),
          ...actions!,
        ],
      ],
    );
  }
}
