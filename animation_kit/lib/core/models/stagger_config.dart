import 'package:equatable/equatable.dart';

import '../enums/animation_curve.dart';
import '../enums/stagger_direction.dart';

/// Stagger Configuration
///
/// Defines configuration for staggered animations.
/// Used with staggered list/grid views to control animation flow.
///
/// ## Examples
///
/// ```dart
/// // Basic stagger configuration
/// final config = StaggerConfig(
///   direction: StaggerDirection.forward,
///   delay: Duration(milliseconds: 50),
///   duration: Duration(milliseconds: 300),
///   curve: AnimationCurve.easeInOut,
/// );
///
/// // Using with staggered list view
/// StaggeredListView(
///   staggerConfig: config,
///   children: items,
/// )
///
/// // Using with staggered grid view
/// StaggeredGridView(
///   staggerConfig: config,
///   children: items,
/// )
/// ```
class StaggerConfig extends Equatable {
  /// Direction of stagger animation
  ///
  /// Determines order in which items animate.
  /// See [StaggerDirection] for available options.
  final StaggerDirection direction;

  /// Delay between consecutive item animations
  ///
  /// Time to wait before animating next item.
  /// Default is 50 milliseconds.
  final Duration delay;

  /// Duration of each item animation
  ///
  /// How long each item's animation takes.
  /// Default is 300 milliseconds.
  final Duration duration;

  /// Animation easing curve
  ///
  /// Controls speed progression of each item animation.
  /// See [AnimationCurve] for available options.
  /// Default is [AnimationCurve.easeInOut].
  final AnimationCurve curve;

  /// Whether to animate items in reverse order
  ///
  /// If true, items animate in reverse order.
  /// Default is false.
  final bool reverse;

  /// Whether to animate items from center outward
  ///
  /// If true, items animate starting from center.
  /// Default is false.
  final bool fromCenter;

  /// Creates a default stagger configuration
  ///
  /// Creates a config with sensible defaults:
  /// - direction: [StaggerDirection.forward]
  /// - delay: 50ms
  /// - duration: 300ms
  /// - curve: [AnimationCurve.easeInOut]
  const StaggerConfig({
    this.direction = StaggerDirection.forward,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
    this.curve = AnimationCurve.easeInOut,
    this.reverse = false,
    this.fromCenter = false,
  });

  /// Creates a forward stagger configuration
  ///
  /// Convenience constructor for forward direction.
  factory StaggerConfig.forward({
    Duration delay = const Duration(milliseconds: 50),
    Duration duration = const Duration(milliseconds: 300),
    AnimationCurve curve = AnimationCurve.easeInOut,
  }) {
    return StaggerConfig(
      delay: delay,
      duration: duration,
      curve: curve,
    );
  }

  /// Creates a reverse stagger configuration
  ///
  /// Convenience constructor for reverse direction.
  factory StaggerConfig.reverse({
    Duration delay = const Duration(milliseconds: 50),
    Duration duration = const Duration(milliseconds: 300),
    AnimationCurve curve = AnimationCurve.easeInOut,
  }) {
    return StaggerConfig(
      direction: StaggerDirection.reverse,
      delay: delay,
      duration: duration,
      curve: curve,
      reverse: true,
    );
  }

  /// Creates a from-center stagger configuration
  ///
  /// Convenience constructor for from-center direction.
  factory StaggerConfig.fromCenter({
    Duration delay = const Duration(milliseconds: 30),
    Duration duration = const Duration(milliseconds: 300),
    AnimationCurve curve = AnimationCurve.easeInOut,
  }) {
    return StaggerConfig(
      direction: StaggerDirection.fromCenter,
      delay: delay,
      duration: duration,
      curve: curve,
      fromCenter: true,
    );
  }

  /// Creates a copy of this configuration with updated values
  ///
  /// Returns a new [StaggerConfig] with specified fields replaced.
  StaggerConfig copyWith({
    StaggerDirection? direction,
    Duration? delay,
    Duration? duration,
    AnimationCurve? curve,
    bool? reverse,
    bool? fromCenter,
  }) {
    return StaggerConfig(
      direction: direction ?? this.direction,
      delay: delay ?? this.delay,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      reverse: reverse ?? this.reverse,
      fromCenter: fromCenter ?? this.fromCenter,
    );
  }

  @override
  List<Object?> get props => [
        direction,
        delay,
        duration,
        curve,
        reverse,
        fromCenter,
      ];

  /// Returns total animation duration for all items
  ///
  /// Calculates total time for [itemCount] items to complete.
  Duration totalDuration(int itemCount) {
    if (itemCount <= 0) {
      return Duration.zero;
    }
    final lastItemDelay = direction.getDelay(
      index: itemCount - 1,
      itemCount: itemCount,
      baseDelay: delay,
    );
    return (duration * itemCount) + lastItemDelay;
  }

  /// Returns a string representation of this config
  ///
  /// Useful for debugging and logging.
  String toDebugString() {
    final buffer = StringBuffer('StaggerConfig(');
    buffer.write('direction: ${direction.displayName}');
    buffer.write(', delay: ${delay.inMilliseconds}ms');
    buffer.write(', duration: ${duration.inMilliseconds}ms');
    buffer.write(', curve: ${curve.displayName}');
    buffer.write(')');
    return buffer.toString();
  }

  @override
  String toString() =>
      'StaggerConfig(direction: ${direction.displayName}, delay: ${delay.inMilliseconds}ms)';
}
