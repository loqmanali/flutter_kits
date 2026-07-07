/// widget_kit
///
/// A project-agnostic collection of reusable Flutter widgets for buttons,
/// inputs, dialogs, feedback states, media, shimmer, and effects.
///
/// Drop-in for any project. Customize per-instance via constructor params,
/// or app-wide by registering a [WidgetKitTheme] on your `ThemeData`:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData.light().copyWith(
///     extensions: const [
///       WidgetKitTheme(
///         inputBorderRadius: 12,
///         primaryButtonColor: Color(0xFF104C65),
///       ),
///     ],
///   ),
/// );
/// ```
library;

// Theme / tokens
export 'src/theme/widget_kit_theme.dart';
export 'src/theme/widget_kit_tokens.dart';

// Utils
export 'src/utils/widget_kit_localization.dart';

// Buttons
export 'src/buttons/adaptive_button/adaptive_button.dart';
export 'src/buttons/app_back_button.dart';

// Inputs
export 'src/inputs/app_text_form_field.dart';
export 'src/inputs/dob_picker/dob_picker.dart';
export 'src/inputs/phone_field/countries.dart';
export 'src/inputs/phone_field/country_flag_button.dart';
export 'src/inputs/phone_field/country_picker_dialog.dart';
export 'src/inputs/phone_field/flutter_intl_phone_field.dart';
export 'src/inputs/phone_field/phone_number.dart';

// Feedback
export 'src/feedback/adaptive_loading.dart';
export 'src/feedback/empty_state_widget.dart';
export 'src/feedback/error_state_widget.dart';
export 'src/feedback/shimmer/flexible_shimmer_loading.dart';
export 'src/feedback/shimmer/language_sheet_shimmer.dart';
export 'src/feedback/shimmer/shimmer_layouts.dart';
export 'src/feedback/shimmer/shimmer_shape.dart';
export 'src/feedback/shimmer/shimmer_shape_type.dart';

// Dialogs
export 'src/dialogs/app_warning_dialog.dart';
export 'src/dialogs/dialog_picker.dart';
export 'src/dialogs/sheet_header.dart';
export 'src/dialogs/ui_helper.dart';

// Layout
export 'src/layout/accordion.dart';
export 'src/layout/app_spacing.dart';
export 'src/layout/page_top_bar.dart';
export 'src/layout/profile_page_layout.dart';

// Media
export 'src/media/app_media_image.dart';
export 'src/media/generic_video_webview.dart';
export 'src/media/youtube_player_widget.dart';

// Effects
export 'src/effects/animated_svg/animated_svg_widget.dart';
export 'src/effects/custom_star_rating.dart';
export 'src/effects/refresh_trigger.dart';
export 'src/effects/traveling_border_widget.dart';
