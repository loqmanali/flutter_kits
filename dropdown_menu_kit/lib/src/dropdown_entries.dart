import 'package:flutter/material.dart';

/// Horizontal alignment of the dropdown panel relative to its trigger.
enum CustomDropdownAlignment { start, center, end }

/// Base class for all dropdown menu entries.
abstract class CustomDropdownEntry {}

/// A clickable menu item with text, optional icon, and callback.
class CustomDropdownItem extends CustomDropdownEntry {
  CustomDropdownItem({
    required this.text,
    this.value,
    this.icon,
    this.shortcut,
    this.onTap,
    this.disabled = false,
  });

  final String text;
  final String? value;
  final IconData? icon;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool disabled;
}

/// A non-interactive section header for grouping items.
class CustomDropdownLabel extends CustomDropdownEntry {
  CustomDropdownLabel({required this.text});

  final String text;
}

/// A thin horizontal divider between groups.
class CustomDropdownSeparator extends CustomDropdownEntry {}

/// A toggleable item. Parent owns the boolean state.
class CustomDropdownCheckbox extends CustomDropdownEntry {
  CustomDropdownCheckbox({
    required this.text,
    required this.checked,
    this.onChanged,
    this.disabled = false,
  });

  final String text;
  final bool checked;
  final ValueChanged<bool?>? onChanged;
  final bool disabled;
}

/// A single-select option. Group multiple radios via the same [groupValue].
class CustomDropdownRadio extends CustomDropdownEntry {
  CustomDropdownRadio({
    required this.text,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.disabled = false,
  });

  final String text;
  final String value;
  final String? groupValue;
  final ValueChanged<String>? onChanged;
  final bool disabled;
}
