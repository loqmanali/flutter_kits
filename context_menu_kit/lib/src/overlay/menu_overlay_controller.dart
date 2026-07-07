import 'package:flutter/material.dart';

/// Manages a stack of [OverlayEntry] instances for a single menu tree.
///
/// Each call to [show] pushes a new entry on top. [dismiss] pops the
/// top-most entry; [dismissAll] pops every entry that this controller
/// owns. Other overlays in the app are left untouched.
///
/// Complexity:
/// - [show]: O(1).
/// - [dismiss]: O(1).
/// - [dismissAll]: O(n) where n is the number of entries this controller
///   owns.
class MenuOverlayController {
  final List<OverlayEntry> _entries = <OverlayEntry>[];

  /// `true` when at least one overlay entry is currently visible.
  bool get isShowing => _entries.isNotEmpty;

  /// Number of entries currently in the stack — useful for debugging.
  int get depth => _entries.length;

  /// Inserts a new overlay entry built by [contentBuilder] into the
  /// nearest [Overlay] above [context], and pushes it on this
  /// controller's stack.
  ///
  /// Optionally invokes [onShown] right after insertion.
  void show({
    required BuildContext context,
    required WidgetBuilder contentBuilder,
    VoidCallback? onShown,
  }) {
    final entry = OverlayEntry(builder: contentBuilder);
    Overlay.of(context).insert(entry);
    _entries.add(entry);
    onShown?.call();
  }

  /// Removes the top-most entry if any.
  void dismiss() {
    if (_entries.isEmpty) return;
    _entries.removeLast().remove();
  }

  /// Removes every entry this controller owns, top-down.
  void dismissAll() {
    while (_entries.isNotEmpty) {
      _entries.removeLast().remove();
    }
  }
}
