/// Queueing rules shared by every placement in a [ToastController].
final class ToastPolicy {
  const ToastPolicy({
    this.dedupeWindow = const Duration(milliseconds: 1500),
    this.maxVisiblePerPlacement = 3,
  });

  /// A request whose dedupe key matches a toast shown (or still pending)
  /// within this window is dropped rather than queued again.
  final Duration dedupeWindow;

  /// How many toasts a single placement shows at once; the rest wait in
  /// that placement's queue.
  final int maxVisiblePerPlacement;

  static const ToastPolicy fallback = ToastPolicy();
}
