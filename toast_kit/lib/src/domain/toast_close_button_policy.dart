/// When a toast shows its close (X) button.
///
/// ponytail: a closed three-value enum covers every request seen in the
/// brief (always / never / sticky-only); widen only if a real caller needs a
/// fourth policy.
enum ToastCloseButtonPolicy {
  /// Always show the close button.
  always,

  /// Never show the close button; the toast is dismissed by its timer,
  /// swipe, tap or an explicit [ToastHandle.dismiss] only.
  never,

  /// Show the close button only for sticky toasts (`duration == null`),
  /// since those have no other way to time out.
  whenSticky,
}
