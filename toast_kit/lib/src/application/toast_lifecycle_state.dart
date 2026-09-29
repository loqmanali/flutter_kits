import '../domain/toast_dismiss_reason.dart';

/// A toast's place in its life, from being queued to being gone.
///
/// `Pending` → `Visible` → `Leaving` → `Removed`. A toast can also go
/// straight from `Pending` to `Removed` if it is dismissed (or evicted)
/// before the presentation layer ever painted it — see
/// `ToastController.markShown`.
sealed class ToastLifecycleState {
  const ToastLifecycleState();
}

/// Allocated a slot in its placement, but the presentation layer has not
/// yet reported (`markShown`) that it was painted. No timer runs yet.
final class ToastPending extends ToastLifecycleState {
  const ToastPending();

  @override
  String toString() => 'ToastPending';
}

/// Painted at least once; its auto-dismiss timer (if any) is running or
/// paused.
final class ToastVisible extends ToastLifecycleState {
  const ToastVisible();

  @override
  String toString() => 'ToastVisible';
}

/// Dismissed; playing its exit animation. Removed once the presentation
/// layer calls `ToastController.acknowledgeRemoved`.
final class ToastLeaving extends ToastLifecycleState {
  const ToastLeaving(this.reason);

  final ToastDismissReason reason;

  @override
  String toString() => 'ToastLeaving($reason)';
}

/// Terminal: gone from every queue.
final class ToastRemoved extends ToastLifecycleState {
  const ToastRemoved(this.reason);

  final ToastDismissReason reason;

  @override
  String toString() => 'ToastRemoved($reason)';
}
