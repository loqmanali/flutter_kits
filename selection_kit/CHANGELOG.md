# Changelog

## 2.0.0

**BREAKING.** Flutter 3.50 / Dart 3.14 migration (monorepo release 2.1.0).

- Migrated from the deprecated `package:flutter/material.dart` / `cupertino.dart` to `package:material_ui` / `package:cupertino_ui`. Requires Flutter >= 3.47 / Dart >= 3.13; extensions and themes are now material_ui `ThemeData` types.
- Dependencies: `material_ui ^1.11.1`.

## 1.0.0

- Initial release extracted from `lib/core/widgets/app_radio_group/`.
- Hooks-free implementation (pure `StatefulWidget`, no `flutter_hooks` dependency).
- Shared `SelectionOption<T>` model used by radio and checkbox.
- `AppRadioGroup<T>` / `AppRadio<T>` for single-select.
- `AppCheckboxGroup<T>` / `AppCheckbox<T>` for multi-select.
- `SelectionKitTheme` (`InheritedWidget`) for app-wide defaults.
- Custom indicator builders, validation, helper/error text, label + required marker.
- Vertical (`Column`) and horizontal (`Wrap`) layouts with optional separator widget.
- Drops legacy `useCustomSpacing` / `itemSpacing` / `sectionSpacing` / `spacingWidget`
  in favor of a single `spacing` + optional `separator`.
- Drops legacy grid-mode (`crossAxisCount`) and horizontal-scroll
  (`itemExtent` / `physics`) — wrap externally if needed.
