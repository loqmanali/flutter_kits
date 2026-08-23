import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part 'refresh_trigger/theme.dart';
part 'refresh_trigger/stage.dart';
part 'refresh_trigger/trigger.dart';
part 'refresh_trigger/default_indicator.dart';
part 'refresh_trigger/pill_indicator.dart';
part 'refresh_trigger/animated_value_builder.dart';
part 'refresh_trigger/physics.dart';

typedef RefreshIndicatorBuilder = Widget Function(
  BuildContext context,
  RefreshTriggerStage stage,
);

typedef FutureVoidCallback = Future<void> Function();
