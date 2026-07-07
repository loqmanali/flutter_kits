import 'package:flutter/foundation.dart';

/// Callbacks exposed to the screen builder so custom UIs can wire their
/// buttons without re-implementing the launch / dismiss logic.
class ForceUpdateActions {
  const ForceUpdateActions({
    required this.openStore,
    required this.dismiss,
    required this.completeFlexibleUpdate,
  });

  /// Triggers the configured update flow:
  /// - On Android with [AndroidInAppUpdateMode] set, starts Play's
  ///   in-app update overlay.
  /// - Otherwise, launches the store listing URL.
  final Future<void> Function() openStore;

  /// Dismisses the gate. `null` when [ForceUpdateConfig.allowLater] is
  /// `false` — custom UIs should hide their dismiss button when this is
  /// null.
  final VoidCallback? dismiss;

  /// Completes a flexible Android in-app update that has finished
  /// downloading. No-op on iOS / when not using flexible mode.
  final Future<bool> Function() completeFlexibleUpdate;
}
