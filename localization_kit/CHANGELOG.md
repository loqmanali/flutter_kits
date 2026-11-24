## 1.1.0

Flutter 3.50 / Dart 3.14 migration (monorepo release 2.1.0).

- Migrated from the deprecated `package:flutter/material.dart` / `cupertino.dart` to `package:material_ui` / `package:cupertino_ui`. Requires Flutter >= 3.47 / Dart >= 3.13; extensions and themes are now material_ui `ThemeData` types.
- Dependencies: `equatable ^3.0.0`, `material_ui ^1.11.1`.
- Dropped the direct `flutter_localizations` dependency: material_ui's `GlobalMaterialLocalizations.delegates` covers widgets, material and cupertino.

## 1.0.0

* Initial release as a standalone, project-agnostic package extracted from
  `lib/core/localization`.
* Three pluggable adapters (`LocalizationStorageAdapter`, `LocalizationApi`,
  `LanguageHeaderSync`) keep the kit free of any specific storage backend,
  HTTP client, or routing.
* `AppLocalizations` and ARB files deliberately **stay in the host app** —
  `flutter gen-l10n` continues to work normally.
* Generic widgets: `LanguageSelector`, `LanguageToggle`, `L10nListener`.
* Generic `Localization` utility with overridable name/flag maps so the kit
  doesn't presume which languages your app supports.
