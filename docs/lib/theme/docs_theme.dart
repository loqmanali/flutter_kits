import 'package:flutter/material.dart';

/// The docs app's light and dark themes.
///
/// Palette is a neutral zinc (forui/shadcn-leaning) so the documented widgets —
/// not the chrome — are what the reader notices. We seed `ColorScheme` and let
/// Material 3 derive the rest, then tighten typography and radii to taste.
class DocsTheme {
  DocsTheme._();

  // Brand accents (zinc + a single blue accent for links/active nav).
  static const Color _accent = Color(0xFF2563EB);
  static const Color _zincLight = Color(0xFFFAFAFA); // app background
  static const Color _zincDark = Color(0xFF09090B); // near-black

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.light,
      surface: _zincLight,
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: _zincLight,
      // Thin dividers, subtle borders — forui's quiet look.
      dividerTheme: DividerThemeData(
        color: Colors.black.withValues(alpha: 0.06),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.dark,
      surface: _zincDark,
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: _zincDark,
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    final isLight = scheme.brightness == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      fontFamily: null, // system default; clean on web.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isLight
                ? Colors.black.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        elevation: 0,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.onSurface,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
      ),
      textTheme: _textTheme(scheme),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    const base = TextStyle(fontFamilyFallback: [
      'Inter',
      'Roboto',
      'Helvetica',
      'Arial',
      'sans-serif',
    ]);
    return TextTheme(
      displayLarge: base.copyWith(fontSize: 48, fontWeight: FontWeight.w800),
      displayMedium: base.copyWith(fontSize: 36, fontWeight: FontWeight.w800),
      displaySmall: base.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
      headlineMedium: base.copyWith(fontSize: 24, fontWeight: FontWeight.w700),
      headlineSmall: base.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
      titleLarge: base.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: base.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: base.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: base.copyWith(fontSize: 16, height: 1.6),
      bodyMedium: base.copyWith(fontSize: 14, height: 1.55, color: scheme.onSurface),
      bodySmall: base.copyWith(
        fontSize: 13,
        height: 1.5,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: base.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
      labelSmall: base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
