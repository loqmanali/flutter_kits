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
