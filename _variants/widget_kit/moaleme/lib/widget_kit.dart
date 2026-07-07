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

// Re-export toastification: it's part of UIHelper.showToast's public API
// (ToastificationType/Style enums) and provides the ToastificationWrapper that
// hosts toasts. Consumers shouldn't need a direct dependency on it.
export 'package:toastification/toastification.dart';

// Layout
export 'src/layout/accordion.dart';
export 'src/layout/app_spacing.dart';
export 'src/layout/page_top_bar.dart';
export 'src/layout/profile_page_layout.dart';

// Media
export 'src/media/app_media_image.dart';
export 'src/media/generic_video_webview.dart';
export 'src/media/youtube_player_widget.dart';

// Dropdown menu
export 'src/dropdown_menu/dropdown_menu.dart';

// Effects
export 'src/effects/custom_star_rating.dart';
export 'src/effects/refresh_trigger.dart';
export 'src/effects/traveling_border_widget.dart';

// Slot / time picker — a date + time-slot selector with bottom-sheet and inline
// modes (merged in from the former standalone slot_time_picker package).
export 'src/slot_time_picker/src/config/slot_date_config.dart'
    show SlotDateConfig, DateDirection, SlotPickerMode;
export 'src/slot_time_picker/src/l10n/slot_picker_labels.dart';
export 'src/slot_time_picker/src/models/slot_item.dart';
export 'src/slot_time_picker/src/theme/slot_picker_theme.dart';
export 'src/slot_time_picker/src/widgets/inline_slot_time_picker.dart'
    show InlineSlotTimePicker, SlotDayLoader;
export 'src/slot_time_picker/src/widgets/slot_time_bottom_sheet_selector.dart'
    show SlotTimeBottomSheetSelector;

// Carousel — image/widget carousel with auto-scroll, indicators, overlays, and
// Riverpod-powered state (merged in from the former standalone carousel_kit).
export 'src/carousel_kit/src/config/auto_scroll_config.dart';
export 'src/carousel_kit/src/config/carousel_config.dart';
export 'src/carousel_kit/src/config/indicator_config.dart';
export 'src/carousel_kit/src/config/layout_config.dart';
export 'src/carousel_kit/src/config/visual_config.dart';
export 'src/carousel_kit/src/models/carousel_item.dart';
export 'src/carousel_kit/src/models/carousel_overlay.dart';
export 'src/carousel_kit/src/models/carousel_state.dart';
export 'src/carousel_kit/src/providers/carousel_controller_provider.dart';
export 'src/carousel_kit/src/providers/carousel_state_provider.dart';
export 'src/carousel_kit/src/widgets/carousel.dart';
export 'src/carousel_kit/src/widgets/carousel_indicator.dart';

// Context menu — tap/long-press popup menu with screen-aware positioning and
// nested submenus (merged in from the former standalone context_menu_kit).
export 'src/context_menu_kit/src/context_menu.dart';
export 'src/context_menu_kit/src/items/custom_menu_item.dart';
export 'src/context_menu_kit/src/items/menu_item.dart';
export 'src/context_menu_kit/src/overlay/menu_overlay_controller.dart';
export 'src/context_menu_kit/src/positioning/menu_position_calculator.dart';
export 'src/context_menu_kit/src/widgets/menu_content.dart';
export 'src/context_menu_kit/src/widgets/menu_submenu.dart';
