# CustomDropdownMenu

A flexible, overlay-based dropdown menu widget for Flutter with rich item types,
smart positioning, smooth animations, and optional outside-tap dismissal.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Import](#import)
- [Widget Parameters](#widget-parameters)
- [Item Types](#item-types)
  - [CustomDropdownItem](#customdropdownitem)
  - [CustomDropdownLabel](#customdropdownlabel)
  - [CustomDropdownSeparator](#customdropdownseparator)
  - [CustomDropdownCheckbox](#customdropdowncheckbox)
  - [CustomDropdownRadio](#customdropdownradio)
- [Alignment](#alignment)
- [Close on Outside Tap](#close-on-outside-tap)
- [Selected Value](#selected-value)
- [Dark Mode](#dark-mode)
- [Customization Guide](#customization-guide)
- [Module Structure](#module-structure)
- [Module Structure](#module-structure)

---

## Quick Start

```dart
CustomDropdownMenu(
  trigger: const Icon(Icons.more_vert),
  items: [
    CustomDropdownItem(text: 'Edit',   icon: Icons.edit,   onTap: () {}),
    CustomDropdownItem(text: 'Delete', icon: Icons.delete, onTap: () {}),
  ],
)
```

---

## Import

Always import the barrel file — never import individual files directly:

```dart
import 'package:widget_kit/widget_kit.dart';
```

---

## Widget Parameters

| Parameter           | Type                        | Default      | Description                                           |
| ------------------- | --------------------------- | ------------ | ----------------------------------------------------- |
| `trigger`           | `Widget`                    | **required** | The widget that opens the dropdown when tapped        |
| `items`             | `List<CustomDropdownEntry>` | **required** | The list of items to show in the dropdown             |
| `width`             | `double?`                   | `null`       | Fixed panel width. Ignored when `autoWidth` is `true` |
| `align`             | `CustomDropdownAlignment`   | `center`     | Panel alignment relative to the trigger               |
| `autoWidth`         | `bool`                      | `true`       | Panel matches the trigger width                       |
| `selectedValue`     | `String?`                   | `null`       | Adds a checkmark next to the matching item            |
| `closeOnTapOutside` | `bool`                      | `true`       | Tapping outside the panel closes it                   |

---

## Item Types

### CustomDropdownItem

A standard clickable row. Supports an icon, keyboard shortcut hint, and disabled state.

```dart
CustomDropdownItem(
  text:     'Rename',
  value:    'rename',       // optional — used with selectedValue
  icon:     Icons.edit,     // optional
  shortcut: '⌘R',           // optional — shown on the right
  disabled: false,          // optional
  onTap:    () { /* ... */ },
)
```

### CustomDropdownLabel

A non-interactive section header for grouping items.

```dart
CustomDropdownLabel(text: 'Actions')
```

### CustomDropdownSeparator

A thin horizontal divider between groups.

```dart
CustomDropdownSeparator()
```

### CustomDropdownCheckbox

A toggleable item. The parent manages the state and rebuilds on change.

```dart
CustomDropdownCheckbox(
  text:      'Show archived',
  checked:   _showArchived,
  disabled:  false,
  onChanged: (value) => setState(() => _showArchived = value ?? false),
)
```

### CustomDropdownRadio

A single-select option. Group multiple radios under the same `groupValue`.

```dart
CustomDropdownRadio(
  text:       'Ascending',
  value:      'asc',
  groupValue: _sortOrder,   // the currently selected value in the group
  onChanged:  (val) => setState(() => _sortOrder = val),
)
```

---

## Alignment

```dart
// Panel left edge aligns with trigger left edge (default for RTL layouts)
CustomDropdownMenu(align: CustomDropdownAlignment.start, ...)

// Panel is centered over the trigger
CustomDropdownMenu(align: CustomDropdownAlignment.center, ...)

// Panel right edge aligns with trigger right edge
CustomDropdownMenu(align: CustomDropdownAlignment.end, ...)
```

The widget automatically clamps to screen edges, so it will never overflow.

---

## Close on Outside Tap

Enabled by default. Disable it when the parent already handles dismissal
(e.g. inside a dialog, or when you want sticky menus).

```dart
CustomDropdownMenu(
  trigger: myButton,
  items: [...],
  closeOnTapOutside: false,   // panel stays open until the trigger is tapped again
)
```

---

## Selected Value

Pass the currently active value to highlight that item with a checkmark:

```dart
CustomDropdownMenu(
  trigger: Text(_currentSort),
  selectedValue: _currentSort,
  items: [
    CustomDropdownItem(text: 'Name',  value: 'name',  onTap: () => setState(() => _currentSort = 'name')),
    CustomDropdownItem(text: 'Date',  value: 'date',  onTap: () => setState(() => _currentSort = 'date')),
    CustomDropdownItem(text: 'Price', value: 'price', onTap: () => setState(() => _currentSort = 'price')),
  ],
)
```

---

## Dark Mode

The widget reads `Theme.of(context).brightness` automatically.
No extra configuration is required — colors adapt to light and dark themes.

---

## Customization Guide

### Change the panel width

```dart
// Fixed width
CustomDropdownMenu(width: 200, autoWidth: false, ...)

// Match trigger width (default)
CustomDropdownMenu(autoWidth: true, ...)
```

### Change animation speed

Open `dropdown_panel.dart` and edit the `AnimationController` duration:

```dart
_controller = AnimationController(
  duration: const Duration(milliseconds: 200), // was 150
  vsync: this,
);
```

### Change panel border / radius / shadow

Open `dropdown_panel.dart`, find the `Material` widget, and adjust its `shape` and `elevation`:

```dart
Material(
  elevation: 4,                       // add shadow
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),   // rounder corners
    side: BorderSide(color: Colors.blue),      // custom border color
  ),
  ...
)
```

### Add a new item type

1. Declare a new class in `dropdown_entries.dart`:

```dart
class CustomDropdownSwitch extends CustomDropdownEntry {
  final String text;
  final bool value;
  final ValueChanged<bool>? onChanged;

  CustomDropdownSwitch({
    required this.text,
    required this.value,
    this.onChanged,
  });
}
```

2. Add a builder in `dropdown_item_renderer.dart`:

```dart
@override
Widget build(BuildContext context) {
  // existing checks ...
  if (item is CustomDropdownSwitch) return _buildSwitch(context, item as CustomDropdownSwitch);
  return const SizedBox.shrink();
}

Widget _buildSwitch(BuildContext context, CustomDropdownSwitch item) {
  return SwitchListTile(
    title: Text(item.text),
    value: item.value,
    onChanged: item.onChanged,
  );
}
```

3. Export is automatic — `dropdown_entries.dart` is already exported from the barrel.

---

## Module Structure

```
lib/core/widgets/
│
├── dropdown_menu_widget.dart          ← legacy path — re-exports the module
│
└── dropdown_menu/
    ├── dropdown_menu.dart             ← BARREL: import this file
    ├── README.md                      ← this file
    │
    ├── dropdown_entries.dart          ← data classes + alignment enum
    ├── dropdown_manager.dart          ← singleton: tracks open dropdowns
    ├── custom_dropdown_menu.dart      ← main HookWidget (public API)
    ├── dropdown_panel.dart            ← animated panel + items list
    └── dropdown_item_renderer.dart    ← per-type item renderers
```

### Responsibility of each file

| File                          | Responsibility                                                          |
| ----------------------------- | ----------------------------------------------------------------------- |
| `dropdown_menu.dart`          | Single import point. Exports everything. Nothing else.                  |
| `dropdown_entries.dart`       | Pure data — no Flutter widgets. Defines all entry types and the enum.   |
| `dropdown_manager.dart`       | Singleton that ensures only one dropdown is open at a time.             |
| `custom_dropdown_menu.dart`   | The widget users interact with. Owns overlay lifecycle and positioning. |
| `dropdown_panel.dart`         | Renders the visible panel with animation and scroll support.            |
| `dropdown_item_renderer.dart` | Maps each `CustomDropdownEntry` subtype to its widget representation.   |

---

## How to Organize a Widget as a Module

This widget follows the Flutter module pattern documented in detail here:

**[docs/widget-module-guide.md](../../../../../docs/widget-module-guide.md)**

That guide covers:

- When to split a widget into a module
- Folder and file structure
- Barrel file rules
- Dependency direction (no circular imports)
- Naming conventions
- Backward compatibility strategy
- Step-by-step refactoring instructions
- A quick-reference checklist
