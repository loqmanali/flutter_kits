import 'package:flutter/widgets.dart';

/// Look of the spotlight: the dimmed backdrop, the cut-out around the target
/// and the pulsing ring. Everything else (bubble surface, text, buttons) comes
/// from the ambient [Theme] so the tour follows the host app.
@immutable
class TourTheme {
  const TourTheme({
    this.overlay = const Color.fromRGBO(0, 0, 0, .65),
    this.radius = 12,
    this.padding = 24,
    this.ring = const Color(0xFFFFFFFF),
  });

  /// Colour painted over everything except the cut-out.
  final Color overlay;

  /// Corner radius of the cut-out and of the info bubble.
  final double radius;

  /// Extra space left around the target inside the cut-out.
  final double padding;

  /// Colour of the ring that pulses around the target.
  final Color ring;

  TourTheme copyWith({
    Color? overlay,
    double? radius,
    double? padding,
    Color? ring,
  }) {
    return TourTheme(
      overlay: overlay ?? this.overlay,
      radius: radius ?? this.radius,
      padding: padding ?? this.padding,
      ring: ring ?? this.ring,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TourTheme &&
          overlay == other.overlay &&
          radius == other.radius &&
          padding == other.padding &&
          ring == other.ring;

  @override
  int get hashCode => Object.hash(overlay, radius, padding, ring);
}
