import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../models/otp_models.dart';
import '../validators/otp_validator.dart';

/// OTP Controller using Riverpod 3.0
///
/// This controller manages the state and logic for OTP input
/// including validation, error handling, and completion callbacks.
///
/// Example usage:
/// ```dart
/// // In your widget
/// final otpController = ref.watch(otpControllerProvider(config));
///
/// // Listen to state changes
/// ref.listen(otpControllerProvider(config), (previous, next) {
///   if (next.isComplete) {
///     // Handle OTP completion
///   }
/// });
/// ```
class OTPController extends StateNotifier<OTPState> {
  final OTPConfig config;

  OTPController(this.config) : super(OTPState.initial(config.length));

  /// Update a single digit at the specified index
  ///
  /// This method handles input validation and state updates
  /// when a user types in a specific OTP field.
  void updateDigit(int index, String value) {
    if (index < 0 || index >= state.digits.length) return;

    // Validate character based on input type
    if (value.isNotEmpty &&
        !OTPValidator.validateCharacter(value, config.inputType)) {
      return;
    }

    // Update digits list
    final newDigits = List<String>.from(state.digits);
    newDigits[index] = value;

    // Combine all digits to get full value
    final newValue = newDigits.join();

    // Complete only when every slot is filled — joining and comparing length
    // would miscount when there are gaps (e.g. ['1','','3']).
    final isComplete = newDigits.every((d) => d.isNotEmpty);

    // Update state
    state = state.copyWith(
      digits: newDigits,
      value: newValue,
      isComplete: isComplete,
      lastModified: DateTime.now(),
      clearError: true,
    );

    // Trigger haptic feedback if enabled
    if (config.enableHapticFeedback && value.isNotEmpty) {
      HapticFeedback.lightImpact();
    }
  }

  /// Replace the whole value **without** haptic feedback.
  ///
  /// Used internally by `OTPTextField` to mirror every keystroke of the
  /// hidden field into this state (per-keystroke haptics are the widget's
  /// job). Prefer [setValue] for programmatic fills — it keeps the
  /// medium-impact haptic.
  void syncValue(String value) {
    final sanitized = OTPValidator.sanitize(value, config.inputType);
    final truncated = sanitized.length > config.length
        ? sanitized.substring(0, config.length)
        : sanitized;

    final newDigits = List<String>.filled(config.length, '');
    for (int i = 0; i < truncated.length; i++) {
      newDigits[i] = truncated[i];
    }

    state = state.copyWith(
      digits: newDigits,
      value: truncated,
      isComplete: truncated.length == config.length,
      lastModified: DateTime.now(),
      clearError: true,
    );
  }

  /// Set the complete OTP value at once
  ///
  /// Useful for paste functionality or auto-fill
  void setValue(String value) {
    // Sanitize input based on input type
    final sanitized = OTPValidator.sanitize(value, config.inputType);

    // Truncate to max length
    final truncated =
        sanitized.length > config.length
            ? sanitized.substring(0, config.length)
            : sanitized;

    // Split into digits
    final newDigits = List<String>.filled(config.length, '');
    for (int i = 0; i < truncated.length; i++) {
      newDigits[i] = truncated[i];
    }

    // Check if complete
    final isComplete = truncated.length == config.length;

    // Update state
    state = state.copyWith(
      digits: newDigits,
      value: truncated,
      isComplete: isComplete,
      lastModified: DateTime.now(),
      clearError: true,
    );

    // Trigger haptic feedback if enabled
    if (config.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Clear all OTP fields
  void clear() {
    state = OTPState.initial(config.length);
  }

  /// Clear a specific digit at index
  void clearDigit(int index) {
    if (index < 0 || index >= state.digits.length) return;

    final newDigits = List<String>.from(state.digits);
    newDigits[index] = '';

    final newValue = newDigits.join();

    state = state.copyWith(
      digits: newDigits,
      value: newValue,
      isComplete: false,
      lastModified: DateTime.now(),
      clearError: true,
    );
  }

  /// Set error state
  void setError(String errorMessage) {
    // Clear all fields if configured to do so
    if (config.clearOnError) {
      state = OTPState.error(errorMessage, length: config.length);
    } else {
      state = state.copyWith(
        hasError: true,
        errorMessage: errorMessage,
      );
    }

    // Trigger error haptic feedback
    if (config.enableHapticFeedback) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Validate current OTP value
  ///
  /// Returns validation error message or null if valid
  String? validate({List<OTPValidationRule>? customRules}) {
    return OTPValidator.validate(
      state.value,
      config,
      customRules: customRules,
    );
  }

  /// Set focus state
  void setFocused(bool isFocused, [int focusedIndex = -1]) {
    state = state.copyWith(
      isFocused: isFocused,
      focusedIndex: focusedIndex,
    );
  }

  /// Set keyboard visibility
  void setKeyboardVisible(bool isVisible) {
    state = state.copyWith(isKeyboardVisible: isVisible);
  }

  /// Set processing state (e.g., during API verification)
  void setProcessing(bool isProcessing) {
    state = state.copyWith(isProcessing: isProcessing);
  }

  /// Handle paste action
  Future<void> handlePaste() async {
    if (!config.enablePaste) return;

    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null) {
        setValue(data!.text!);
      }
    } catch (e) {
      // Handle clipboard errors silently
    }
  }

  /// Get current progress (0.0 to 1.0)
  double get progress => state.progress;

  /// Check if can submit
  bool get canSubmit => state.canSubmit;

  /// Get filled count
  int get filledCount => state.filledCount;
}

/// Provider for OTP Controller
///
/// This is an **autoDispose** family provider that creates a controller for
/// each unique config. Multiple OTP fields with the same config share the
/// same controller instance while mounted.
///
/// autoDispose matters: without it the typed digits survived the screen —
/// re-opening an OTP screen with an equal config combined stale digits with
/// fresh input, faking an instant completion (auto-submit of a garbage code
/// and a self-dismissing keyboard).
///
/// Example:
/// ```dart
/// final controller = ref.watch(otpControllerProvider(myConfig));
/// ```
final otpControllerProvider = StateNotifierProvider.autoDispose
    .family<OTPController, OTPState, OTPConfig>((ref, config) {
  return OTPController(config);
});

/// Provider for OTP configuration
///
/// Override this provider to set a default configuration for your app.
///
/// Example:
/// ```dart
/// ProviderScope(
///   overrides: [
///     otpConfigProvider.overrideWithValue(
///       OTPConfig(length: 6, inputType: OTPInputType.numeric),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
final otpConfigProvider = Provider<OTPConfig>((ref) {
  return const OTPConfig();
});

/// Helper provider to watch OTP value
///
/// Use this to watch only the OTP value without rebuilding on other state changes
///
/// Example:
/// ```dart
/// final otpValue = ref.watch(otpValueProvider(config));
/// ```
final otpValueProvider = Provider.autoDispose.family<String, OTPConfig>((ref, config) {
  return ref.watch(otpControllerProvider(config).select((state) => state.value));
});

/// Helper provider to watch OTP completion status
///
/// Example:
/// ```dart
/// final isComplete = ref.watch(otpIsCompleteProvider(config));
/// ```
final otpIsCompleteProvider = Provider.autoDispose.family<bool, OTPConfig>((ref, config) {
  return ref.watch(
      otpControllerProvider(config).select((state) => state.isComplete));
});

/// Helper provider to watch OTP error status
///
/// Example:
/// ```dart
/// final hasError = ref.watch(otpHasErrorProvider(config));
/// ```
final otpHasErrorProvider = Provider.autoDispose.family<bool, OTPConfig>((ref, config) {
  return ref
      .watch(otpControllerProvider(config).select((state) => state.hasError));
});

/// Helper provider to watch OTP error message
///
/// Example:
/// ```dart
/// final errorMessage = ref.watch(otpErrorMessageProvider(config));
/// ```
final otpErrorMessageProvider =
    Provider.autoDispose.family<String?, OTPConfig>((ref, config) {
  return ref.watch(
      otpControllerProvider(config).select((state) => state.errorMessage));
});

/// Helper provider to watch OTP progress
///
/// Example:
/// ```dart
/// final progress = ref.watch(otpProgressProvider(config));
/// ```
final otpProgressProvider = Provider.autoDispose.family<double, OTPConfig>((ref, config) {
  return ref
      .watch(otpControllerProvider(config).select((state) => state.progress));
});
