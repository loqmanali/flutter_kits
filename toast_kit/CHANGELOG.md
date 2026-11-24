# Changelog

## 1.0.0

**BREAKING.** Flutter 3.50 / Dart 3.14 migration (monorepo release 2.1.0).

- Migrated from the deprecated `package:flutter/material.dart` / `cupertino.dart` to `package:material_ui` / `package:cupertino_ui`. Requires Flutter >= 3.47 / Dart >= 3.13; extensions and themes are now material_ui `ThemeData` types.
- Dependencies: `material_ui ^1.11.1`.

## 0.1.0

- Initial release: `ToastHost`, `ToastController`, `ToastKitTheme`, five
  built-in layouts (`flat`, `filled`, `outlined`, `minimal`, `banner`).
- The auto-dismiss timer starts only once a toast has actually painted
  (`ToastController.markShown`, reported from a post-frame callback), so a
  toast occluded before its first frame is never dismissed early nor left
  stuck.
- Dedupe window, per-placement queueing, pause/resume on press-and-hold,
  swipe/tap/close/action dismissal, sticky toasts.
- RTL by construction, accessible navigation and reduced-motion support.
- Debug/profile-only DevTools service extensions
  (`ext.toast_kit.show`/`dismissAll`/`state`) and `dart:developer` lifecycle
  logging.
- `@Preview` gallery for every layout × tone plus RTL, dark, large-text and
  stacked-toast cases.
