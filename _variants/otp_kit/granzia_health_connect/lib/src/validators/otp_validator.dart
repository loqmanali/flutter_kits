import '../models/otp_models.dart';

/// Caller-overridable error messages used by [OTPValidator].
///
/// The defaults are English. Replace at app startup to localize:
/// ```dart
/// OTPValidatorMessages.instance = const OTPValidatorMessages(
///   required: 'مطلوب إدخال الرمز',
///   wrongLength: 'الرمز يجب أن يكون من {length} أرقام',
///   notNumeric: 'الرمز يجب أن يحتوي أرقامًا فقط',
///   notAlphabetic: 'الرمز يجب أن يحتوي حروفًا فقط',
///   notAlphanumeric: 'الرمز يجب أن يحتوي حروفًا وأرقامًا فقط',
///   invalidCharacter: 'حرف غير صالح',
///   sequential: 'الرمز لا يمكن أن يكون أرقامًا متتالية',
///   repeated: 'الرمز لا يمكن أن يكون رقمًا واحدًا متكررًا',
/// );
/// ```
class OTPValidatorMessages {
  const OTPValidatorMessages({
    this.required = 'OTP is required',
    this.wrongLength = 'OTP must be {length} digits',
    this.notNumeric = 'OTP must contain only numbers',
    this.notAlphabetic = 'OTP must contain only letters',
    this.notAlphanumeric = 'OTP must contain only letters and numbers',
    this.invalidCharacter = 'Invalid character',
    this.sequential = 'OTP cannot be sequential numbers',
    this.repeated = 'OTP cannot be all the same digit',
  });

  final String required;
  final String wrongLength; // supports `{length}` placeholder
  final String notNumeric;
  final String notAlphabetic;
  final String notAlphanumeric;
  final String invalidCharacter;
  final String sequential;
  final String repeated;

  /// Mutable singleton — set once at app startup.
  static OTPValidatorMessages instance = const OTPValidatorMessages();
}

/// Validator for OTP input.
///
/// Validation order: length → input-type per-character → custom rules.
/// Error strings come from [OTPValidatorMessages.instance] so they can be
/// localized without changing the validator signature.
class OTPValidator {
  /// Validates OTP value based on configuration.
  ///
  /// Returns `null` if valid, or a localized error message.
  static String? validate(
    String value,
    OTPConfig config, {
    List<OTPValidationRule>? customRules,
  }) {
    final messages = OTPValidatorMessages.instance;

    if (value.isEmpty) return messages.required;

    if (value.length != config.length) {
      return messages.wrongLength
          .replaceFirst('{length}', config.length.toString());
    }

    for (int i = 0; i < value.length; i++) {
      if (!config.inputType.isValidCharacter(value[i])) {
        return _getInvalidCharacterMessage(config.inputType);
      }
    }

    if (customRules != null) {
      for (final rule in customRules) {
        final error = rule.validate(value);
        if (error != null) return error;
      }
    }

    return null;
  }

  /// Validates a single digit/character
  ///
  /// Returns true if valid, false otherwise
  static bool validateCharacter(String char, OTPInputType inputType) {
    if (char.isEmpty) return true;
    return inputType.isValidCharacter(char);
  }

  /// Checks if OTP is complete
  static bool isComplete(String value, int requiredLength) {
    return value.length == requiredLength && value.isNotEmpty;
  }

  /// Validates OTP format (all digits filled)
  static bool hasValidFormat(List<String> digits) {
    if (digits.isEmpty) return false;
    return digits.every((digit) => digit.isNotEmpty);
  }

  /// Get error message for invalid character based on input type
  static String _getInvalidCharacterMessage(OTPInputType inputType) {
    final m = OTPValidatorMessages.instance;
    return switch (inputType) {
      OTPInputType.numeric => m.notNumeric,
      OTPInputType.alphabetic => m.notAlphabetic,
      OTPInputType.alphanumeric => m.notAlphanumeric,
      OTPInputType.any => m.invalidCharacter,
    };
  }

  /// Sanitize input value based on input type
  static String sanitize(String value, OTPInputType inputType) {
    return value.split('').where((char) {
      return inputType.isValidCharacter(char);
    }).join();
  }

  /// Check if value contains sequential numbers (e.g., 1234, 4321)
  static bool hasSequentialNumbers(String value) {
    if (value.length < 3) return false;

    final digits = value.split('').map(int.tryParse).whereType<int>().toList();
    if (digits.length != value.length) return false;

    // Check ascending sequence
    bool isAscending = true;
    bool isDescending = true;

    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] + 1) isAscending = false;
      if (digits[i] != digits[i - 1] - 1) isDescending = false;
    }

    return isAscending || isDescending;
  }

  /// Check if value contains repeated digits (e.g., 1111, 2222)
  static bool hasRepeatedDigits(String value) {
    if (value.isEmpty) return false;
    return value.split('').toSet().length == 1;
  }

  /// Advanced validation with common patterns check
  static String? validateWithPatterns(
    String value,
    OTPConfig config, {
    bool checkSequential = false,
    bool checkRepeated = false,
  }) {
    // Basic validation first
    final basicError = validate(value, config);
    if (basicError != null) return basicError;

    final messages = OTPValidatorMessages.instance;

    if (checkSequential && hasSequentialNumbers(value)) {
      return messages.sequential;
    }

    if (checkRepeated && hasRepeatedDigits(value)) {
      return messages.repeated;
    }

    return null;
  }
}

/// Custom validation rule interface
abstract class OTPValidationRule {
  /// Validates the OTP value
  ///
  /// Returns null if valid, error message if invalid
  String? validate(String value);
}

/// Example: Minimum unique digits validation rule
class MinimumUniqueDigitsRule implements OTPValidationRule {
  final int minimumUnique;
  final String? errorMessage;

  const MinimumUniqueDigitsRule({
    required this.minimumUnique,
    this.errorMessage,
  });

  @override
  String? validate(String value) {
    final uniqueDigits = value.split('').toSet().length;
    if (uniqueDigits < minimumUnique) {
      return errorMessage ??
          'OTP must have at least $minimumUnique different digits';
    }
    return null;
  }
}

/// Example: No sequential pattern rule
class NoSequentialPatternRule implements OTPValidationRule {
  final String? errorMessage;

  const NoSequentialPatternRule({this.errorMessage});

  @override
  String? validate(String value) {
    if (OTPValidator.hasSequentialNumbers(value)) {
      return errorMessage ?? 'OTP cannot contain sequential numbers';
    }
    return null;
  }
}

/// Example: No repeated digits rule
class NoRepeatedDigitsRule implements OTPValidationRule {
  final String? errorMessage;

  const NoRepeatedDigitsRule({this.errorMessage});

  @override
  String? validate(String value) {
    if (OTPValidator.hasRepeatedDigits(value)) {
      return errorMessage ?? 'OTP cannot be all the same digit';
    }
    return null;
  }
}

/// Example: Custom pattern matching rule
class PatternMatchRule implements OTPValidationRule {
  final RegExp pattern;
  final String? errorMessage;

  const PatternMatchRule({
    required this.pattern,
    this.errorMessage,
  });

  @override
  String? validate(String value) {
    if (!pattern.hasMatch(value)) {
      return errorMessage ?? 'OTP does not match required pattern';
    }
    return null;
  }
}

/// Example: Length range validation rule
class LengthRangeRule implements OTPValidationRule {
  final int minLength;
  final int maxLength;
  final String? errorMessage;

  const LengthRangeRule({
    required this.minLength,
    required this.maxLength,
    this.errorMessage,
  });

  @override
  String? validate(String value) {
    if (value.length < minLength || value.length > maxLength) {
      return errorMessage ??
          'OTP must be between $minLength and $maxLength characters';
    }
    return null;
  }
}
