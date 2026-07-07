# OTP Module — API Reference

Public surface exported from `package:client_app/core/otp_module/otp_module.dart`.

---

## Models

### `OTPConfig`

Immutable value object. Equality is structural — two configs with identical
fields share the same `OTPController` instance via the family provider.

```dart
const OTPConfig({
  int length = 4,
  double spacing = 8.0,
  double size = 50.0,
  double borderRadius = 8.0,
  double borderWidth = 1.5,
  Color? activeColor,
  Color? inactiveColor,
  Color? errorColor,
  Color? backgroundColor,
  Color? textColor,
  TextStyle? textStyle,
  bool isRTL = false,
  EdgeInsets fieldPadding = const EdgeInsets.symmetric(horizontal: 4),
  bool autoFocus = true,
  bool obscureText = false,
  String obscureCharacter = '•',
  bool enableHapticFeedback = true,
  bool enableAnimations = true,
  int animationDuration = 300,
  bool autoSubmit = false,
  OTPInputType inputType = OTPInputType.numeric,
  bool enablePaste = true,
  bool clearOnError = false,
  bool autoDismissKeyboard = false,
  bool enableShadow = true,
  double shadowElevation = 2.0,
  bool dedupeCompletion = false,
});
```

Methods:
- `OTPConfig copyWith({...})` — returns a new instance with fields replaced.

---

### `OTPInputType` (enum)

```dart
enum OTPInputType { numeric, alphabetic, alphanumeric, any }
```

Extension `OTPInputTypeExtension` adds:
- `TextInputType get keyboardType`
- `bool isValidCharacter(String char)` — single-char predicate

---

### `OTPState`

Immutable snapshot of the input field's state.

```dart
const OTPState({
  String value = '',
  List<String> digits = const [],
  bool isComplete = false,
  bool hasError = false,
  String? errorMessage,
  bool isFocused = false,
  int focusedIndex = -1,
  bool isKeyboardVisible = false,
  bool isProcessing = false,
  DateTime? lastModified,
});
```

Factories:
- `OTPState.initial(int length)` — empty state with `length` slots
- `OTPState.error(String message, {required int length})` — error + cleared
- `OTPState.completed(String value)` — complete, no error

Computed:
- `int filledCount` / `int emptyCount`
- `double progress` (`0.0`..`1.0`)
- `bool canSubmit` (`isComplete && !hasError && !isProcessing`)
- `bool isIndexFilled(int index)`

`copyWith({..., bool clearError = false})` — set `clearError: true` to wipe
the error fields without setting them to new values.

---

### `ResendState` (sealed)

```dart
sealed class ResendState {
  int attemptsUsed;
  int maxAttempts;
  int get attemptsRemaining;     // clamped 0..maxAttempts
  bool get canResend;            // true only for IdleResendState
}
```

Variants:

| Variant | Extra field | Meaning |
|---|---|---|
| `IdleResendState` | — | Resend is enabled |
| `TickingResendState` | `int remainingSeconds` | Initial countdown after sending |
| `ShortCooldownResendState` | `int remainingSeconds` | Anti-spam delay after a resend tap |
| `LongCooldownResendState` | `int remainingSeconds` | Lockout after `maxAttempts` |

Use exhaustive `switch` to render:
```dart
final label = switch (state) {
  IdleResendState() => 'Resend',
  TickingResendState(:final remainingSeconds) => 'Wait $remainingSeconds s',
  ShortCooldownResendState(:final remainingSeconds) => '...',
  LongCooldownResendState(:final remainingSeconds) => '...',
};
```

---

### `ResendCooldownConfig`

```dart
const ResendCooldownConfig({
  required String namespace,
  int initialCountdownSeconds = 60,
  int shortCooldownSeconds = 60,
  int longCooldownSeconds = 5 * 60,
  int maxAttempts = 3,
});
```

Equality is structural — two configs with the same fields share the same
`ResendCooldownNotifier` instance via the family provider.

---

## Services

### `ResendCooldownService`

Persists resend attempts and the long-cooldown end-time across app restarts.
All keys are scoped by a `namespace` argument.

```dart
class ResendCooldownService {
  ResendCooldownService({SharedPreferences? prefs});

  Future<int>  readAttempts(String namespace);
  Future<void> writeAttempts(String namespace, int attempts);

  Future<DateTime?> readLongCooldownEnd(String namespace); // auto-clears expired
  Future<void>      writeLongCooldownEnd(String namespace, DateTime endsAt);
  Future<void>      clearLongCooldown(String namespace);

  Future<void> reset(String namespace);  // wipes both keys
}
```

Storage keys:
- `otp.<namespace>.attempts` — `int`
- `otp.<namespace>.longCooldownEndsAt` — `int` millis-since-epoch

Pass a fake to test:
```dart
ProviderScope(
  overrides: [
    resendCooldownServiceProvider.overrideWithValue(MyFakeService()),
  ],
)
```

---

## Providers

### `otpControllerProvider`

```dart
final otpControllerProvider =
    StateNotifierProvider.family<OTPController, OTPState, OTPConfig>(...);
```

Family-keyed by `OTPConfig`. `OTPConfig` overrides `==`/`hashCode` so equal
configs share the same controller.

Selector providers (rebuild only when their slice changes):

| Provider | Returns |
|---|---|
| `otpValueProvider(OTPConfig)` | `String` — current value |
| `otpIsCompleteProvider(OTPConfig)` | `bool` |
| `otpHasErrorProvider(OTPConfig)` | `bool` |
| `otpErrorMessageProvider(OTPConfig)` | `String?` |
| `otpProgressProvider(OTPConfig)` | `double` |

Default-config provider (override at the root for app-wide defaults):
```dart
final otpConfigProvider = Provider<OTPConfig>((ref) => const OTPConfig());
```

---

### `OTPController extends StateNotifier<OTPState>`

```dart
OTPController(OTPConfig config);

void updateDigit(int index, String value);
void setValue(String value);             // paste / autofill path
void clear();
void clearDigit(int index);
void setError(String errorMessage);      // triggers shake + heavy haptic
void clearError();
String? validate({List<OTPValidationRule>? customRules});
void setFocused(bool isFocused, [int focusedIndex = -1]);
void setKeyboardVisible(bool isVisible);
void setProcessing(bool isProcessing);
Future<void> handlePaste();              // reads system clipboard

double  get progress;
bool    get canSubmit;
int     get filledCount;
```

---

### `resendCooldownProvider`

```dart
final resendCooldownProvider = StateNotifierProvider.family<
    ResendCooldownNotifier, ResendState, ResendCooldownConfig>(...);
```

Family-keyed by `ResendCooldownConfig`. The notifier:
- Bootstraps from `ResendCooldownService` on init (re-emits a long cooldown
  if one is still active).
- Runs a single `Timer.periodic` that recomputes `remainingSeconds` against
  a stored end-time so it stays accurate across backgrounding.
- Is `mounted`-safe: dispose cancels the ticker, future emissions are no-ops.

```dart
class ResendCooldownNotifier extends StateNotifier<ResendState> {
  Future<bool> recordResend();   // returns true if triggered, false if rate-limited
  Future<void> resetAll();       // call after successful verification
}
```

Service injection point:
```dart
final resendCooldownServiceProvider = Provider<ResendCooldownService>(
  (ref) => ResendCooldownService(),
);
```

---

## Widgets

### `OTPTextField`

```dart
const OTPTextField({
  Key? key,
  required OTPConfig config,
  void Function(String)? onCompleted,
  void Function(String)? onChanged,
  List<OTPValidationRule>? customValidationRules,
});
```

Behavior:
- Renders one `TextField` per cell, sized adaptively to the available width.
- Auto-advances focus on each digit; backspace navigates back.
- Multi-character inserts (paste, SMS auto-fill) are routed to
  `OTPController.setValue` and distributed across cells.
- The first cell carries `AutofillHints.oneTimeCode`.
- `enableAnimations: true` adds a per-cell scale on input and a horizontal
  shake on `setError`.
- `dedupeCompletion: true` suppresses repeat `onCompleted` for the same
  value until the field is wiped (auto-resets when the controller's value
  goes empty).
- Long-press triggers paste when `enablePaste: true`.

---

### `OTPResendButton`

```dart
const OTPResendButton({
  Key? key,
  required ResendCooldownConfig config,
  required ResendButtonLabels labels,
  required VoidCallback onResend,
  required Widget Function(
    BuildContext context, {
    required String label,
    required VoidCallback? onPressed,
  }) buttonBuilder,
  TextStyle? timerStyle,
  TextStyle? cooldownTextStyle,
  double spacing = 8.0,
  double bottomSpacing = 16.0,
});
```

Renders:
1. Countdown timer text (`mm:ss`, or `hh:mm:ss` when ≥ 1 hour).
2. Optional cooldown line (only during short/long cooldown).
3. The button — built by `buttonBuilder`. `onPressed` is `null` when the
   button must stay disabled, non-null when the user can tap; the widget
   handles `recordResend()` internally and only fires `onResend` when the
   notifier accepts the tap.

---

### `ResendButtonLabels`

```dart
const ResendButtonLabels({
  required String resend,                                  // "Resend code"
  required String Function(String formattedTime) shortCooldown,
  required String Function(String formattedTime) longCooldown,
});
```

Caller-supplied so the module has no localization dependency. The label is
suffixed with `(N)` automatically when attempts remain.

---

## Validators

### `OTPValidator`

Static-only utility class.

```dart
static String? validate(String value, OTPConfig config, {
  List<OTPValidationRule>? customRules,
});
static bool validateCharacter(String char, OTPInputType inputType);
static bool isComplete(String value, int requiredLength);
static bool hasValidFormat(List<String> digits);
static bool hasSequentialNumbers(String value);  // 1234, 4321
static bool hasRepeatedDigits(String value);     // 1111
static String? validateWithPatterns(String value, OTPConfig config, {
  bool checkSequential = false,
  bool checkRepeated = false,
});
static String sanitize(String value, OTPInputType inputType);
```

### `OTPValidationRule` (interface)

```dart
abstract class OTPValidationRule {
  String? validate(String value);
}
```

Built-in rules:

| Class | Constructor | Rejects |
|---|---|---|
| `MinimumUniqueDigitsRule` | `(minimumUnique: int, errorMessage:?)` | < N unique digits |
| `NoSequentialPatternRule` | `(errorMessage:?)` | `1234`, `4321` |
| `NoRepeatedDigitsRule` | `(errorMessage:?)` | `1111` |
| `PatternMatchRule` | `(pattern: RegExp, errorMessage:?)` | Doesn't match regex |
| `LengthRangeRule` | `(minLength, maxLength, errorMessage:?)` | Length out of range |

---

## Theme — `OTPTheme`

Static factories returning `OTPConfig`:

| Factory | Length | Notes |
|---|---|---|
| `OTPTheme.defaultLight(BuildContext)` | 4 | Standard cells, light scheme |
| `OTPTheme.defaultDark(BuildContext)` | 4 | Dark scheme |
| `OTPTheme.minimal(BuildContext)` | 4 | No shadow |
| `OTPTheme.rounded(BuildContext)` | 4 | Full border radius |
| `OTPTheme.modern(BuildContext)` | 6 | Larger cells, surface fill |
| `OTPTheme.compact(BuildContext)` | 4 | Tight spacing |
| `OTPTheme.large(BuildContext)` | 4 | Accessibility-friendly sizing |
| `OTPTheme.secure(BuildContext)` | 6 | `obscureText: true`, `clearOnError: true` |
| `OTPTheme.premium(BuildContext)` | 6 | Heavy weight, max elevation |
| `OTPTheme.underline(BuildContext)` | 4 | Bottom border only |
| `OTPTheme.adaptive(BuildContext)` | 4 | Picks light/dark from current theme |

Custom builder:
```dart
OTPTheme.custom({
  required BuildContext context,
  int length = 4,
  // ...all OTPConfig fields
});
```

---

## Utilities — `OTPUtils`

Static-only utility class. All methods are pure / I/O-free except where noted.

```dart
static String  formatOTP(String value, {String separator = ' '});
static String  maskOTP(String value, {String maskChar = '*'});
static String? extractOTPFromText(String text, {int length = 4});
static String  generateTestOTP({int length = 4, bool numericOnly = true});

static bool    isValidFormat(String value, {required int length});
static bool    isNumeric(String value);
static bool    isAlphabetic(String value);
static bool    isAlphanumeric(String value);

static bool     isExpired(DateTime expiryTime);
static Duration remainingTime(DateTime expiryTime);
static String   formatRemainingTime(DateTime expiryTime);   // mm:ss

static String sanitizeNumeric(String value);
static String sanitizeAlphanumeric(String value);

static double calculateStrength(String value);              // 0.0..1.0
static String getStrengthLabel(double strength);            // Weak..Very Strong

static int? toInt(String value);

// I/O
static Future<void>     copyToClipboard(String value);
static Future<String?>  getFromClipboard();
```

---

## Provider override quick reference

| Provider | Override use case |
|---|---|
| `resendCooldownServiceProvider` | Inject a fake `ResendCooldownService` in tests/previews |
| `otpConfigProvider` | App-wide default `OTPConfig` |
| `otpControllerProvider(config)` | Almost never overridden — keyed by config |
| `resendCooldownProvider(config)` | Almost never overridden — keyed by config |

---

## Testing helpers

```dart
import 'package:shared_preferences/shared_preferences.dart';

setUp(() {
  SharedPreferences.setMockInitialValues(<String, Object>{});
});
```

For widget tests, wrap with a `ProviderScope` (or `UncontrolledProviderScope`
+ `ProviderContainer` for direct inspection):

```dart
final container = ProviderContainer();
addTearDown(container.dispose);

await tester.pumpWidget(
  UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: OTPTextField(config: cfg)),
  ),
);

final state = container.read(otpControllerProvider(cfg));
```
