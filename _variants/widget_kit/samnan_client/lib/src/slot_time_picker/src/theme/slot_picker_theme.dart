import 'package:flutter/material.dart';

/// Visual configuration for all slot-picker widgets.
///
/// Every color, radius, and text style is overridable. Sensible defaults are
/// provided so the widget works out-of-the-box without any configuration.
class SlotPickerTheme {
  // ── Colors ────────────────────────────────────────────────────────────────

  /// Accent / brand color used for selected states and the confirm button.
  final Color primaryColor;

  /// Light tint of [primaryColor]; used as the selector-tile fill when a
  /// date+time is already chosen.
  final Color primaryLightColor;

  /// Surface / card background color.
  final Color backgroundColor;

  /// Subtle background used for the empty-state message container.
  final Color emptyStateFillColor;

  // ── Neutral palette (roughly maps to a 50-900 scale) ─────────────────────

  final Color grey50;
  final Color grey400;
  final Color grey500;
  final Color grey600;
  final Color grey700;
  final Color grey900;

  // ── Border radii ──────────────────────────────────────────────────────────

  /// Radius of the outer selector tile (the collapsed button).
  final double selectorBorderRadius;

  /// Radius of individual day tiles in the horizontal strip.
  final double dayTileBorderRadius;

  /// Radius of individual time-slot chips in the grid.
  final double timeSlotBorderRadius;

  /// Radius of the top corners of the modal bottom sheet.
  final double bottomSheetBorderRadius;

  // ── Sizes ─────────────────────────────────────────────────────────────────

  /// Fixed width of each day tile in the horizontal scrolling strip.
  final double dayTileWidth;

  /// Fixed height of the horizontal day-strip container.
  final double dayStripHeight;

  /// Height of each row in the time-slot grid.
  final double timeSlotGridRowHeight;

  /// Number of columns in the time-slot grid.
  final int timeSlotGridCrossAxisCount;

  // ── Text styles ───────────────────────────────────────────────────────────

  /// Style for the day abbreviation (e.g. "MON") inside a day tile.
  final TextStyle? dayNameStyle;

  /// Style for the day number (e.g. "05") inside a day tile.
  final TextStyle? dayNumberStyle;

  /// Style for time-slot chip labels.
  final TextStyle? timeSlotLabelStyle;

  /// Style for the month/year heading in the calendar header.
  final TextStyle? monthHeadingStyle;

  /// Style for section headings ("Time", etc.).
  final TextStyle? sectionHeadingStyle;

  /// Style for the selector button's display label.
  final TextStyle? selectorLabelStyle;

  /// Style for empty/error state messages.
  final TextStyle? emptyStateMessageStyle;

  // ── Bottom-sheet sizing ───────────────────────────────────────────────────

  final double bottomSheetInitialSize;
  final double bottomSheetMinSize;
  final double bottomSheetMaxSize;

  // ── Confirm button ────────────────────────────────────────────────────────

  /// Override the confirm button completely. When null the default
  /// [ElevatedButton] is used.
  final Widget Function(
    BuildContext context,
    VoidCallback? onPressed,
    String label,
  )?
  confirmButtonBuilder;

  // ── Loading indicator ─────────────────────────────────────────────────────

  /// Override the loading indicator. Defaults to [CircularProgressIndicator].
  final WidgetBuilder? loadingBuilder;

  const SlotPickerTheme({
    this.primaryColor = const Color(0xFF4CAF50),
    this.primaryLightColor = const Color(0xFFE8F5E9),
    this.backgroundColor = Colors.white,
    this.emptyStateFillColor = const Color(0xFFF5F5F5),
    this.grey50 = const Color(0xFFF5F5F5),
    this.grey400 = const Color(0xFFBDBDBD),
    this.grey500 = const Color(0xFF9E9E9E),
    this.grey600 = const Color(0xFF757575),
    this.grey700 = const Color(0xFF616161),
    this.grey900 = const Color(0xFF212121),
    this.selectorBorderRadius = 12,
    this.dayTileBorderRadius = 14,
    this.timeSlotBorderRadius = 10,
    this.bottomSheetBorderRadius = 22,
    this.dayTileWidth = 82,
    this.dayStripHeight = 116,
    this.timeSlotGridRowHeight = 46,
    this.timeSlotGridCrossAxisCount = 2,
    this.dayNameStyle,
    this.dayNumberStyle,
    this.timeSlotLabelStyle,
    this.monthHeadingStyle,
    this.sectionHeadingStyle,
    this.selectorLabelStyle,
    this.emptyStateMessageStyle,
    this.bottomSheetInitialSize = 0.76,
    this.bottomSheetMinSize = 0.48,
    this.bottomSheetMaxSize = 0.92,
    this.confirmButtonBuilder,
    this.loadingBuilder,
  });

  SlotPickerTheme copyWith({
    Color? primaryColor,
    Color? primaryLightColor,
    Color? backgroundColor,
    Color? emptyStateFillColor,
    Color? grey50,
    Color? grey400,
    Color? grey500,
    Color? grey600,
    Color? grey700,
    Color? grey900,
    double? selectorBorderRadius,
    double? dayTileBorderRadius,
    double? timeSlotBorderRadius,
    double? bottomSheetBorderRadius,
    double? dayTileWidth,
    double? dayStripHeight,
    double? timeSlotGridRowHeight,
    int? timeSlotGridCrossAxisCount,
    TextStyle? dayNameStyle,
    TextStyle? dayNumberStyle,
    TextStyle? timeSlotLabelStyle,
    TextStyle? monthHeadingStyle,
    TextStyle? sectionHeadingStyle,
    TextStyle? selectorLabelStyle,
    TextStyle? emptyStateMessageStyle,
    double? bottomSheetInitialSize,
    double? bottomSheetMinSize,
    double? bottomSheetMaxSize,
    Widget Function(BuildContext, VoidCallback?, String)? confirmButtonBuilder,
    WidgetBuilder? loadingBuilder,
  }) {
    return SlotPickerTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      primaryLightColor: primaryLightColor ?? this.primaryLightColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      emptyStateFillColor: emptyStateFillColor ?? this.emptyStateFillColor,
      grey50: grey50 ?? this.grey50,
      grey400: grey400 ?? this.grey400,
      grey500: grey500 ?? this.grey500,
      grey600: grey600 ?? this.grey600,
      grey700: grey700 ?? this.grey700,
      grey900: grey900 ?? this.grey900,
      selectorBorderRadius: selectorBorderRadius ?? this.selectorBorderRadius,
      dayTileBorderRadius: dayTileBorderRadius ?? this.dayTileBorderRadius,
      timeSlotBorderRadius: timeSlotBorderRadius ?? this.timeSlotBorderRadius,
      bottomSheetBorderRadius:
          bottomSheetBorderRadius ?? this.bottomSheetBorderRadius,
      dayTileWidth: dayTileWidth ?? this.dayTileWidth,
      dayStripHeight: dayStripHeight ?? this.dayStripHeight,
      timeSlotGridRowHeight:
          timeSlotGridRowHeight ?? this.timeSlotGridRowHeight,
      timeSlotGridCrossAxisCount:
          timeSlotGridCrossAxisCount ?? this.timeSlotGridCrossAxisCount,
      dayNameStyle: dayNameStyle ?? this.dayNameStyle,
      dayNumberStyle: dayNumberStyle ?? this.dayNumberStyle,
      timeSlotLabelStyle: timeSlotLabelStyle ?? this.timeSlotLabelStyle,
      monthHeadingStyle: monthHeadingStyle ?? this.monthHeadingStyle,
      sectionHeadingStyle: sectionHeadingStyle ?? this.sectionHeadingStyle,
      selectorLabelStyle: selectorLabelStyle ?? this.selectorLabelStyle,
      emptyStateMessageStyle:
          emptyStateMessageStyle ?? this.emptyStateMessageStyle,
      bottomSheetInitialSize:
          bottomSheetInitialSize ?? this.bottomSheetInitialSize,
      bottomSheetMinSize: bottomSheetMinSize ?? this.bottomSheetMinSize,
      bottomSheetMaxSize: bottomSheetMaxSize ?? this.bottomSheetMaxSize,
      confirmButtonBuilder: confirmButtonBuilder ?? this.confirmButtonBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
    );
  }
}
