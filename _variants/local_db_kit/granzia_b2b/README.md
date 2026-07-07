# local_db_kit

A pluggable, **project-agnostic** local relational-database kit for Flutter.

It ships the Drift/sqlite3 *plumbing* so any app can work offline with real
tables and relations — while **you** define the schema. No chat-, e-commerce- or
any other domain assumptions baked in.

## What you get

| Concern | The kit handles it |
| --- | --- |
| Where the file lives | Resolves documents/support/temp dir + joins the name |
| Opening safely | Lazy, on a background isolate (off the UI thread) |
| Relational integrity | `PRAGMA foreign_keys = ON` on every connection |
| Migrations | Ordered `MigrationStep` list → a clean `MigrationStrategy` |
| Encryption (optional) | SQLite3MultipleCiphers + key from the platform keychain |
| **Offline-first sync** | Outbox + connectivity + push/pull/conflict engine |
| Riverpod DI | A provider factory with auto-close + test overrides |
| Testing | In-memory executor + `withDatabase` helper |

What it deliberately does **not** do: define tables for you. That's your app's
job — which is exactly what makes it reusable across projects.

## Install

```yaml
dependencies:
  local_db_kit:
    path: ../packages/local_db_kit   # or wherever you vendor it
  drift: ^2.33.0
dev_dependencies:
  drift_dev: ^2.33.0
  build_runner: ^2.15.0
```

## Define your schema

```dart
import 'package:drift/drift.dart';
import 'package:local_db_kit/local_db_kit.dart';

part 'app_db.g.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  IntColumn get totalCents => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Users, Orders])
class AppDb extends _$AppDb {
  AppDb(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => LocalDbMigrations.build(
    steps: [
      MigrationStep(
        toVersion: 2,
        migrate: (m, from) => m.createTable(orders),
      ),
    ],
  );
}
```

Run codegen: `dart run build_runner build`.

## Open it

```dart
final db = AppDb(
  LocalDbKit.openExecutor(const LocalDbOptions(name: 'app.sqlite')),
);
```

## Riverpod (optional)

```dart
final dbProvider = localDatabaseProvider<AppDb>(
  options: const LocalDbOptions(name: 'app.sqlite'),
  create: AppDb.new,
);

// Read anywhere; it closes itself when disposed.
final db = ref.watch(dbProvider);

// In tests, swap for in-memory:
ProviderContainer(overrides: [
  dbProvider.overrideWithValue(AppDb(LocalDbKit.inMemory())),
]);
```

## Encryption (optional)

Encryption is **opt-in per database**. Two steps:

1. Copy the `hooks:` block from this package's `pubspec.yaml` into your **app's**
   `pubspec.yaml` — it swaps the bundled sqlite for the SQLite3MultipleCiphers
   build. Databases opened *without* a key stay plain, so this is safe to enable
   even if only some of your databases are encrypted.

   ```yaml
   hooks:
     user_defines:
       sqlite3:
         source: sqlite3mc
   ```

2. Pass an `EncryptionConfig`:

   ```dart
   final db = AppDb(LocalDbKit.openExecutor(
     const LocalDbOptions(
       name: 'secure.sqlite',
       // Generates a random 256-bit key on first run and stores it in the
       // Keychain/Keystore; reads it back on later opens.
       encryption: EncryptionConfig.fromSecureStorage(),
     ),
   ));
   ```

   Or supply your own key with `EncryptionConfig.withKey('...')`.

If you request encryption but forget the `hooks:` block, the kit **throws** on
open rather than silently writing plaintext.

> **Why not `sqlcipher_flutter_libs`?** With `sqlite3` v3 the old runtime
> `open.overrideFor` mechanism was removed in favour of build hooks, and
> `sqlcipher_flutter_libs` is obsolete. SQLite3MultipleCiphers is the supported
> path and is ABI-compatible with a SQLCipher-style key.

## Offline-first sync

Out of the box the kit already makes your app **work offline** — every read and
write hits the local database, so there's nothing to "turn on" for offline mode.
The sync layer adds the other half: **queue local writes while offline and flush
them to your server automatically when the network returns**, pulling remote
changes back down and resolving conflicts.

### How it works

```
        write                       reconnect
   UI ─────────▶ your local DB          │
    │                                   ▼
    └─ enqueue ─▶ outbox (sync.sqlite) ─┴─▶ SyncEngine ──push──▶ your API
                                              │  ◀──pull────────
                                              └─ conflict: last-write-wins
```

1. You write the row to **your own** database (source of truth locally).
2. You call `engine.enqueue(...)` to record the change in the kit's durable
   outbox.
3. `connectivity_plus` detects when you're online; the engine drains the outbox
   (**push**), then fetches remote changes (**pull**) and merges them.
4. If the same row changed on both sides, the **conflict resolver** decides —
   last-write-wins by `updatedAt` by default.

The kit owns all the mechanics (queue, ordering, retry/backoff, connectivity,
conflict arbitration). You implement **one `SyncEndpoint` per entity type** — the
only code that knows your API and tables.

### Implement an endpoint

```dart
class TodosEndpoint implements SyncEndpoint {
  TodosEndpoint(this._db, this._api);
  final AppDb _db;
  final MyApi _api;

  @override
  String get entityType => 'todos';

  @override
  Future<void> push(SyncOperation op) async {
    switch (op.opType) {
      case SyncOpType.create:
      case SyncOpType.update:
        await _api.put('/todos/${op.entityId}', body: op.payload);
      case SyncOpType.delete:
        await _api.delete('/todos/${op.entityId}');
    }
  }

  @override
  Future<PullResult> pull({String? cursor}) async {
    final res = await _api.get('/todos?since=${cursor ?? ''}');
    return PullResult(
      changes: [for (final j in res.items) RemoteChange(
        entityId: j['id'],
        opType: j['deleted'] == true ? SyncOpType.delete : SyncOpType.update,
        payload: jsonEncode(j),
        updatedAt: DateTime.parse(j['updated_at']),
      )],
      nextCursor: res.cursor,
    );
  }

  @override
  Future<void> applyLocal(RemoteChange change) async {
    if (change.opType == SyncOpType.delete) {
      await (_db.delete(_db.todos)..where((t) => t.id.equals(change.entityId))).go();
    } else {
      await _db.into(_db.todos).insertOnConflictUpdate(/* decode change.payload */);
    }
  }

  @override
  Future<DateTime?> localUpdatedAt(String entityId) async {
    final row = await (_db.select(_db.todos)..where((t) => t.id.equals(entityId)))
        .getSingleOrNull();
    return row?.updatedAt;
  }
}
```

### Wire it up (Riverpod)

```dart
final appDbProvider = localDatabaseProvider<AppDb>(
  options: const LocalDbOptions(name: 'app.sqlite'),
  create: AppDb.new,
);

final todoSyncProvider = syncEngineProvider(
  endpoints: (ref) => [TodosEndpoint(ref.watch(appDbProvider), MyApi())],
  // conflictResolver: ConflictResolvers.serverWins,   // optional
);

// When the user adds a todo:
await db.into(db.todos).insert(companion);          // 1. local write
await ref.read(todoSyncProvider).enqueue(SyncOperation(
  id: uuid(), entityType: 'todos', entityId: todo.id,
  opType: SyncOpType.create, payload: jsonEncode(todo),
  updatedAt: DateTime.now(),
));                                                  // 2. queue for sync

// Pull-to-refresh:
await ref.read(todoSyncProvider).syncNow();

// Status UI (spinner / "N waiting" / "synced ✓"):
final status = ref.watch(syncStatusProvider(todoSyncProvider));
```

> The outbox lives in its own `sync.sqlite`, separate from your app database, so
> you never run Drift codegen for it. No setup beyond adding the kit.

### Without Riverpod

Construct `SyncEngine` directly — pass a `SyncDatabase(LocalDbKit.openExecutor(...))`,
your endpoints, and a `ConnectivityPlusMonitor()`. Everything else is identical.

### Conflict policies

`ConflictResolvers.lastWriteWins` (default), `.serverWins`, `.clientWins`, or
pass your own `ConflictResolver` function for custom logic.

### Batching rapid writes (debounce)

A burst of `enqueue` calls (dragging to reorder, fast typing, importing a list)
shouldn't start a network push per write. The engine debounces the *automatic*
sync: after the last `enqueue` it waits `SyncConfig.debounceWindow` (default
300 ms; a fresh enqueue resets the timer) and then runs **one** cycle for the
whole batch. Each entry is still persisted to the outbox immediately, so nothing
is lost if the app dies mid-burst.

`syncNow()` (pull-to-refresh) and reconnect always run **immediately** — only the
enqueue trigger is debounced. Set `debounceWindow: Duration.zero` to push eagerly
on every write.

```dart
final engineProvider = syncEngineProvider(
  endpoints: (ref) => [TodosEndpoint(ref.watch(appDbProvider), MyApi())],
  config: const SyncConfig(debounceWindow: Duration(milliseconds: 500)),
);
```

> Auto-sync fires on an offline→online **transition**, not at startup. For a
> launch-time pull, call `syncNow()` yourself when the app starts.

## Testing

### Unit tests (host — fast, in-memory)

Use `LocalDbTesting` for your own database logic; it runs on the host VM with no
device needed:

```dart
test('inserts a user', () async {
  await LocalDbTesting.withDatabase(AppDb.new, (db) async {
    await db.into(db.users).insert(
      UsersCompanion.insert(id: '1', name: 'Ada'),
    );
    expect(await db.select(db.users).get(), hasLength(1));
  });
});
```

The kit itself ships **83 host unit tests** (`flutter test` in the package root)
covering the outbox, sync engine, conflict resolvers, encryption resolver,
connectivity monitors, and migration builder — all against in-memory databases.

### Integration tests (device/desktop — real filesystem)

On-disk persistence, encryption at rest, and the path/`path_provider` behaviour
can't run on the host VM. The example app carries an integration suite for them
under `example/integration_test/`:

```bash
cd example
flutter test integration_test -d macos      # or: -d <device-id> for a phone
```

It verifies writes survive a reopen, `deleteDatabase` wipes the file, foreign
keys are enforced on the real connection, the support directory works, the
Riverpod providers open/close a real database, and the sync engine flushes a
real on-disk outbox.

> **Encryption is platform-gated.** The `sqlite3mc` build hook links the cipher
> library per platform (it needs the CocoaPods/SPM or Gradle integration on
> iOS/Android, and is not active on a bare `flutter create` macOS runner). When
> the cipher build isn't present, the kit **throws on open** rather than writing
> plaintext — so the encryption integration tests detect that and skip rather
> than give a false pass. Verify encryption on the platform you actually ship.

## License

Private / internal (`publish_to: none`).
