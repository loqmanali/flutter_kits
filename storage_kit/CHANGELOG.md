## 1.0.1

### Fixed

* `saveAuthTokens` / `saveAccessToken` used to set the in-memory
  `_cachedAccessToken` unconditionally, before the write was even attempted,
  and never rolled it back on failure. Since the adapters swallow every
  write exception and just return `false`, a failed write was invisible:
  `getAccessTokenSync()` would keep reporting a token that was never
  actually persisted, so a restart would silently sign the user out with no
  trace. The cache now follows the accessToken write's own result — on
  failure it rolls back to the previous (still-persisted) value instead of
  the unwritten one, since the adapters never partially write, so whatever
  was cached before is still exactly what's on disk.

## 1.0.0

* Initial release as a standalone, project-agnostic package extracted from
  `lib/core/storage`.
* Generic [AppStorage] entry point with [StorageAdapter] interface and two
  built-in adapters: [SharedPrefsAdapter] and [HiveAdapter] (AES-256
  encryption optional).
* Domain-specific helpers (`StorageKeys`, `LocalStorageRepository`, auth /
  device convenience methods) deliberately **left out** of this package — they
  belong to the consuming app, not a generic storage facade.
* [StorageInspector] now takes keys as a parameter instead of pulling them
  from a hard-coded `StorageKeys` set.
* `Hive` backend uses [hive_ce](https://pub.dev/packages/hive_ce) (the
  maintained community fork) instead of the unmaintained `hive` package.
