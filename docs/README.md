# flutter_kits docs

A forui.dev-style documentation & showcase app, built with **Flutter Web**. Every
kit ships with a live preview and copyable code, organized in a sidebar tree.

Currently documents **otp_kit**; the same shell is reused as more kits are added.

## Run it

```bash
cd packages/docs
flutter pub get
flutter run -d chrome
```

## Build a static site

```bash
flutter build web
# output: build/web — deploy anywhere static (GitHub Pages, Netlify, …)
```

## How it's organized

```
lib/
  main.dart                 app entry: theme (light/dark) + router + ProviderScope
  router.dart               flat route resolution from the catalog + home page
  theme/docs_theme.dart     light/dark ThemeData (neutral zinc palette)
  shell/                    persistent layout: sidebar, top bar, theme toggle
  core/                     building blocks: PreviewTabs (Preview/Code toggle),
                            DemoSection, CodeBlock (copy), ApiTable, ComponentPage
  data/
    docs_catalog.dart       KitEntry / PageEntry models
    catalog.dart            the single source of truth — kits + pages in order
  content/<kit>/sections/   one file per documented page
  content/<kit>/snippets/   hand-written code strings shown under each demo
```

## Add a kit

1. Create `lib/content/<kit>/sections/*.dart` (one file per page; each returns a
   `ComponentPage` body).
2. Create `lib/content/<kit>/snippets/*.dart` with the copyable code strings.
3. Append a `KitEntry` to `catalog` in `lib/data/catalog.dart`.

The sidebar, router, and home page all update automatically.

## Conventions

- **Preview/Code = tabs** (forui-style), not stacked.
- **Snippets are hand-written** to stay minimal and copyable; verify they match
  the kit's real API when it changes.
- The OTP widgets adapt to `Theme.of(context)`, so the theme toggle in the top
  bar flips the documented widgets live.
