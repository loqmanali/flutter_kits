# context_menu_kit

A project-agnostic context menu for Flutter. Wraps any widget and opens a
floating menu at the tap (or long-press) point — automatically clamped to
stay inside the screen, with nested submenu support.

## Highlights

- **Two trigger modes** — `tap` (desktop / icon button) or `longPress`
  (mobile gesture).
- **Screen-aware positioning** — the menu is laid out once, measured, and
  re-positioned to stay inside the viewport. O(1) clamp per axis.
- **Nested submenus** — `MenuItem.subItems` opens a child menu on hover
  (desktop) or tap (mobile), positioned to the right with the same
  clamping logic.
- **Two item APIs** — pass a `List<MenuItem>` for the built-in row, or a
  `List<CustomMenuItem>` (with your own `build`) for fully custom rows.
- **Optional dividers** between items, custom backgrounds, elevations,
  border radii, and per-item builders.
- **No host-app coupling** — no `AppColors`, no app-wide theme imports.

## Install

```yaml
dependencies:
  context_menu_kit:
    path: ../packages/context_menu_kit
```

```dart
import 'package:context_menu_kit/context_menu_kit.dart';
```

## Quick start

```dart
ContextMenu(
  items: [
    MenuItem(
      title: 'Copy',
      icon: Icons.copy,
      onTap: () => doCopy(),
    ),
    MenuItem(
      title: 'Share',
      icon: Icons.share,
      onTap: () {},
      subItems: [
        MenuItem(title: 'Link',  icon: Icons.link,    onTap: () {}),
        MenuItem(title: 'Image', icon: Icons.image,   onTap: () {}),
      ],
    ),
    MenuItem(
      title: 'Delete',
      icon: Icons.delete,
      iconColor: Colors.red,
      onTap: () => doDelete(),
    ),
  ],
  child: const Icon(Icons.more_vert),
);
```

## Trigger mode

```dart
ContextMenu(
  trigger: MenuTrigger.longPress,
  items: items,
  child: const Text('Long press me'),
);
```

## Custom item rendering

For a single row layout tweak, use `itemBuilder`:

```dart
ContextMenu(
  items: items,
  itemBuilder: (context, item) => MyRow(item: item),
  child: ...,
);
```

For fully custom items (anything that paints itself), implement
`CustomMenuItem`:

```dart
class HeaderItem implements CustomMenuItem {
  @override
  Widget build(BuildContext context) =>
    const Padding(padding: EdgeInsets.all(8), child: Text('Header'));
}

ContextMenu(customItems: [HeaderItem(), ...], child: ...);
```
