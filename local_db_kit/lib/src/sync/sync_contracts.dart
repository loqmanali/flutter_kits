/// The contracts a consuming app implements to make its data sync.
///
/// The kit owns the *mechanics* (queueing offline writes, detecting
/// connectivity, ordering, retry/backoff, conflict arbitration). The app owns
/// the *specifics* (which endpoint, how to serialize, how to merge) by
/// implementing a [SyncEndpoint] per syncable entity type.
library;

/// The kind of local change queued for the server.
enum SyncOpType { create, update, delete }

/// A single pending change, recorded in the outbox the moment it happens
/// locally. The engine drains these oldest-first when online.
class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.payload,
    required this.updatedAt,
    this.attempts = 0,
  });

  /// Stable, unique id for this queue entry (e.g. a uuid). Used for dedup and
  /// idempotent re-enqueue.
  final String id;

  /// Logical type the operation belongs to, e.g. `'todos'`. Routes the entry to
  /// the matching [SyncEndpoint].
  final String entityType;

  /// Primary key of the affected row in the app's own table.
  final String entityId;

  final SyncOpType opType;

  /// The serialized row (usually JSON) the endpoint needs to perform the write.
  /// For [SyncOpType.delete] this may be empty.
  final String payload;

  /// When the change happened locally — the tiebreaker for last-write-wins.
  final DateTime updatedAt;

  /// How many times pushing this entry has failed. Drives backoff.
  final int attempts;

  SyncOperation copyWith({int? attempts}) => SyncOperation(
        id: id,
        entityType: entityType,
        entityId: entityId,
        opType: opType,
        payload: payload,
        updatedAt: updatedAt,
        attempts: attempts ?? this.attempts,
      );
}

/// A change the server reports during a pull, to be merged into local data.
class RemoteChange {
  const RemoteChange({
    required this.entityId,
    required this.opType,
    required this.payload,
    required this.updatedAt,
  });

  final String entityId;
  final SyncOpType opType;

  /// Serialized remote row (JSON, typically). Empty for deletes.
  final String payload;

  /// The server's modification time for this row — compared against the local
  /// row's `updatedAt` to resolve conflicts.
  final DateTime updatedAt;
}

/// The result of pulling one entity type from the server.
class PullResult {
  const PullResult({required this.changes, required this.nextCursor});

  /// Remote changes since the cursor passed to [SyncEndpoint.pull].
  final List<RemoteChange> changes;

  /// Opaque cursor/timestamp to persist and pass to the next pull, so each pull
  /// only fetches what's new. Null means "no change to the cursor".
  final String? nextCursor;
}

/// What the app implements, once per syncable entity type, to bridge the kit's
/// outbox/merge machinery to its real backend and local tables.
///
/// All three methods may throw on network/serialization failure — the engine
/// catches, counts the attempt, and retries with backoff. Implementations
/// should be idempotent: [push] of the same operation twice, or [applyLocal] of
/// the same change twice, must be safe.
abstract interface class SyncEndpoint {
  /// The [SyncOperation.entityType] this endpoint handles.
  String get entityType;

  /// Send one queued local change to the server. Throw to retry later. Return
  /// normally to mark the entry done and remove it from the outbox.
  Future<void> push(SyncOperation op);

  /// Fetch remote changes newer than [cursor] (null on the first ever pull).
  Future<PullResult> pull({String? cursor});

  /// Apply one remote change to the app's local database (insert/update/delete
  /// the corresponding row). The engine has already decided this change wins any
  /// conflict, so just write it.
  Future<void> applyLocal(RemoteChange change);

  /// Read the local row's modification time for [entityId], or null if it does
  /// not exist locally. Used to detect and resolve conflicts during a pull.
  Future<DateTime?> localUpdatedAt(String entityId);
}

/// Decides who wins when the same row changed both locally and remotely.
typedef ConflictResolver = ConflictWinner Function(
  RemoteChange remote,
  DateTime localUpdatedAt,
);

/// Outcome of a conflict.
enum ConflictWinner {
  /// Apply the remote change, overwriting local.
  remote,

  /// Keep local; the pending local change will be pushed instead.
  local,
}

/// Built-in resolvers covering the common policies.
abstract final class ConflictResolvers {
  /// The newest `updatedAt` wins. The sensible default for most apps.
  static ConflictWinner lastWriteWins(RemoteChange remote, DateTime local) =>
      remote.updatedAt.isAfter(local) ? ConflictWinner.remote : ConflictWinner.local;

  /// The server is always authoritative.
  static ConflictWinner serverWins(RemoteChange remote, DateTime local) =>
      ConflictWinner.remote;

  /// Local changes are never overwritten by a pull (they'll be pushed up).
  static ConflictWinner clientWins(RemoteChange remote, DateTime local) =>
      ConflictWinner.local;
}
