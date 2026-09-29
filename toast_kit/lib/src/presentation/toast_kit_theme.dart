import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../domain/toast_close_button_policy.dart';
import '../domain/toast_placement.dart';
import '../domain/toast_tone.dart';
import 'layouts/banner_toast_layout.dart';
import 'layouts/filled_toast_layout.dart';
import 'layouts/flat_toast_layout.dart';
import 'layouts/minimal_toast_layout.dart';
import 'layouts/outlined_toast_layout.dart';
import 'toast_layout.dart';
import 'toast_strings.dart';

/// App-wide defaults for every `toast_kit` surface.
///
/// Register once on `ThemeData` and stop passing styling to individual
/// toasts. Every field is nullable: unset fields fall back to [fallback],
/// and colors that are still unset fall back to the ambient `ColorScheme`.
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData.light().copyWith(
///     extensions: const [ToastKitTheme(defaultLayoutKey: 'filled')],
///   ),
/// );
/// ```
///
/// A tone's *accent* is the one color you set (`successColor`, ...); its
/// background, border, icon and readable foreground are all derived from it
/// and the ambient `ColorScheme`, the same way `confirm_kit`'s
/// `ConfirmKitTheme` derives a destructive button's readable label from one
/// `destructiveColor`.
@immutable
class ToastKitTheme extends ThemeExtension<ToastKitTheme> with Diagnosticable {
  const ToastKitTheme({
    this.successColor,
    this.errorColor,
    this.warningColor,
    this.infoColor,
    this.neutralColor,
    this.tintOpacity,
    this.titleTextStyle,
    this.messageTextStyle,
    this.maxTitleLines,
    this.maxMessageLines,
    this.padding,
    this.margin,
    this.spacing,
    this.maxWidth,
    this.borderRadius,
    this.elevation,
    this.showDuration,
    this.enterDuration,
    this.exitDuration,
    this.enterCurve,
    this.exitCurve,
    this.defaultPlacement,
    this.defaultLayoutKey,
    this.layouts,
    this.closeButtonPolicy,
    this.showProgress,
    this.strings,
  });

  // ---- Tone accents ----
  final Color? successColor;
  final Color? errorColor;
  final Color? warningColor;
  final Color? infoColor;
  final Color? neutralColor;

  /// How strongly a tone's accent tints its background, `0`-`1`.
  final double? tintOpacity;

  // ---- Text ----
  final TextStyle? titleTextStyle;
  final TextStyle? messageTextStyle;
  final int? maxTitleLines;
  final int? maxMessageLines;

  // ---- Geometry ----
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsDirectional? margin;

  /// Gap between two stacked toasts in the same placement.
  final double? spacing;
  final double? maxWidth;
  final double? borderRadius;
  final double? elevation;

  // ---- Motion ----
  /// Default auto-dismiss duration when a [ToastRequest] does not set one.
  final Duration? showDuration;
  final Duration? enterDuration;
  final Duration? exitDuration;
  final Curve? enterCurve;
  final Curve? exitCurve;

  // ---- Defaults ----
  final ToastPlacement? defaultPlacement;
  final String? defaultLayoutKey;

  /// Layout registry, keyed by name. An app-supplied map is merged over the
  /// built-ins, so overriding `'flat'` (say) does not lose `'banner'`.
  final Map<String, ToastLayout>? layouts;
  final ToastCloseButtonPolicy? closeButtonPolicy;
  final bool? showProgress;
  final ToastStrings? strings;

  static const Map<String, ToastLayout> _builtinLayouts = <String, ToastLayout>{
    'flat': FlatToastLayout(),
    'filled': FilledToastLayout(),
    'outlined': OutlinedToastLayout(),
    'minimal': MinimalToastLayout(),
    'banner': BannerToastLayout(),
  };

  /// Values used for anything the app has not overridden.
  static const ToastKitTheme fallback = ToastKitTheme(
    tintOpacity: 0.14,
    maxTitleLines: 5,
    maxMessageLines: 3,
    padding: EdgeInsetsDirectional.all(16),
    margin: EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
    spacing: 8,
    maxWidth: 480,
    borderRadius: 12,
    elevation: 4,
    showDuration: Duration(seconds: 4),
    enterDuration: Duration(milliseconds: 200),
    exitDuration: Duration(milliseconds: 150),
    enterCurve: Curves.easeOutCubic,
    exitCurve: Curves.easeInCubic,
    defaultPlacement: ToastPlacement.topCenter,
    defaultLayoutKey: 'flat',
    layouts: _builtinLayouts,
    closeButtonPolicy: ToastCloseButtonPolicy.whenSticky,
    showProgress: true,
    strings: ToastStrings.fallback,
  );

  /// The effective theme: [fallback] with the app's extension layered on
  /// top, and the app's [layouts] merged over the built-ins.
  static ToastKitTheme of(BuildContext context) =>
      fallback.merge(Theme.of(context).extension<ToastKitTheme>());

  ToastLayout layoutFor(String key) =>
      (layouts ?? _builtinLayouts)[key] ??
      _builtinLayouts[key] ??
      _builtinLayouts['flat']!;

  Color _accentFor(ToastTone tone, ColorScheme scheme) => switch (tone) {
        ToastTone.success => successColor ?? const Color(0xFF2E7D32),
        ToastTone.error => errorColor ?? scheme.error,
        ToastTone.warning => warningColor ?? const Color(0xFFE8A33D),
        ToastTone.info => infoColor ?? scheme.tertiary,
        ToastTone.neutral => neutralColor ?? scheme.onSurfaceVariant,
      };

  /// Solid accent color for [tone] — the border/icon color for every
  /// non-neutral layout, and the fill for `filled`.
  Color accentFor(ToastTone tone, ColorScheme scheme) =>
      _accentFor(tone, scheme);

  /// Background for a tinted layout (`flat`, `outlined`, `minimal`):
  /// [tone]'s accent blended lightly over `scheme.surface`, except
  /// [ToastTone.neutral], which reads as `scheme.inverseSurface` (the same
  /// look as a default `SnackBar`).
  Color backgroundFor(ToastTone tone, ColorScheme scheme) {
    if (tone == ToastTone.neutral) return scheme.inverseSurface;
    return Color.alphaBlend(
      _accentFor(tone, scheme).withValues(alpha: tintOpacity ?? 0.14),
      scheme.surface,
    );
  }

  /// Readable foreground for [backgroundFor], chosen by measured contrast —
  /// `scheme.onInverseSurface` for neutral, otherwise whichever of
  /// black/white clears 4.5:1 against the tinted background (or the higher
  /// of the two, if neither does).
  Color foregroundFor(ToastTone tone, ColorScheme scheme) {
    if (tone == ToastTone.neutral) return scheme.onInverseSurface;
    return _readableOn(backgroundFor(tone, scheme));
  }

  /// WCAG contrast ratio between two colours.
  static double _contrastRatio(Color a, Color b) {
    double channel(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    double luminance(Color c) =>
        0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
    final la = luminance(a) + 0.05;
    final lb = luminance(b) + 0.05;
    return la > lb ? la / lb : lb / la;
  }

  static Color _readableOn(Color background) {
    final white = _contrastRatio(Colors.white, background);
    final black = _contrastRatio(Colors.black, background);
    return white >= black ? Colors.white : Colors.black;
  }

  /// White or black, whichever reads better on [background] — public so
  /// layouts other than the built-ins (e.g. `filled`) can pick a readable
  /// label for a solid accent fill.
  static Color readableOn(Color background) => _readableOn(background);

  ToastKitTheme merge(ToastKitTheme? other) {
    if (other == null) return this;
    return copyWith(
      successColor: other.successColor,
      errorColor: other.errorColor,
      warningColor: other.warningColor,
      infoColor: other.infoColor,
      neutralColor: other.neutralColor,
      tintOpacity: other.tintOpacity,
      titleTextStyle: other.titleTextStyle,
      messageTextStyle: other.messageTextStyle,
      maxTitleLines: other.maxTitleLines,
      maxMessageLines: other.maxMessageLines,
      padding: other.padding,
      margin: other.margin,
      spacing: other.spacing,
      maxWidth: other.maxWidth,
      borderRadius: other.borderRadius,
      elevation: other.elevation,
      showDuration: other.showDuration,
      enterDuration: other.enterDuration,
      exitDuration: other.exitDuration,
      enterCurve: other.enterCurve,
      exitCurve: other.exitCurve,
      defaultPlacement: other.defaultPlacement,
      defaultLayoutKey: other.defaultLayoutKey,
      layouts: other.layouts == null
          ? layouts
          : <String, ToastLayout>{...?layouts, ...?other.layouts},
      closeButtonPolicy: other.closeButtonPolicy,
      showProgress: other.showProgress,
      strings: other.strings,
    );
  }

  @override
  ToastKitTheme copyWith({
    Color? successColor,
    Color? errorColor,
    Color? warningColor,
    Color? infoColor,
    Color? neutralColor,
    double? tintOpacity,
    TextStyle? titleTextStyle,
    TextStyle? messageTextStyle,
    int? maxTitleLines,
    int? maxMessageLines,
    EdgeInsetsGeometry? padding,
    EdgeInsetsDirectional? margin,
    double? spacing,
    double? maxWidth,
    double? borderRadius,
    double? elevation,
    Duration? showDuration,
    Duration? enterDuration,
    Duration? exitDuration,
    Curve? enterCurve,
    Curve? exitCurve,
    ToastPlacement? defaultPlacement,
    String? defaultLayoutKey,
    Map<String, ToastLayout>? layouts,
    ToastCloseButtonPolicy? closeButtonPolicy,
    bool? showProgress,
    ToastStrings? strings,
  }) {
    return ToastKitTheme(
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      neutralColor: neutralColor ?? this.neutralColor,
      tintOpacity: tintOpacity ?? this.tintOpacity,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      messageTextStyle: messageTextStyle ?? this.messageTextStyle,
      maxTitleLines: maxTitleLines ?? this.maxTitleLines,
      maxMessageLines: maxMessageLines ?? this.maxMessageLines,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      spacing: spacing ?? this.spacing,
      maxWidth: maxWidth ?? this.maxWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      showDuration: showDuration ?? this.showDuration,
      enterDuration: enterDuration ?? this.enterDuration,
      exitDuration: exitDuration ?? this.exitDuration,
      enterCurve: enterCurve ?? this.enterCurve,
      exitCurve: exitCurve ?? this.exitCurve,
      defaultPlacement: defaultPlacement ?? this.defaultPlacement,
      defaultLayoutKey: defaultLayoutKey ?? this.defaultLayoutKey,
      layouts: layouts ?? this.layouts,
      closeButtonPolicy: closeButtonPolicy ?? this.closeButtonPolicy,
      showProgress: showProgress ?? this.showProgress,
      strings: strings ?? this.strings,
    );
  }

  @override
  ToastKitTheme lerp(ThemeExtension<ToastKitTheme>? other, double t) {
    if (other is! ToastKitTheme) return this;
    return ToastKitTheme(
      successColor: Color.lerp(successColor, other.successColor, t),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      infoColor: Color.lerp(infoColor, other.infoColor, t),
      neutralColor: Color.lerp(neutralColor, other.neutralColor, t),
      tintOpacity: lerpDouble(tintOpacity, other.tintOpacity, t),
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t),
      messageTextStyle:
          TextStyle.lerp(messageTextStyle, other.messageTextStyle, t),
      maxTitleLines: t < 0.5 ? maxTitleLines : other.maxTitleLines,
      maxMessageLines: t < 0.5 ? maxMessageLines : other.maxMessageLines,
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t),
      margin: EdgeInsetsDirectional.lerp(margin, other.margin, t),
      spacing: lerpDouble(spacing, other.spacing, t),
      maxWidth: lerpDouble(maxWidth, other.maxWidth, t),
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t),
      elevation: lerpDouble(elevation, other.elevation, t),
      showDuration: t < 0.5 ? showDuration : other.showDuration,
      enterDuration: t < 0.5 ? enterDuration : other.enterDuration,
      exitDuration: t < 0.5 ? exitDuration : other.exitDuration,
      enterCurve: t < 0.5 ? enterCurve : other.enterCurve,
      exitCurve: t < 0.5 ? exitCurve : other.exitCurve,
      defaultPlacement: t < 0.5 ? defaultPlacement : other.defaultPlacement,
      defaultLayoutKey: t < 0.5 ? defaultLayoutKey : other.defaultLayoutKey,
      layouts: t < 0.5 ? layouts : other.layouts,
      closeButtonPolicy: t < 0.5 ? closeButtonPolicy : other.closeButtonPolicy,
      showProgress: t < 0.5 ? showProgress : other.showProgress,
      strings: t < 0.5 ? strings : other.strings,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('defaultLayoutKey', defaultLayoutKey))
      ..add(DiagnosticsProperty<ToastPlacement?>(
          'defaultPlacement', defaultPlacement))
      ..add(IntProperty('maxTitleLines', maxTitleLines))
      ..add(IntProperty('maxMessageLines', maxMessageLines))
      ..add(FlagProperty(
        'showProgress',
        value: showProgress,
        ifTrue: 'showing progress',
      ));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ToastKitTheme &&
        other.successColor == successColor &&
        other.errorColor == errorColor &&
        other.warningColor == warningColor &&
        other.infoColor == infoColor &&
        other.neutralColor == neutralColor &&
        other.tintOpacity == tintOpacity &&
        other.titleTextStyle == titleTextStyle &&
        other.messageTextStyle == messageTextStyle &&
        other.maxTitleLines == maxTitleLines &&
        other.maxMessageLines == maxMessageLines &&
        other.padding == padding &&
        other.margin == margin &&
        other.spacing == spacing &&
        other.maxWidth == maxWidth &&
        other.borderRadius == borderRadius &&
        other.elevation == elevation &&
        other.showDuration == showDuration &&
        other.enterDuration == enterDuration &&
        other.exitDuration == exitDuration &&
        other.enterCurve == enterCurve &&
        other.exitCurve == exitCurve &&
        other.defaultPlacement == defaultPlacement &&
        other.defaultLayoutKey == defaultLayoutKey &&
        mapEquals(other.layouts, layouts) &&
        other.closeButtonPolicy == closeButtonPolicy &&
        other.showProgress == showProgress &&
        other.strings == strings;
  }

  @override
  int get hashCode => Object.hash(
        successColor,
        errorColor,
        warningColor,
        infoColor,
        neutralColor,
        tintOpacity,
        titleTextStyle,
        messageTextStyle,
        maxTitleLines,
        maxMessageLines,
        Object.hash(
            padding, margin, spacing, maxWidth, borderRadius, elevation),
        Object.hash(
            showDuration, enterDuration, exitDuration, enterCurve, exitCurve),
        Object.hash(defaultPlacement, defaultLayoutKey, closeButtonPolicy,
            showProgress, strings),
      );
}
