import 'package:flutter/material.dart';

/// A widget for selecting quantity with increment/decrement buttons.
///
/// ## Usage
///
/// ```dart
/// QuantitySelectorWidget(
///   quantity: 2,
///   onChanged: (newQuantity) => updateQuantity(newQuantity),
///   minQuantity: 1,
///   maxQuantity: 10,
/// )
/// ```
class QuantitySelectorWidget extends StatelessWidget {
  /// Current quantity.
  final int quantity;

  /// Called when quantity changes.
  final ValueChanged<int> onChanged;

  /// Minimum allowed quantity.
  final int minQuantity;

  /// Maximum allowed quantity.
  final int? maxQuantity;

  /// Size of the buttons.
  final double buttonSize;

  /// Text style for the quantity.
  final TextStyle? textStyle;

  /// Button color.
  final Color? buttonColor;

  /// Icon color.
  final Color? iconColor;

  /// Whether to show the delete icon when quantity is 1.
  final bool showDeleteAtMin;

  /// Called when delete is pressed (at min quantity).
  final VoidCallback? onDelete;

  /// Widget orientation.
  final Axis axis;

  const QuantitySelectorWidget({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minQuantity = 1,
    this.maxQuantity,
    this.buttonSize = 32,
    this.textStyle,
    this.buttonColor,
    this.iconColor,
    this.showDeleteAtMin = false,
    this.onDelete,
    this.axis = Axis.horizontal,
  });

  bool get _canDecrement => quantity > minQuantity;
  bool get _canIncrement => maxQuantity == null || quantity < maxQuantity!;
  bool get _showDelete => showDeleteAtMin && quantity <= minQuantity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveButtonColor =
        buttonColor ?? theme.colorScheme.primary.withValues(alpha: 0.1);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;

    final children = [
      // Decrement / Delete button
      _buildButton(
        icon: _showDelete ? Icons.delete_outline : Icons.remove,
        onPressed: _showDelete
            ? onDelete
            : (_canDecrement ? () => onChanged(quantity - 1) : null),
        color: effectiveButtonColor,
        iconColor: _showDelete
            ? theme.colorScheme.error
            : (_canDecrement ? effectiveIconColor : theme.disabledColor),
      ),

      // Quantity display
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          quantity.toString(),
          style: textStyle ??
              theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),

      // Increment button
      _buildButton(
        icon: Icons.add,
        onPressed: _canIncrement ? () => onChanged(quantity + 1) : null,
        color: effectiveButtonColor,
        iconColor: _canIncrement ? effectiveIconColor : theme.disabledColor,
      ),
    ];

    if (axis == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: children.reversed.toList(),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    required Color iconColor,
  }) {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(buttonSize / 2),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(buttonSize / 2),
          child: Icon(
            icon,
            size: buttonSize * 0.5,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

/// Compact quantity selector for use in lists.
class CompactQuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int minQuantity;
  final int? maxQuantity;
  final VoidCallback? onDelete;

  const CompactQuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minQuantity = 1,
    this.maxQuantity,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return QuantitySelectorWidget(
      quantity: quantity,
      onChanged: onChanged,
      minQuantity: minQuantity,
      maxQuantity: maxQuantity,
      buttonSize: 28,
      showDeleteAtMin: onDelete != null,
      onDelete: onDelete,
    );
  }
}
