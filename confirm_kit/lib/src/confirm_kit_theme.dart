import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'confirm_enums.dart';
import 'confirm_strings.dart';

/// App-wide defaults for every `confirm_kit` surface.
///
/// Register once on your `ThemeData` and stop passing styling to individual
/// dialogs. Anything you pass on a dialog still wins over the theme.
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData.light().copyWith(
///     extensions: const [
///       ConfirmKitTheme(
///         borderRadius: 20,
///         destructiveColor: Color(0xFFD53B3B),
///         actionBorderRadius: 12,
///       ),
///     ],
///   ),
/// );
/// ```
///
/// Every field is nullable: unset fields fall back to [fallback], and colors
/// that are still unset fall back to the ambient `ColorScheme`.
@immutable
class ConfirmKitTheme extends ThemeExtension<ConfirmKitTheme> {
  const ConfirmKitTheme({
    this.borderRadius,
    this.backgroundColor,
    this.elevation,
    this.insetPadding,
    this.contentPadding,
    this.maxWidth,
    this.iconSize,
    this.iconBackground,
    this.iconBackgroundOpacity,
    this.titleStyle,
    this.messageStyle,
    this.actionHeight,
    this.actionBorderRadius,
    this.actionSpacing,
    this.neutralColor,
    this.primaryColor,
    this.destructiveColor,
    this.successColor,
    this.warningColor,
    this.infoColor,
    this.strings,
  });

  // ---- Surface ----
  /// Corner radius of the dialog, or of the sheet's top corners.
  final double? borderRadius;
  final Color? backgroundColor;
  final double? elevation;

  /// Space kept between the dialog and the screen edges.
  final EdgeInsets? insetPadding;

  /// Padding around the icon/title/message/actions block.
  final EdgeInsetsGeometry? contentPadding;

  /// Upper bound on the content width, so the dialog stays readable on
  /// tablets and desktop.
  final double? maxWidth;

  // ---- Icon ----
  final double? iconSize;

  /// Whether the icon sits inside a tinted circle.
  final bool? iconBackground;

  /// Opacity of that tinted circle.
  final double? iconBackgroundOpacity;

  // ---- Text ----
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;

  // ---- Actions ----
  final double? actionHeight;
  final double? actionBorderRadius;

  /// Gap between two action buttons, in either layout.
  final double? actionSpacing;

  // ---- Intent colors ----
  final Color? neutralColor;
  final Color? primaryColor;
  final Color? destructiveColor;
  final Color? successColor;
  final Color? warningColor;
  final Color? infoColor;

  /// Default button labels. See [ConfirmStrings].
  final ConfirmStrings? strings;

  /// Values used for anything the app has not overridden.
  static const ConfirmKitTheme fallback = ConfirmKitTheme(
    borderRadius: 20,
    elevation: 8,
    insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    contentPadding: EdgeInsets.all(20),
    maxWidth: 420,
    iconSize: 28,
    iconBackground: true,
    iconBackgroundOpacity: 0.12,
    actionHeight: 48,
    actionBorderRadius: 12,
    actionSpacing: 12,
    strings: ConfirmStrings.fallback,
  );

  /// The effective theme: [fallback] with the app's extension layered on top.
  static ConfirmKitTheme of(BuildContext context) =>
      fallback.merge(Theme.of(context).extension<ConfirmKitTheme>());

  /// Accent color for [intent], falling back to roles on [scheme].
  Color colorFor(ConfirmIntent intent, ColorScheme scheme) => switch (intent) {
        ConfirmIntent.neutral => neutralColor ?? scheme.onSurface,
        ConfirmIntent.primary => primaryColor ?? scheme.primary,
        ConfirmIntent.destructive => destructiveColor ?? scheme.error,
        // Success and warning are semantic, not brand: green means "done" and
        // amber means "careful" in every app, the way an error is red. The
        // ColorScheme has no role for either, so they need a literal default.
        ConfirmIntent.success => successColor ?? const Color(0xFF2E7D32),
        ConfirmIntent.warning => warningColor ?? const Color(0xFFE8A33D),
        ConfirmIntent.info => infoColor ?? scheme.tertiary,
      };

  /// Readable foreground for a filled button painted in [background].
  static Color onColor(Color background) =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark
          ? Colors.white
          : Colors.black;

  /// Returns this theme with every non-null field of [other] applied on top.
  ConfirmKitTheme merge(ConfirmKitTheme? other) {
    if (other == null) return this;
    return copyWith(
      borderRadius: other.borderRadius,
      backgroundColor: other.backgroundColor,
      elevation: other.elevation,
      insetPadding: other.insetPadding,
      contentPadding: other.contentPadding,
      maxWidth: other.maxWidth,
      iconSize: other.iconSize,
      iconBackground: other.iconBackground,
      iconBackgroundOpacity: other.iconBackgroundOpacity,
      titleStyle: other.titleStyle,
      messageStyle: other.messageStyle,
      actionHeight: other.actionHeight,
      actionBorderRadius: other.actionBorderRadius,
      actionSpacing: other.actionSpacing,
      neutralColor: other.neutralColor,
      primaryColor: other.primaryColor,
      destructiveColor: other.destructiveColor,
      successColor: other.successColor,
      warningColor: other.warningColor,
      infoColor: other.infoColor,
      strings: other.strings,
    );
  }

  @override
  ConfirmKitTheme copyWith({
    double? borderRadius,
    Color? backgroundColor,
    double? elevation,
    EdgeInsets? insetPadding,
    EdgeInsetsGeometry? contentPadding,
    double? maxWidth,
    double? iconSize,
    bool? iconBackground,
    double? iconBackgroundOpacity,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    double? actionHeight,
    double? actionBorderRadius,
    double? actionSpacing,
    Color? neutralColor,
    Color? primaryColor,
    Color? destructiveColor,
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    ConfirmStrings? strings,
  }) {
    return ConfirmKitTheme(
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      insetPadding: insetPadding ?? this.insetPadding,
      contentPadding: contentPadding ?? this.contentPadding,
      maxWidth: maxWidth ?? this.maxWidth,
      iconSize: iconSize ?? this.iconSize,
      iconBackground: iconBackground ?? this.iconBackground,
      iconBackgroundOpacity:
          iconBackgroundOpacity ?? this.iconBackgroundOpacity,
      titleStyle: titleStyle ?? this.titleStyle,
      messageStyle: messageStyle ?? this.messageStyle,
      actionHeight: actionHeight ?? this.actionHeight,
      actionBorderRadius: actionBorderRadius ?? this.actionBorderRadius,
      actionSpacing: actionSpacing ?? this.actionSpacing,
      neutralColor: neutralColor ?? this.neutralColor,
      primaryColor: primaryColor ?? this.primaryColor,
      destructiveColor: destructiveColor ?? this.destructiveColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      strings: strings ?? this.strings,
    );
  }

  @override
  ConfirmKitTheme lerp(ThemeExtension<ConfirmKitTheme>? other, double t) {
    if (other is! ConfirmKitTheme) return this;
    return ConfirmKitTheme(
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      elevation: lerpDouble(elevation, other.elevation, t),
      insetPadding: EdgeInsets.lerp(insetPadding, other.insetPadding, t),
      contentPadding:
          EdgeInsetsGeometry.lerp(contentPadding, other.contentPadding, t),
      maxWidth: lerpDouble(maxWidth, other.maxWidth, t),
      iconSize: lerpDouble(iconSize, other.iconSize, t),
      iconBackground: t < 0.5 ? iconBackground : other.iconBackground,
      iconBackgroundOpacity:
          lerpDouble(iconBackgroundOpacity, other.iconBackgroundOpacity, t),
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
      messageStyle: TextStyle.lerp(messageStyle, other.messageStyle, t),
      actionHeight: lerpDouble(actionHeight, other.actionHeight, t),
      actionBorderRadius:
          lerpDouble(actionBorderRadius, other.actionBorderRadius, t),
      actionSpacing: lerpDouble(actionSpacing, other.actionSpacing, t),
      neutralColor: Color.lerp(neutralColor, other.neutralColor, t),
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t),
      destructiveColor: Color.lerp(destructiveColor, other.destructiveColor, t),
      successColor: Color.lerp(successColor, other.successColor, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      infoColor: Color.lerp(infoColor, other.infoColor, t),
      strings: t < 0.5 ? strings : other.strings,
    );
  }
}
