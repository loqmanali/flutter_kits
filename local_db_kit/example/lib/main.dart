// A minimal, self-contained example of using local_db_kit in any app.
//
// It defines its own tiny schema (a `notes` table) — proving the kit carries no
// domain assumptions — then opens, writes, and reads through the kit's plumbing.
//
// Run codegen before launching: `dart run build_runner build`.
import 'package:drift/drift.dart';
// `Table` exists in both drift and material; we want drift's here.
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_db_kit/local_db_kit.dart';

part 'main.g.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Notes])
class ExampleDb extends _$ExampleDb {
  ExampleDb(super.e);

  @override
  int get schemaVersion => 1;

  Stream<List<Note>> watchNotes() =>
      (select(notes)..orderBy([(n) => OrderingTerm.desc(n.createdAt)])).watch();

  Future<void> addNote(String body) => into(notes).insert(
        NotesCompanion.insert(body: body, createdAt: DateTime.now()),
      );
}

// The kit's provider factory wires lifecycle + disposal for us.
final dbProvider = localDatabaseProvider<ExampleDb>(
  options: const LocalDbOptions(name: 'example.sqlite'),
  create: ExampleDb.new,
);

final notesProvider = StreamProvider<List<Note>>(
  (ref) => ref.watch(dbProvider).watchNotes(),
);

void main() => runApp(const ProviderScope(child: ExampleApp()));

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: NotesPage());
  }
}

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('local_db_kit example')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(dbProvider).addNote('Note @ ${DateTime.now()}'),
        child: const Icon(Icons.add),
      ),
      body: notes.when(
        data: (rows) => ListView(
          children: [
            for (final n in rows) ListTile(title: Text(n.body)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
