# Customizing widget_kit from your app

The goal: customize how kit widgets look, behave, what sub-widget they embed,
and what text they show **from the consuming app** — without editing this
package.

## Resolution order

Every customizable value resolves highest-priority-first:

```
1. Constructor param on the widget instance   (per call-site)
2. App-level config: WidgetKitTheme / WidgetKitScope
3. Built-in default baked into widget_kit
```

If you set nothing, you get widget_kit's built-in look and behavior — exactly.

## The four axes

| Axis | Where you set it | Examples |
|------|------------------|----------|
| **Style** (colors, radii, sizes) | `WidgetKitTheme` in `ThemeData.extensions` | `primaryButtonColor`, `dialogBorderRadius`, `loadingColor`, `shimmerBaseColor` |
| **Behavior** (defaults) | `WidgetKitScope` → `WidgetKitBehavior` | `bottomSheetUseSafeArea`, `bottomSheetIsDismissible`, `dialogBarrierDismissible` |
| **Whole-widget injection** ("interface") | `WidgetKitScope` → `WidgetKitBuilders` | `loadingBuilder`, `emptyStateBuilder`, `errorStateBuilder` |
| **Strings** | `WidgetKitScope` → `WidgetKitStrings` | `confirm`, `cancel`, `retry`, `search`, `done`, `noResults` |

Style lives in a `ThemeExtension` (so it gets light/dark + animated `lerp` for
free). The other three ride on an `InheritedWidget` (`WidgetKitScope`).

## One-time setup at your app root

```dart
MaterialApp(
  // 1) Styling — a ThemeExtension.
  theme: ThemeData.light().copyWith(
    extensions: const [
      WidgetKitTheme(
        primaryButtonColor: Color(0xFF104C65),
        dialogBorderRadius: 20,
        loadingColor: Color(0xFF104C65),
      ),
    ],
  ),
  // 2) Behavior + injection + strings — one WidgetKitScope near the root.
  builder: (context, child) => WidgetKitScope(
    config: WidgetKitConfig(
      behavior: const WidgetKitBehavior(bottomSheetUseSafeArea: true),
      builders: WidgetKitBuilders(
        loadingBuilder: (ctx) => const MyBrandSpinner(),
        emptyStateBuilder: (ctx, data) => MyEmptyState(
          title: data.title,
          subtitle: data.subtitle,
          onAction: data.onAction,
        ),
      ),
      strings: const WidgetKitStrings(confirm: 'تأكيد', cancel: 'إلغاء'),
    ),
    child: child!,
  ),
);
```

A custom builder receives a data object (`EmptyStateData`, `ErrorStateData`)
carrying everything the built-in widget would — so your widget can render
however you like with the same inputs.

## Adding a new customization hook (~3 lines)

When you hit a value that isn't yet customizable, add a hook here once and
every app can drive it from outside. The pattern, e.g. for a new behavior flag:

1. **Declare** a nullable field in the relevant config class
   (`WidgetKitBehavior` / `WidgetKitBuilders` / `WidgetKitTheme`):
   ```dart
   final bool? myNewFlag;   // null == use built-in default
   ```
2. **Resolve** it at the widget's build site, keeping the current literal as the
   final fallback so nothing changes when it's unset:
   ```dart
   final flag = param ?? WidgetKitScope.of(context).behavior.myNewFlag ?? false;
   ```
3. That's it — it's already exported. For a whole-widget slot, add a
   `Widget Function(...)?` to `WidgetKitBuilders` and return it early when set.

**Invariant:** every new field is nullable/optional and every resolution ends
at the existing built-in default. Absent config == today's behavior. That's how
we add extension points without breaking any app already on widget_kit.

## What is intentionally NOT wired here

- **Buttons** have their own `AppButtonThemeExtension` (per-style colors,
  elevation, borders) — customize buttons through that, not `WidgetKitTheme`.
- **Bottom-sheet corner radius** defers to Flutter's `BottomSheetThemeData` —
  set it on your app theme.
