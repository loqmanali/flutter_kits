import 'package:flutter/material.dart';

import '../../core/models/cart_item.dart';
import 'quantity_selector_widget.dart';

/// A widget for displaying a cart item.
///
/// ## Usage
///
/// ```dart
/// CartItemWidget(
///   item: cartItem,
///   onQuantityChanged: (qty) => updateQuantity(item.id, qty),
///   onRemove: () => removeItem(item.id),
/// )
/// ```
class CartItemWidget extends StatelessWidget {
  /// The cart item to display.
  final CartItem item;

  /// Called when quantity changes.
  final ValueChanged<int>? onQuantityChanged;

  /// Called when remove is pressed.
  final VoidCallback? onRemove;

  /// Called when the item is tapped.
  final VoidCallback? onTap;

  /// Maximum allowed quantity.
  final int? maxQuantity;

  /// Whether to show the image.
  final bool showImage;

  /// Image size.
  final double imageSize;

  /// Custom image widget builder.
  final Widget Function(CartItem item)? imageBuilder;

  /// Whether to show the note.
  final bool showNote;

  /// Whether to show selected options.
  final bool showOptions;

  /// Padding around the widget.
  final EdgeInsetsGeometry padding;

  const CartItemWidget({
    super.key,
    required this.item,
    this.onQuantityChanged,
    this.onRemove,
    this.onTap,
    this.maxQuantity,
    this.showImage = true,
    this.imageSize = 80,
    this.imageBuilder,
    this.showNote = true,
    this.showOptions = true,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (showImage) ...[
              _buildImage(context),
              const SizedBox(width: 12),
            ],

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.totalPrice.formatted,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  // Options
                  if (showOptions && item.hasOptions) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.optionsSummary,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Note
                  if (showNote && item.hasNote) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.note!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Quantity controls
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (onQuantityChanged != null)
                        CompactQuantitySelector(
                          quantity: item.quantity,
                          onChanged: onQuantityChanged!,
                          maxQuantity: maxQuantity,
                          onDelete: onRemove,
                        )
                      else
                        Text(
                          'Qty: ${item.quantity}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      const Spacer(),
                      if (item.quantity > 1)
                        Text(
                          '${item.unitPrice.formatted} each',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (imageBuilder != null) {
      return SizedBox(
        width: imageSize,
        height: imageSize,
        child: imageBuilder!(item),
      );
    }

    final theme = Theme.of(context);

    if (item.image == null) {
      return Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.image_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: item.image!.isAsset
          ? Image.asset(
              item.image!.source,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            )
          : Image.network(
              item.image!.source,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: imageSize,
                height: imageSize,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
    );
  }
}
