import 'package:flutter/material.dart';

import 'indicators/indicator_params.dart';

/// Controls when item labels are rendered.
enum NavigationLabelBehavior {
  /// Always render the label below the icon.
  alwaysShow,

  /// Never render the label.
  alwaysHide,

  /// Render the label only for the currently selected item.
  onlyShowSelected,
}

/// Callback fired when the user selects a destination.
///
/// [index] is the zero-based index of the selected item in the
/// `items` list passed to the navigation bar.
typedef DestinationSelected = void Function(int index);

/// Builder for a fully custom indicator widget.
///
/// Receives a [IndicatorParams] containing all geometry and animation data
/// needed to paint a custom indicator (current/previous index, item width,
/// active color, animation, RTL flag).
typedef IndicatorBuilder = Widget Function(
  BuildContext context,
  IndicatorParams params,
);
