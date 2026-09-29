import 'dart:async';
import 'dart:developer' as developer;

import '../domain/toast_clock.dart';
import '../domain/toast_dismiss_reason.dart';
import '../domain/toast_placement.dart';
import '../domain/toast_policy.dart';
import '../domain/toast_request.dart';
import 'toast_entry.dart';
import 'toast_handle.dart';
import 'toast_lifecycle_state.dart';

/// Owns every toast's queue, dedupe and lifecycle, per [ToastPlacement].
///
/// Pure Dart: the presentation layer (`ToastHost`) is the only thing that
/// paints anything, and reads this controller through [visibleIn],
/// [pendingIn] and [addListener].
///
/// **The invariant this kit exists for:** a toast's auto-dismiss timer
/// starts only when the presentation layer calls [markShown] from a
/// post-frame callback after the toast widget's first build — never at
/// [show] time. A toast that is occluded (no frames render) cannot burn its
/// duration before anyone sees it, and a [dismiss] that arrives first
/// removes it from the pending queue so [markShown] finding nothing is a
/// no-op, not a resurrection.
final class ToastController {
  ToastController({
    ToastClock clock = const SystemToastClock(),
    ToastPolicy policy = ToastPolicy.fallback,
  })  : _clock = clock,
        _policy = policy;

  final ToastClock _clock;
  final ToastPolicy _policy;
  final Map<ToastPlacement, List<ToastEntry>> _visible = {};
  final Map<ToastPlacement, List<ToastEntry>> _queue = {};
  final List<void Function()> _listeners = [];
  int _nextId = 0;
  bool _disposed = false;

  void addListener(void Function() listener) => _listeners.add(listener);

  void removeListener(void Function() listener) => _listeners.remove(listener);

  void _notify() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  /// `dart:developer` log + `postEvent('toast_kit.lifecycle', ...)` for one
  /// entry's transition, so DevTools' timeline/logging views show every
  /// toast's life without a `print()` in the tree.
  void _logTransition(ToastEntry entry, String event) {
    developer.log(
      '$event: #${entry.id} "${entry.request.title}" (${entry.request.tone.name})',
      name: 'toast_kit',
    );
    developer.postEvent('toast_kit.lifecycle', <String, Object?>{
      'id': entry.id,
      'event': event,
      'tone': entry.request.tone.name,
      'title': entry.request.title,
      'placement': entry.placement.toString(),
      'state': entry.state.toString(),
    });
  }

  /// Toasts currently occupying a slot in [placement] (painted or about to
  /// be — see [ToastPending]).
  List<ToastEntry> visibleIn(ToastPlacement placement) =>
      List.unmodifiable(_visible[placement] ?? const <ToastEntry>[]);

  /// Toasts in [placement] waiting for a slot.
  List<ToastEntry> pendingIn(ToastPlacement placement) =>
      List.unmodifiable(_queue[placement] ?? const <ToastEntry>[]);

  /// Placements that currently hold at least one toast (visible or
  /// queued). A placement whose last toast was removed is dropped here too
  /// — otherwise the host would keep rendering (and this would keep
  /// reporting) an empty stack for every placement ever used.
  Iterable<ToastPlacement> get activePlacements => {
        for (final e in _visible.entries)
          if (e.value.isNotEmpty) e.key,
        for (final e in _queue.entries)
          if (e.value.isNotEmpty) e.key,
      };

  /// Admits [request] to [placement]. Returns a duplicate's handle
  /// unresolved if it is still within the dedupe window (see
  /// [ToastPolicy.dedupeWindow]) instead of queuing a second copy.
  ToastHandle show(ToastRequest request, {required ToastPlacement placement}) {
    if (_disposed) {
      throw StateError('show() called on a disposed ToastController.');
    }
    final dedupeKey = request.dedupeKey ?? request.defaultDedupeKey;
    final now = _clock.now();
    final duplicate = _findWithinDedupeWindow(dedupeKey, now);
    if (duplicate != null) {
      return ToastHandle(
        id: duplicate.id,
        controller: this,
        completer: Completer<ToastDismissReason>()
          ..complete(ToastDismissReason.replaced),
      );
    }

    final entry = ToastEntry(
      id: _nextId++,
      request: request,
      placement: placement,
      createdAt: now,
      dedupeKey: dedupeKey,
    );
    final visibleList = _visible.putIfAbsent(placement, () => <ToastEntry>[]);
    if (visibleList.length < _policy.maxVisiblePerPlacement) {
      visibleList.add(entry);
      _logTransition(entry, 'queued');
    } else {
      _queue.putIfAbsent(placement, () => <ToastEntry>[]).add(entry);
      _logTransition(entry, 'waiting');
    }
    _notify();
    return ToastHandle(
        id: entry.id, controller: this, completer: entry.completer);
  }

  ToastEntry? _findWithinDedupeWindow(String key, DateTime now) {
    for (final list in <List<ToastEntry>>[
      ..._visible.values,
      ..._queue.values
    ]) {
      for (final entry in list) {
        if (entry.dedupeKey == key &&
            now.difference(entry.createdAt) <= _policy.dedupeWindow) {
          return entry;
        }
      }
    }
    return null;
  }

  ToastEntry? _findById(int id) {
    for (final list in <List<ToastEntry>>[
      ..._visible.values,
      ..._queue.values
    ]) {
      for (final entry in list) {
        if (entry.id == id) return entry;
      }
    }
    return null;
  }

  /// Reported by the presentation layer once the toast has actually
  /// painted. Starts the auto-dismiss timer; a no-op if the toast was
  /// dismissed (and thus already removed) before it got here.
  ///
  /// [suppressTimer] mirrors `SnackBar`'s own accessibility behaviour: when
  /// a screen reader is active (`MediaQuery.accessibleNavigationOf`), a
  /// timed toast is treated as sticky so it is never dismissed before the
  /// user has had a chance to hear it.
  void markShown(int id, {bool suppressTimer = false}) {
    final entry = _findById(id);
    if (entry == null || entry.state is! ToastPending) return;
    entry.state = const ToastVisible();
    if (suppressTimer) {
      entry.remaining = null;
    } else {
      _startTimer(entry);
    }
    _logTransition(entry, 'shown');
    _notify();
  }

  void _startTimer(ToastEntry entry) {
    final remaining = entry.remaining;
    if (remaining == null) return; // sticky: no timer at all.
    entry.startedAt = _clock.now();
    entry.timer = _clock.scheduleOnce(remaining, () => _timeout(entry.id));
  }

  void _timeout(int id) {
    final entry = _findById(id);
    if (entry == null || entry.state is! ToastVisible) return;
    _beginLeaving(entry, ToastDismissReason.timeout);
  }

  /// Freezes the remaining time (press-and-hold). No-op unless the toast is
  /// currently visible and running.
  void pause(int id) {
    final entry = _findById(id);
    if (entry == null || entry.state is! ToastVisible) return;
    final startedAt = entry.startedAt;
    if (startedAt == null) return; // sticky, nothing to pause.
    entry.timer?.cancel();
    entry.timer = null;
    entry.startedAt = null;
    final elapsed = _clock.now().difference(startedAt);
    final remaining = entry.remaining! - elapsed;
    entry.remaining = remaining.isNegative ? Duration.zero : remaining;
  }

  /// Resumes a paused toast with its remaining time intact.
  void resume(int id) {
    final entry = _findById(id);
    if (entry == null || entry.state is! ToastVisible || entry.timer != null) {
      return;
    }
    _startTimer(entry);
  }

  /// Dismisses [id] for [reason]. A still-pending (never shown) or still-
  /// queued toast is removed outright; a visible one starts its exit
  /// animation (see [acknowledgeRemoved]).
  void dismiss(int id,
      [ToastDismissReason reason = ToastDismissReason.programmatic]) {
    for (final queue in _queue.values) {
      final index = queue.indexWhere((entry) => entry.id == id);
      if (index != -1) {
        final entry = queue.removeAt(index);
        _finish(entry, reason);
        return;
      }
    }
    final entry = _findById(id);
    if (entry == null) return;
    switch (entry.state) {
      case ToastPending():
        _remove(entry, reason);
      case ToastVisible():
        entry.timer?.cancel();
        entry.timer = null;
        _beginLeaving(entry, reason);
      case ToastLeaving():
      case ToastRemoved():
        return;
    }
  }

  void _beginLeaving(ToastEntry entry, ToastDismissReason reason) {
    entry.state = ToastLeaving(reason);
    _logTransition(entry, 'leaving');
    _notify();
  }

  /// Reported by the presentation layer once a toast's exit animation has
  /// finished: actually removes it and promotes the next queued toast.
  void acknowledgeRemoved(int id) {
    final entry = _findById(id);
    if (entry == null || entry.state is! ToastLeaving) return;
    _remove(entry, (entry.state as ToastLeaving).reason);
  }

  void _remove(ToastEntry entry, ToastDismissReason reason) {
    _visible[entry.placement]?.remove(entry);
    _finish(entry, reason);
    _promote(entry.placement);
  }

  void _finish(ToastEntry entry, ToastDismissReason reason) {
    entry.state = ToastRemoved(reason);
    if (!entry.completer.isCompleted) entry.completer.complete(reason);
    _logTransition(entry, 'removed');
    _notify();
  }

  void _promote(ToastPlacement placement) {
    final queue = _queue[placement];
    final visibleList = _visible[placement];
    if (queue == null || queue.isEmpty || visibleList == null) return;
    if (visibleList.length >= _policy.maxVisiblePerPlacement) return;
    visibleList.add(queue.removeAt(0));
  }

  /// Dismisses every active (visible or queued) toast.
  void dismissAll(
      [ToastDismissReason reason = ToastDismissReason.programmatic]) {
    for (final id in _allIds().toList(growable: false)) {
      dismiss(id, reason);
    }
  }

  Iterable<int> _allIds() sync* {
    for (final list in <List<ToastEntry>>[
      ..._visible.values,
      ..._queue.values
    ]) {
      for (final entry in list) {
        yield entry.id;
      }
    }
  }

  bool get isDisposed => _disposed;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final list in <List<ToastEntry>>[
      ..._visible.values,
      ..._queue.values
    ]) {
      for (final entry in List.of(list)) {
        entry.timer?.cancel();
        if (!entry.completer.isCompleted) {
          entry.completer.complete(ToastDismissReason.hostDisposed);
        }
      }
    }
    _visible.clear();
    _queue.clear();
    _listeners.clear();
  }
}
