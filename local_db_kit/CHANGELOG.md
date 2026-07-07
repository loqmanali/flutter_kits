# Changelog

## 1.2.1

- Added an integration test suite under `example/integration_test/` (run with
  `flutter test integration_test -d macos`). Covers on-disk persistence,
  reopen-survives, `deleteDatabase`, foreign-key enforcement on the real
  connection, the support directory, encryption at rest, the Riverpod providers,
  and a real on-disk sync flush. Generated the macOS runner for the example so
  the suite runs on desktop.
- Expanded host unit tests to 83 across encryption, connectivity monitors, the
  sync database DAO, the migration builder, and the value/contract types.

## 1.2.0

- `SyncConfig.debounceWindow` (default 300 ms) — coalesces bursts of `enqueue`
  calls into a single sync cycle. `syncNow` and reconnect still run immediately;
  set `Duration.zero` to push eagerly. Entries are persisted before the debounce,
  so nothing is lost mid-burst.
- Auto-sync now fires only on an offline→online **transition**, not on the first
  connectivity value at startup (no surprise launch-time sync; call `syncNow`
  for a startup pull).

## 1.1.0

Offline-first sync layer.

- `SyncEngine` — drains a durable outbox to the server (push), pulls remote
  changes, and resolves conflicts; auto-triggers when connectivity returns and
  on demand via `syncNow`. Serialized cycles with mid-cycle rerun so a change
  enqueued during a sync is never stranded. Per-entry retry with exponential
  backoff.
- `SyncEndpoint` contract (push/pull/applyLocal/localUpdatedAt) — the only code
  a consumer writes; one per entity type.
- `ConflictResolvers` — last-write-wins (default), server-wins, client-wins, or a
  custom resolver.
- `SyncDatabase` — kit-owned, self-contained outbox + cursor store (no consumer
  codegen).
- `ConnectivityMonitor` — `ConnectivityPlusMonitor` (default), plus
  `StreamConnectivityMonitor` and `ManualConnectivityMonitor` for adapting an
  existing signal or testing.
- `SyncStatus` + Riverpod `syncEngineProvider` / `syncStatusProvider` /
  `syncDatabaseProvider` / `connectivityMonitorProvider`.

## 1.0.0

Initial release.

- `LocalDbKit.openExecutor` / `inMemory` / `deleteDatabase` — Drift `QueryExecutor`
  plumbing with lazy, background-isolate open, configurable directory, and
  `PRAGMA foreign_keys` enforcement.
- `LocalDbOptions` — file name, directory, logging, foreign-key, and encryption
  configuration.
- Optional at-rest encryption via SQLite3MultipleCiphers (`hooks:` build config),
  with `EncryptionConfig.withKey` / `.fromSecureStorage` and a guard that throws
  rather than silently writing plaintext when the cipher build is missing.
- `LocalDbMigrations.build` + `MigrationStep` — ordered migration runner.
- `localDatabaseProvider` / `inMemoryDatabaseProvider` — Riverpod DI with
  auto-close and test overrides.
- `LocalDbTesting` — in-memory executor and `withDatabase` helper for tests.
