import 'package:flutter/material.dart';

import 'dropdown_entries.dart';
import 'dropdown_theme.dart';

/// Maps each [CustomDropdownEntry] subtype to its visual representation.
class DropdownItemRenderer extends StatelessWidget {
  const DropdownItemRenderer({
    super.key,
    required this.item,
    required this.onClose,
    this.selectedValue,
    this.radioGroupValueOverride,
    this.onRadioSelected,
  });

  final CustomDropdownEntry item;
  final VoidCallback onClose;
  final String? selectedValue;

  /// When provided, overrides the [CustomDropdownRadio.groupValue] so the host
  /// panel can coordinate a single selection across all radio rows.
  final String? radioGroupValueOverride;

  /// Notified after the host's per-row callback fires, so the panel can refresh
  /// every radio with the new shared groupValue.
  final ValueChanged<String>? onRadioSelected;

  @override
  Widget build(BuildContext context) {
    final entry = item;
    if (entry is CustomDropdownLabel) return _LabelRow(label: entry);
    if (entry is CustomDropdownSeparator) return const _SeparatorRow();
    if (entry is CustomDropdownItem) {
      return _ItemRow(
        item: entry,
        selectedValue: selectedValue,
        onClose: onClose,
      );
    }
    if (entry is CustomDropdownCheckbox) return _CheckboxRow(item: entry);
    if (entry is CustomDropdownRadio) {
      return _RadioRow(
        item: entry,
        groupValueOverride: radioGroupValueOverride,
        onSelected: onRadioSelected,
      );
    }
    return const SizedBox.shrink();
  }
}

class _LabelRow extends StatelessWidget {
  const _LabelRow({required this.label});
  final CustomDropdownLabel label;

  @override
  Widget build(BuildContext context) {
    final theme = DropdownKitTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Text(
        label.text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.labelTextColor,
        ),
      ),
    );
  }
}

class _SeparatorRow extends StatelessWidget {
  const _SeparatorRow();

  @override
  Widget build(BuildContext context) {
    final theme = DropdownKitTheme.of(context);
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: theme.separatorColor,
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.onClose,
    required this.selectedValue,
  });

  final CustomDropdownItem item;
  final VoidCallback onClose;
  final String? selectedValue;

  @override
  Widget build(BuildContext context) {
    final theme = DropdownKitTheme.of(context);
    final isSelected = item.value != null && item.value == selectedValue;
    final textColor = item.disabled
        ? theme.itemDisabledTextColor
        : (isSelected ? theme.itemSelectedTextColor : theme.itemTextColor);
    final iconColor = item.disabled
        ? theme.itemDisabledTextColor
        : (isSelected ? theme.itemSelectedIconColor : theme.itemIconColor);

    return InkWell(
      onTap: item.disabled
          ? null
          : () {
              onClose();
              item.onTap?.call();
            },
      borderRadius: BorderRadius.circular(theme.itemBorderRadius!),
      child: Container(
        padding: theme.itemPadding,
        margin: theme.itemMargin,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.itemSelectedBackground
              : Colors.transparent,
          borderRadius: BorderRadius.circular(theme.itemBorderRadius!),
        ),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check, size: 16, color: theme.checkIconColor),
            ],
            if (item.shortcut != null && !isSelected) ...[
              const SizedBox(width: 12),
              Text(
                item.shortcut!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: theme.shortcutTextColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stateful checkbox / radio rows
// ---------------------------------------------------------------------------
// The dropdown panel lives in an Overlay, which does not automatically rebuild
// when the host calls setState. Owning local state here keeps the visual state
// in sync with the tap before the parent's onChanged callback round-trips.

class _CheckboxRow extends StatefulWidget {
  const _CheckboxRow({required this.item});
  final CustomDropdownCheckbox item;

  @override
  State<_CheckboxRow> createState() => _CheckboxRowState();
}

class _CheckboxRowState extends State<_CheckboxRow> {
  late bool _checked = widget.item.checked;

  @override
  void didUpdateWidget(covariant _CheckboxRow old) {
    super.didUpdateWidget(old);
    if (old.item.checked != widget.item.checked) {
      _checked = widget.item.checked;
    }
  }

  void _handleTap() {
    if (widget.item.disabled) return;
    final next = !_checked;
    setState(() => _checked = next);
    widget.item.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = DropdownKitTheme.of(context);
    final textColor = widget.item.disabled
        ? theme.itemDisabledTextColor
        : theme.itemTextColor;

    return InkWell(
      onTap: widget.item.disabled ? null : _handleTap,
      borderRadius: BorderRadius.circular(theme.itemBorderRadius!),
      child: Container(
        padding: theme.itemPadding,
        margin: theme.itemMargin,
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: Checkbox(
                value: _checked,
                onChanged:
                    widget.item.disabled ? null : (_) => _handleTap(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.item.text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.item,
    this.groupValueOverride,
    this.onSelected,
  });

  final CustomDropdownRadio item;
  final String? groupValueOverride;
  final ValueChanged<String>? onSelected;

  void _handleTap() {
    if (item.disabled) return;
    item.onChanged?.call(item.value);
    onSelected?.call(item.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = DropdownKitTheme.of(context);
    final textColor =
        item.disabled ? theme.itemDisabledTextColor : theme.itemTextColor;
    final effectiveGroupValue = groupValueOverride ?? item.groupValue;

    return InkWell(
      onTap: item.disabled ? null : _handleTap,
      borderRadius: BorderRadius.circular(theme.itemBorderRadius!),
      child: Container(
        padding: theme.itemPadding,
        margin: theme.itemMargin,
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: AbsorbPointer(
                absorbing: item.disabled,
                child: RadioGroup<String>(
                  groupValue: effectiveGroupValue,
                  onChanged: (_) => _handleTap(),
                  child: Radio<String>(
                    value: item.value,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
