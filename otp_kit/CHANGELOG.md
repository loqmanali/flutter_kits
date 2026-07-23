# Changelog

All notable changes to the OTP Module will be documented in this file.

## [3.1.0] - 2026-07-23

### Added

- `OTPConfig.successColor` — border color applied when every cell is
  filled without an error (the "valid" state). Defaults to null, so
  existing configs keep using `activeColor`/`inactiveColor` for
  completed cells.

## [3.0.0] - 2026-07-06

Internal rewrite of `OTPTextField` for mobile-soft-keyboard correctness.
The public API (`OTPTextField`, `OTPConfig`, `OTPTheme`) is unchanged.

### Fixed

- **Backspace now works on mobile soft keyboards.** The old N-TextFields
  design relied on `KeyboardListener`, which iOS/Android soft keyboards do
  not trigger on an empty field — deletes silently did nothing. The widget is
  now backed by a **single hidden text field** with painted cells: backspace
  deletes natively and the active cell walks back.
- **Keyboard no longer flickers/dismisses while typing.** No more per-cell
  focus hops; there is only one focus node.
- **Stale state across screens.** `otpControllerProvider` is now
  `autoDispose` (plus a defensive clear on mount). Previously, digits typed
  on one screen survived into the next mount with an equal config, faking an
  instant completion (auto-submitting a garbage code and closing the
  keyboard after one keystroke).
- **Typing is strictly sequential** — it is impossible to fill a later cell
  before an earlier one.
- **Paste / SMS autofill** fill the cells directly (single string, no manual
  distribution); over-long input is truncated to `length`.
- `updateDigit` computed `isComplete` from the joined value length, which
  miscounts when there are gaps; it now requires every slot to be filled.
- Tapping the field when focus is held but the keyboard was dismissed
  (iOS swipe-down) re-summons the keyboard.

### Added

- `OTPConfig.showCursor` — draws a blinking caret in the active cell
  (default `true`; set `false` for a pure cell look).
- `OTPController.syncValue(value)` — haptic-free value sync used by the
  widget; `setValue` keeps its haptic for programmatic fills.
- `customValidationRules` are now actually enforced: a failing rule sets the
  error state (shake + error border) instead of firing `onCompleted`.
- `OTPConfig.enableShadow`/`shadowElevation` are now rendered (previously
  declared but ignored).
- Widget test suite covering typing, deletion, paste, filtering, dedupe and
  custom-rule gating (`test/otp_text_field_test.dart`).

### Changed

- **Breaking (provider consumers only):** `otpControllerProvider` and the
  helper providers are `autoDispose`; long-lived listeners outside the
  widget tree must use `ref.keepAlive()` if they need the old behavior.
- `autoSubmit` is a no-op (completion already fires `onCompleted`); kept for
  API compatibility.
- Removed the broken `resolution: workspace` marker and the unused
  `logging_kit` dependency — the package now resolves standalone and can be
  dropped into any project.

## [2.0.0] - 2026-05-12

Major refactor: production-hardened resend flow, paste/SMS-autofill correctness,
test suite, and widget previews.

### Breaking changes

- **`OTPVerificationScreen` now requires `namespace` and `onResend`.** Each
  verification flow must scope its own cooldown counters and provide its own
  resend network call. Update each call-site:
  ```dart
  OTPVerificationScreen(
    title: ...,
    subtitle: ...,
    namespace: 'verify_account_passwordRecovery', // NEW
    onOTPCompleted: (otp) => verify(otp),
    onResend: () => resend(),                     // NEW (was internal)
  )
  ```
- **`OTPConfig.dedupeCompletion` defaults to `false`.** Every completion of
  the field now fires `onCompleted` — including when the user re-enters the
  same digits after a server error. Set `dedupeCompletion: true` if your
  screen auto-submits and you want to suppress duplicate API calls.
- **Feature-layer `OTPTextField` adapter and `OTPTimerWidget` deleted.**
  Screens import `OTPTextField` and `OTPResendButton` from
  `package:client_app/core/otp_module/otp_module.dart` directly.
- **Resend cooldown defaults updated** (industry-standard for SMS OTP):
  - `initialCountdownSeconds`: `59` → `60`
  - `shortCooldownSeconds`: `10` → `60`
  - `longCooldownSeconds`: `15 min` → `5 min`
- **Long-cooldown timer formatter is now adaptive.** `< 1 hour` renders as
  `mm:ss` (e.g. `14:00`), `≥ 1 hour` renders as `hh:mm:ss`.

### Added

- `services/resend_cooldown_service.dart` — `ResendCooldownService` abstracts
  the SharedPreferences keys used to persist resend attempts and the long-
  cooldown end-time. Namespace-scoped so multiple flows don't share counters.
- `models/resend_state.dart` — sealed `ResendState` with variants
  `IdleResendState`, `TickingResendState`, `ShortCooldownResendState`,
  `LongCooldownResendState`. Drives the resend button and countdown text.
- `providers/resend_cooldown_notifier.dart` — `ResendCooldownNotifier`
  (Riverpod `StateNotifier`) and `resendCooldownProvider` family keyed by
  `ResendCooldownConfig`. Single wall-clock-driven `Timer.periodic` instead
  of three concurrent timers. Bootstraps from persisted state so a long
  cooldown survives app restart.
- `widgets/otp_resend_button.dart` — `OTPResendButton` consumer widget that
  renders countdown text + resend button. Caller supplies a `buttonBuilder`
  so the module stays free of UI library deps.
- `previews/otp_previews.dart` — 9 `@Preview` entries covering OTP themes
  (default light, modern, secure, premium, RTL) and resend-button states
  (idle, ticking, short cooldown, long cooldown).
- Test suite with 76 tests under `test/core/otp_module/`:
  - `otp_validator_test.dart` (16)
  - `otp_utils_test.dart` (17)
  - `otp_controller_test.dart` (11)
  - `resend_cooldown_service_test.dart` (8)
  - `resend_cooldown_notifier_test.dart` (5)
  - `otp_text_field_test.dart` (7)
  - `otp_resend_button_test.dart` (3)

### Fixed

- **`OTPTimerWidget` cleared its persisted long-cooldown key in `dispose()`**
  — leaving the screen reset the lockout, defeating the security intent.
  The new notifier persists state through the service and only resets on
  successful flow completion or natural cooldown expiry.
- **Three concurrent `Timer.periodic`s** — replaced by one wall-clock-driven
  ticker computed against an end-time, so it stays accurate across app
  backgrounding and pause/resume.
- **`_startLongWaitTimer` was `async` without awaiting its body** — all I/O
  is now explicitly awaited or `unawaited`.
- **`setState` could fire after dispose.** All emit paths gate on `mounted`.
- **`maxLength: 1` truncated multi-character paste before our distribution
  branch ran.** Switched to `MaxLengthEnforcement.none` with the input
  formatter handling the multi-char paste/SMS-autofill case.
- **SMS auto-fill never worked.** First cell now declares
  `autofillHints: [AutofillHints.oneTimeCode]` and the `_OTPInputFormatter`
  filters multi-char inserts down to allowed characters before distribution.
- **Sign-up flow sent empty phone on resend.** `OTPVerificationScreen` now
  requires `onResend` — callers wire the phone in their closure.
- **Phone state lost across rebuilds in `ForgetPasswordScreen`** — fixed
  in v1.0.x but documented here for completeness.

### Migration

| v1 | v2 |
|---|---|
| `import '...presentation/widgets/otp_text_field.dart';` | `import 'package:client_app/core/otp_module/otp_module.dart';` |
| `import '...presentation/widgets/otp_timer_widget.dart';` | `import 'package:client_app/core/otp_module/otp_module.dart';` |
| `OTPTimerWidget(attempts: n, onResendPressed: ..., onTimerComplete: ...)` | `OTPResendButton(config: ResendCooldownConfig(namespace: ...), labels: ..., onResend: ..., buttonBuilder: ...)` |
| `OTPVerificationScreen(title, subtitle, phone, onOTPCompleted)` | `OTPVerificationScreen(title, subtitle, namespace, onOTPCompleted, onResend)` |

## [1.0.0] - 2026-02-02

Initial release. See git history for the full v1 feature list.
