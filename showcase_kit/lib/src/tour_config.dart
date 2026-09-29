import 'package:flutter/foundation.dart';

import 'tour_labels.dart';
import 'tour_theme.dart';

/// Everything the tour needs beyond the steps themselves.
@immutable
class TourConfig {
  const TourConfig({
    this.auto = false,
    this.delay = const Duration(seconds: 3),
    this.theme = const TourTheme(),
    this.labels = const TourLabels(),
  });

  /// Advance on a timer instead of waiting for a tap.
  final bool auto;

  /// How long each step stays up when [auto] is set.
  final Duration delay;

  final TourTheme theme;
  final TourLabels labels;

  TourConfig copyWith({
    bool? auto,
    Duration? delay,
    TourTheme? theme,
    TourLabels? labels,
  }) {
    return TourConfig(
      auto: auto ?? this.auto,
      delay: delay ?? this.delay,
      theme: theme ?? this.theme,
      labels: labels ?? this.labels,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TourConfig &&
          auto == other.auto &&
          delay == other.delay &&
          theme == other.theme &&
          labels == other.labels;

  @override
  int get hashCode => Object.hash(auto, delay, theme, labels);
}
