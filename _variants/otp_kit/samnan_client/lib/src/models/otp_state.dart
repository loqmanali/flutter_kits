/// Represents the current state of the OTP input
///
/// This class manages the state of the OTP input including
/// the current value, validation status, and error state.
///
/// Example:
/// ```dart
/// final state = OTPState(
///   value: '1234',
///   isComplete: true,
///   hasError: false,
/// );
/// ```
class OTPState {
  /// Current OTP value as a string
  final String value;

  /// Individual digits as a list
  final List<String> digits;

  /// Whether all digits are filled
  final bool isComplete;

  /// Whether there's a validation error
  final bool hasError;

  /// Error message if any
  final String? errorMessage;

  /// Whether the field is currently focused
  final bool isFocused;

  /// Index of currently focused field (-1 if none)
  final int focusedIndex;

  /// Whether keyboard is visible
  final bool isKeyboardVisible;

  /// Whether currently processing (e.g., verifying OTP)
  final bool isProcessing;

  /// Timestamp of last modification
  final DateTime? lastModified;

  const OTPState({
    this.value = '',
    this.digits = const [],
    this.isComplete = false,
    this.hasError = false,
    this.errorMessage,
    this.isFocused = false,
    this.focusedIndex = -1,
    this.isKeyboardVisible = false,
    this.isProcessing = false,
    this.lastModified,
  });

  /// Create initial state
  factory OTPState.initial(int length) {
    return OTPState(
      value: '',
      digits: List.filled(length, ''),
      isComplete: false,
      hasError: false,
      isFocused: false,
      focusedIndex: -1,
      isKeyboardVisible: false,
      isProcessing: false,
    );
  }

  /// Create state with error
  factory OTPState.error(String message, {required int length}) {
    return OTPState(
      value: '',
      digits: List.filled(length, ''),
      isComplete: false,
      hasError: true,
      errorMessage: message,
      isFocused: false,
      focusedIndex: -1,
    );
  }

  /// Create state with completed value
  factory OTPState.completed(String value) {
    return OTPState(
      value: value,
      digits: value.split(''),
      isComplete: true,
      hasError: false,
      isFocused: false,
      focusedIndex: -1,
    );
  }

  /// Copy with method for state updates
  OTPState copyWith({
    String? value,
    List<String>? digits,
    bool? isComplete,
    bool? hasError,
    String? errorMessage,
    bool? isFocused,
    int? focusedIndex,
    bool? isKeyboardVisible,
    bool? isProcessing,
    DateTime? lastModified,
    bool clearError = false,
  }) {
    return OTPState(
      value: value ?? this.value,
      digits: digits ?? this.digits,
      isComplete: isComplete ?? this.isComplete,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isFocused: isFocused ?? this.isFocused,
      focusedIndex: focusedIndex ?? this.focusedIndex,
      isKeyboardVisible: isKeyboardVisible ?? this.isKeyboardVisible,
      isProcessing: isProcessing ?? this.isProcessing,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  /// Get the number of filled digits
  int get filledCount => digits.where((d) => d.isNotEmpty).length;

  /// Get the number of empty digits
  int get emptyCount => digits.where((d) => d.isEmpty).length;

  /// Check if a specific index is filled
  bool isIndexFilled(int index) {
    if (index < 0 || index >= digits.length) return false;
    return digits[index].isNotEmpty;
  }

  /// Get progress as percentage (0.0 to 1.0)
  double get progress {
    if (digits.isEmpty) return 0.0;
    return filledCount / digits.length;
  }

  /// Check if can submit (all filled and no error)
  bool get canSubmit => isComplete && !hasError && !isProcessing;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OTPState &&
        other.value == value &&
        _listEquals(other.digits, digits) &&
        other.isComplete == isComplete &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.isFocused == isFocused &&
        other.focusedIndex == focusedIndex &&
        other.isKeyboardVisible == isKeyboardVisible &&
        other.isProcessing == isProcessing &&
        other.lastModified == lastModified;
  }

  @override
  int get hashCode {
    return Object.hash(
      value,
      Object.hashAll(digits),
      isComplete,
      hasError,
      errorMessage,
      isFocused,
      focusedIndex,
      isKeyboardVisible,
      isProcessing,
      lastModified,
    );
  }

  @override
  String toString() {
    return 'OTPState(value: $value, isComplete: $isComplete, hasError: $hasError, errorMessage: $errorMessage, focusedIndex: $focusedIndex, progress: ${(progress * 100).toStringAsFixed(0)}%)';
  }

  /// Helper method to compare lists
  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
