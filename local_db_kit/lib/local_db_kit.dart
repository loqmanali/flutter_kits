/// local_db_kit
///
/// A pluggable, project-agnostic local relational-database kit for Flutter.
///
/// It gives you the Drift/sqlite3 *plumbing* — path resolution, background open,
/// foreign-key enforcement, an ordered migration runner, optional at-rest
/// encryption, Riverpod DI, and testing helpers — while each project defines its
/// own `@DriftDatabase` and tables. No domain assumptions; offline by design.
///
/// ## Quick start
///
/// 1. Add the kit (and Drift's codegen) to your app:
///    ```yaml
///    dependencies:
///      local_db_kit:
///        path: ../packages/local_db_kit
///      drift: ^2.33.0
///    dev_dependencies:
///      drift_dev: ^2.33.0
///      build_runner: ^2.15.0
///    ```
///
/// 2. Define your own schema and database:
///    ```dart
///    import 'package:drift/drift.dart';
///    import 'package:local_db_kit/local_db_kit.dart';
///
///    part 'app_db.g.dart';
///
///    class Users extends Table {
///      TextColumn get id => text()();
///      TextColumn get name => text()();
///      @override
///      Set<Column> get primaryKey => {id};
///    }
///
///    @DriftDatabase(tables: [Users])
///    class AppDb extends _$AppDb {
///      AppDb(super.e);
///      @override
///      int get schemaVersion => 1;
///    }
///    ```
///
/// 3. Open it through the kit:
///    ```dart
///    final db = AppDb(
///      LocalDbKit.openExecutor(const LocalDbOptions(name: 'app.sqlite')),
///    );
///    ```
///
/// ## Encryption
///
/// Opt in per database by passing an [EncryptionConfig]. The encrypted build of
/// sqlite (SQLite3MultipleCiphers) is selected by a `hooks:` block in pubspec —
/// see this package's own pubspec for the snippet to copy into your app.
/// ```dart
/// final db = AppDb(LocalDbKit.openExecutor(
///   const LocalDbOptions(
///     name: 'secure.sqlite',
///     encryption: EncryptionConfig.fromSecureStorage(),
///   ),
/// ));
/// ```
library;

export 'src/encryption/encryption_config.dart';
export 'src/encryption/encryption_resolver.dart';
export 'src/local_db_kit.dart';
export 'src/local_db_options.dart';
export 'src/migrations/migration_builder.dart';
export 'src/riverpod/local_db_providers.dart';
export 'src/testing/test_database.dart';

// Offline-first sync layer. Writes land in your local database first; queued
// changes flush to the server automatically when connectivity returns.
export 'src/sync/connectivity_monitor.dart';
export 'src/sync/sync_contracts.dart';
// The generated database type + its row/companion classes are needed by callers
// constructing SyncDatabase; the table classes themselves stay internal.
export 'src/sync/sync_database.dart' show SyncDatabase;
export 'src/sync/sync_engine.dart';
export 'src/sync/sync_providers.dart';
export 'src/sync/sync_status.dart';
