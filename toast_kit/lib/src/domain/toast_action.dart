/// Callback shape used by [ToastAction] and the close button, kept local so
/// this layer never needs `dart:ui`'s `VoidCallback`.
typedef ToastCallback = void Function();

/// An optional inline action a toast offers, e.g. "Undo".
final class ToastAction {
  const ToastAction({required this.label, required this.onPressed});

  final String label;
  final ToastCallback onPressed;
}
