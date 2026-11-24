import 'package:flutter/foundation.dart';

/// Button copy for the spotlight bubble.
///
/// The package ships no localisation: a localised app passes its own strings
/// (e.g. `TourLabels(skip: l10n.skip, previous: l10n.previous, next: l10n.next)`).
@immutable
class TourLabels {
  const TourLabels({
    this.skip = 'Skip',
    this.previous = 'Prev',
    this.next = 'Next',
    this.done = 'Done',
  });

  final String skip;
  final String previous;

  /// Shown on every step but the last.
  final String next;

  /// Shown instead of [next] on the last step.
  final String done;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TourLabels &&
          skip == other.skip &&
          previous == other.previous &&
          next == other.next &&
          done == other.done;

  @override
  int get hashCode => Object.hash(skip, previous, next, done);
}
