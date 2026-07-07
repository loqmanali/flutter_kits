import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_db_kit/src/local_db_kit.dart';
import 'package:local_db_kit/src/local_db_options.dart';
import 'package:local_db_kit/src/sync/connectivity_monitor.dart';
import 'package:local_db_kit/src/sync/sync_contracts.dart';
import 'package:local_db_kit/src/sync/sync_database.dart';
import 'package:local_db_kit/src/sync/sync_engine.dart';
import 'package:local_db_kit/src/sync/sync_status.dart';

/// Riverpod wiring for the offline-first sync layer.
///
/// Most apps only need [syncEngineProvider]: give it the endpoints, and read
/// `ref.watch(syncEngineProvider).statusChanges` in the UI. The lower-level
/// providers are exposed for overrides in tests.
///
/// ```dart
/// final engineProvider = syncEngineProvider(
///   endpoints: (ref) => [TodosEndpoint(ref.watch(appDbProvider))],
/// );
///
/// // UI:
/// final status = ref.watch(syncStatusProvider(engineProvider));
/// ```

/// The kit's own bookkeeping database (outbox + cursors). Closes itself on
/// dispose. Override in tests with `SyncDatabase(LocalDbKit.inMemory())`.
final syncDatabaseProvider = Provider<SyncDatabase>(
  name: 'syncDatabaseProvider',
  (ref) {
    final db = SyncDatabase(
      LocalDbKit.openExecutor(const LocalDbOptions(name: 'sync.sqlite')),
    );
    ref.onDispose(db.close);
    return db;
  },
);

/// Connectivity source for the engine. Defaults to `connectivity_plus`; override
/// with [ManualConnectivityMonitor] in tests or [StreamConnectivityMonitor] to
/// reuse an existing signal.
final connectivityMonitorProvider = Provider<ConnectivityMonitor>(
  name: 'connectivityMonitorProvider',
  (ref) {
    final monitor = ConnectivityPlusMonitor();
    ref.onDispose(monitor.dispose);
    return monitor;
  },
);

/// Builds a [SyncEngine] provider for a given set of endpoints.
///
/// [endpoints] is a callback so the endpoints can themselves read other
/// providers (e.g. the app's domain database). The engine is disposed with the
/// provider.
Provider<SyncEngine> syncEngineProvider({
  required List<SyncEndpoint> Function(Ref ref) endpoints,
  ConflictResolver conflictResolver = ConflictResolvers.lastWriteWins,
  SyncConfig config = const SyncConfig(),
  String? name,
}) {
  return Provider<SyncEngine>(
    name: name ?? 'syncEngineProvider',
    (ref) {
      final engine = SyncEngine(
        database: ref.watch(syncDatabaseProvider),
        endpoints: endpoints(ref),
        connectivity: ref.watch(connectivityMonitorProvider),
        conflictResolver: conflictResolver,
        config: config,
      );
      ref.onDispose(engine.dispose);
      return engine;
    },
  );
}

/// Streams the live [SyncStatus] of a given engine provider — for spinners,
/// "synced ✓", and a pending-changes badge.
StreamProvider<SyncStatus> syncStatusProvider(Provider<SyncEngine> engine) {
  return StreamProvider<SyncStatus>(
    (ref) => ref.watch(engine).statusChanges,
  );
}
