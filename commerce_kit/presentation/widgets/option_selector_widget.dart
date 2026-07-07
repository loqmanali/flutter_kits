import 'package:flutter/material.dart';

import '../../core/models/product_option.dart';
import '../../core/models/product_option_value.dart';

/// A widget for selecting multiple options (extras, add-ons).
///
/// ## Usage
///
/// ```dart
/// OptionSelectorWidget(
///   option: extrasOption,
///   selectedValueIds: {'cheese', 'bacon'},
///   onSelectionChanged: (ids) => updateExtras(ids),
/// )
/// ```
class OptionSelectorWidget extends StatelessWidget {
  /// The option to display.
  final ProductOption option;

  /// Currently selected value IDs.
  final Set<String> selectedValueIds;

  /// Called when selection changes.
  final ValueChanged<Set<String>> onSelectionChanged;

  /// Whether to show price modifiers.
  final bool showPrices;

  const OptionSelectorWidget({
    super.key,
    required this.option,
    required this.selectedValueIds,
    required this.onSelectionChanged,
    this.showPrices = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Text(
                option.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (option.maxSelections != null)
              Text(
                'Max ${option.maxSelections}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Options
        ...option.availableValues.map((value) {
          final isSelected = selectedValueIds.contains(value.id);
          final canSelect = option.maxSelections == null ||
              selectedValueIds.length < option.maxSelections! ||
              isSelected;

          return _OptionCheckbox(
            value: value,
            isSelected: isSelected,
            canSelect: canSelect,
            showPrice: showPrices,
            onTap: () => _toggleSelection(value.id),
          );
        }),
      ],
    );
  }

  void _toggleSelection(String valueId) {
    final newSelection = Set<String>.from(selectedValueIds);

    if (newSelection.contains(valueId)) {
      newSelection.remove(valueId);
    } else {
      if (option.maxSelections == null ||
          newSelection.length < option.maxSelections!) {
        newSelection.add(valueId);
      }
    }

    onSelectionChanged(newSelection);
  }
}

class _OptionCheckbox extends StatelessWidget {
  final ProductOptionValue value;
  final bool isSelected;
  final bool canSelect;
  final bool showPrice;
  final VoidCallback onTap;

  const _OptionCheckbox({
    required this.value,
    required this.isSelected,
    required this.canSelect,
    required this.showPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = value.isAvailable && (canSelect || isSelected);

    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : null,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Label
            Expanded(
              child: Text(
                value.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isEnabled ? null : theme.disabledColor,
                ),
              ),
            ),

            // Price
            if (showPrice && value.hasExtraCost)
              Text(
                '+${value.priceModifier.formatted}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Radio-style option selector for single selection.
class RadioOptionSelector extends StatelessWidget {
  final ProductOption option;
  final String? selectedValueId;
  final ValueChanged<ProductOptionValue> onSelected;
  final bool showPrices;

  const RadioOptionSelector({
    super.key,
    required this.option,
    required this.selectedValueId,
    required this.onSelected,
    this.showPrices = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              Text('*', style: TextStyle(color: theme.colorScheme.error)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ...option.availableValues.map((value) {
          final isSelected = value.id == selectedValueId;

          return InkWell(
            onTap: value.isAvailable ? () => onSelected(value) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Radio
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: value.isAvailable ? null : theme.disabledColor,
                          ),
                        ),
                        if (value.description != null)
                          Text(
                            value.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Price
                  if (showPrices && value.hasExtraCost)
                    Text(
                      '+${value.priceModifier.formatted}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
