# toast_kit

A project-agnostic toast/notification kit for Flutter. Queued, deduped,
theme-able — and built around one guarantee the others don't make: a toast's
auto-dismiss timer only starts once it has actually been painted, so one
shown while the app is occluded (a native permission dialog, an
`AlertDialog`, a screen-off moment) is never burned through unseen, and never
gets stuck either.

## Highlights

- **The frame-occlusion guarantee.** `ToastController.markShown` — called
  from the toast widget's own post-frame callback — is the only thing that
  starts the countdown. A `dismiss()` that arrives before that removes the
  toast from its queue outright, so a late `markShown` can never resurrect
  it. See `test/presentation/toast_host_test.dart`'s
  *"the frame-occlusion regression"* test.
- **Context-less use**, the same way `ScaffoldMessenger` does it: the app
  owns a `GlobalKey<ToastHostState>` and calls `.show()` on it from anywhere.
- **Five built-in layouts** — `flat`, `filled`, `outlined`, `minimal`,
  `banner` — registered by key, overridable per-app or per-toast.
- **Dedupe + queueing.** Identical toasts within a window (default 1.5s) are
  dropped, not stacked; each placement shows up to 3 at once (configurable)
  and queues the rest.
- **RTL by construction** — `EdgeInsetsDirectional`, `AlignmentDirectional`,
  `start`/`end` throughout; a start-anchored toast in Arabic sits on the
  physical right.
- **Accessible by default** — `Semantics(liveRegion: true)`, a screen reader
  keeps a timed toast up until dismissed (mirrors `SnackBar`), and
  `MediaQuery.disableAnimationsOf` skips all motion.
- **No third-party dependencies.** Flutter SDK only.

## Install

```yaml
dependencies:
  toast_kit:
    path: ../packages/toast_kit
```

## Host setup

Put `ToastHost` in `MaterialApp.builder`, above the `Navigator`, so toasts
survive route pushes, pops and dialogs:

```dart
final toastKey = GlobalKey<ToastHostState>();

MaterialApp(
  builder: (context, child) => ToastHost(key: toastKey, child: child!),
  home: const HomeScreen(),
);
```

## Showing a toast

With a `BuildContext`:

```dart
ToastHost.of(context).show(
  const ToastRequest(title: 'Saved', tone: ToastTone.success),
);
```

Context-less, from anywhere (a repository, a background callback) — the same
shape as `scaffoldMessengerKey`:

```dart
toastKey.currentState!.show(
  const ToastRequest(title: 'Upload failed', tone: ToastTone.error),
);
```

`show()` returns a `ToastHandle`:

```dart
final handle = ToastHost.of(context).show(
  const ToastRequest(title: 'Item removed', duration: null),
);
final reason = await handle.closed; // ToastDismissReason
handle.dismiss(); // or dismiss it yourself
```

## Theming

Everything is a `ToastKitTheme` `ThemeExtension` — every field is nullable
and falls back to `ToastKitTheme.fallback`, so an app only overrides what it
needs to:

```dart
MaterialApp(
  theme: ThemeData.light().copyWith(
    extensions: const [
      ToastKitTheme(
        defaultLayoutKey: 'filled',
        defaultPlacement: ToastPlacement.bottomCenter,
        borderRadius: 16,
        successColor: Color(0xFF2E7D32),
      ),
    ],
  ),
);
```

A tone's *accent* is the one color you set (`successColor`, `errorColor`,
`warningColor`, `infoColor`, `neutralColor`); its background, border, icon
and a readable foreground are all derived from that accent and the ambient
`ColorScheme` by measured WCAG contrast — the same approach `confirm_kit`'s
`ConfirmKitTheme` uses for a destructive button's label.

Strings (the close button's semantics label, the live-region prefix a screen
reader hears) live on `ToastStrings`, passed via `ToastKitTheme(strings:
...)`. The kit ships English defaults and owns no translations.

## Custom layout

Implement `ToastLayout` and register it on the theme:

```dart
final class MyLayout implements ToastLayout {
  const MyLayout();
  @override
  Widget build(BuildContext context, ToastView view) => MyToastWidget(view: view);
}

ToastKitTheme(layouts: {'mine': const MyLayout()});
```

An app's `layouts` map is *merged* over the five built-ins, so overriding one
key never loses the others. `ToastView` carries the resolved request, the
tone's colors, a remaining-progress `Animation<double>`, and `onClose`/
`onAction` callbacks — a layout only draws, it never touches the controller.

## Previews

`lib/src/presentation/previews/toast_kit_previews.dart` (not exported from
the barrel) has `@Preview` functions for every layout × tone, an RTL
5-line-Arabic-title case, dark brightness, `textScaleFactor: 2.0`, a stack of
3 at top and bottom, and action+close together. Open with:

```
flutter widget-preview start
```

## DevTools

In debug/profile builds only, `ToastHost` registers three service
extensions once a host is mounted:

- `ext.toast_kit.show` — params `title`, `tone`, `duration` (ms), `layout`.
- `ext.toast_kit.dismissAll`
- `ext.toast_kit.state` — JSON of every placement's visible/pending toasts.

Every lifecycle transition also logs via `dart:developer`'s `log(name:
'toast_kit')` and posts a `'toast_kit.lifecycle'` event — no `print()`
anywhere in the kit.

## Architecture

- `lib/toast_kit.dart` — the one public barrel.
- `lib/src/domain/` — pure Dart value types and enums (`ToastRequest`,
  `ToastTone`, `ToastPlacement`, `ToastDismissReason`, `ToastPolicy`,
  `ToastClock`). No Flutter import, not even `foundation.dart`.
- `lib/src/application/` — `ToastController`, pure Dart: queues, dedupe,
  the Pending → Visible → Leaving → Removed lifecycle, `ToastHandle`.
- `lib/src/presentation/` — `ToastHost`, `ToastItemWidget`, `ToastKitTheme`,
  `ToastCard` and the five built-in layouts. Every widget is a class.

Run the suite from this package's directory:

```
flutter test
```
