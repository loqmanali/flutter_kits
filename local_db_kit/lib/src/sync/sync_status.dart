/// What the engine is doing right now — drive a spinner or "synced ✓" badge.
enum SyncPhase { idle, syncing, offline }

/// A snapshot of sync state, emitted on [SyncEngine.statusChanges].
class SyncStatus {
  const SyncStatus({
    required this.phase,
    this.pendingCount = 0,
    this.lastError,
    this.lastSyncedAt,
  });

  final SyncPhase phase;

  /// Local changes still waiting to reach the server.
  final int pendingCount;

  /// The most recent sync error, if the last cycle failed. Cleared on success.
  final Object? lastError;

  /// When the last fully-successful cycle finished.
  final DateTime? lastSyncedAt;

  bool get isSynced => phase == SyncPhase.idle && pendingCount == 0 && lastError == null;

  SyncStatus copyWith({
    SyncPhase? phase,
    int? pendingCount,
    Object? lastError,
    bool clearError = false,
    DateTime? lastSyncedAt,
  }) {
    return SyncStatus(
      phase: phase ?? this.phase,
      pendingCount: pendingCount ?? this.pendingCount,
      lastError: clearError ? null : (lastError ?? this.lastError),
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
