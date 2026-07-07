import 'package:flutter/material.dart';

import 'widget_kit_tokens.dart';

/// Project-wide defaults for `widget_kit` widgets.
///
/// Register once in `ThemeData.extensions` and every widget in the kit will
/// fall back to these values when its constructor parameters are not set.
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData.light().copyWith(
///     extensions: const [
///       WidgetKitTheme(
///         inputBorderRadius: 12,
///         inputBorderColor: Color(0xFFE0E0E0),
///         primaryButtonColor: Color(0xFF104C65),
///       ),
///     ],
///   ),
/// );
/// ```
///
/// All fields are nullable — pass only what you want to override. Resolve
/// a single value with [resolve] / [resolveColor] (which fall back to the
/// supplied default when the extension is absent).
class WidgetKitTheme extends ThemeExtension<WidgetKitTheme> {
  // ---- Input fields ----
  final double? inputBorderRadius;
  final double? inputBorderWidth;
  final double? inputFocusedBorderWidth;
  final Color? inputBorderColor;
  final Color? inputFocusedBorderColor;
  final Color? inputBackgroundColor;
  final Color? inputErrorColor;
  final Color? inputTextColor;
  final Color? inputHintColor;
  final double? inputFontSize;
  final double? inputHintFontSize;

  // ---- Buttons ----
  final double? buttonBorderRadius;
  final double? buttonHeight;
  final Color? primaryButtonColor;
  final Color? primaryButtonTextColor;
  final Color? secondaryButtonColor;
  final Color? secondaryButtonTextColor;

  // ---- Surfaces / dialogs / sheets ----
  final double? dialogBorderRadius;
  final Color? dialogBackgroundColor;
  final double? sheetBorderRadius;

  // ---- Feedback states ----
  final Color? emptyStateIconColor;
  final Color? errorStateIconColor;
  final Color? loadingColor;

  // ---- Shimmer ----
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;

  // ---- Media placeholder ----
  final Color? mediaPlaceholderColor;
  final Color? mediaErrorIconColor;

  const WidgetKitTheme({
    this.inputBorderRadius,
    this.inputBorderWidth,
    this.inputFocusedBorderWidth,
    this.inputBorderColor,
    this.inputFocusedBorderColor,
    this.inputBackgroundColor,
    this.inputErrorColor,
    this.inputTextColor,
    this.inputHintColor,
    this.inputFontSize,
    this.inputHintFontSize,
    this.buttonBorderRadius,
    this.buttonHeight,
    this.primaryButtonColor,
    this.primaryButtonTextColor,
    this.secondaryButtonColor,
    this.secondaryButtonTextColor,
    this.dialogBorderRadius,
    this.dialogBackgroundColor,
    this.sheetBorderRadius,
    this.emptyStateIconColor,
    this.errorStateIconColor,
    this.loadingColor,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.mediaPlaceholderColor,
    this.mediaErrorIconColor,
  });

  /// Default values backed by [WidgetKitTokens]. Used as the fallback when
  /// no extension is registered.
  static const WidgetKitTheme fallback = WidgetKitTheme(
    inputBorderRadius: WidgetKitTokens.radiusSm,
    inputBorderWidth: WidgetKitTokens.borderThin,
    inputFocusedBorderWidth: WidgetKitTokens.borderThick,
    inputFontSize: WidgetKitTokens.fontMd,
    inputHintFontSize: WidgetKitTokens.fontSm,
    buttonBorderRadius: WidgetKitTokens.radiusSm,
    buttonHeight: WidgetKitTokens.buttonHeight,
    dialogBorderRadius: WidgetKitTokens.radiusLg,
    sheetBorderRadius: WidgetKitTokens.radiusLg,
  );

  /// Look up the [WidgetKitTheme] for the current [BuildContext].
  ///
  /// Returns [fallback] if no extension is registered, so widgets always
  /// have working defaults.
  static WidgetKitTheme of(BuildContext context) {
    return Theme.of(context).extension<WidgetKitTheme>() ?? fallback;
  }

  @override
  WidgetKitTheme copyWith({
    double? inputBorderRadius,
    double? inputBorderWidth,
    double? inputFocusedBorderWidth,
    Color? inputBorderColor,
    Color? inputFocusedBorderColor,
    Color? inputBackgroundColor,
    Color? inputErrorColor,
    Color? inputTextColor,
    Color? inputHintColor,
    double? inputFontSize,
    double? inputHintFontSize,
    double? buttonBorderRadius,
    double? buttonHeight,
    Color? primaryButtonColor,
    Color? primaryButtonTextColor,
    Color? secondaryButtonColor,
    Color? secondaryButtonTextColor,
    double? dialogBorderRadius,
    Color? dialogBackgroundColor,
    double? sheetBorderRadius,
    Color? emptyStateIconColor,
    Color? errorStateIconColor,
    Color? loadingColor,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    Color? mediaPlaceholderColor,
    Color? mediaErrorIconColor,
  }) {
    return WidgetKitTheme(
      inputBorderRadius: inputBorderRadius ?? this.inputBorderRadius,
      inputBorderWidth: inputBorderWidth ?? this.inputBorderWidth,
      inputFocusedBorderWidth:
          inputFocusedBorderWidth ?? this.inputFocusedBorderWidth,
      inputBorderColor: inputBorderColor ?? this.inputBorderColor,
      inputFocusedBorderColor:
          inputFocusedBorderColor ?? this.inputFocusedBorderColor,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      inputErrorColor: inputErrorColor ?? this.inputErrorColor,
      inputTextColor: inputTextColor ?? this.inputTextColor,
      inputHintColor: inputHintColor ?? this.inputHintColor,
      inputFontSize: inputFontSize ?? this.inputFontSize,
      inputHintFontSize: inputHintFontSize ?? this.inputHintFontSize,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonHeight: buttonHeight ?? this.buttonHeight,
      primaryButtonColor: primaryButtonColor ?? this.primaryButtonColor,
      primaryButtonTextColor:
          primaryButtonTextColor ?? this.primaryButtonTextColor,
      secondaryButtonColor: secondaryButtonColor ?? this.secondaryButtonColor,
      secondaryButtonTextColor:
          secondaryButtonTextColor ?? this.secondaryButtonTextColor,
      dialogBorderRadius: dialogBorderRadius ?? this.dialogBorderRadius,
      dialogBackgroundColor:
          dialogBackgroundColor ?? this.dialogBackgroundColor,
      sheetBorderRadius: sheetBorderRadius ?? this.sheetBorderRadius,
      emptyStateIconColor: emptyStateIconColor ?? this.emptyStateIconColor,
      errorStateIconColor: errorStateIconColor ?? this.errorStateIconColor,
      loadingColor: loadingColor ?? this.loadingColor,
      shimmerBaseColor: shimmerBaseColor ?? this.shimmerBaseColor,
      shimmerHighlightColor:
          shimmerHighlightColor ?? this.shimmerHighlightColor,
      mediaPlaceholderColor:
          mediaPlaceholderColor ?? this.mediaPlaceholderColor,
      mediaErrorIconColor: mediaErrorIconColor ?? this.mediaErrorIconColor,
    );
  }

  @override
  WidgetKitTheme lerp(ThemeExtension<WidgetKitTheme>? other, double t) {
    if (other is! WidgetKitTheme) return this;
    return WidgetKitTheme(
      inputBorderRadius:
          _lerpDouble(inputBorderRadius, other.inputBorderRadius, t),
      inputBorderWidth:
          _lerpDouble(inputBorderWidth, other.inputBorderWidth, t),
      inputFocusedBorderWidth: _lerpDouble(
          inputFocusedBorderWidth, other.inputFocusedBorderWidth, t),
      inputBorderColor:
          Color.lerp(inputBorderColor, other.inputBorderColor, t),
      inputFocusedBorderColor: Color.lerp(
          inputFocusedBorderColor, other.inputFocusedBorderColor, t),
      inputBackgroundColor:
          Color.lerp(inputBackgroundColor, other.inputBackgroundColor, t),
      inputErrorColor: Color.lerp(inputErrorColor, other.inputErrorColor, t),
      inputTextColor: Color.lerp(inputTextColor, other.inputTextColor, t),
      inputHintColor: Color.lerp(inputHintColor, other.inputHintColor, t),
      inputFontSize: _lerpDouble(inputFontSize, other.inputFontSize, t),
      inputHintFontSize:
          _lerpDouble(inputHintFontSize, other.inputHintFontSize, t),
      buttonBorderRadius:
          _lerpDouble(buttonBorderRadius, other.buttonBorderRadius, t),
      buttonHeight: _lerpDouble(buttonHeight, other.buttonHeight, t),
      primaryButtonColor:
          Color.lerp(primaryButtonColor, other.primaryButtonColor, t),
      primaryButtonTextColor:
          Color.lerp(primaryButtonTextColor, other.primaryButtonTextColor, t),
      secondaryButtonColor:
          Color.lerp(secondaryButtonColor, other.secondaryButtonColor, t),
      secondaryButtonTextColor: Color.lerp(
          secondaryButtonTextColor, other.secondaryButtonTextColor, t),
      dialogBorderRadius:
          _lerpDouble(dialogBorderRadius, other.dialogBorderRadius, t),
      dialogBackgroundColor:
          Color.lerp(dialogBackgroundColor, other.dialogBackgroundColor, t),
      sheetBorderRadius:
          _lerpDouble(sheetBorderRadius, other.sheetBorderRadius, t),
      emptyStateIconColor:
          Color.lerp(emptyStateIconColor, other.emptyStateIconColor, t),
      errorStateIconColor:
          Color.lerp(errorStateIconColor, other.errorStateIconColor, t),
      loadingColor: Color.lerp(loadingColor, other.loadingColor, t),
      shimmerBaseColor:
          Color.lerp(shimmerBaseColor, other.shimmerBaseColor, t),
      shimmerHighlightColor:
          Color.lerp(shimmerHighlightColor, other.shimmerHighlightColor, t),
      mediaPlaceholderColor:
          Color.lerp(mediaPlaceholderColor, other.mediaPlaceholderColor, t),
      mediaErrorIconColor:
          Color.lerp(mediaErrorIconColor, other.mediaErrorIconColor, t),
    );
  }

  static double? _lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    return (a ?? 0) + ((b ?? 0) - (a ?? 0)) * t;
  }
}
