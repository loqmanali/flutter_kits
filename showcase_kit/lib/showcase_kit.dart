/// Coach-marks / product tour for Flutter.
///
/// Wrap the widgets you want to highlight in [ShowcaseTarget], describe them
/// as [ShowcaseStep]s, then call [useShowcaseTour] to get a controller:
///
/// ```dart
/// final steps = useMemoized(() => [
///   ShowcaseStep(key: GlobalKey(), title: 'Search', body: 'Find an order'),
/// ]);
/// final tour = useShowcaseTour(steps);
/// // ... tour.start();
/// ```
library;

export 'src/showcase_step.dart';
export 'src/showcase_target.dart';
export 'src/spotlight_navigator.dart';
export 'src/tour_config.dart';
export 'src/tour_labels.dart';
export 'src/tour_manager.dart';
export 'src/tour_theme.dart';
export 'src/use_showcase_tour.dart';
