# storage_kit

Pluggable, project-agnostic key-value storage facade for Flutter.

One uniform API, swappable backends (SharedPreferences ↔ Hive with optional
AES-256 encryption), zero domain assumptions — drop it into any project.

## Why

Most apps end up with a thin wrapper around `SharedPreferences` that quickly
grows app-specific helpers (`saveAuthTokens`, `saveProfile`, …). When you
start a new project you either copy the wrapper and rip out the
project-specific parts, or rewrite it. `storage_kit` keeps the boring,
reusable part as a package and leaves the domain helpers to your app.

## What's in the box

- `AppStorage` — singleton facade, initialized once.
- `StorageAdapter` — abstract contract.
- `SharedPrefsAdapter` — backed by `shared_preferences`.
- `HiveAdapter` — backed by [`hive_ce`](https://pub.dev/packages/hive_ce)
  (community fork of the original `hive`, which is no longer maintained).
  Supports AES-256 encryption via a passphrase.
- `StorageType` — enum for picking a backend at init time.
- `StorageInspector` — debug utility for measuring storage usage; takes the
  set of keys to inspect as a parameter (you supply them, the package
  doesn't presume anything).

## Add to your project

```yaml
dependencies:
  storage_kit:
    path: ../packages/storage_kit
```

```dart
import 'package:storage_kit/storage_kit.dart';
```

## Quick start

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.initialize();        // defaults to SharedPreferences

  await AppStorage.instance.setString('locale', 'ar');
  final locale = await AppStorage.instance.getString('locale');

  runApp(const MyApp());
}
```

## Picking a backend

```dart
// SharedPreferences (default)
await AppStorage.initialize();

// Hive
await AppStorage.initialize(type: StorageType.hive);

// Hive with encryption (any string is padded/truncated to 32 bytes)
await AppStorage.initialize(
  type: StorageType.hive,
  hiveBoxName: 'secure_storage',
  hiveEncryptionKey: 'your-passphrase',
);

// Or plug in a custom adapter (e.g. flutter_secure_storage, in-memory, etc.)
await AppStorage.initializeWithAdapter(MyAdapter());
```

## API surface (generic key/value)

```dart
final s = AppStorage.instance;

await s.setString(key, value);   await s.getString(key);
await s.setInt(key, value);      await s.getInt(key);
await s.setDouble(key, value);   await s.getDouble(key);
await s.setBool(key, value);     await s.getBool(key);
await s.setStringList(key, []);  await s.getStringList(key);

await s.containsKey(key);
await s.remove(key);
await s.clear(allowList: {'keep_me'});
await s.getKeys();
await s.reload();
await s.close();
```

## Build your own domain layer

The package deliberately doesn't ship helpers like `saveAuthTokens` or
`saveSettings` — those belong to your app. The recommended pattern is to put
your keys and convenience methods in your project, on top of `AppStorage`:

```dart
// in your app: lib/core/storage/app_storage_keys.dart
class AppStorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const userId = 'user_id';

  static const clearableOnLogout = {accessToken, refreshToken, userId};
}

// in your app: lib/core/storage/auth_storage.dart
extension AuthStorage on AppStorage {
  Future<void> saveAuthTokens(String access, String refresh) async {
    await setString(AppStorageKeys.accessToken, access);
    await setString(AppStorageKeys.refreshToken, refresh);
  }

  Future<String?> getAccessToken() => getString(AppStorageKeys.accessToken);

  Future<bool> logout() => clear(allowList: {/* keys to keep */});
}
```

## StorageInspector

```dart
// Inspect a specific set of keys
final summary = await StorageInspector.getUsageSummary(
  keys: {'access_token', 'settings', 'cart_items'},
);

// Or every key currently in storage
final summary = await StorageInspector.getUsageSummaryForAllKeys();

for (final entry in summary.entries) {
  print('${entry.key}: ${StorageInspector.humanizeBytes(entry.sizeBytes)}');
}
print('Total: ${StorageInspector.humanizeBytes(summary.totalBytes)}');
```

## Testing

`AppStorage.resetForTesting()` clears the singleton between tests. Combine
with `initializeWithAdapter` to inject an in-memory adapter:

```dart
setUp(() async {
  await AppStorage.resetForTesting();
  await AppStorage.initializeWithAdapter(InMemoryAdapter());
});
```

## Notes

- The `hive_ce_flutter` package handles `Hive.initFlutter()` internally; you
  don't need to call it yourself.
- `SharedPrefsAdapter.reload()` and `.close()` are no-ops — kept for
  interface symmetry with `HiveAdapter`.
- The clear-with-allowList semantics: any key **not** in the allowList is
  removed. Pass `null` (the default) to wipe everything.
