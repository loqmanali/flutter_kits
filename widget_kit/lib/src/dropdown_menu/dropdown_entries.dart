import 'package:flutter/material.dart';

// ============================================================================
// Dropdown Alignment
// ============================================================================

enum CustomDropdownAlignment { start, center, end }

// ============================================================================
// Data Classes for Dropdown Items
// ============================================================================

/// Base class for all dropdown menu entries
abstract class AppDropdownEntry {}

/// A clickable menu item with text, optional icon, and callback
class AppDropdownItem extends AppDropdownEntry {
  final String text;
  final String? value;
  final IconData? icon;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool disabled;

  AppDropdownItem({
    required this.text,
    this.value,
    this.icon,
    this.shortcut,
    this.onTap,
    this.disabled = false,
  });
}

/// A section header label for grouping menu items
class AppDropdownLabel extends AppDropdownEntry {
  final String text;
  AppDropdownLabel({required this.text});
}

/// A visual separator (horizontal line) between menu items
class AppDropdownSeparator extends AppDropdownEntry {}

/// A menu item with a checkbox for toggleable options
class AppDropdownCheckbox extends AppDropdownEntry {
  final String text;
  final bool checked;
  final ValueChanged<bool?>? onChanged;
  final bool disabled;

  AppDropdownCheckbox({
    required this.text,
    required this.checked,
    this.onChanged,
    this.disabled = false,
  });
}

/// A menu item with a radio button for single-select options
class AppDropdownRadio extends AppDropdownEntry {
  final String text;
  final String value;
  final String? groupValue;
  final ValueChanged<String>? onChanged;
  final bool disabled;

  AppDropdownRadio({
    required this.text,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.disabled = false,
  });
}
