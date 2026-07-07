import 'package:drift/drift.dart';

/// A single, ordered schema step that runs when upgrading *to* [toVersion].
///
/// You register these in order; the runner applies every step whose
/// [toVersion] is greater than the database's current version, in ascending
/// order. This keeps migrations readable — one block per version bump — instead
/// of a wall of `if (from < n)` branches.
class MigrationStep {
  const MigrationStep({required this.toVersion, required this.migrate});

  /// The schema version this step brings the database up to. Must be > 1.
  final int toVersion;

  /// The work to perform. Typically `m.addColumn(...)`, `m.createTable(...)`,
  /// etc. Receives the live [Migrator] and the version being migrated *from*.
  final Future<void> Function(Migrator m, int from) migrate;
}

/// Builds a Drift [MigrationStrategy] from an ordered list of [MigrationStep]s.
///
/// ```dart
/// @override
/// MigrationStrategy get migration => LocalDbMigrations.build(
///   steps: [
///     MigrationStep(
///       toVersion: 2,
///       migrate: (m, from) => m.addColumn(users, users.avatarUrl),
///     ),
///     MigrationStep(
///       toVersion: 3,
///       migrate: (m, from) => m.createTable(orders),
///     ),
///   ],
///   beforeOpen: (details) async {
///     // optional: runs after migrations on every open
///   },
/// );
/// ```
abstract final class LocalDbMigrations {
  /// Assembles the strategy. [steps] need not be pre-sorted — they are sorted by
  /// [MigrationStep.toVersion] here. On a fresh database `createAll` runs and no
  /// steps are applied.
  static MigrationStrategy build({
    required List<MigrationStep> steps,
    OnCreate? onCreate,
    OnBeforeOpen? beforeOpen,
  }) {
    final sorted = [...steps]..sort((a, b) => a.toVersion.compareTo(b.toVersion));

    return MigrationStrategy(
      onCreate: onCreate ?? (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        for (final step in sorted) {
          if (from < step.toVersion && step.toVersion <= to) {
            await step.migrate(m, from);
          }
        }
      },
      beforeOpen: beforeOpen ?? (_) async {},
    );
  }
}
