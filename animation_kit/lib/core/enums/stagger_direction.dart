/// Stagger Direction
///
/// Defines the direction of staggered animations.
/// Used with staggered list/grid views to control animation flow.
///
/// ## Examples
///
/// ```dart
/// // Staggered list view with forward direction
/// StaggeredListView(
///   staggerConfig: StaggerConfig(
///     direction: StaggerDirection.forward,
///     delay: Duration(milliseconds: 50),
///   ),
///   children: items,
/// )
///
/// // Staggered grid view with reverse direction
/// StaggeredGridView(
///   staggerConfig: StaggerConfig(
///     direction: StaggerDirection.reverse,
///     delay: Duration(milliseconds: 50),
///   ),
///   children: items,
/// )
/// ```
///
/// ## Direction Types
///
/// - **forward**: Items animate from first to last
/// - **reverse**: Items animate from last to first
/// - **fromCenter**: Items animate from center outward
enum StaggerDirection {
  /// Forward - animate from first to last
  ///
  /// Items animate in order from index 0 to end.
  /// First item starts animation, then second, and so on.
  ///
  /// Example:
  /// ```dart
  /// StaggeredListView(
  ///   staggerConfig: StaggerConfig(
  ///     direction: StaggerDirection.forward,
  ///     delay: Duration(milliseconds: 50),
  ///   ),
  ///   children: items,
  /// )
  /// ```
  forward,

  /// Reverse - animate from last to first
  ///
  /// Items animate in reverse order from end to index 0.
  /// Last item starts animation, then second to last, and so on.
  ///
  /// Example:
  /// ```dart
  /// StaggeredListView(
  ///   staggerConfig: StaggerConfig(
  ///     direction: StaggerDirection.reverse,
  ///     delay: Duration(milliseconds: 50),
  ///   ),
  ///   children: items,
  /// )
  /// ```
  reverse,

  /// From Center - animate from center outward
  ///
  /// Items animate starting from the center and moving outward.
  /// Middle items start first, then items on either side.
  ///
  /// Example:
  /// ```dart
  /// StaggeredGridView(
  ///   staggerConfig: StaggerConfig(
  ///     direction: StaggerDirection.fromCenter,
  ///     delay: Duration(milliseconds: 30),
  ///   ),
  ///   children: items,
  /// )
  /// ```
  fromCenter,
}

/// Extension methods for [StaggerDirection]
extension StaggerDirectionExtension on StaggerDirection {
  /// Returns delay for given index and total count
  ///
  /// Calculates the delay for an item at [index] based on
  /// the stagger direction and total [itemCount].
  ///
  /// Example:
  /// ```dart
  /// final direction = StaggerDirection.forward;
  /// final delay = direction.getDelay(index: 2, itemCount: 5, baseDelay: 50);
  /// // Returns: 100 (2 * 50ms)
  /// ```
  Duration getDelay({
    required int index,
    required int itemCount,
    required Duration baseDelay,
  }) {
    switch (this) {
      case StaggerDirection.forward:
        return Duration(
          milliseconds: baseDelay.inMilliseconds * index,
        );

      case StaggerDirection.reverse:
        return Duration(
          milliseconds: baseDelay.inMilliseconds * (itemCount - 1 - index),
        );

      case StaggerDirection.fromCenter:
        final centerIndex = (itemCount - 1) / 2;
        final distanceFromCenter = (index - centerIndex).abs();
        return Duration(
          milliseconds: (baseDelay.inMilliseconds * distanceFromCenter).toInt(),
        );
    }
  }

  /// Returns animation order for given index and total count
  ///
  /// Returns the order in which item at [index] should animate
  /// based on stagger direction and total [itemCount].
  ///
  /// Example:
  /// ```dart
  /// final direction = StaggerDirection.reverse;
  /// final order = direction.getOrder(index: 2, itemCount: 5);
  /// // Returns: 2 (in reverse order, index 2 animates 2nd)
  /// ```
  int getOrder({
    required int index,
    required int itemCount,
  }) {
    switch (this) {
      case StaggerDirection.forward:
        return index;

      case StaggerDirection.reverse:
        return itemCount - 1 - index;

      case StaggerDirection.fromCenter:
        final centerIndex = (itemCount - 1) / 2;
        final distanceFromCenter = (index - centerIndex).abs();
        return distanceFromCenter.toInt();
    }
  }

  /// Returns true if this is a linear direction
  ///
  /// Linear directions include forward and reverse.
  bool get isLinear {
    switch (this) {
      case StaggerDirection.forward:
      case StaggerDirection.reverse:
        return true;
      case StaggerDirection.fromCenter:
        return false;
    }
  }

  /// Returns true if this is a radial direction
  ///
  /// Radial directions include fromCenter.
  bool get isRadial {
    switch (this) {
      case StaggerDirection.fromCenter:
        return true;
      case StaggerDirection.forward:
      case StaggerDirection.reverse:
        return false;
    }
  }

  /// Returns a human-readable name for stagger direction
  String get displayName {
    switch (this) {
      case StaggerDirection.forward:
        return 'Forward';
      case StaggerDirection.reverse:
        return 'Reverse';
      case StaggerDirection.fromCenter:
        return 'From Center';
    }
  }

  /// Returns a description of stagger direction
  String get description {
    switch (this) {
      case StaggerDirection.forward:
        return 'Items animate from first to last';
      case StaggerDirection.reverse:
        return 'Items animate from last to first';
      case StaggerDirection.fromCenter:
        return 'Items animate from center outward';
    }
  }

  /// Returns the opposite direction
  ///
  /// Returns the opposite stagger direction.
  /// Useful for reversing animations.
  StaggerDirection get reverse {
    switch (this) {
      case StaggerDirection.forward:
        return StaggerDirection.reverse;
      case StaggerDirection.reverse:
        return StaggerDirection.forward;
      case StaggerDirection.fromCenter:
        return StaggerDirection.fromCenter;
    }
  }
}
