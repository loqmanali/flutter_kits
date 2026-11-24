import 'package:flutter/widgets.dart';

/// Scroll physics that lets the user overscroll freely so the trigger can grow
/// past the boundary on platforms that would otherwise clamp it.
class RefreshTriggerPhysics extends ScrollPhysics {
  const RefreshTriggerPhysics({super.parent});

  @override
  RefreshTriggerPhysics applyTo(ScrollPhysics? ancestor) {
    return RefreshTriggerPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset;
  }
}
