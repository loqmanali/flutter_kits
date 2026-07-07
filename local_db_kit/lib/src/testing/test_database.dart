import 'package:drift/drift.dart';
import 'package:local_db_kit/src/local_db_kit.dart';

/// Test helpers for project databases built on this kit.
abstract final class LocalDbTesting {
  /// A fresh in-memory executor — the canonical way to construct a database in a
  /// unit test. Foreign keys are enforced so tests catch integrity bugs that the
  /// app would hit at runtime.
  ///
  /// ```dart
  /// late MyDb db;
  /// setUp(() => db = MyDb(LocalDbTesting.executor()));
  /// tearDown(() => db.close());
  /// ```
  static QueryExecutor executor({bool foreignKeys = true}) =>
      LocalDbKit.inMemory(foreignKeys: foreignKeys);

  /// Builds, hands to [body], then reliably closes an in-memory database so a
  /// test never leaks a connection even if it throws.
  ///
  /// ```dart
  /// test('inserts a user', () async {
  ///   await LocalDbTesting.withDatabase(MyDb.new, (db) async {
  ///     await db.into(db.users).insert(...);
  ///     expect(await db.select(db.users).get(), hasLength(1));
  ///   });
  /// });
  /// ```
  static Future<R> withDatabase<T extends GeneratedDatabase, R>(
    T Function(QueryExecutor executor) create,
    Future<R> Function(T db) body, {
    bool foreignKeys = true,
  }) async {
    final db = create(LocalDbKit.inMemory(foreignKeys: foreignKeys));
    try {
      return await body(db);
    } finally {
      await db.close();
    }
  }
}
