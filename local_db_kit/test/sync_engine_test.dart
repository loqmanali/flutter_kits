import 'package:flutter_test/flutter_test.dart';
import 'package:local_db_kit/local_db_kit.dart';

/// A fake backend + local store standing in for a real app's endpoint. It
/// records what was pushed, serves scripted remote changes on pull, and applies
/// merges into an in-memory map so we can assert the final local state.
class FakeEndpoint implements SyncEndpoint {
  FakeEndpoint({List<RemoteChange> remote = const []}) : _remote = remote;

  @override
  final String entityType = 'todos';

  final List<SyncOperation> pushed = [];
  final Map<String, RemoteChange> applied = {};
  final Map<String, DateTime> localTimes = {};
  List<RemoteChange> _remote;

  /// When true, [push] throws to simulate a server/network failure.
  bool failPush = false;

  void scriptRemote(List<RemoteChange> changes) => _remote = changes;

  @override
  Future<void> push(SyncOperation op) async {
    if (failPush) throw StateError('network down');
    pushed.add(op);
  }

  /// How many times a cycle reached the pull stage — one per completed cycle,
  /// so tests can assert that a burst of writes collapsed into a single cycle.
  int pullCount = 0;

  @override
  Future<PullResult> pull({String? cursor}) async {
    pullCount++;
    final changes = _remote;
    _remote = const []; // one-shot, so a second pull returns nothing
    return PullResult(changes: changes, nextCursor: 'cursor-1');
  }

  @override
  Future<void> applyLocal(RemoteChange change) async {
    applied[change.entityId] = change;
    localTimes[change.entityId] = change.updatedAt;
  }

  @override
  Future<DateTime?> localUpdatedAt(String entityId) async => localTimes[entityId];
}

SyncOperation _op(String id, {DateTime? at}) => SyncOperation(
      id: id,
      entityType: 'todos',
      entityId: 'todo-$id',
      opType: SyncOpType.create,
      payload: '{"id":"todo-$id"}',
      updatedAt: at ?? DateTime(2026, 1, 1),
    );

void main() {
  late SyncDatabase db;
  late FakeEndpoint endpoint;
  late ManualConnectivityMonitor connectivity;

  // A fixed clock keeps backoff math deterministic.
  final fixedNow = DateTime(2026, 6, 9, 12);

  SyncEngine buildEngine({
    ConflictResolver resolver = ConflictResolvers.lastWriteWins,
    SyncConfig config = const SyncConfig(),
    bool online = true,
  }) {
    connectivity = ManualConnectivityMonitor(initial: online);
    return SyncEngine(
      database: db,
      endpoints: [endpoint],
      connectivity: connectivity,
      conflictResolver: resolver,
      config: config,
      clock: () => fixedNow,
    );
  }

  setUp(() {
    db = SyncDatabase(LocalDbKit.inMemory());
    endpoint = FakeEndpoint();
  });

  tearDown(() => db.close());

  group('outbox', () {
    test('enqueue persists a pending entry', () async {
      await db.enqueue(_op('1'), now: fixedNow);
      final pending = await db.pendingReady(now: fixedNow);
      expect(pending, hasLength(1));
      expect(pending.single.entityId, 'todo-1');
    });

    test('enqueue with same id is idempotent (upsert)', () async {
      await db.enqueue(_op('1'), now: fixedNow);
      await db.enqueue(_op('1'), now: fixedNow);
      expect(await db.pendingReady(now: fixedNow), hasLength(1));
    });

    test('markDone removes the entry', () async {
      await db.enqueue(_op('1'), now: fixedNow);
      await db.markDone('1');
      expect(await db.pendingReady(now: fixedNow), isEmpty);
    });

    test('backoff hides an entry until its nextAttemptAt', () async {
      await db.enqueue(_op('1'), now: fixedNow);
      await db.markFailed('1', attempts: 1, nextAttemptAt: fixedNow.add(const Duration(minutes: 1)));

      expect(await db.pendingReady(now: fixedNow), isEmpty, reason: 'still backed off');
      expect(
        await db.pendingReady(now: fixedNow.add(const Duration(minutes: 2))),
        hasLength(1),
        reason: 'backoff elapsed',
      );
    });
  });

  group('SyncEngine push', () {
    test('drains queued changes to the endpoint when online', () async {
      final engine = buildEngine();
      addTearDown(engine.dispose);

      await engine.enqueue(_op('1'));
      await engine.enqueue(_op('2'));
      await engine.syncNow();

      // Both reach the server and the queue empties. (enqueue triggers an eager
      // sync, so the two may push across separate cycles — order isn't
      // guaranteed, completeness is.)
      expect(endpoint.pushed.map((o) => o.id).toSet(), {'1', '2'});
      expect(await db.pendingReady(now: fixedNow), isEmpty);
    });

    test('a failed push is retried later, not dropped', () async {
      final engine = buildEngine();
      addTearDown(engine.dispose);
      endpoint.failPush = true;

      await engine.enqueue(_op('1'));
      await engine.syncNow();

      // Entry is still queued (backed off), with one recorded attempt.
      final stillThere = await db.pendingReady(
        now: fixedNow.add(const Duration(hours: 1)),
      );
      expect(stillThere, hasLength(1));
      expect(stillThere.single.attempts, 1);
    });
  });

  group('SyncEngine pull + conflicts', () {
    test('applies a remote change with no local counterpart', () async {
      final engine = buildEngine();
      addTearDown(engine.dispose);
      endpoint.scriptRemote([
        RemoteChange(
          entityId: 'r1',
          opType: SyncOpType.create,
          payload: '{"id":"r1"}',
          updatedAt: DateTime(2026, 5, 1),
        ),
      ]);

      await engine.syncNow();
      expect(endpoint.applied.containsKey('r1'), isTrue);
    });

    test('last-write-wins: newer remote overwrites older local', () async {
      final engine = buildEngine();
      addTearDown(engine.dispose);
      endpoint.localTimes['x'] = DateTime(2026, 1, 1); // local is old
      endpoint.scriptRemote([
        RemoteChange(
          entityId: 'x',
          opType: SyncOpType.update,
          payload: '{"id":"x","v":2}',
          updatedAt: DateTime(2026, 5, 1), // remote is newer → wins
        ),
      ]);

      await engine.syncNow();
      expect(endpoint.applied.containsKey('x'), isTrue, reason: 'remote won');
    });

    test('last-write-wins: older remote does NOT overwrite newer local', () async {
      final engine = buildEngine();
      addTearDown(engine.dispose);
      endpoint.localTimes['x'] = DateTime(2026, 5, 1); // local is newer
      endpoint.scriptRemote([
        RemoteChange(
          entityId: 'x',
          opType: SyncOpType.update,
          payload: '{"id":"x","v":1}',
          updatedAt: DateTime(2026, 1, 1), // remote is older → loses
        ),
      ]);

      await engine.syncNow();
      expect(endpoint.applied.containsKey('x'), isFalse, reason: 'local kept');
    });

    test('serverWins resolver always applies remote', () async {
      final engine = buildEngine(resolver: ConflictResolvers.serverWins);
      addTearDown(engine.dispose);
      endpoint.localTimes['x'] = DateTime(2026, 5, 1); // newer local...
      endpoint.scriptRemote([
        RemoteChange(
          entityId: 'x',
          opType: SyncOpType.update,
          payload: '{}',
          updatedAt: DateTime(2026, 1, 1), // ...older remote still wins
        ),
      ]);

      await engine.syncNow();
      expect(endpoint.applied.containsKey('x'), isTrue);
    });
  });

  group('SyncEngine offline behaviour', () {
    test('does not push while offline; flushes on reconnect', () async {
      final engine = buildEngine(online: false);
      addTearDown(engine.dispose);

      await engine.enqueue(_op('1'));
      await engine.syncNow();
      expect(endpoint.pushed, isEmpty, reason: 'offline → nothing sent');

      // Network returns → auto-sync should drain the queue.
      connectivity.set(true);
      // Let the reconnect listener + cycle run.
      await Future<void>.delayed(Duration.zero);
      await engine.syncNow();

      expect(endpoint.pushed.map((o) => o.id), ['1']);
    });
  });

  group('SyncEngine debounce', () {
    const window = Duration(milliseconds: 40);

    test('a burst of enqueues collapses into one cycle', () async {
      final engine = buildEngine(
        config: const SyncConfig(debounceWindow: window),
      );
      addTearDown(engine.dispose);

      // Five rapid writes — each resets the debounce timer, so none triggers a
      // cycle on its own.
      for (var i = 0; i < 5; i++) {
        await engine.enqueue(_op('$i'));
      }
      expect(endpoint.pullCount, 0, reason: 'still within the debounce window');

      // After the window settles, exactly one cycle runs for the whole batch.
      await Future<void>.delayed(window * 3);
      expect(endpoint.pullCount, 1, reason: 'one coalesced cycle');
      expect(endpoint.pushed.map((o) => o.id).toSet(), {'0', '1', '2', '3', '4'});
    });

    test('syncNow bypasses the debounce and runs immediately', () async {
      final engine = buildEngine(
        // A long window proves syncNow doesn't wait for it.
        config: const SyncConfig(debounceWindow: Duration(seconds: 30)),
      );
      addTearDown(engine.dispose);

      await engine.enqueue(_op('1'));
      await engine.syncNow(); // should not wait 30s

      expect(endpoint.pushed.map((o) => o.id), ['1']);
      expect(endpoint.pullCount, 1);
    });

    test('zero window pushes eagerly without an explicit syncNow', () async {
      final engine = buildEngine(
        config: const SyncConfig(debounceWindow: Duration.zero),
      );
      addTearDown(engine.dispose);

      await engine.enqueue(_op('1'));
      // Zero-duration timer fires on the next event-loop turn.
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(endpoint.pushed.map((o) => o.id), ['1']);
    });
  });
}
