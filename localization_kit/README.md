# localization_kit

Pluggable, project-agnostic localization toolkit for Flutter.

It owns the **infrastructure** of localization — current locale, persistence,
optional remote language list, HTTP header sync — and stays out of the
**content** of localization (your `AppLocalizations` and ARB files), which
remain in the host app where `flutter gen-l10n` can generate them normally.

## What you get

- Riverpod state for the active locale, with computed slices (`isArabic`,
  `textDirection`, `availableLanguages`, …).
- Persistent storage of the chosen language via a pluggable adapter
  (defaults to in-memory so you can pick `shared_preferences` / Hive /
  `storage_kit` / anything).
- Optional API-driven language list (e.g. Odoo's `/languages` endpoint) —
  plug in a `LocalizationApi`.
- HTTP header sync via a single callback — keep `Accept-Language` aligned
  with the user's choice without baking any HTTP client into the package.
- Ready-made widgets: `LanguageSelector`, `LanguageToggle`, `L10nListener`.
- Small utility for friendly language names + flag emoji, easy to extend.

## What you bring

- Your own generated `AppLocalizations` (from your own ARB files via
  `flutter gen-l10n`). The kit doesn't ship strings.
- Your own storage adapter (or use a default like `shared_preferences`).
- Optionally, your own `LocalizationApi` implementation and HTTP header
  sync callback.

## Install

```yaml
dependencies:
  localization_kit:
    path: ../packages/localization_kit
```

```dart
import 'package:localization_kit/localization_kit.dart';
```

## Integration (3 steps)

### 1) Generate your AppLocalizations as usual

Keep your ARB files (`l10n/app_en.arb`, `l10n/app_ar.arb`, …) inside the
host app and run `flutter gen-l10n`. Nothing changes.

### 2) Configure the runtime once in `main()`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localization_kit/localization_kit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LocalizationKitRuntime.use(
    defaultLanguages: const [
      LanguageModel(code: 'en_US', name: 'English', isoCode: 'en'),
      LanguageModel(code: 'ar_EG', name: 'العربية', isoCode: 'ar'),
    ],
    defaultIsoCode: 'en',
    defaultApiCode: 'en_US',

    // Optional — defaults to in-memory:
    // storage: MySharedPrefsStorageAdapter(),

    // Optional — only if you fetch the language list from a backend:
    // api: MyOdooLanguageApi(myApiClient),

    // Optional — push the code into your HTTP client:
    // onLanguageChanged: (apiCode) async {
    //   await MyApiClient.instance.setHeader('Accept-Language', apiCode);
    // },
  );

  runApp(const ProviderScope(child: MyApp()));
}
```

### 3) Wire `MaterialApp` to the providers

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load the saved language on first read.
    ref.listen(languageProvider, (_, __) {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(languageProvider.notifier).initialize();
    });

    final locale = ref.watch(currentLocaleProvider);

    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => L10nListener(child: child!),
      home: const MyHomePage(),
    );
  }
}
```

That's it — switching the language now updates the UI, persists across
launches, and (if configured) syncs HTTP headers.

## Adapters

### `LocalizationStorageAdapter` (optional)

Default is in-memory. Plug in any backend:

```dart
class SharedPrefsLocalizationStorage implements LocalizationStorageAdapter {
  static const _kIso = 'app.locale.iso';
  static const _kApi = 'app.locale.api';

  @override
  Future<String?> getLocaleCode() async =>
      (await SharedPreferences.getInstance()).getString(_kIso);

  @override
  Future<void> setLocaleCode(String iso) async =>
      (await SharedPreferences.getInstance()).setString(_kIso, iso);

  @override
  Future<String?> getLanguageCode() async =>
      (await SharedPreferences.getInstance()).getString(_kApi);

  @override
  Future<void> setLanguageCode(String api) async =>
      (await SharedPreferences.getInstance()).setString(_kApi, api);
}
```

### `LocalizationApi` (optional)

If your backend exposes a list of supported languages, implement this:

```dart
class OdooLanguageApi implements LocalizationApi {
  OdooLanguageApi(this._client);
  final ApiClient _client;

  @override
  Future<List<LanguageModel>> getLanguages() async {
    final response = await _client.get('/api/languages');
    return LanguageModel.fromJsonList(response as List<dynamic>);
  }
}
```

The notifier will call it during `initialize(useLocal: false)` and update
the `languages` slice once results are back.

### `LanguageHeaderSync` (optional callback)

Push the active API code into your HTTP layer:

```dart
LocalizationKitRuntime.use(
  onLanguageChanged: (apiCode) async {
    MyDio.instance.options.headers['Accept-Language'] = apiCode;
  },
);
```

## Switching languages from the UI

```dart
class SettingsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: LanguageSelector(
        supportedLocales: AppLocalizations.supportedLocales,
        onChanged: (locale) {
          // Look up the API code from the kit's language list.
          final languages = ref.read(availableLanguagesProvider);
          final match = languages.firstWhere(
            (l) => l.isoCode == locale.languageCode,
            orElse: () => LanguageModel(
              code: '${locale.languageCode}_US',
              name: locale.languageCode,
              isoCode: locale.languageCode,
            ),
          );

          ref.read(languageProvider.notifier).changeLocale(
                isoCode: match.isoCode,
                apiCode: match.code,
              );
        },
      ),
    );
  }
}
```

Or the compact `AppBar` variant: `LanguageToggle`.

## RTL helpers

```dart
final isRtl = ref.watch(textDirectionProvider) == TextDirection.rtl;

// Or from any BuildContext:
if (context.isArabic) { ... }
if (context.isRtl)     { ... }
```

## Customising display names / flags

```dart
// Anywhere in startup code:
Localization.languageNameOverrides['fr'] = 'Français';
Localization.languageFlagOverrides['fr'] = '🇫🇷';
```

## Notes

- The kit doesn't bake in a specific storage or HTTP client.
- The kit doesn't ship strings — your app generates its own
  `AppLocalizations` from its own ARB files via `flutter gen-l10n`.
- Wrapping `MaterialApp.builder` with `L10nListener` is only necessary if
  you cache localized strings outside `AppLocalizations.of(context)` (e.g.
  in a global `L10n.someKey` forwarder). For most apps, you can skip it.
