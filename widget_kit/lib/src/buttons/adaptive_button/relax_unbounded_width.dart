part of 'adaptive_button.dart';

/// A single-child render box that neutralises an unbounded incoming width
/// before it reaches the child.
///
/// When the maximum incoming width is infinite, the child is laid out with
/// `maxWidth` loosened to its own minimum-intrinsic width (so a button whose
/// style demands `minimumSize.width == infinity` shrink-wraps instead of being
/// forced to an infinite, crashing layout). When the incoming width is bounded
/// the constraints are passed through untouched, so existing layouts are
/// pixel-identical. All intrinsic-dimension and dry-layout queries are
/// delegated to the child, so this widget is safe inside IntrinsicWidth /
/// IntrinsicHeight (unlike LayoutBuilder).
class _RelaxUnboundedWidth extends SingleChildRenderObjectWidget {
  const _RelaxUnboundedWidth({required Widget super.child});

  @override
  _RenderRelaxUnboundedWidth createRenderObject(BuildContext context) =>
      _RenderRelaxUnboundedWidth();
}

class _RenderRelaxUnboundedWidth extends RenderProxyBox {
  BoxConstraints _resolve(BoxConstraints constraints) {
    if (constraints.maxWidth != double.infinity) return constraints;
    final child = this.child;
    final intrinsic =
        child == null ? 0.0 : child.getMinIntrinsicWidth(constraints.maxHeight);
    // Loosen to the child's natural width so the button shrink-wraps; clamp to
    // the (possibly non-zero) incoming minWidth to stay a valid constraint.
    final maxWidth = math.max(intrinsic, constraints.minWidth);
    return constraints.copyWith(maxWidth: maxWidth);
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_resolve(constraints), parentUsesSize: true);
    size = child.size;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    return child.getDryLayout(_resolve(constraints));
  }
}
