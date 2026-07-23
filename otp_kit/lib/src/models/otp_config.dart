import 'package:flutter/material.dart';

/// Configuration class for OTP TextField
///
/// This class contains all customization options for the OTP input field
/// including visual styling, behavior settings, and validation rules.
///
/// Example:
/// ```dart
/// final config = OTPConfig(
///   length: 6,
///   autoFocus: true,
///   obscureText: true,
/// );
/// ```
class OTPConfig {
  /// Number of OTP digits (default: 4)
  final int length;

  /// Spacing between input fields in pixels (default: 8.0)
  final double spacing;

  /// Size of each input field (width and height) (default: 50.0)
  final double size;

  /// Border radius for input fields (default: 12.0)
  final double borderRadius;

  /// Border width for input fields (default: 1.5)
  final double borderWidth;

  /// Active/focused border color
  final Color? activeColor;

  /// Inactive/unfocused border color
  final Color? inactiveColor;

  /// Error state border color
  final Color? errorColor;

  /// Border color when every cell is filled without an error (the
  /// "valid" state). When null, completed cells keep using
  /// [activeColor]/[inactiveColor].
  final Color? successColor;

  /// Background color for input fields
  final Color? backgroundColor;

  /// Text color for digits
  final Color? textColor;

  /// Text style for digits
  final TextStyle? textStyle;

  /// Whether to use RTL (Right-to-Left) direction (default: false)
  final bool isRTL;

  /// Padding around each field
  final EdgeInsets fieldPadding;

  /// Whether to auto-focus first field on init (default: true)
  final bool autoFocus;

  /// Whether to obscure text (for security) (default: false)
  final bool obscureText;

  /// Obscure character (default: '•')
  final String obscureCharacter;

  /// Enable haptic feedback on input (default: true)
  final bool enableHapticFeedback;

  /// Enable animations (default: true)
  final bool enableAnimations;

  /// Animation duration in milliseconds (default: 300)
  final int animationDuration;

  /// Enable auto-submit when complete (default: false)
  final bool autoSubmit;

  /// Input type restriction (default: numeric)
  final OTPInputType inputType;

  /// Enable paste functionality (default: true)
  final bool enablePaste;

  /// Clear all fields on error (default: false)
  final bool clearOnError;

  /// Auto-dismiss keyboard on completion (default: false)
  final bool autoDismissKeyboard;

  /// Enable field elevation shadow (default: true)
  final bool enableShadow;

  /// Shadow elevation (default: 2.0)
  final double shadowElevation;

  /// Suppress repeated [onCompleted] callbacks for the same value until the
  /// field is explicitly cleared. Default: `false` — every completion fires.
  ///
  /// Set to `true` for screens that auto-submit on completion and want to
  /// avoid duplicate API calls when the user backspaces and re-types the
  /// exact same digits.
  final bool dedupeCompletion;

  /// Whether the blinking text cursor is shown inside each cell. Default:
  /// `true`. Set to `false` for a pure cell-based look where the filled
  /// digit alone signals progress.
  final bool showCursor;

  const OTPConfig({
    this.length = 4,
    this.spacing = 8.0,
    this.size = 50.0,
    this.borderRadius = 8.0,
    this.borderWidth = 1.5,
    this.activeColor,
    this.inactiveColor,
    this.errorColor,
    this.successColor,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.isRTL = false,
    this.fieldPadding = const EdgeInsets.symmetric(horizontal: 4),
    this.autoFocus = true,
    this.obscureText = false,
    this.obscureCharacter = '•',
    this.enableHapticFeedback = true,
    this.enableAnimations = true,
    this.animationDuration = 300,
    this.autoSubmit = false,
    this.inputType = OTPInputType.numeric,
    this.enablePaste = true,
    this.clearOnError = false,
    this.autoDismissKeyboard = false,
    this.enableShadow = true,
    this.shadowElevation = 2.0,
    this.dedupeCompletion = false,
    this.showCursor = true,
  });

  /// Create a copy of this config with specified fields replaced
  OTPConfig copyWith({
    int? length,
    double? spacing,
    double? size,
    double? borderRadius,
    double? borderWidth,
    Color? activeColor,
    Color? inactiveColor,
    Color? errorColor,
    Color? successColor,
    Color? backgroundColor,
    Color? textColor,
    TextStyle? textStyle,
    bool? isRTL,
    EdgeInsets? fieldPadding,
    bool? autoFocus,
    bool? obscureText,
    String? obscureCharacter,
    bool? enableHapticFeedback,
    bool? enableAnimations,
    int? animationDuration,
    bool? autoSubmit,
    OTPInputType? inputType,
    bool? enablePaste,
    bool? clearOnError,
    bool? autoDismissKeyboard,
    bool? enableShadow,
    double? shadowElevation,
    bool? dedupeCompletion,
    bool? showCursor,
  }) {
    return OTPConfig(
      length: length ?? this.length,
      spacing: spacing ?? this.spacing,
      size: size ?? this.size,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      textStyle: textStyle ?? this.textStyle,
      isRTL: isRTL ?? this.isRTL,
      fieldPadding: fieldPadding ?? this.fieldPadding,
      autoFocus: autoFocus ?? this.autoFocus,
      obscureText: obscureText ?? this.obscureText,
      obscureCharacter: obscureCharacter ?? this.obscureCharacter,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      animationDuration: animationDuration ?? this.animationDuration,
      autoSubmit: autoSubmit ?? this.autoSubmit,
      inputType: inputType ?? this.inputType,
      enablePaste: enablePaste ?? this.enablePaste,
      clearOnError: clearOnError ?? this.clearOnError,
      autoDismissKeyboard: autoDismissKeyboard ?? this.autoDismissKeyboard,
      enableShadow: enableShadow ?? this.enableShadow,
      shadowElevation: shadowElevation ?? this.shadowElevation,
      dedupeCompletion: dedupeCompletion ?? this.dedupeCompletion,
      showCursor: showCursor ?? this.showCursor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OTPConfig &&
        other.length == length &&
        other.spacing == spacing &&
        other.size == size &&
        other.borderRadius == borderRadius &&
        other.borderWidth == borderWidth &&
        other.activeColor == activeColor &&
        other.inactiveColor == inactiveColor &&
        other.errorColor == errorColor &&
        other.successColor == successColor &&
        other.backgroundColor == backgroundColor &&
        other.textColor == textColor &&
        other.textStyle == textStyle &&
        other.isRTL == isRTL &&
        other.fieldPadding == fieldPadding &&
        other.autoFocus == autoFocus &&
        other.obscureText == obscureText &&
        other.obscureCharacter == obscureCharacter &&
        other.enableHapticFeedback == enableHapticFeedback &&
        other.enableAnimations == enableAnimations &&
        other.animationDuration == animationDuration &&
        other.autoSubmit == autoSubmit &&
        other.inputType == inputType &&
        other.enablePaste == enablePaste &&
        other.clearOnError == clearOnError &&
        other.autoDismissKeyboard == autoDismissKeyboard &&
        other.enableShadow == enableShadow &&
        other.shadowElevation == shadowElevation &&
        other.dedupeCompletion == dedupeCompletion &&
        other.showCursor == showCursor;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      length,
      spacing,
      size,
      borderRadius,
      borderWidth,
      activeColor,
      inactiveColor,
      errorColor,
      successColor,
      backgroundColor,
      textColor,
      textStyle,
      isRTL,
      fieldPadding,
      autoFocus,
      obscureText,
      obscureCharacter,
      enableHapticFeedback,
      enableAnimations,
      animationDuration,
      autoSubmit,
      inputType,
      enablePaste,
      clearOnError,
      autoDismissKeyboard,
      enableShadow,
      shadowElevation,
      dedupeCompletion,
      showCursor,
    ]);
  }

  @override
  String toString() {
    return 'OTPConfig(length: $length, spacing: $spacing, size: $size, borderRadius: $borderRadius, borderWidth: $borderWidth, isRTL: $isRTL, autoFocus: $autoFocus, obscureText: $obscureText, inputType: $inputType)';
  }
}

/// Input type restrictions for OTP field
enum OTPInputType {
  /// Only numeric digits (0-9)
  numeric,

  /// Only alphabetic characters (a-z, A-Z)
  alphabetic,

  /// Alphanumeric (letters and numbers)
  alphanumeric,

  /// Any character
  any,
}

/// Extension methods for OTPInputType
extension OTPInputTypeExtension on OTPInputType {
  /// Get TextInputType for keyboard
  TextInputType get keyboardType {
    switch (this) {
      case OTPInputType.numeric:
        return TextInputType.number;
      case OTPInputType.alphabetic:
        return TextInputType.text;
      case OTPInputType.alphanumeric:
        return TextInputType.text;
      case OTPInputType.any:
        return TextInputType.text;
    }
  }

  /// Validate if character is allowed for this input type
  bool isValidCharacter(String char) {
    if (char.isEmpty) return true;

    switch (this) {
      case OTPInputType.numeric:
        return RegExp(r'^\d$').hasMatch(char);
      case OTPInputType.alphabetic:
        return RegExp(r'^[a-zA-Z]$').hasMatch(char);
      case OTPInputType.alphanumeric:
        return RegExp(r'^[a-zA-Z0-9]$').hasMatch(char);
      case OTPInputType.any:
        return true;
    }
  }
}
