import 'package:drift/drift.dart';
import 'package:local_db_kit/src/sync/sync_contracts.dart';

part 'sync_database.g.dart';

/// Outbox: one row per pending local change, drained oldest-first when online.
class OutboxRows extends Table {
  /// Stable queue-entry id (uuid). Primary key — re-enqueue with the same id is
  /// an idempotent upsert.
  TextColumn get id => text()();

  /// Logical entity type, routes to a [SyncEndpoint] (e.g. 'todos').
  TextColumn get entityType => text()();

  /// Affected row's primary key in the app's own table.
  TextColumn get entityId => text()();

  /// 'create' | 'update' | 'delete' — stored as the enum name.
  TextColumn get opType => text()();

  /// Serialized row the endpoint needs to perform the write (JSON, usually).
  TextColumn get payload => text().withDefault(const Constant(''))();

  /// Local modification time — the last-write-wins tiebreaker.
  DateTimeColumn get updatedAt => dateTime()();

  /// When this entry was first queued (FIFO ordering).
  DateTimeColumn get enqueuedAt => dateTime()();

  /// Failed push attempts so far — drives backoff.
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// When this entry may next be retried; the engine skips entries whose time
  /// is in the future (backoff). Null means "eligible now".
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Per-entity-type pull cursor, so each pull only fetches what is new.
class SyncStateRows extends Table {
  TextColumn get entityType => text()();

  /// Opaque cursor/timestamp returned by the last successful pull.
  TextColumn get cursor => text().nullable()();

  /// When the last successful pull for this type completed.
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {entityType};
}

/// The kit's own, self-contained database for sync bookkeeping.
///
/// Deliberately separate from the app's domain database: the app never has to
/// run Drift codegen for the outbox, and there is no cross-package database-type
/// coupling. Open it with [LocalDbKit.openExecutor] using a distinct file name
/// (e.g. `sync.sqlite`).
@DriftDatabase(tables: [OutboxRows, SyncStateRows])
class SyncDatabase extends _$SyncDatabase {
  SyncDatabase(super.e);

  @override
  int get schemaVersion => 1;

  // --- Outbox ---

  /// Queues (or idempotently re-queues) a local change.
  Future<void> enqueue(SyncOperation op, {required DateTime now}) {
    return into(outboxRows).insertOnConflictUpdate(
      OutboxRowsCompanion.insert(
        id: op.id,
        entityType: op.entityType,
        entityId: op.entityId,
        opType: op.opType.name,
        payload: Value(op.payload),
        updatedAt: op.updatedAt,
        enqueuedAt: now,
        attempts: Value(op.attempts),
      ),
    );
  }

  /// Pending entries eligible to send right now (backoff time passed),
  /// oldest-first. [now] is injected so tests are deterministic.
  Future<List<SyncOperation>> pendingReady({required DateTime now}) async {
    final query = select(outboxRows)
      ..where(
        (r) => r.nextAttemptAt.isNull() | r.nextAttemptAt.isSmallerOrEqualValue(now),
      )
      ..orderBy([(r) => OrderingTerm.asc(r.enqueuedAt)]);
    final rows = await query.get();
    return rows.map(_toOperation).toList();
  }

  /// Total pending entries, regardless of backoff — for a "N changes waiting"
  /// badge.
  Stream<int> watchPendingCount() {
    final count = outboxRows.id.count();
    final query = selectOnly(outboxRows)..addColumns([count]);
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  /// Removes a successfully-pushed entry.
  Future<void> markDone(String id) =>
      (delete(outboxRows)..where((r) => r.id.equals(id))).go();

  /// Records a failed attempt and schedules the next retry.
  Future<void> markFailed(String id, {required int attempts, required DateTime nextAttemptAt}) {
    return (update(outboxRows)..where((r) => r.id.equals(id))).write(
      OutboxRowsCompanion(
        attempts: Value(attempts),
        nextAttemptAt: Value(nextAttemptAt),
      ),
    );
  }

  // --- Sync cursors ---

  Future<String?> cursorFor(String entityType) async {
    final row = await (select(syncStateRows)
          ..where((r) => r.entityType.equals(entityType)))
        .getSingleOrNull();
    return row?.cursor;
  }

  Future<void> saveCursor(
    String entityType,
    String? cursor, {
    required DateTime now,
  }) {
    return into(syncStateRows).insertOnConflictUpdate(
      SyncStateRowsCompanion.insert(
        entityType: entityType,
        cursor: Value(cursor),
        lastSyncedAt: Value(now),
      ),
    );
  }

  static SyncOperation _toOperation(OutboxRow r) => SyncOperation(
        id: r.id,
        entityType: r.entityType,
        entityId: r.entityId,
        opType: SyncOpType.values.asNameMap()[r.opType] ?? SyncOpType.update,
        payload: r.payload,
        updatedAt: r.updatedAt,
        attempts: r.attempts,
      );
}
