import 'package:flutter/material.dart';

/// A badge showing cart item count.
///
/// ## Usage
///
/// ```dart
/// CartBadgeWidget(
///   count: 5,
///   child: IconButton(
///     icon: Icon(Icons.shopping_cart),
///     onPressed: () => openCart(),
///   ),
/// )
/// ```
class CartBadgeWidget extends StatelessWidget {
  /// The item count to display.
  final int count;

  /// The child widget (usually an icon button).
  final Widget child;

  /// Badge background color.
  final Color? badgeColor;

  /// Badge text color.
  final Color? textColor;

  /// Badge position offset.
  final Offset offset;

  /// Whether to show the badge when count is 0.
  final bool showZero;

  /// Maximum count to display (shows "9+" if exceeded).
  final int? maxCount;

  /// Animation duration.
  final Duration animationDuration;

  const CartBadgeWidget({
    super.key,
    required this.count,
    required this.child,
    this.badgeColor,
    this.textColor,
    this.offset = const Offset(8, -8),
    this.showZero = false,
    this.maxCount = 99,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBadgeColor = badgeColor ?? theme.colorScheme.error;
    final effectiveTextColor = textColor ?? theme.colorScheme.onError;

    final shouldShow = showZero || count > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: offset.dx,
          top: offset.dy,
          child: AnimatedScale(
            scale: shouldShow ? 1.0 : 0.0,
            duration: animationDuration,
            curve: Curves.easeOutBack,
            child: AnimatedSwitcher(
              duration: animationDuration,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Container(
                key: ValueKey(count),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                constraints: const BoxConstraints(minWidth: 18),
                decoration: BoxDecoration(
                  color: effectiveBadgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _formatCount(count),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (maxCount != null && count > maxCount!) {
      return '$maxCount+';
    }
    return count.toString();
  }
}

/// Cart icon button with badge.
class CartIconButton extends StatelessWidget {
  final int itemCount;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? badgeColor;
  final double iconSize;

  const CartIconButton({
    super.key,
    required this.itemCount,
    this.onPressed,
    this.iconColor,
    this.badgeColor,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return CartBadgeWidget(
      count: itemCount,
      badgeColor: badgeColor,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          Icons.shopping_cart_outlined,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}
