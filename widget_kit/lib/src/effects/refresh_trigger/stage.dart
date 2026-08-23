part of '../refresh_trigger.dart';

/// ===============================
/// PUBLIC API
/// ===============================

enum TriggerStage { idle, pulling, refreshing, completed }

class RefreshTriggerStage {
  final TriggerStage stage;
  final Animation<double> extent;
  final Axis direction;
  final bool reverse;

  const RefreshTriggerStage(
    this.stage,
    this.extent,
    this.direction,
    this.reverse,
  );

  double get extentValue => extent.value;
}
