# Changelog

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
