import 'dart:async';

import 'package:local_db_kit/src/sync/connectivity_monitor.dart';
import 'package:local_db_kit/src/sync/sync_contracts.dart';
import 'package:local_db_kit/src/sync/sync_database.dart';
import 'package:local_db_kit/src/sync/sync_status.dart';

/// Tuning knobs for the engine.
class SyncConfig {
  const SyncConfig({
    this.maxAttempts = 8,
    this.baseBackoff = const Duration(seconds: 2),
    this.maxBackoff = const Duration(minutes: 5),
    this.autoSyncOnReconnect = true,
    this.debounceWindow = const Duration(milliseconds: 300),
  });

  /// After this many failed pushes, an outbox entry is left in place but no
  /// longer retried automatically (it still counts as pending). Surface these to
  /// the user as "couldn't sync".
  final int maxAttempts;

  /// First retry delay; doubles each attempt up to [maxBackoff].
  final Duration baseBackoff;
  final Duration maxBackoff;

  /// Kick off a sync automatically the moment connectivity returns.
  final bool autoSyncOnReconnect;

  /// Coalesces bursts of [SyncEngine.enqueue] calls: after the last enqueue the
  /// engine waits this long (a fresh enqueue resets the timer), then runs one
  /// cycle for the whole batch. Avoids starting a push per keystroke / per item
  /// when many writes happen in quick succession.
  ///
  /// Only the *automatic* enqueue trigger is debounced — [SyncEngine.syncNow]
  /// and reconnect run immediately. Set to [Duration.zero] to push eagerly on
  /// every enqueue.
  final Duration debounceWindow;
}

/// Orchestrates offline-first sync: it drains the outbox to the server (push),
/// pulls remote changes, and arbitrates conflicts — all triggered automatically
/// when connectivity returns, and on demand via [syncNow].
///
/// The engine owns the mechanics; the app supplies one [SyncEndpoint] per
/// entity type plus an optional [ConflictResolver]. Writes always land in the
/// app's local database first (the app does that, then calls [enqueue]); this
/// engine only moves queued changes across the wire.
class SyncEngine {
  SyncEngine({
    required SyncDatabase database,
    required List<SyncEndpoint> endpoints,
    required ConnectivityMonitor connectivity,
    ConflictResolver conflictResolver = ConflictResolvers.lastWriteWins,
    SyncConfig config = const SyncConfig(),
    DateTime Function()? clock,
  })  : _db = database,
        _endpoints = {for (final e in endpoints) e.entityType: e},
        _connectivity = connectivity,
        _resolveConflict = conflictResolver,
        _config = config,
        _clock = clock ?? DateTime.now {
    _wireConnectivity();
    _wirePendingCount();
  }

  final SyncDatabase _db;
  final Map<String, SyncEndpoint> _endpoints;
  final ConnectivityMonitor _connectivity;
  final ConflictResolver _resolveConflict;
  final SyncConfig _config;
  final DateTime Function() _clock;

  final StreamController<SyncStatus> _status =
      StreamController<SyncStatus>.broadcast();
  SyncStatus _current = const SyncStatus(phase: SyncPhase.idle);

  StreamSubscription<bool>? _connSub;
  StreamSubscription<int>? _pendingSub;
  Future<void>? _inFlight;
  Timer? _debounce;
  bool _rerunRequested = false;
  // Seeded true so the first online value the stream reports at startup is NOT
  // treated as a reconnect (no surprise sync on launch); a real offline→online
  // transition flips this and triggers the auto-sync.
  bool _wasOnline = true;
  bool _disposed = false;

  /// Live sync state for the UI (spinner, pending badge, error).
  Stream<SyncStatus> get statusChanges => _status.stream;
  SyncStatus get status => _current;

  /// Reactive count of changes still waiting to sync.
  Stream<int> get pendingCount => _db.watchPendingCount();

  /// Queue a local change for the server. Call this right after you write the
  /// row to your app's own database. Returns once the entry is durably queued —
  /// the actual network sync is scheduled separately.
  ///
  /// To avoid starting a push per write during a burst, the triggered sync is
  /// debounced by [SyncConfig.debounceWindow]; the entry is still persisted
  /// immediately, so nothing is lost if the app is killed before the sync runs.
  Future<void> enqueue(SyncOperation op) async {
    await _db.enqueue(op, now: _clock());
    _scheduleDebouncedSync();
  }

  /// Force a sync cycle now (e.g. pull-to-refresh). Cancels any pending debounce
  /// and runs immediately. Safe to call concurrently — overlapping calls coalesce
  /// onto the one in-flight cycle.
  Future<void> syncNow() {
    _debounce?.cancel();
    return _runCycle();
  }

  /// (Re)starts the debounce timer. Each enqueue pushes the sync out, so a burst
  /// of writes collapses into a single cycle once the writes settle. With a zero
  /// window the sync fires on the next microtask — effectively eager.
  void _scheduleDebouncedSync() {
    if (_disposed) return;
    _debounce?.cancel();
    _debounce = Timer(_config.debounceWindow, () {
      if (!_disposed) unawaited(_maybeSync());
    });
  }

  void _wireConnectivity() {
    _connSub = _connectivity.onlineChanges.listen((online) {
      if (!online) {
        _wasOnline = false;
        _emit(_current.copyWith(phase: SyncPhase.offline));
        return;
      }
      _emit(_current.copyWith(phase: SyncPhase.idle));
      // Only auto-sync on an actual offline→online *transition*, not on the
      // first value the stream reports at startup. A launch-time pull should be
      // the app's explicit choice (call syncNow), so startup stays predictable.
      final reconnected = !_wasOnline;
      _wasOnline = true;
      if (reconnected && _config.autoSyncOnReconnect) unawaited(_maybeSync());
    });
  }

  void _wirePendingCount() {
    _pendingSub = _db.watchPendingCount().listen((count) {
      _emit(_current.copyWith(pendingCount: count));
    });
  }

  Future<void> _maybeSync() async {
    if (await _connectivity.isOnline) await _runCycle();
  }

  /// Runs a full push→pull cycle.
  ///
  /// Concurrent callers coalesce onto the running cycle, but a request that
  /// arrives *while* a cycle is running schedules exactly one more cycle after
  /// it. This matters because a cycle reads the outbox once at its start: without
  /// the rerun, a change enqueued mid-cycle would sit unsent until the next
  /// trigger. Callers await until no further reruns are pending, so on return the
  /// queue has been drained as of their request.
  Future<void> _runCycle() {
    if (_inFlight != null) {
      _rerunRequested = true;
      return _inFlight!;
    }
    return _inFlight = _cycleThenRerun();
  }

  Future<void> _cycleThenRerun() async {
    try {
      do {
        _rerunRequested = false;
        await _cycle();
      } while (_rerunRequested && !_disposed);
    } finally {
      _inFlight = null;
    }
  }

  Future<void> _cycle() async {
    if (_disposed) return;
    if (!await _connectivity.isOnline) {
      _emit(_current.copyWith(phase: SyncPhase.offline));
      return;
    }

    _emit(_current.copyWith(phase: SyncPhase.syncing, clearError: true));
    try {
      await _push();
      await _pull();
      _emit(_current.copyWith(
        phase: SyncPhase.idle,
        clearError: true,
        lastSyncedAt: _clock(),
      ));
    } catch (error) {
      _emit(_current.copyWith(phase: SyncPhase.idle, lastError: error));
    }
  }

  /// Drains the outbox oldest-first. A failed entry is backed off, not dropped,
  /// so a single bad entry can't block the queue forever.
  Future<void> _push() async {
    final pending = await _db.pendingReady(now: _clock());
    for (final op in pending) {
      final endpoint = _endpoints[op.entityType];
      if (endpoint == null) continue; // no handler registered; leave queued
      try {
        await endpoint.push(op);
        await _db.markDone(op.id);
      } catch (_) {
        final attempts = op.attempts + 1;
        if (attempts >= _config.maxAttempts) {
          // Give up auto-retrying; entry stays pending for the user to see.
          await _db.markFailed(op.id, attempts: attempts, nextAttemptAt: _farFuture());
        } else {
          await _db.markFailed(
            op.id,
            attempts: attempts,
            nextAttemptAt: _clock().add(_backoff(attempts)),
          );
        }
      }
    }
  }

  /// Pulls each entity type from its cursor and merges, resolving conflicts.
  Future<void> _pull() async {
    for (final endpoint in _endpoints.values) {
      final cursor = await _db.cursorFor(endpoint.entityType);
      final result = await endpoint.pull(cursor: cursor);

      for (final change in result.changes) {
        final localAt = await endpoint.localUpdatedAt(change.entityId);
        if (localAt == null) {
          // Not present locally → just apply.
          await endpoint.applyLocal(change);
          continue;
        }
        final winner = _resolveConflict(change, localAt);
        if (winner == ConflictWinner.remote) {
          await endpoint.applyLocal(change);
        }
        // ConflictWinner.local → keep local; its outbox entry (if any) pushes up.
      }

      await _db.saveCursor(endpoint.entityType, result.nextCursor, now: _clock());
    }
  }

  Duration _backoff(int attempt) {
    final scaled = _config.baseBackoff * (1 << (attempt - 1));
    return scaled > _config.maxBackoff ? _config.maxBackoff : scaled;
  }

  DateTime _farFuture() => _clock().add(const Duration(days: 3650));

  void _emit(SyncStatus next) {
    _current = next;
    if (!_status.isClosed) _status.add(next);
  }

  /// Stops listening and releases resources. The [SyncDatabase] is owned by the
  /// caller and is NOT closed here.
  Future<void> dispose() async {
    _disposed = true;
    _debounce?.cancel();
    await _connSub?.cancel();
    await _pendingSub?.cancel();
    await _status.close();
  }
}
