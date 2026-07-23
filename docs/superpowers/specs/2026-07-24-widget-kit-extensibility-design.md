# widget_kit Extensibility — Design Spec

**Date:** 2026-07-24
**Status:** Approved, ready for implementation
**Branch:** `feat/widget-kit-extensibility`

## Problem

`widget_kit` is a project-agnostic widget package shared across multiple apps.
Today, customizing a widget's look, behavior, embedded sub-widget, or text
often requires editing the package itself. Concretely:

- `WidgetKitTheme` (a `ThemeExtension`) declares fields for inputs, buttons,
  dialogs, sheets, feedback, shimmer, and media — but **only two widgets**
  (`app_text_form_field`, `app_media_image`) actually read it. The rest use
  hardcoded values.
- Feedback widgets (`LoadingIndicator`, `EmptyStateWidget`, `ErrorStateWidget`)
  hardcode colors/sizes and cannot be swapped for an app's branded version.
- Behavior defaults (e.g. bottom-sheet `useSafeArea`, `useRootNavigator`,
  dialog dismissibility, toast duration) are fixed at each call site.
- `WidgetKitStrings` exists but is only injectable per-widget, never app-wide.

**Goal:** let any consuming app customize styling, behavior, whole sub-widgets
("interface"), and strings from *outside* the package — without editing it and
without breaking anything that currently works.

## Non-goals

- Not wiring all ~90 files. We build the mechanism once and wire the
  high-value, already-themed surface. Extending to any other widget later is a
  ~3-line change, documented.
- No new runtime dependencies.
- No breaking changes to any existing public constructor.

## Core model — resolution order

Every customizable value resolves highest-priority-first:

```
1. Constructor param on the widget instance   (per-instance override)
2. App-level config (WidgetKitTheme / WidgetKitScope)
3. Built-in default baked into widget_kit     (current behavior, unchanged)
```

**Backward-compatibility invariant:** when no constructor param and no
app-level config are provided, resolution MUST end at the exact value the
widget renders today. Nothing changes for existing consumers.

## Architecture — Approach B (chosen)

Two complementary, both-optional layers:

- **Styling → `WidgetKitTheme` (existing `ThemeExtension`).** Stays in
  `ThemeData.extensions`; gets light/dark + `lerp` for free. We only *wire it
  into more widgets* and add any missing fields. Existing behavior untouched.
- **Behavior + Builders + Strings → `WidgetKitScope` (new `InheritedWidget`).**
  Carries a `WidgetKitConfig`. Read via `WidgetKitScope.of(context)`, which
  returns a const fallback when absent (so absence == today's behavior).

Rejected alternatives:
- **A. Everything in one InheritedWidget** — would duplicate the existing
  `WidgetKitTheme` and lose ThemeData/lerp/dark-mode integration for styling.
- **C. Static singleton** — not context-reactive (no subtree overrides, no
  dark-mode reactivity), global mutable state, hard to test.

### New types (Phase 1)

```dart
/// Non-styling app-level config. All fields optional.
class WidgetKitConfig {
  final WidgetKitBehavior behavior;
  final WidgetKitBuilders builders;
  final WidgetKitStrings strings;
  const WidgetKitConfig({
    this.behavior = const WidgetKitBehavior(),
    this.builders = const WidgetKitBuilders(),
    this.strings = WidgetKitStrings.fallback,
  });
}

/// Behavioral defaults. Nullable => "unset, use built-in default".
class WidgetKitBehavior {
  final bool? bottomSheetUseSafeArea;
  final bool? useRootNavigator;
  final bool? dialogBarrierDismissible;
  final bool? bottomSheetIsDismissible;
  final Duration? toastDuration;
  const WidgetKitBehavior({...});
}

/// Slot injection = the "interface". Nullable builders => use built-in widget.
class WidgetKitBuilders {
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, EmptyStateData data)? emptyStateBuilder;
  final Widget Function(BuildContext context, ErrorStateData data)? errorStateBuilder;
  const WidgetKitBuilders({...});
}

/// InheritedWidget carrier.
class WidgetKitScope extends InheritedWidget {
  final WidgetKitConfig config;
  const WidgetKitScope({required this.config, required super.child, super.key});
  static WidgetKitConfig of(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<WidgetKitScope>()?.config
      ?? const WidgetKitConfig();   // fallback == today's behavior
  @override
  bool updateShouldNotify(WidgetKitScope old) => old.config != config;
}
```

`EmptyStateData` / `ErrorStateData` are small immutable structs carrying the
data the built-in widget already receives (icon, title, subtitle, action,
onRetry…), so an app's custom builder has everything it needs. The existing
public widget constructors stay the source of truth for that data.

### Consumer setup (once, at app root)

```dart
MaterialApp(
  theme: ThemeData.light().copyWith(
    extensions: [WidgetKitTheme(primaryButtonColor: ..., sheetBorderRadius: ...)],
  ),
  builder: (context, child) => WidgetKitScope(
    config: WidgetKitConfig(
      behavior: const WidgetKitBehavior(bottomSheetUseSafeArea: true),
      builders: WidgetKitBuilders(loadingBuilder: (ctx) => MyBrandSpinner()),
      strings: const WidgetKitStrings(confirm: 'تأكيد', cancel: 'إلغاء'),
    ),
    child: child!,
  ),
);
```

## Scope of work

### Phase 1 — Foundation (zero behavior change)
- Add `WidgetKitConfig`, `WidgetKitBehavior`, `WidgetKitBuilders`,
  `EmptyStateData`, `ErrorStateData`, `WidgetKitScope` under
  `lib/src/theme/` (or `lib/src/config/`).
- `WidgetKitStrings` already lives in `utils/`; reuse it inside the config.
- Export the new public types from `widget_kit.dart`.
- No existing widget changes yet → `analyze` clean, nothing renders differently.

### Phase 2 — Wire high-value widgets (defaults preserved)
- **Feedback trio:** `LoadingIndicator`, `EmptyStateWidget`, `ErrorStateWidget`
  consult `WidgetKitBuilders` (return the app widget if provided) and read
  colors from `WidgetKitTheme` (`loadingColor`, `emptyStateIconColor`,
  `errorStateIconColor`) instead of hardcoded grey; each falls back to the
  current hardcoded value.
- **`UIHelper`** bottom sheet/dialog/toast: unset params fall back to
  `WidgetKitBehavior` before the current literal default.
- **Wire the already-declared, currently-unused `WidgetKitTheme` fields** into
  their widgets: buttons (`buttonBorderRadius`, `buttonHeight`, colors),
  dialogs (`dialogBorderRadius`, `dialogBackgroundColor`), sheets
  (`sheetBorderRadius`), shimmer (`shimmerBaseColor`, `shimmerHighlightColor`),
  feedback colors. Bounded by the existing field set — not all 90 files.

### Phase 3 — Document the convention
- README section: the resolution order + the one-time consumer setup.
- `EXTENDING.md`: "how to add a new customization hook in ~3 lines"
  (add nullable field → resolve `param ?? config ?? default` → export).

## Backward-compatibility & verification

Guarantees:
- Every new field nullable / optional; every resolution ends at today's value.
- No existing constructor signature changes incompatibly (additive only).
- `WidgetKitScope.of` returns a const fallback when no scope is mounted.

Verification (the "don't break anything" gate):
- `flutter analyze` clean.
- `example/` app still builds.
- Widget tests: for each wired widget, assert it renders the same output with
  no scope/theme mounted (locks the invariant), plus one test proving a
  builder/behavior/theme override takes effect.

## Rollout

One branch, one PR. Commit per phase. Each phase leaves the package green.
