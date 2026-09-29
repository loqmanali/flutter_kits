# Changelog

## 1.0.0

- Initial release, generalized from `lekbox`'s `ActionConfirmationDialog`.
- `ConfirmDialog<T>` — icon + title + message + optional content + 1..N actions.
- `ConfirmIntent` (neutral / primary / destructive / success / warning / info)
  drives the accent color, the default icon and the default confirm label.
- `ConfirmAction<T>` with `filled` / `tonal` / `outlined` / `text` styles,
  per-action intent, leading icon, `enabled`, `autoPop`, and an async
  `onPressed` that renders an in-button spinner and locks the dialog until it
  settles.
- Surfaces: centered dialog, bottom sheet (keyboard-aware, drag handle), or
  bare content embedded in your own layout.
- `.show(context)` for the typed result, `.ask(context)` for the yes/no case;
  the widget also works with a plain `showDialog` / `showModalBottomSheet`.
- `ConfirmKitTheme` (`ThemeExtension`) for app-wide radius, padding, colors,
  text styles, button metrics and default labels; unset colors resolve from the
  ambient `ColorScheme`, so light/dark follow the app.
- `ConfirmStrings` for localized default labels, per dialog or app-wide.
- Content scrolls rather than overflowing on short screens; the confirmation
  refuses to be dismissed while async work is in flight.
