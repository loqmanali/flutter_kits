# flutter_kits

Single source of truth for all shared `*_kit` Flutter packages. One folder per
package. Apps consume kits as **git dependencies pinned to a ref** — never by
copying folders into the app repo.

```yaml
dependencies:
  widget_kit:
    git:
      url: https://github.com/loqmanali/flutter_kits.git
      path: widget_kit
      ref: v1.0.0   # tag or commit SHA — bump deliberately, per app
```

While actively developing a kit alongside an app, override locally (keep the
committed pubspec pointing at git):

```yaml
# pubspec_overrides.yaml (git-ignored)
dependency_overrides:
  widget_kit:
    path: ../packages/widget_kit
```

## Rules

1. Never edit a kit inside an app repo. Edit here, commit, tag.
2. Apps pin a `ref:` and upgrade with `flutter pub upgrade <kit>` when ready.
3. New kit = new folder here from day one.

## Status

Consolidated and analyzer-clean: logging_kit (tag now configurable via
`AppLogger.setTag`), local_db_kit, notify_kit, storage_kit (see git log for
per-kit migration notes), plus all kits that were byte-identical across
projects: localization, deep_link, carousel, map, context_menu, selection,
navigation, dropdown_menu, system_ui, firebase, and the single-copy kits
(animation, commerce, force_update_gate).

Still pending merge — raw forks preserved under `_variants/` (and forever in
git history, see `_variants/README.md`):

- **widget_kit** — 7 forks, all divergent; biggest job. Suggested base:
  granzia_b2b (93 files), fold in samnan/moaleme/health_connect diffs.
- **api_kit / flutter_api_kit** — 3 lineages; pick one API, port the rest.
- **otp_kit** — health_connect v3 vs samnan v1 (~420 unique lines to review).
- **notification_kit** — legacy generation, superseded by notify_kit; keep
  frozen for apps that still use it.
- **navigation_kit/notification_admin** — different product sharing the name;
  rename (e.g. admin_nav_kit) or keep app-local.

## Follow-ups

- notify_kit: eload's fork carries a flutter_local_notifications v18→v21
  migration worth adopting (in `_variants` history).
- storage_kit / notify_kit: hardcoded app-specific keys (health insights,
  gemini prompts) could move behind a config surface.
