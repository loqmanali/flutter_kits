import 'package:flutter/material.dart';

import '../pages/buttons_page.dart';
import '../pages/context_menu_page.dart';
import '../pages/dialogs_page.dart';
import '../pages/dropdown_page.dart';
import '../pages/effects_page.dart';
import '../pages/feedback_page.dart';
import '../pages/inputs_page.dart';
import '../pages/layout_page.dart';
import '../pages/slot_picker_page.dart';
import '../pages/theme_page.dart';

/// One catalogue entry: a category of widgets and the page that documents them.
///
/// This is the single source of truth for both the home grid and routing —
/// add a category here and it shows up everywhere automatically.
class GalleryCategory {
  const GalleryCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.build,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  /// Builds the page for this category. (No-arg so the list stays `const` via
  /// top-level function tear-offs.)
  final Widget Function() build;
}

// Top-level tear-offs keep the [galleryCategories] list const-evaluable.
Widget _buttons() => const ButtonsPage();
Widget _inputs() => const InputsPage();
Widget _feedback() => const FeedbackPage();
Widget _dialogs() => const DialogsPage();
Widget _layout() => const LayoutPage();
Widget _effects() => const EffectsPage();
Widget _dropdown() => const DropdownPage();
Widget _contextMenu() => const ContextMenuPage();
Widget _slotPicker() => const SlotPickerPage();
Widget _theme() => const ThemePage();

/// Every documented category, in display order.
const List<GalleryCategory> galleryCategories = [
  GalleryCategory(
    title: 'Buttons',
    subtitle: 'AppButton styles, sizes, states, FAB, back button',
    icon: Icons.smart_button,
    color: Color(0xFFDC1213),
    build: _buttons,
  ),
  GalleryCategory(
    title: 'Inputs',
    subtitle: 'Text field, phone field, date-of-birth picker',
    icon: Icons.edit,
    color: Color(0xFF104C65),
    build: _inputs,
  ),
  GalleryCategory(
    title: 'Feedback',
    subtitle: 'Empty / error states, loading indicators, shimmer',
    icon: Icons.feedback_outlined,
    color: Color(0xFFF49B25),
    build: _feedback,
  ),
  GalleryCategory(
    title: 'Dialogs & Toasts',
    subtitle: 'Warning dialog, picker dialog, sheet header, toasts',
    icon: Icons.chat_bubble_outline,
    color: Color(0xFF7B61FF),
    build: _dialogs,
  ),
  GalleryCategory(
    title: 'Layout',
    subtitle: 'Accordion, spacing, top bar, profile layout',
    icon: Icons.dashboard_outlined,
    color: Color(0xFF2E7D32),
    build: _layout,
  ),
  GalleryCategory(
    title: 'Effects',
    subtitle: 'Star rating, refresh trigger, traveling border',
    icon: Icons.auto_awesome,
    color: Color(0xFFE91E63),
    build: _effects,
  ),
  GalleryCategory(
    title: 'Dropdown Menu',
    subtitle: 'Items, labels, separators, checkboxes, radios',
    icon: Icons.arrow_drop_down_circle_outlined,
    color: Color(0xFF00897B),
    build: _dropdown,
  ),
  GalleryCategory(
    title: 'Context Menu',
    subtitle: 'Tap / long-press, submenus, custom rows',
    icon: Icons.more_vert,
    color: Color(0xFF8D6E63),
    build: _contextMenu,
  ),
  GalleryCategory(
    title: 'Slot / Time Picker',
    subtitle: 'Inline and bottom-sheet date + time-slot selection',
    icon: Icons.schedule,
    color: Color(0xFF0277BD),
    build: _slotPicker,
  ),
  GalleryCategory(
    title: 'Theme & Tokens',
    subtitle: 'Design tokens and the WidgetKitTheme extension',
    icon: Icons.palette_outlined,
    color: Color(0xFF6A1B9A),
    build: _theme,
  ),
];
