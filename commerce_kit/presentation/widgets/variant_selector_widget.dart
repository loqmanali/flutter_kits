import 'package:flutter/material.dart';

import '../../core/models/product_option.dart';
import '../../core/models/product_option_value.dart';

/// A widget for selecting product variants/options.
///
/// ## Usage
///
/// ```dart
/// VariantSelectorWidget(
///   option: sizeOption,
///   selectedValueId: 'medium',
///   onSelected: (value) => selectOption('size', value.id),
/// )
/// ```
class VariantSelectorWidget extends StatelessWidget {
  /// The option to display.
  final ProductOption option;

  /// Currently selected value ID.
  final String? selectedValueId;

  /// Called when a value is selected.
  final ValueChanged<ProductOptionValue> onSelected;

  /// Whether to show price modifiers.
  final bool showPrices;

  /// Whether to wrap buttons.
  final bool wrap;

  /// Spacing between buttons.
  final double spacing;

  const VariantSelectorWidget({
    super.key,
    required this.option,
    required this.selectedValueId,
    required this.onSelected,
    this.showPrices = true,
    this.wrap = true,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final buttons = option.availableValues.map((value) {
      final isSelected = value.id == selectedValueId;

      return _OptionButton(
        value: value,
        isSelected: isSelected,
        showPrice: showPrices && value.hasExtraCost,
        onTap: () => onSelected(value),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              option.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (option.isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Options
        if (wrap)
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: buttons,
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: buttons
                  .map(
                    (b) => Padding(
                      padding: EdgeInsets.only(right: spacing),
                      child: b,
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  final ProductOptionValue value;
  final bool isSelected;
  final bool showPrice;
  final VoidCallback onTap;

  const _OptionButton({
    required this.value,
    required this.isSelected,
    required this.showPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: value.isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : (value.isAvailable
                          ? theme.colorScheme.onSurface
                          : theme.disabledColor),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (showPrice) ...[
                const SizedBox(height: 2),
                Text(
                  '+${value.priceModifier.formatted}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Color swatch selector for color options.
class ColorSwatchSelector extends StatelessWidget {
  final ProductOption option;
  final String? selectedValueId;
  final ValueChanged<ProductOptionValue> onSelected;
  final double swatchSize;

  const ColorSwatchSelector({
    super.key,
    required this.option,
    required this.selectedValueId,
    required this.onSelected,
    this.swatchSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          option.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: option.values.map((value) {
            final isSelected = value.id == selectedValueId;
            final color = _parseColor(value.colorCode);

            return GestureDetector(
              onTap: value.isAvailable ? () => onSelected(value) : null,
              child: Container(
                width: swatchSize,
                height: swatchSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: _contrastColor(color),
                        size: swatchSize * 0.5,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _parseColor(String? colorCode) {
    if (colorCode == null || colorCode.isEmpty) return Colors.grey;
    try {
      final hex = colorCode.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  Color _contrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
