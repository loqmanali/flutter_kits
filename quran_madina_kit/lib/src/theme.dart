import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'source.dart';

/// How the kit should show a quran.com link.
///
/// Receives the tapped element's context and the URL. Return when the link has
/// been handled — the kit does nothing else.
typedef MadinaTranslateHandler = Future<void> Function(
  BuildContext context,
  Uri url,
);

/// How a justified line's scaleX is obtained.
enum MadinaStretchMode {
  /// Replay the DB's stored factor times the size correction — byte-for-byte
  /// the web runtime's geometry, including its drift.
  ///
  /// Those factors were measured in headless Chrome. Flutter's shaping differs
  /// slightly, so a line may not land exactly on the frame: half of all lines
  /// stay within 1% for every font, but Uthman drifts over 2% on 12% of its
  /// lines (up to 8.6%, ≈23px), which reads as a ragged edge.
  stored,

  /// Measure the line and derive `lineWidth / measuredWidth`, so every
  /// justified line fills the frame exactly (verified: 0.0000% max drift for
  /// all five fonts). Self-correcting, and makes the font-size interpolation
  /// correction unnecessary. The default.
  measured,
}

/// `inline="auto" | "no" | "yes"`.
enum MadinaInline { auto, no, yes }

/// WCAG relative luminance.
///
/// Used to pick a mark pair that contrasts with the host app's actual ambient
/// text colour — not a guess from the platform brightness, which need not match
/// how the host implements its own dark mode.
double relativeLuminance(Color c) {
  double lin(double channel) => channel <= 0.03928
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
}

/// The `color-mix(in srgb, X N%, transparent)` equivalent.
Color mixWithTransparent(Color c, double fraction) =>
    c.withValues(alpha: fraction.clamp(0.0, 1.0));

/// The six CSS custom properties the web stylesheet exposes.
class MadinaTheme {
  const MadinaTheme({
    required this.background,
    required this.header,
    required this.highlight,
    required this.error,
    required this.highlightText,
    required this.errorText,
  });

  /// `--qmh-background: #F5F5DC` (beige), `--qmh-header: black`.
  factory MadinaTheme.light() => const MadinaTheme(
        background: Color(0xFFF5F5DC),
        header: Color(0xFF000000),
        highlight: Color(0xFFFFF3B0),
        error: Color(0xFFF5C6CB),
        highlightText: Color(0xFF1A1A1A),
        errorText: Color(0xFF1A1A1A),
      );

  /// The `[data-qmh-text-scheme="dark"]` mark pair.
  factory MadinaTheme.dark() => const MadinaTheme(
        background: Color(0xFFF5F5DC),
        header: Color(0xFF000000),
        highlight: Color(0xFF5C4600),
        error: Color(0xFF6B1A24),
        highlightText: Color(0xFFFFFFFF),
        errorText: Color(0xFFFFFFFF),
      );

  final Color background;
  final Color header;
  final Color highlight;
  final Color error;
  final Color highlightText;
  final Color errorText;

  /// Swaps in the dark mark pair when the ambient text colour is light, so
  /// `highlight=`/`error=` stay legible on any host background. Background and
  /// header are the caller's choice and pass through untouched.
  MadinaTheme forAmbient(Color ambientTextColour) {
    if (relativeLuminance(ambientTextColour) <= 0.5) return this;
    final dark = MadinaTheme.dark();
    return MadinaTheme(
      background: background,
      header: header,
      highlight: dark.highlight,
      error: dark.error,
      highlightText: dark.highlightText,
      errorText: dark.errorText,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MadinaTheme &&
      other.background == background &&
      other.header == header &&
      other.highlight == highlight &&
      other.error == error &&
      other.highlightText == highlightText &&
      other.errorText == errorText;

  @override
  int get hashCode => Object.hash(
        background,
        header,
        highlight,
        error,
        highlightText,
        errorText,
      );
}

/// The loader-script config: `data-name`, `data-font`, `data-font-size`, plus
/// the Flutter-only source and stretch-mode choices.
class MadinaConfig {
  const MadinaConfig({
    this.name = 'Madina05',
    this.font = 'Hafs',
    this.fontSize = 16,
    this.source,
    this.stretchMode = MadinaStretchMode.measured,
    this.onTranslate,
  });

  final String name;
  final String font;
  final double fontSize;

  /// Defaults to [MadinaAssetSource] when null, so the kit works offline out of
  /// the box.
  final MadinaSource? source;

  final MadinaStretchMode stretchMode;

  /// What the translate action does. Defaults to [openMadinaWebPage], which
  /// shows quran.com on a full-screen page **inside** the app.
  ///
  /// Point it at your own in-app browser, router or sheet to keep the link in
  /// your app's own navigation:
  ///
  /// ```dart
  /// MadinaConfig(
  ///   onTranslate: (context, url) => context.push('/browser?url=$url'),
  /// )
  /// ```
  final MadinaTranslateHandler? onTranslate;

  @override
  bool operator ==(Object other) =>
      other is MadinaConfig &&
      other.name == name &&
      other.font == font &&
      other.fontSize == fontSize &&
      other.source == source &&
      other.stretchMode == stretchMode &&
      other.onTranslate == onTranslate;

  @override
  int get hashCode =>
      Object.hash(name, font, fontSize, source, stretchMode, onTranslate);
}

/// Supplies config and theme to every `QuranMadinaView` below it.
class MadinaScope extends InheritedWidget {
  MadinaScope({
    super.key,
    MadinaConfig? config,
    MadinaTheme? theme,
    required super.child,
  })  : config = config ?? const MadinaConfig(),
        theme = theme ?? MadinaTheme.light();

  final MadinaConfig config;
  final MadinaTheme theme;

  /// Returns a default scope when none is in the tree, so a bare
  /// `QuranMadinaView` still renders.
  static MadinaScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MadinaScope>() ??
      MadinaScope(child: const SizedBox.shrink());

  @override
  bool updateShouldNotify(MadinaScope old) =>
      old.config != config || old.theme != theme;
}
