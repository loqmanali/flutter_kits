import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'showcase_step.dart';
import 'tour_config.dart';
import 'tour_labels.dart';
import 'tour_manager.dart';
import 'tour_theme.dart';

/// Starts and stops a tour. Returned by [useShowcaseTour].
class ShowcaseController {
  const ShowcaseController(this._manager);

  final TourManager _manager;

  /// Shows the first step. Call it after the first frame, once the targets
  /// exist — e.g. from `WidgetsBinding.instance.addPostFrameCallback`.
  void start() => _manager.start();

  /// Ends the tour and removes the spotlight.
  void stop() => _manager.skip();

  /// Whether a spotlight is currently on screen.
  bool get isRunning => _manager.isRunning;
}

/// Creates a tour tied to the lifetime of the calling widget: when it is
/// removed the spotlight and any auto-play timer go with it.
///
/// [steps] is read once — keep it stable (`useMemoized`) rather than rebuilding
/// the list each frame.
ShowcaseController useShowcaseTour(
  List<ShowcaseStep> steps, {
  bool autoPlay = false,
  Duration autoPlayDelay = const Duration(seconds: 3),
  TourTheme theme = const TourTheme(),
  TourLabels labels = const TourLabels(),
}) {
  final overlay = Overlay.of(useContext(), rootOverlay: true);
  final manager = useMemoized(
    () => TourManager(
      steps,
      overlay,
      TourConfig(
        auto: autoPlay,
        delay: autoPlayDelay,
        theme: theme,
        labels: labels,
      ),
    ),
    [overlay],
  );
  useEffect(() => manager.dispose, [manager]);
  return ShowcaseController(manager);
}
