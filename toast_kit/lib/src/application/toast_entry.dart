import 'dart:async';

import '../domain/toast_clock.dart';
import '../domain/toast_dismiss_reason.dart';
import '../domain/toast_placement.dart';
import '../domain/toast_request.dart';
import 'toast_lifecycle_state.dart';

/// A [ToastRequest] once it has been admitted to a [ToastController]: an
/// id, a resolved placement and its lifecycle.
///
/// Mutable by design — the controller is the only writer, mirroring the
/// framework's own imperative animation/ticker state rather than the
/// immutable value types in `domain/`.
final class ToastEntry {
  ToastEntry({
    required this.id,
    required this.request,
    required this.placement,
    required this.createdAt,
    required this.dedupeKey,
  })  : state = const ToastPending(),
        remaining = request.duration;

  final int id;
  final ToastRequest request;
  final ToastPlacement placement;
  final DateTime createdAt;
  final String dedupeKey;

  ToastLifecycleState state;

  /// Time left before auto-dismiss; `null` for a sticky toast. Frozen while
  /// paused.
  Duration? remaining;

  DateTime? startedAt;
  ToastCancellable? timer;
  final Completer<ToastDismissReason> completer =
      Completer<ToastDismissReason>();
}
