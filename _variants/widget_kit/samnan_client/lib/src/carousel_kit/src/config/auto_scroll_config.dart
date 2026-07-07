/// Configuration for automatic carousel scrolling behavior.
///
/// Use this class to enable and customize automatic page transitions
/// in the carousel.
class AutoScrollConfig {
  /// Whether auto-scroll is enabled.
  final bool enabled;

  /// Interval between automatic page transitions.
  final Duration interval;

  /// Whether to pause auto-scroll when user interacts with the carousel.
  final bool pauseOnInteraction;

  /// Duration to pause auto-scroll after user interaction.
  final Duration pauseDuration;

  /// Whether to loop back to the first item after reaching the last.
  final bool loop;

  /// Whether to reverse the auto-scroll direction.
  final bool reverse;

  const AutoScrollConfig({
    this.enabled = false,
    this.interval = const Duration(seconds: 5),
    this.pauseOnInteraction = true,
    this.pauseDuration = const Duration(seconds: 3),
    this.loop = true,
    this.reverse = false,
  });

  /// Creates a copy with the given fields replaced.
  AutoScrollConfig copyWith({
    bool? enabled,
    Duration? interval,
    bool? pauseOnInteraction,
    Duration? pauseDuration,
    bool? loop,
    bool? reverse,
  }) {
    return AutoScrollConfig(
      enabled: enabled ?? this.enabled,
      interval: interval ?? this.interval,
      pauseOnInteraction: pauseOnInteraction ?? this.pauseOnInteraction,
      pauseDuration: pauseDuration ?? this.pauseDuration,
      loop: loop ?? this.loop,
      reverse: reverse ?? this.reverse,
    );
  }

  /// Preset: Fast auto-scroll (3 seconds interval).
  static const fast = AutoScrollConfig(
    enabled: true,
    interval: Duration(seconds: 3),
  );

  /// Preset: Normal auto-scroll (5 seconds interval).
  static const normal = AutoScrollConfig(enabled: true);

  /// Preset: Slow auto-scroll (8 seconds interval).
  static const slow = AutoScrollConfig(
    enabled: true,
    interval: Duration(seconds: 8),
  );

  /// Preset: Disabled auto-scroll.
  static const disabled = AutoScrollConfig();
}
