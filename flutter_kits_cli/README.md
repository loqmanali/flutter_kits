# fkit — the flutter_kits CLI

Browse the kits, add them to a project with the right git ref, and generate the
theming boilerplate they expect.

## Install

```bash
dart pub global activate --source git \
  https://github.com/loqmanali/flutter_kits.git --git-path flutter_kits_cli
```

Make sure `~/.pub-cache/bin` is on your `PATH`. While developing the CLI itself:

```bash
cd packages/flutter_kits_cli
dart pub global activate --source path .
```

## Commands

| Command | What it does |
|---|---|
| `fkit ls` | Every kit, its version and blurb; `●` marks the ones this project uses. `-i` filters to those. |
| `fkit add <kit...>` | Writes the git dependency block(s) into `pubspec.yaml` and runs `flutter pub get`. No arguments opens a multi-select. |
| `fkit remove <kit...>` | Drops kits from `pubspec.yaml`. |
| `fkit theme --primary <hex>` | Generates `lib/theme/kits_theme.dart` — `WidgetKitTheme` **and** `AppButtonThemeExtension`, all ten button styles derived from your brand colour. |
| `fkit snippet ls` | Lists the ready-made files you can copy in. |
| `fkit snippet create <name...>` | Copies them into the project. No arguments opens a multi-select. |
| `fkit style ls` | Lists the per-widget style templates. |
| `fkit style create <name...>` | Generates one widget's styling boilerplate, every value spelled out. `--all` for the lot. |
| `fkit doctor` | Checks the setup for the mistakes that actually happen (see below). |

## The full guide

A complete, searchable guide lives in [`guide/`](guide/). It is static HTML —
open `guide/index.html` in a browser, no server or build step needed.

### Useful flags

```bash
fkit add widget_kit --dry-run          # print the resulting pubspec, write nothing
fkit add widget_kit --ref v1.1.13      # pin to a specific tag, branch, or commit
fkit add widget_kit --path ../kits     # local path deps, for working on the kits
fkit add widget_kit --force            # replace an existing entry
fkit add widget_kit --no-pub-get       # edit only
```

## Why `ref:` is not the kit's version

Tags in this repo are **monorepo releases** (`v2.0.0`). A kit's own version is
separate: `widget_kit` is at `1.2.0`, and it ships *inside* the `v2.0.0` tag.
Pinning `ref: v1.2.0` fails, because no such tag exists.

`fkit add` writes the right tag. `fkit doctor` catches it when something else
wrote the wrong one.

## What `doctor` checks

- A `ref:` that looks like a package version — the mistake above.
- A missing `ref:`, which silently floats on the default branch.
- A kit declared as a pub.dev version constraint; these are not published.
- A local `path:` dependency, which breaks for everyone else once committed.
- `widget_kit` installed with no `AppButtonThemeExtension` anywhere in `lib/`.
  `AppButton` does **not** read `WidgetKitTheme`, and its built-in defaults are
  the brand red and orange of the app the kit was extracted from — so without
  that extension every button in your app ships red. `fkit theme` fixes it.

## Keeping the catalog current

The kit list is compiled into the CLI, because it runs inside *your* project and
cannot read the monorepo. Regenerate it from the kits' pubspecs and the newest
git tag after adding a kit or cutting a release:

```bash
cd packages/flutter_kits_cli
dart run tool/sync_catalog.dart
```

That rewrites `lib/src/catalog.g.dart`. Setup notes live in
`lib/src/kit.dart` and are never touched by regeneration.

## Adding a snippet or style

Neither is stored as a string here. Each is a real Dart file under
`packages/docs/lib/` — `snippets/` or `styles/` — where `flutter analyze`
compiles it against the actual kits. A template that stops matching a kit's API
fails the build instead of shipping broken.

1. Add `packages/docs/lib/{snippets,styles}/<name>.dart` with a metadata header:

   ```dart
   // template: my-thing
   // description: One line, shown by `fkit snippet ls`.
   // kits: widget_kit
   // pub: hooks_riverpod        // optional; pub.dev packages it imports
   // output: lib/widgets/my_thing.dart
   ```

2. `cd packages/docs && flutter analyze lib` — it must be clean.
3. `cd packages/flutter_kits_cli && dart run tool/sync_templates.dart`

## Tests

```bash
cd packages/flutter_kits_cli
dart test
```
