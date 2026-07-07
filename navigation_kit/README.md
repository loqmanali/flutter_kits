# navigation_kit

A project-agnostic bottom navigation bar for Flutter. Drop into any project —
no host-app theming, colors, or localization required.

## Highlights

- **Typed items** via the `NavigationItem` interface — no `dynamic` lists, no
  runtime `is`-checks at the call site.
- **Two built-in indicators** — a sliding underline and an animated water-drop —
  plus an `indicatorBuilder` hook for fully custom indicators.
- **Optional floating center item** (FAB-style) at any index, with its own
  size, color, elevation, and tap override.
- **RTL aware** — the drop indicator and center positioning mirror correctly.
- **Configurable label behavior** — always show, always hide, or only when
  selected.
- **Pure `StatefulWidget`** — no Riverpod / no hooks dependency.

## Install

```yaml
dependencies:
  navigation_kit:
    path: ../packages/navigation_kit
```

```dart
import 'package:navigation_kit/navigation_kit.dart';
```

## Quick start

```dart
final items = <NavigationItem>[
  IconNavigationItem(
    icon: const Icon(Icons.home_outlined),
    activeIcon: const Icon(Icons.home),
    label: 'Home',
  ),
  IconNavigationItem(
    icon: const Icon(Icons.search),
    activeIcon: const Icon(Icons.search),
    label: 'Search',
  ),
  IconNavigationItem(
    icon: const Icon(Icons.person_outline),
    activeIcon: const Icon(Icons.person),
    label: 'Profile',
  ),
];

NavigationKitBar(
  items: items,
  selectedIndex: _index,
  onDestinationSelected: (i) => setState(() => _index = i),
);
```

## Indicators

```dart
// Default underline (shown when showDefaultIndicator: true)
NavigationKitBar(showDefaultIndicator: true, ...);

// Animated water-drop
NavigationKitBar(showDropIndicator: true, ...);

// Custom indicator
NavigationKitBar(
  indicatorBuilder: (context, params) => MyCustomIndicator(params: params),
  ...
);
```

Only one indicator renders at a time: `indicatorBuilder` wins over
`showDropIndicator`, which wins over `showDefaultIndicator`.

## Floating center item

```dart
NavigationKitBar(
  items: items, // include a center item somewhere in the list
  selectedIndex: _index,
  onDestinationSelected: (i) => setState(() => _index = i),
  centerItemIndex: 2,
  centerItemSize: 56,
  centerItemBackground: Colors.amber,
);
```

## Custom items

Implement `NavigationItem` to render anything you want inside a slot:

```dart
class BadgeNavItem implements NavigationItem {
  BadgeNavItem({required this.icon, required this.activeIcon, required this.label, required this.badge});

  @override final Widget icon;
  @override final Widget activeIcon;
  @override final String label;
  final int badge;

  @override
  Widget build(BuildContext context, NavigationItemState state) {
    // … render with state.isSelected, state.activeColor, state.inactiveColor …
  }
}
```
