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
