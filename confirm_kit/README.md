# confirm_kit

One widget for every "are you sure?" in an app — destructive deletes, permission
prompts, multi-way choices, and actions that must finish before the dialog
closes. Pure Flutter: no `flutter_svg`, no state-management package, no assets.

```dart
if (await const ConfirmDialog(
  title: 'Delete account?',
  message: 'Your orders and addresses are removed permanently.',
  intent: ConfirmIntent.destructive,
).ask(context)) {
  await api.deleteAccount();
}
```

`.ask(context)` returns `Future<bool>` (`false` on cancel **and** on dismissal).
`.show(context)` returns `Future<T?>` when you need the full result.

## Every case it covers

| Case | How |
|---|---|
| Yes / no confirmation | `ConfirmDialog(title: ..., message: ...)` |
| Irreversible action | `intent: ConfirmIntent.destructive` — error accent, `Delete` label |
| Success / warning / info / neutral | `intent:` — accent color + matching default icon |
| Acknowledge only (one button) | `showCancel: false` — label defaults to `OK` |
| Three-way choice, custom result type | `ConfirmDialog<MyEnum>(actions: [...])` |
| Async work before closing | `onConfirm: () async {...}` — in-button spinner, other actions disabled, dialog locked |
| Confirm gated on input | `content:` + `ConfirmAction(enabled: ...)` |
| Extra content (checkbox, list, field) | `content: AnyWidget()` |
| Custom icon (SVG, image, emoji) | `icon: SvgPicture.asset(...)`, `iconBackground: false` |
| No icon | `showIcon: false` |
| Bottom sheet instead of dialog | `surface: ConfirmSurface.sheet` |
| Embedded in a page or card | `surface: ConfirmSurface.bare` |
| User must choose (no barrier/back dismissal) | `dismissible: false` |
| Material order vs. confirm-first | `confirmFirst: true` |
| Centered or start-aligned content | `alignment: ConfirmAlignment.start` |
| Buttons side by side or stacked | `actionsLayout:` — `auto` stacks beyond two actions |
| Button weight | `ConfirmActionStyle.filled / tonal / outlined / text` |
| Localized labels | `ConfirmStrings` per dialog or once on the theme |
| App-wide styling | `ConfirmKitTheme` on `ThemeData.extensions` |

## App-wide theme

```dart
MaterialApp(
  theme: ThemeData.light().copyWith(
    extensions: [
      ConfirmKitTheme(
        borderRadius: 20,
        actionBorderRadius: 12,
        destructiveColor: const Color(0xFFD53B3B),
        strings: ConfirmStrings(
          confirm: l10n.confirm,
          cancel: l10n.cancel,
          delete: l10n.delete,
          ok: l10n.ok,
        ),
      ),
    ],
  ),
);
```

Unset fields fall back to `ConfirmKitTheme.fallback`, and unset colors fall back
to the ambient `ColorScheme` — so the kit follows light/dark automatically.
Anything passed on a single dialog wins over the theme.

`success` and `warning` have no `ColorScheme` role, so they carry literal
defaults (`#2E7D32`, `#E8A33D`). Override them if your brand disagrees.

## Recipes

**Async action, no dismissal until it settles**

```dart
await ConfirmDialog(
  title: 'Cancel order #1042?',
  intent: ConfirmIntent.destructive,
  dismissible: false,
  confirmText: 'Cancel order',
  cancelText: 'Keep it',
  onConfirm: () => api.cancelOrder(1042),
).show(context);
```

**Three-way choice**

```dart
final choice = await const ConfirmDialog<SaveChoice>(
  title: 'Unsaved changes',
  intent: ConfirmIntent.warning,
  actions: [
    ConfirmAction(label: 'Save', result: SaveChoice.save),
    ConfirmAction.destructive(
      label: 'Discard',
      result: SaveChoice.discard,
      style: ConfirmActionStyle.tonal,
    ),
    ConfirmAction.cancel(
      label: 'Keep editing',
      result: SaveChoice.keep,
      style: ConfirmActionStyle.text,
    ),
  ],
).show(context);
```

**Your own icon asset**

```dart
ConfirmDialog(
  title: 'Delete address?',
  intent: ConfirmIntent.destructive,
  icon: SvgPicture.asset(AppSvgIcons.alertIcon, height: 48),
  iconBackground: false,
)
```

**Plain `showDialog`** — the widget is an ordinary widget, so existing call
sites keep working:

```dart
final ok = await showDialog<bool>(
  context: context,
  builder: (_) => const ConfirmDialog(title: 'Log out?'),
);
```

## Notes

- In `ConfirmSurface.bare` the widget never pops a route — actions only run
  their `onPressed`, because popping would dismiss the host page.
- An action with `autoPop: false` is responsible for closing the route itself.
- A running async action blocks the barrier, the drag and the system back
  button on its own, whatever `dismissible` says.
- Long content scrolls instead of overflowing; the sheet lifts above the
  software keyboard, so a `TextField` in `content` stays visible.

## Install

```yaml
dependencies:
  confirm_kit:
    git:
      url: https://github.com/loqmanali/flutter_kits.git
      path: confirm_kit
      ref: v1.0.0
```

Run the gallery of every case with `cd example && flutter run`.
