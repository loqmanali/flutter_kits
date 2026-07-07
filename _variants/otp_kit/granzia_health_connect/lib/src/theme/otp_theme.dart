import 'package:flutter/material.dart';

import '../models/otp_models.dart';

/// Theme configuration for OTP module
///
/// This class provides pre-defined themes and theme builders
/// for consistent OTP field styling across your app.
///
/// Example:
/// ```dart
/// final config = OTPTheme.defaultLight(context);
/// ```
class OTPTheme {
  /// Create a default light theme configuration
  static OTPConfig defaultLight(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OTPConfig(
      spacing: 12.0,
      size: 56.0,
      borderRadius: 12.0,
      borderWidth: 2.0,
      activeColor: colorScheme.primary,
      inactiveColor: colorScheme.outline,
      errorColor: colorScheme.error,
      backgroundColor: colorScheme.surface,
      textColor: colorScheme.onSurface,
      textStyle: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }

  /// Create a default dark theme configuration
  static OTPConfig defaultDark(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OTPConfig(
      spacing: 12.0,
      size: 56.0,
      borderRadius: 12.0,
      borderWidth: 2.0,
      activeColor: colorScheme.primary,
      inactiveColor: colorScheme.outline,
      errorColor: colorScheme.error,
      backgroundColor: colorScheme.surface,
      textColor: colorScheme.onSurface,
      textStyle: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }

  /// Minimal theme with simple border design
  static OTPConfig minimal(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OTPConfig(
      borderWidth: 1.0,
      activeColor: colorScheme.primary,
      inactiveColor: colorScheme.outline.withValues(alpha: 0.3),
      errorColor: colorScheme.error,
      backgroundColor: Colors.transparent,
      textColor: colorScheme.onSurface,
      textStyle: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      enableHapticFeedback: false,
      enableAnimations: false,
      enableShadow: false,
    );
  }

  /// Rounded theme with circular design
  static OTPConfig rounded(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OTPConfig(
      spacing: 16.0,
      size: 60.0,
      borderRadius: 30.0,
      borderWidth: 2.5,
      activeColor: colorScheme.primary,
      inactiveColor: colorScheme.outline,
      errorColor: colorScheme.error,
      backgroundColor: colorScheme.surface,
      textColor: colorScheme.onSurface,
      textStyle: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      shadowElevation: 4.0,
    );
  }

  /// Modern theme with gradient-like effects
  static OTPConfig modern(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OTPConfig(
      length: 6,
      spacing: 10.0,
      size: 54.0,
      borderRadius: 16.0,
      borderWidth: 2.0,
      activeColor: colorScheme.primary,
      inactiveColor: colorScheme.outlineVariant,
      errorColor: colorScheme.error,
      backgroundColor: colorScheme.surfaceContainerHighest,
      textColor: colorScheme.onSurface,
      textStyle: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
      ),
      shadowElevation: 3.0,
    );
  }

  /// Compact theme for smaller screens
  static OTPConfig compact(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OTPConfig(
      spacing: 6.0,
      size: 44.0,
      activeColor: colorScheme.primary,
      inactiveColor: colorScheme.outline,
      errorColor: colorScheme.error,
      backgroundColor: colorScheme.surface,
      textColor: colorScheme.onSurface,
      textStyle: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      fieldPadding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  /// Large theme for better accessibility
  static OTPConfig large(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OTPConfig(
      spacing: 16.0,
      size: 68.0,
      borderRadius: 16.0,
      borderWidth: 3.0,
      activeColor: colorScheme.primary,
      inactiveColor: colorScheme.outline,
      errorColor: colorScheme.error,
      backgroundColor: colorScheme.surface,
      textColor: colorScheme.onSurface,
      textStyle: theme.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      fieldPadding: const EdgeInsets.symmetric(horizontal: 6),
      shadowElevation: 4.0,
    );
  }

  /// Security-focused theme with obscured text
  static OTPConfig secure(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OTPConfig(
      length: 6,
      spacing: 12.0,
      size: 56.0,
      borderRadius: 12.0,
      borderWidth: 2.0,
      activeColor: colorScheme.primary,
      inactiveColor: colorScheme.outline,
      errorColor: colorScheme.error,
      backgroundColor: colorScheme.surface,
      textColor: colorScheme.onSurface,
      textStyle: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      obscureText: true,
      obscureCharacter: '●',
      autoDismissKeyboard: true,
      clearOnError: true,
    );
  }

  /// Premium theme with enhanced visual effects
  static OTPConfig premium(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OTPConfig(
      length: 6,
      spacing: 14.0,
      size: 62.0,
      borderRadius: 18.0,
      borderWidth: 2.5,
      activeColor: colorScheme.primary,
      inactiveColor: colorScheme.outline.withValues(alpha: 0.5),
      errorColor: colorScheme.error,
      backgroundColor: colorScheme.surface,
      textColor: colorScheme.onSurface,
      textStyle: theme.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
      animationDuration: 400,
      shadowElevation: 6.0,
    );
  }

  /// Underline style theme (bottom border only)
  static OTPConfig underline(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OTPConfig(
      spacing: 20.0,
      size: 48.0,
      borderRadius: 0.0,
      borderWidth: 0.0,
      activeColor: colorScheme.primary,
      inactiveColor: colorScheme.outline,
      errorColor: colorScheme.error,
      backgroundColor: Colors.transparent,
      textColor: colorScheme.onSurface,
      textStyle: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      enableShadow: false,
    );
  }

  /// Adaptive theme based on platform brightness
  static OTPConfig adaptive(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? defaultDark(context)
        : defaultLight(context);
  }

  /// Custom theme builder. Starts from the [adaptive] preset and applies
  /// any overrides via [OTPConfig.copyWith].
  static OTPConfig custom({
    required BuildContext context,
    int? length,
    double? spacing,
    double? size,
    double? borderRadius,
    double? borderWidth,
    Color? activeColor,
    Color? inactiveColor,
    Color? errorColor,
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
    return adaptive(context).copyWith(
      length: length,
      spacing: spacing,
      size: size,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      errorColor: errorColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      textStyle: textStyle,
      isRTL: isRTL,
      fieldPadding: fieldPadding,
      autoFocus: autoFocus,
      obscureText: obscureText,
      obscureCharacter: obscureCharacter,
      enableHapticFeedback: enableHapticFeedback,
      enableAnimations: enableAnimations,
      animationDuration: animationDuration,
      autoSubmit: autoSubmit,
      inputType: inputType,
      enablePaste: enablePaste,
      clearOnError: clearOnError,
      autoDismissKeyboard: autoDismissKeyboard,
      enableShadow: enableShadow,
      shadowElevation: shadowElevation,
      dedupeCompletion: dedupeCompletion,
      showCursor: showCursor,
    );
  }
}
