import 'package:flutter/material.dart';

import 'dropdown_entries.dart';

// ============================================================================
// Individual Item Renderer
// ============================================================================

class DropdownItemRenderer extends StatelessWidget {
  final CustomDropdownEntry item;
  final VoidCallback onClose;
  final String? selectedValue;

  const DropdownItemRenderer({
    super.key,
    required this.item,
    required this.onClose,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    if (item is CustomDropdownLabel) {
      return _buildLabel(context, item as CustomDropdownLabel);
    }
    if (item is CustomDropdownSeparator) return _buildSeparator(context);
    if (item is CustomDropdownItem) {
      return _buildItem(context, item as CustomDropdownItem);
    }
    if (item is CustomDropdownCheckbox) {
      return _buildCheckbox(context, item as CustomDropdownCheckbox);
    }
    if (item is CustomDropdownRadio) {
      return _buildRadio(context, item as CustomDropdownRadio);
    }
    return const SizedBox.shrink();
  }

  // ---------- Label ----------------------------------------------------------

  Widget _buildLabel(BuildContext context, CustomDropdownLabel label) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Text(
        label.text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  // ---------- Separator ------------------------------------------------------

  Widget _buildSeparator(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  // ---------- Item -----------------------------------------------------------

  Widget _buildItem(BuildContext context, CustomDropdownItem item) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = item.value != null && item.value == selectedValue;

    return InkWell(
      onTap: item.disabled
          ? null
          : () {
              onClose();
              item.onTap?.call();
            },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primaryContainer.withValues(alpha: 0.4)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 16,
                color: item.disabled
                    ? colors.onSurfaceVariant
                    : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: item.disabled
                      ? colors.onSurfaceVariant
                      : colors.onSurface,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check, size: 16, color: colors.primary),
            ],
            if (item.shortcut != null && !isSelected) ...[
              const SizedBox(width: 12),
              Text(
                item.shortcut!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------- Checkbox -------------------------------------------------------

  Widget _buildCheckbox(BuildContext context, CustomDropdownCheckbox item) =>
      _CheckboxItem(item: item);

  // ---------- Radio ----------------------------------------------------------

  Widget _buildRadio(BuildContext context, CustomDropdownRadio item) =>
      _RadioItem(item: item);
}

// ---------------------------------------------------------------------------
// Stateful checkbox item
// ---------------------------------------------------------------------------
// The dropdown panel lives in an Overlay, which does not automatically rebuild
// when the parent widget calls setState. By owning local state here, the
// checkbox / radio visually reflect the tap immediately.

class _CheckboxItem extends StatefulWidget {
  final CustomDropdownCheckbox item;
  const _CheckboxItem({required this.item});

  @override
  State<_CheckboxItem> createState() => _CheckboxItemState();
}

class _CheckboxItemState extends State<_CheckboxItem> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.item.checked;
  }

  @override
  void didUpdateWidget(covariant _CheckboxItem old) {
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
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: widget.item.disabled ? null : _handleTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: Checkbox(
                value: _checked,
                onChanged: widget.item.disabled ? null : (_) => _handleTap(),
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
                  color: widget.item.disabled
                      ? colors.onSurfaceVariant
                      : colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stateful radio item
// ---------------------------------------------------------------------------

class _RadioItem extends StatefulWidget {
  final CustomDropdownRadio item;
  const _RadioItem({required this.item});

  @override
  State<_RadioItem> createState() => _RadioItemState();
}

class _RadioItemState extends State<_RadioItem> {
  late String? _groupValue;

  @override
  void initState() {
    super.initState();
    _groupValue = widget.item.groupValue;
  }

  @override
  void didUpdateWidget(covariant _RadioItem old) {
    super.didUpdateWidget(old);
    if (old.item.groupValue != widget.item.groupValue) {
      _groupValue = widget.item.groupValue;
    }
  }

  void _handleTap() {
    if (widget.item.disabled) return;
    setState(() => _groupValue = widget.item.value);
    widget.item.onChanged?.call(widget.item.value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: widget.item.disabled ? null : _handleTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: AbsorbPointer(
                absorbing: widget.item.disabled,
                child: RadioGroup<String>(
                  groupValue: _groupValue,
                  onChanged: (_) => _handleTap(),
                  child: Radio<String>(
                    value: widget.item.value,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.item.text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: widget.item.disabled
                      ? colors.onSurfaceVariant
                      : colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
