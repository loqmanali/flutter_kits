import 'package:flutter/widgets.dart';

/// Configuration for overlay content on carousel items.
///
/// Use this class to add text, buttons, or other widgets
/// on top of carousel images.
class CarouselOverlay {
  /// Main title text.
  final String? title;

  /// Subtitle or description text.
  final String? subtitle;

  /// Custom style for title text.
  final TextStyle? titleStyle;

  /// Custom style for subtitle text.
  final TextStyle? subtitleStyle;

  /// Maximum lines for title.
  final int titleMaxLines;

  /// Maximum lines for subtitle.
  final int subtitleMaxLines;

  /// Trailing widget (e.g., button, price tag).
  final Widget? trailing;

  /// Leading widget (e.g., icon, badge).
  final Widget? leading;

  /// Custom gradient for the overlay background.
  final Gradient? gradient;

  /// Opacity of the default gradient overlay.
  final double gradientOpacity;

  /// Padding around the overlay content.
  final EdgeInsets padding;

  /// Alignment of the overlay content.
  final MainAxisAlignment mainAxisAlignment;

  /// Cross-axis alignment of the overlay content.
  final CrossAxisAlignment crossAxisAlignment;

  const CarouselOverlay({
    this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.titleMaxLines = 2,
    this.subtitleMaxLines = 1,
    this.trailing,
    this.leading,
    this.gradient,
    this.gradientOpacity = 0.6,
    this.padding = const EdgeInsets.all(16.0),
    this.mainAxisAlignment = MainAxisAlignment.end,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// Creates a copy with the given fields replaced.
  CarouselOverlay copyWith({
    String? title,
    String? subtitle,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    int? titleMaxLines,
    int? subtitleMaxLines,
    Widget? trailing,
    Widget? leading,
    Gradient? gradient,
    double? gradientOpacity,
    EdgeInsets? padding,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    return CarouselOverlay(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      titleMaxLines: titleMaxLines ?? this.titleMaxLines,
      subtitleMaxLines: subtitleMaxLines ?? this.subtitleMaxLines,
      trailing: trailing ?? this.trailing,
      leading: leading ?? this.leading,
      gradient: gradient ?? this.gradient,
      gradientOpacity: gradientOpacity ?? this.gradientOpacity,
      padding: padding ?? this.padding,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
    );
  }

  /// Preset: Simple title overlay.
  static CarouselOverlay simpleTitle(String title) => CarouselOverlay(
        title: title,
      );

  /// Preset: Title with subtitle.
  static CarouselOverlay titleWithSubtitle(String title, String subtitle) =>
      CarouselOverlay(
        title: title,
        subtitle: subtitle,
      );

  /// Preset: Centered content.
  static CarouselOverlay centered({
    String? title,
    String? subtitle,
    Widget? trailing,
  }) =>
      CarouselOverlay(
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      );
}
