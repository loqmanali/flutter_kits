part of '../refresh_trigger.dart';

class RefreshTriggerPhysics extends ScrollPhysics {
  const RefreshTriggerPhysics({super.parent});

  @override
  RefreshTriggerPhysics applyTo(ScrollPhysics? ancestor) {
    return RefreshTriggerPhysics(parent: buildParent(ancestor));
  }
}
