/// context_menu_kit
///
/// A project-agnostic context-menu module for Flutter. Wraps any widget,
/// opens a floating menu at the tap (or long-press) point, supports nested
/// submenus, screen-edge clamping, custom item builders, and a typed
/// `CustomMenuItem` interface for fully custom rows.
///
/// Quick start:
/// ```dart
/// import 'package:context_menu_kit/context_menu_kit.dart';
///
/// ContextMenu(
///   items: [
///     MenuItem(title: 'Copy',   icon: Icons.copy,   onTap: doCopy),
///     MenuItem(title: 'Delete', icon: Icons.delete, onTap: doDelete),
///   ],
///   child: const Icon(Icons.more_vert),
/// );
/// ```
library;

export 'src/context_menu.dart';
export 'src/items/custom_menu_item.dart';
export 'src/items/menu_item.dart';
export 'src/overlay/menu_overlay_controller.dart';
export 'src/positioning/menu_position_calculator.dart';
export 'src/widgets/menu_content.dart';
export 'src/widgets/menu_submenu.dart';
