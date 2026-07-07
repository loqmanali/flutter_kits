import 'package:flutter/material.dart';

import '../../core/models/money.dart';

/// A button for adding items to the cart.
///
/// ## Usage
///
/// ```dart
/// AddToCartButton(
///   price: Money(99),
///   onPressed: () => addToCart(),
/// )
/// ```
class AddToCartButton extends StatelessWidget {
  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// The price to display.
  final Money? price;

  /// Custom label text.
  final String? label;

  /// Whether the button is in loading state.
  final bool isLoading;

  /// Whether the button is disabled.
  final bool isDisabled;

  /// Disabled message to show.
  final String? disabledMessage;

  /// Icon to display.
  final IconData icon;

  /// Button style.
  final ButtonStyle? style;

  /// Whether to expand to full width.
  final bool expanded;

  const AddToCartButton({
    super.key,
    this.onPressed,
    this.price,
    this.label,
    this.isLoading = false,
    this.isDisabled = false,
    this.disabledMessage,
    this.icon = Icons.add_shopping_cart,
    this.style,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveLabel = isDisabled && disabledMessage != null
        ? disabledMessage!
        : label ?? 'Add to Cart';

    final button = ElevatedButton(
      onPressed: isLoading || isDisabled ? null : onPressed,
      style: style ??
          ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(effectiveLabel),
                if (price != null) ...[
                  const SizedBox(width: 8),
                  Text('• ${price!.formatted}'),
                ],
              ],
            ),
    );

    if (expanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

/// A floating add to cart button.
class FloatingAddToCartButton extends StatelessWidget {
  final Money price;
  final int quantity;
  final VoidCallback? onPressed;
  final VoidCallback? onQuantityIncrement;
  final VoidCallback? onQuantityDecrement;
  final bool isLoading;

  const FloatingAddToCartButton({
    super.key,
    required this.price,
    this.quantity = 1,
    this.onPressed,
    this.onQuantityIncrement,
    this.onQuantityDecrement,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Quantity selector
            if (onQuantityIncrement != null && onQuantityDecrement != null) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: quantity > 1 ? onQuantityDecrement : null,
                      icon: const Icon(Icons.remove),
                      iconSize: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        quantity.toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onQuantityIncrement,
                      icon: const Icon(Icons.add),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],

            // Add to cart button
            Expanded(
              child: AddToCartButton(
                price: Money(price.amount * quantity, currency: price.currency),
                onPressed: onPressed,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
