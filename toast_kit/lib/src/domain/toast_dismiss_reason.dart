/// Why a toast stopped being shown, mirroring `SnackBarClosedReason`
/// (`package:flutter/src/material/snack_bar.dart`) but widened for the
/// cases this kit adds: a queue overflow that replaces a toast, and the
/// host itself going away.
enum ToastDismissReason {
  /// The toast's timer expired.
  timeout,

  /// The user tapped the close button.
  closeButton,

  /// The user swiped the toast away.
  swipe,

  /// The user tapped the toast body (when `dismissible` policy allows tap).
  tap,

  /// The user tapped the toast's action.
  action,

  /// [ToastHandle.dismiss] or [ToastController.dismiss] was called directly.
  programmatic,

  /// The toast was still pending (never shown) and got evicted because a
  /// higher-priority toast or the placement's `maxVisiblePerPlacement`
  /// policy replaced it.
  replaced,

  /// The [ToastHost] that owned the toast was disposed while it was active.
  hostDisposed,
}
