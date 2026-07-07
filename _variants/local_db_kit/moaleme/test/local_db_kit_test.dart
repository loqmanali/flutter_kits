import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_db_kit/local_db_kit.dart';

part 'local_db_kit_test.g.dart';

// A tiny throwaway schema, defined in the test itself — proof the kit makes no
// assumptions about your tables.
class Authors extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Books extends Table {
  TextColumn get id => text()();
  TextColumn get authorId => text().references(Authors, #id)();
  TextColumn get title => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Authors, Books])
class TestDb extends _$TestDb {
  TestDb(super.e);
  @override
  int get schemaVersion => 1;
}

void main() {
  group('LocalDbKit.inMemory', () {
    late TestDb db;

    setUp(() => db = TestDb(LocalDbKit.inMemory()));
    tearDown(() => db.close());

    test('persists and reads rows', () async {
      await db
          .into(db.authors)
          .insert(AuthorsCompanion.insert(id: 'a1', name: 'Ada'));

      final rows = await db.select(db.authors).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, 'Ada');
    });

    test('enforces foreign keys (the kit turns the pragma on)', () async {
      // Inserting a book whose author does not exist must fail when FK
      // enforcement is on — that is the whole point of the relational tier.
      await expectLater(
        db.into(db.books).insert(
              BooksCompanion.insert(
                id: 'b1',
                authorId: 'missing',
                title: 'Orphan',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('foreign keys can be disabled when asked', () async {
      // Close the group's default db first so only one TestDb is live (drift
      // warns about concurrent instances of the same database class).
      await db.close();
      final loose = TestDb(LocalDbKit.inMemory(foreignKeys: false));
      addTearDown(loose.close);

      // With enforcement off, the orphan insert is allowed.
      await loose.into(loose.books).insert(
            BooksCompanion.insert(
              id: 'b1',
              authorId: 'missing',
              title: 'Orphan',
            ),
          );
      expect(await loose.select(loose.books).get(), hasLength(1));
    });
  });

  group('LocalDbMigrations.build', () {
    test('applies only the steps in (from, to] range, in order', () async {
      final applied = <int>[];
      final strategy = LocalDbMigrations.build(
        steps: [
          // Intentionally out of order to prove the builder sorts them.
          MigrationStep(toVersion: 3, migrate: (m, from) async => applied.add(3)),
          MigrationStep(toVersion: 2, migrate: (m, from) async => applied.add(2)),
          MigrationStep(toVersion: 4, migrate: (m, from) async => applied.add(4)),
        ],
      );

      // Simulate an upgrade from v2 → v4: step 2 already applied, so only 3 & 4.
      await strategy.onUpgrade(_NoopMigrator(), 2, 4);

      expect(applied, [3, 4]);
    });
  });
}

// onUpgrade never touches the Migrator in the test above (the steps only record
// their version), so a stand-in that is never used is enough.
class _NoopMigrator implements Migrator {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Migrator should not be used in this test');
}
