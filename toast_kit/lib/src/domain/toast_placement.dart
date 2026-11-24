/// Which screen edge a toast stack anchors to.
enum ToastVerticalEdge { top, bottom }

/// Where along that edge a toast stack sits.
enum ToastHorizontalAnchor { start, center, end }

/// A resolved place on screen a toast (or a stack of toasts) is shown.
///
/// Two placements are equal when their edge and anchor match, so a
/// [ToastPlacement] can key a `Map` of per-placement queues.
final class ToastPlacement {
  const ToastPlacement({
    this.edge = ToastVerticalEdge.top,
    this.anchor = ToastHorizontalAnchor.center,
  });

  final ToastVerticalEdge edge;
  final ToastHorizontalAnchor anchor;

  static const ToastPlacement topCenter = ToastPlacement();
  static const ToastPlacement bottomCenter = ToastPlacement(
    edge: ToastVerticalEdge.bottom,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToastPlacement && other.edge == edge && other.anchor == anchor;

  @override
  int get hashCode => Object.hash(edge, anchor);

  @override
  String toString() => 'ToastPlacement(edge: $edge, anchor: $anchor)';
}
