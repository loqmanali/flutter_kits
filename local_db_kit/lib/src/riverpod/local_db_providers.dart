import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_db_kit/src/local_db_kit.dart';
import 'package:local_db_kit/src/local_db_options.dart';

/// Riverpod DI for a project-defined Drift database.
///
/// The kit can't ship a provider for *your* database type, so this is a small
/// factory: give it how to build your database from a [QueryExecutor], and it
/// returns a ready provider that
///  - opens the database lazily on first read,
///  - closes it automatically when the provider is disposed (no leaked file
///    handles), and
///  - can be overridden in tests with an in-memory instance.
///
/// ```dart
/// final dbProvider = localDatabaseProvider<MyDb>(
///   options: const LocalDbOptions(name: 'my.sqlite'),
///   create: MyDb.new,
/// );
///
/// // In a widget / notifier:
/// final db = ref.watch(dbProvider);
///
/// // In a test:
/// ProviderContainer(overrides: [
///   dbProvider.overrideWithValue(MyDb(LocalDbKit.inMemory())),
/// ]);
/// ```
///
/// [T] must expose `close()` — every `GeneratedDatabase` does.
Provider<T> localDatabaseProvider<T extends GeneratedDatabase>({
  required LocalDbOptions options,
  required T Function(QueryExecutor executor) create,
  String? name,
}) {
  return Provider<T>(
    name: name ?? 'localDatabaseProvider<$T>(${options.name})',
    (ref) {
      final db = create(LocalDbKit.openExecutor(options));
      ref.onDispose(db.close);
      return db;
    },
  );
}

/// Like [localDatabaseProvider] but backed by an in-memory executor. Handy as a
/// drop-in `overrideWith` target, or for previews/demos that shouldn't persist.
Provider<T> inMemoryDatabaseProvider<T extends GeneratedDatabase>({
  required T Function(QueryExecutor executor) create,
  bool foreignKeys = true,
  String? name,
}) {
  return Provider<T>(
    name: name ?? 'inMemoryDatabaseProvider<$T>',
    (ref) {
      final db = create(LocalDbKit.inMemory(foreignKeys: foreignKeys));
      ref.onDispose(db.close);
      return db;
    },
  );
}
