# OTP Module

Production-ready OTP (One-Time Password) input + resend cooldown for Flutter.
Internal module of `client_app` — not published to pub.

## What's in here

| Layer | Files | Purpose |
|---|---|---|
| Models | `models/otp_config.dart`, `models/otp_state.dart`, `models/resend_state.dart` | Immutable config/state value objects + sealed resend state |
| Services | `services/resend_cooldown_service.dart` | SharedPreferences abstraction for resend persistence |
| State | `providers/otp_controller.dart`, `providers/resend_cooldown_notifier.dart` | Riverpod controllers + family providers |
| Widgets | `widgets/otp_text_field.dart`, `widgets/otp_resend_button.dart` | The two consumer widgets you embed in screens |
| Validation | `validators/otp_validator.dart` | Validator + 5 ready-made rule classes |
| Theming | `theme/otp_theme.dart` | 11 pre-built `OTPConfig` factories |
| Utilities | `utils/otp_utils.dart` | Formatting, masking, SMS extraction, strength |
| Previews | `previews/otp_previews.dart` | `@Preview` widgets for IDE rendering |

Single import for everything:
```dart
import 'package:client_app/core/otp_module/otp_module.dart';
```

## Quick start

### 1. Just the input field

```dart
OTPTextField(
  config: OTPTheme.defaultLight(context),
  onCompleted: (otp) => verify(otp),
)
```

### 2. Input field + resend button (most common)

```dart
class MyScreen extends ConsumerStatefulWidget { ... }

class _MyScreenState extends ConsumerState<MyScreen> {
  late final OTPConfig _otp;
  late final ResendCooldownConfig _resend;

  @override
  void initState() {
    super.initState();
    _otp = OTPConfig(length: 4, dedupeCompletion: false);
    _resend = const ResendCooldownConfig(namespace: 'my_flow');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OTPTextField(
          config: _otp,
          onCompleted: (otp) => ref.read(myVerifyProvider.notifier).verify(otp),
        ),
        const SizedBox(height: 24),
        OTPResendButton(
          config: _resend,
          labels: ResendButtonLabels(
            resend: 'Resend code',
            shortCooldown: (t) => 'Wait $t before retrying',
            longCooldown: (t) => 'Try again in $t',
          ),
          onResend: () => ref.read(myResendProvider.notifier).resend(),
          buttonBuilder: (context, {required label, required onPressed}) {
            return ElevatedButton(onPressed: onPressed, child: Text(label));
          },
        ),
      ],
    );
  }
}
```

### 3. Use the bundled `OTPVerificationScreen`

The feature layer ships an opinionated screen that combines the above with
header/scaffold chrome:

```dart
OTPVerificationScreen(
  title: 'Verify your phone',
  subtitle: 'Enter the code we sent',
  namespace: 'verify_account',          // scopes the cooldown across navs
  onOTPCompleted: (otp) => ref.read(otpNotifier).verify(phone, otp),
  onResend: () => ref.read(passwordNotifier).forgotPassword(phone),
)
```

## Resend cooldown — how it works

The resend flow has four states (sealed `ResendState`):

| State | When | UI behavior |
|---|---|---|
| `TickingResendState` | Right after sending — initial delivery window | Button disabled, countdown shows `mm:ss` |
| `IdleResendState` | Countdown elapsed | Button enabled, label shows attempts remaining |
| `ShortCooldownResendState` | Right after a resend tap | Button disabled for `shortCooldownSeconds` |
| `LongCooldownResendState` | After `maxAttempts` resends | Button disabled, end-time persisted to disk so it survives app restart |

Defaults (`ResendCooldownConfig`):
- `initialCountdownSeconds: 60`
- `shortCooldownSeconds: 60`
- `longCooldownSeconds: 5 * 60` (5 minutes)
- `maxAttempts: 3`

**Namespacing.** Two flows that share a `namespace` share counters. Use
distinct strings for distinct flows so the lockout from one doesn't leak
into another:

```dart
const ResendCooldownConfig(namespace: 'password_recovery')
const ResendCooldownConfig(namespace: 'phone_change')
const ResendCooldownConfig(namespace: 'sign_up_verify')
```

**Reset on success.** Call `ref.read(resendCooldownProvider(config).notifier).resetAll()`
once verification succeeds, so the user starts fresh next time.

## Configuration

### `OTPConfig` — the input field

| Property | Type | Default | Description |
|---|---|---|---|
| `length` | `int` | `4` | Number of cells |
| `spacing` | `double` | `8.0` | Gap between cells |
| `size` | `double` | `50.0` | Cell width/height (clamps to fit) |
| `borderRadius` | `double` | `8.0` | Corner radius |
| `borderWidth` | `double` | `1.5` | Border thickness |
| `activeColor` / `inactiveColor` / `errorColor` | `Color?` | theme | Border colors |
| `backgroundColor` / `textColor` | `Color?` | theme | Cell + glyph colors |
| `textStyle` | `TextStyle?` | system | Glyph style |
| `isRTL` | `bool` | `false` | Right-to-left direction |
| `fieldPadding` | `EdgeInsets` | `horizontal: 4` | Around each cell |
| `autoFocus` | `bool` | `true` | Focus first cell on mount |
| `obscureText` / `obscureCharacter` | `bool` / `String` | `false` / `'•'` | Mask digits |
| `enableHapticFeedback` | `bool` | `true` | Native vibration on input/error |
| `enableAnimations` / `animationDuration` | `bool` / `int` (ms) | `true` / `300` | Scale + shake |
| `inputType` | `OTPInputType` | `numeric` | Allowed characters |
| `enablePaste` | `bool` | `true` | Long-press triggers paste |
| `clearOnError` | `bool` | `false` | Wipe digits when error is set |
| `autoDismissKeyboard` | `bool` | `false` | Unfocus on completion |
| `enableShadow` / `shadowElevation` | `bool` / `double` | `true` / `2.0` | Cell elevation |
| `dedupeCompletion` | `bool` | `false` | Suppress repeat `onCompleted` for the same value |

### `ResendCooldownConfig` — the resend timer

| Property | Type | Default | Description |
|---|---|---|---|
| `namespace` | `String` | required | Scopes counters across screens |
| `initialCountdownSeconds` | `int` | `60` | First countdown after sending |
| `shortCooldownSeconds` | `int` | `60` | Anti-spam window between resends |
| `longCooldownSeconds` | `int` | `300` | Lockout after `maxAttempts` |
| `maxAttempts` | `int` | `3` | Resends allowed before lockout |

### `OTPInputType`

```dart
enum OTPInputType { numeric, alphabetic, alphanumeric, any }
```

`OTPInputType.numeric` (default) sets `keyboardType: number` and rejects
non-digit characters via the input formatter.

## Themes

11 ready-made `OTPConfig` factories under `OTPTheme`:

| Theme | Length | Highlight |
|---|---|---|
| `defaultLight` / `defaultDark` | 4 | Standard cells |
| `minimal` | 4 | No shadow |
| `rounded` | 4 | Full radius |
| `modern` | 6 | Larger cells, surfaceContainerHighest fill |
| `compact` | 4 | Tight spacing for narrow screens |
| `large` | 4 | Accessibility — bigger cells/text |
| `secure` | 6 | `obscureText: true`, `clearOnError: true` |
| `premium` | 6 | Elevated, heavy weight |
| `underline` | 4 | Bottom border only |
| `adaptive` | 4 | Picks light/dark from `Theme.of(context).brightness` |

Custom builder:
```dart
OTPTheme.custom(context: context, length: 6, ...)
```

## Validation

Built-in rules:

- `MinimumUniqueDigitsRule(minimumUnique: 3)` — rejects `1112`
- `NoSequentialPatternRule()` — rejects `1234`, `4321`
- `NoRepeatedDigitsRule()` — rejects `1111`
- `PatternMatchRule(pattern: RegExp(r'^...$'))`
- `LengthRangeRule(minLength: 4, maxLength: 6)`

Apply at submission:
```dart
final error = ref
    .read(otpControllerProvider(_config).notifier)
    .validate(customRules: const [
      NoSequentialPatternRule(),
      NoRepeatedDigitsRule(),
    ]);
if (error != null) controller.setError(error);
```

Or write your own:
```dart
class StartsWithZeroRule implements OTPValidationRule {
  const StartsWithZeroRule();
  @override
  String? validate(String value) =>
      value.startsWith('0') ? 'Cannot start with 0' : null;
}
```

## SMS auto-fill & paste

- **SMS auto-fill (Android / iOS):** the first cell carries
  `AutofillHints.oneTimeCode`. When the platform delivers the code, it lands
  in cell 0 as a multi-character insert and the widget distributes the chars
  across cells.
- **Clipboard paste:** long-press the field. Reads the clipboard, sanitizes
  via the input type, and fills.

## Programmatic control

```dart
final notifier = ref.read(otpControllerProvider(config).notifier);

notifier.clear();              // wipe all cells
notifier.clearDigit(2);        // wipe one cell
notifier.setValue('1234');     // populate via paste/autofill path
notifier.setError('Wrong');    // mark error (triggers shake animation)
notifier.clearError();
notifier.setProcessing(true);  // disable submission while verifying
final err = notifier.validate(customRules: ...);
```

Selectors (rebuild only when the slice changes):
```dart
final value      = ref.watch(otpValueProvider(config));
final isComplete = ref.watch(otpIsCompleteProvider(config));
final hasError   = ref.watch(otpHasErrorProvider(config));
final progress   = ref.watch(otpProgressProvider(config));
```

## Utilities (`OTPUtils`)

- `formatOTP('1234', separator: '-')` → `'1-2-3-4'`
- `maskOTP('123456')` → `'1****6'`
- `extractOTPFromText('Your code is 1234.')` → `'1234'`
- `isValidFormat('1234', length: 4)`
- `isExpired(deadline)` / `remainingTime(deadline)` / `formatRemainingTime(deadline)`
- `sanitizeNumeric` / `sanitizeAlphanumeric`
- `calculateStrength(value)` + `getStrengthLabel(0..1)`

## Widget previews

Open the *Flutter Widget Preview* tab in your IDE (or run
`flutter widget-preview start`) — `previews/otp_previews.dart` ships 9
previews:

- **OTPTextField:** default light, modern (6 cells), secure (obscured),
  premium, RTL
- **OTPResendButton:** idle, ticking, short cooldown, long cooldown

The resend previews use `ProviderScope.overrides` with a stub
`ResendCooldownService` so each preview renders deterministically.

## Testing

76 tests live under `test/core/otp_module/`. Run them all:
```bash
flutter test test/core/otp_module/
```

Use `SharedPreferences.setMockInitialValues({})` in `setUp` for any test
that touches `ResendCooldownService` or `ResendCooldownNotifier`. Override
`resendCooldownServiceProvider` to inject a fake service in widget tests.

## Why this is structured the way it is

- **Service / Notifier / Widget split** — SharedPreferences access lives in
  one place (`ResendCooldownService`); state lives in one place
  (`ResendCooldownNotifier`); UI is a dumb consumer. Easy to test, easy to
  mock, no implicit shared state.
- **Sealed `ResendState`** — exhaustive `switch` expressions catch missing
  cases at compile time when adding a new phase.
- **Wall-clock-driven timer** — single `Timer.periodic` recomputes the
  remaining seconds against a stored end-time. Accurate across pause/resume
  and app backgrounding; long cooldowns survive app restart.
- **`namespace` instead of a global counter** — distinct verification flows
  shouldn't share resend counters or lockouts.
- **`buttonBuilder` instead of a styled button** — module stays free of
  any UI-library or design-system dependency. Caller controls the look.
