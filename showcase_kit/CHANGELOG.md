# Changelog

## 2.0.0

**BREAKING.** Flutter 3.50 / Dart 3.14 migration (monorepo release 2.1.0).

- Migrated from the deprecated `package:flutter/material.dart` / `cupertino.dart` to `package:material_ui` / `package:cupertino_ui`. Requires Flutter >= 3.47 / Dart >= 3.13; extensions and themes are now material_ui `ThemeData` types.
- Dependencies: `flutter_hooks ^0.21.4`, `material_ui ^1.11.1`.

## 1.0.0

First release, ported from the in-app `showcase_tour` widget.

- `useShowcaseTour` hook, `ShowcaseController`, `ShowcaseStep`,
  `ShowcaseTarget`, `TourManager`, `TourTheme`, `TourLabels`, `TourConfig`.
- The tour is disposed with the widget that created it — the previous version
  leaked its `OverlayEntry` and auto-play timer when the host was unmounted.
- `Prev` on the first step no longer silently ends the tour; `Next` on the last
  step finishes it and reads `done`.
- The bubble is clamped inside the safe area and flips above a target that sits
  low on the screen, instead of being pushed off the top edge.
- The backdrop is modal: taps no longer fall through to the app behind it.
- Button copy comes from `TourLabels` instead of hard-coded English.
- The bubble follows the ambient `ColorScheme` instead of the default canvas
  colour and `Colors.grey`.
- Waiting for a target to mount is bounded at 60 frames rather than an
  unbounded post-frame loop.
