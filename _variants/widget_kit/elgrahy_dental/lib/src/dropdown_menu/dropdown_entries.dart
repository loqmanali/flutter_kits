import 'package:flutter/material.dart';

// ============================================================================
// Dropdown Alignment
// ============================================================================

enum CustomDropdownAlignment { start, center, end }

// ============================================================================
// Data Classes for Dropdown Items
// ============================================================================

/// Base class for all dropdown menu entries
abstract class CustomDropdownEntry {}

/// A clickable menu item with text, optional icon, and callback
class CustomDropdownItem extends CustomDropdownEntry {
  final String text;
  final String? value;
  final IconData? icon;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool disabled;

  CustomDropdownItem({
    required this.text,
    this.value,
    this.icon,
    this.shortcut,
    this.onTap,
    this.disabled = false,
  });
}

/// A section header label for grouping menu items
class CustomDropdownLabel extends CustomDropdownEntry {
  final String text;
  CustomDropdownLabel({required this.text});
}

/// A visual separator (horizontal line) between menu items
class CustomDropdownSeparator extends CustomDropdownEntry {}

/// A menu item with a checkbox for toggleable options
class CustomDropdownCheckbox extends CustomDropdownEntry {
  final String text;
  final bool checked;
  final ValueChanged<bool?>? onChanged;
  final bool disabled;

  CustomDropdownCheckbox({
    required this.text,
    required this.checked,
    this.onChanged,
    this.disabled = false,
  });
}

/// A menu item with a radio button for single-select options
class CustomDropdownRadio extends CustomDropdownEntry {
  final String text;
  final String value;
  final String? groupValue;
  final ValueChanged<String>? onChanged;
  final bool disabled;

  CustomDropdownRadio({
    required this.text,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.disabled = false,
  });
}
