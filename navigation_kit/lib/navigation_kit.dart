/// navigation_kit
///
/// A project-agnostic, fully customizable bottom navigation bar for Flutter.
///
/// Features:
/// - Typed [NavigationItem] interface — no `dynamic` lists.
/// - Built-in underline and water-drop indicators, plus a custom indicator
///   builder hook.
/// - Optional floating center (FAB-style) item at any index.
/// - RTL aware.
/// - Configurable label behavior (always show / hide / only selected).
/// - Pure `StatefulWidget` — no Riverpod or hooks dependency.
///
/// Quick start:
/// ```dart
/// import 'package:navigation_kit/navigation_kit.dart';
///
/// NavigationKitBar(
///   items: items,
///   selectedIndex: _index,
///   onDestinationSelected: (i) => setState(() => _index = i),
/// );
/// ```
library;

export 'src/items/icon_navigation_item.dart';
export 'src/items/navigation_item.dart';
export 'src/indicators/drop_indicator.dart';
export 'src/indicators/indicator_params.dart';
export 'src/indicators/underline_indicator.dart';
export 'src/navigation_kit_bar.dart';
export 'src/semantics/destination_semantics.dart';
export 'src/types.dart';
