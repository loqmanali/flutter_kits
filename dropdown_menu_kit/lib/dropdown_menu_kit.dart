/// dropdown_menu_kit
///
/// Overlay-based dropdown menu widgets for Flutter.
///
/// - [CustomDropdownMenu] — main HookWidget; owns overlay lifecycle.
/// - [CustomDropdownItem] / [CustomDropdownLabel] / [CustomDropdownSeparator]
///   / [CustomDropdownCheckbox] / [CustomDropdownRadio] — entry types.
/// - [CustomDropdownAlignment] — horizontal alignment relative to trigger.
/// - [DropdownKitTheme] / [DropdownKitThemeData] — app-wide visual defaults.
/// - [DropdownManager] — singleton that enforces single-open behavior.
library;

export 'src/custom_dropdown_menu.dart';
export 'src/dropdown_entries.dart';
export 'src/dropdown_manager.dart';
export 'src/dropdown_panel.dart';
export 'src/dropdown_theme.dart';
