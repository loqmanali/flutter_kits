# flutter_kits

A monorepo of shared Flutter packages ("kits") — one folder per package.
Consume kits as **git dependencies pinned to a ref**:

```yaml
dependencies:
  widget_kit:
    git:
      url: https://github.com/loqmanali/flutter_kits.git
      path: widget_kit
      ref: v1.1.0   # tag or commit SHA — bump deliberately, per app
```

While actively developing a kit alongside an app, override locally (keep the
committed pubspec pointing at git):

```yaml
# pubspec_overrides.yaml (git-ignored)
dependency_overrides:
  widget_kit:
    path: ../flutter_kits/widget_kit
```

## Packages

| Kit | What it is |
|---|---|
| `api_kit` | Dio-based API client: auth interceptor with concurrency-safe token refresh, error→failure mapping, force-update handling, response readers |
| `widget_kit` | UI toolkit: buttons, inputs, dialogs/toasts (UIHelper), carousel, dropdowns, slot/time picker, shimmer, animated SVG, and more |
| `notify_kit` | Lightweight FCM + local notifications facade with offline scheduling and campaign open-tracking hooks |
| `storage_kit` | Pluggable key-value storage facade (SharedPreferences/Hive adapters) with usage inspector |
| `local_db_kit` | Drift/SQLite local database with optional SQLCipher encryption and sync bookkeeping |
| `otp_kit` | OTP input field (single-hidden-field architecture), themes, resend cooldown, RTL support |
| `logging_kit` | Tiny static logger (`AppLogger`) — levels, custom handler, configurable tag |
| `localization_kit` | Locale switching providers + persistence |
| `navigation_kit` | Navigation helpers |
| `deep_link_kit` | Deep-link parsing/dispatch |
| `map_kit` | Map widgets + OSRM/Nominatim helpers (bring your own server) |
| `carousel_kit` | Standalone image/content carousel |
| `firebase_kit` | Firebase auth/data-source wrappers |
| `selection_kit`, `dropdown_menu_kit`, `context_menu_kit`, `system_ui_kit`, `animation_kit`, `commerce_kit`, `force_update_gate` | Smaller focused kits |

## Rules

1. Never edit a kit inside an app repo. Edit here, commit, tag.
2. Apps pin a `ref:` and upgrade with `flutter pub upgrade <kit>` when ready.
3. New kit = new folder here from day one.

## Quality bar

Every kit passes `dart analyze` clean; kits with test suites keep them green
(`otp_kit`, `widget_kit`, and others). Formatting is `dart format` standard.
