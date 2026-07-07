/// selection_kit
///
/// Themable selection-control widgets for Flutter.
///
/// - [SelectionOption] — shared option model for radio + checkbox.
/// - [AppRadioGroup] / [AppRadio] — single-select.
/// - [AppCheckboxGroup] / [AppCheckbox] — multi-select.
/// - [SelectionKitTheme] / [SelectionKitThemeData] — app-wide defaults.
library;

export 'src/checkbox/app_checkbox.dart';
export 'src/checkbox/app_checkbox_group.dart';
export 'src/internal/selection_indicators.dart'
    show RadioIndicator, CheckboxIndicator, SelectionIndicatorBuilder;
export 'src/models/selection_option.dart';
export 'src/radio/app_radio.dart';
export 'src/radio/app_radio_group.dart';
export 'src/theme/selection_kit_theme.dart';
