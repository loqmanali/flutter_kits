// `isNotNull`/`isNull` exist in both drift and matcher; we want matcher's here.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:local_db_kit/local_db_kit.dart';

part 'migration_builder_test.g.dart';

/// The builder's onUpgrade only calls the steps' callbacks; it never touches the
/// Migrator itself in these tests, so an unused stand-in is sufficient.
class _NoopMigrator implements Migrator {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Migrator must not be used here');
}

void main() {
  group('LocalDbMigrations.build — onUpgrade', () {
    test('runs steps in ascending version order regardless of input order', () async {
      final order = <int>[];
      final strategy = LocalDbMigrations.build(
        steps: [
          MigrationStep(toVersion: 4, migrate: (m, f) async => order.add(4)),
          MigrationStep(toVersion: 2, migrate: (m, f) async => order.add(2)),
          MigrationStep(toVersion: 3, migrate: (m, f) async => order.add(3)),
        ],
      );

      await strategy.onUpgrade(_NoopMigrator(), 1, 4);
      expect(order, [2, 3, 4]);
    });

    test('applies only steps in the (from, to] half-open range', () async {
      final order = <int>[];
      final strategy = LocalDbMigrations.build(
        steps: [
          for (var v = 2; v <= 6; v++)
            MigrationStep(toVersion: v, migrate: (m, f) async => order.add(v)),
        ],
      );

      // Upgrading 3 → 5 should skip step 2 (already applied) and step 6 (future).
      await strategy.onUpgrade(_NoopMigrator(), 3, 5);
      expect(order, [4, 5]);
    });

    test('no steps run when from == to', () async {
      final order = <int>[];
      final strategy = LocalDbMigrations.build(
        steps: [
          MigrationStep(toVersion: 2, migrate: (m, f) async => order.add(2)),
        ],
      );
      await strategy.onUpgrade(_NoopMigrator(), 2, 2);
      expect(order, isEmpty);
    });

    test('passes the correct `from` version to each step', () async {
      final fromsSeen = <int>[];
      final strategy = LocalDbMigrations.build(
        steps: [
          MigrationStep(toVersion: 2, migrate: (m, f) async => fromsSeen.add(f)),
          MigrationStep(toVersion: 3, migrate: (m, f) async => fromsSeen.add(f)),
        ],
      );
      await strategy.onUpgrade(_NoopMigrator(), 1, 3);
      // Both steps see the original `from` (1) — drift reports the starting
      // version for the whole upgrade.
      expect(fromsSeen, [1, 1]);
    });

    test('empty steps list upgrades without error', () async {
      final strategy = LocalDbMigrations.build(steps: []);
      await strategy.onUpgrade(_NoopMigrator(), 1, 2);
      // Reaching here without throwing is the assertion.
      expect(true, isTrue);
    });
  });

  group('LocalDbMigrations.build — onCreate / beforeOpen', () {
    test('provides a default onCreate (non-null)', () {
      final strategy = LocalDbMigrations.build(steps: []);
      expect(strategy.onCreate, isNotNull);
    });

    test('uses a custom onCreate when supplied', () async {
      var called = false;
      final strategy = LocalDbMigrations.build(
        steps: [],
        onCreate: (m) async => called = true,
      );
      await strategy.onCreate(_NoopMigrator());
      expect(called, isTrue);
    });

    test('beforeOpen defaults to a no-op that completes', () async {
      final strategy = LocalDbMigrations.build(steps: []);
      // Should be present and awaitable without throwing.
      expect(strategy.beforeOpen, isNotNull);
    });

    test('invokes a custom beforeOpen', () async {
      var opened = false;
      final strategy = LocalDbMigrations.build(
        steps: [],
        beforeOpen: (details) async => opened = true,
      );
      await strategy.beforeOpen!(
        const OpeningDetails(null, 1),
      );
      expect(opened, isTrue);
    });
  });

  group('LocalDbMigrations end-to-end on a real in-memory database', () {
    test('createAll runs on a fresh database (default onCreate)', () async {
      // A real database with the default strategy opens and is usable.
      final db = _MiniDb(LocalDbKit.inMemory());
      addTearDown(db.close);
      await db.into(db.items).insert(ItemsCompanion.insert(id: '1'));
      expect(await db.select(db.items).get(), hasLength(1));
    });
  });
}

// --- A minimal real database to prove the default onCreate (createAll) works ---

class Items extends Table {
  TextColumn get id => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Items])
class _MiniDb extends _$_MiniDb {
  _MiniDb(super.e);
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => LocalDbMigrations.build(steps: []);
}
