import 'package:flutter/material.dart';

/// Localization helpers for `widget_kit`.
///
/// The kit does not own translation strings — it only needs to know if the
/// current text direction is RTL. We read this from [Directionality], which
/// any properly configured Flutter app already provides via `MaterialApp`.
extension WidgetKitDirectionality on BuildContext {
  /// `true` when the surrounding [Directionality] is RTL.
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}

/// Container for user-supplied strings used by interactive `widget_kit`
/// widgets (e.g. dialog confirm/cancel labels, error retry button, search
/// hints in the country picker).
///
/// Pass overrides per-widget; sensible English defaults are used otherwise.
class WidgetKitStrings {
  final String confirm;
  final String cancel;
  final String retry;
  final String search;
  final String done;
  final String noResults;

  const WidgetKitStrings({
    this.confirm = 'Confirm',
    this.cancel = 'Cancel',
    this.retry = 'Retry',
    this.search = 'Search',
    this.done = 'Done',
    this.noResults = 'No results',
  });

  static const WidgetKitStrings fallback = WidgetKitStrings();
}
