# widget_kit gallery

A living catalogue that documents **every widget in `widget_kit`** with a live,
interactive demo, a short description, and copy-able code — like a built-in
Storybook for the kit.

## Run it

```bash
cd packages/widget_kit/example
flutter run            # any device
flutter run -d macos   # desktop
```

The home screen shows a card per category; tap one to open its page.

## What's covered

Each category page documents its widgets with **live demos + descriptions +
copy-able code snippets**:

| Category | Widgets |
| --- | --- |
| Buttons | `AppButton` (10 styles, 3 sizes, loading/disabled, icon, `.fab`), `AppBackButton` |
| Inputs | `AppTextFormField`, `IntlPhoneField`, `showDobPicker` |
| Feedback | `EmptyStateWidget`, `ErrorStateWidget`, `LoadingIndicator`, `ShimmerLayouts`, `ShimmerShape` |
| Dialogs & Toasts | `AppWarningDialog`, `DialogPicker`, `SheetHeader`, `UIHelper` (bottom sheet, toast) |
| Layout | `Accordion`, `AppSpacing`, `PageTopBar`, `ProfilePageLayout` |
| Effects | `CustomStarRating`, `TravelingBorderWidget`, `RefreshTrigger` |
| Dropdown Menu | `CustomDropdownMenu` + item / label / separator / checkbox / radio |
| Context Menu | `ContextMenu` (tap / long-press, submenus, disabled rows) |
| Slot / Time Picker | `InlineSlotTimePicker` (date+time and time-only modes) |
| Theme & Tokens | `WidgetKitTokens`, `WidgetKitTheme` extension |

## How it's organised

```
lib/
  main.dart                 app entry: ToastificationWrapper + WidgetKitTheme +
                            the home catalogue grid
  gallery/
    categories.dart         single source of truth: the category registry that
                            drives both the home grid and routing
    gallery_scaffold.dart   the standard page shell (app bar + padded scroll body)
    demo_section.dart       DemoSection (title + desc + live demo + code) and
                            DemoGroup (a labelled cluster of demos)
    code_block.dart         monospaced snippet with a copy-to-clipboard button
  pages/
    *_page.dart             one page per category, composed entirely of
                            DemoSections — zero layout boilerplate
```

Adding a widget's demo is a one-liner `DemoSection`; adding a whole category is a
single entry in `categories.dart`.

## Setup notes

- **Toasts** need a `ToastificationWrapper` above the app — `main.dart` provides it.
- **Slot picker** date strip needs `initializeDateFormatting()` — called in `main`.
- The webview-based media widgets (`GenericVideoWebview`, `YoutubePlayerWidget`)
  are integration-only and not shown in the gallery.
