import '../exceptions/commerce_exception.dart';

/// Result of a validation operation.
class ValidationResult {
  /// Whether validation passed.
  final bool isValid;

  /// Validation errors by field.
  final Map<String, List<String>> errors;

  const ValidationResult._({
    required this.isValid,
    this.errors = const {},
  });

  /// Creates a valid result.
  const ValidationResult.valid() : this._(isValid: true);

  /// Creates an invalid result.
  const ValidationResult.invalid(Map<String, List<String>> errors)
      : this._(isValid: false, errors: errors);

  /// Creates from a single error.
  factory ValidationResult.error(String field, String message) {
    return ValidationResult.invalid({
      field: [message],
    });
  }

  /// Merges multiple validation results.
  factory ValidationResult.merge(List<ValidationResult> results) {
    final allErrors = <String, List<String>>{};
    bool hasErrors = false;

    for (final result in results) {
      if (!result.isValid) {
        hasErrors = true;
        for (final entry in result.errors.entries) {
          allErrors.putIfAbsent(entry.key, () => []).addAll(entry.value);
        }
      }
    }

    return hasErrors
        ? ValidationResult.invalid(allErrors)
        : const ValidationResult.valid();
  }

  /// Whether validation failed.
  bool get isInvalid => !isValid;

  /// Gets all error messages as a flat list.
  List<String> get allMessages => errors.values.expand((e) => e).toList();

  /// Gets the first error message.
  String? get firstMessage => allMessages.isNotEmpty ? allMessages.first : null;

  /// Throws a ValidationException if invalid.
  void throwIfInvalid() {
    if (isInvalid) {
      throw ValidationException.multiple(errors);
    }
  }
}

/// A validation rule.
typedef ValidationRule<T> = String? Function(T? value);

/// Builder for validation rules.
class Validator<T> {
  final String _fieldName;
  final List<ValidationRule<T>> _rules = [];

  Validator(this._fieldName);

  /// Adds a custom validation rule.
  Validator<T> addRule(ValidationRule<T> rule) {
    _rules.add(rule);
    return this;
  }

  /// Validates the value against all rules.
  ValidationResult validate(T? value) {
    final errors = <String>[];

    for (final rule in _rules) {
      final error = rule(value);
      if (error != null) {
        errors.add(error);
      }
    }

    if (errors.isEmpty) {
      return const ValidationResult.valid();
    }

    return ValidationResult.invalid({_fieldName: errors});
  }
}

/// String validator.
class StringValidator extends Validator<String> {
  StringValidator(super.fieldName);

  /// Value is required (not null or empty).
  StringValidator required([String? message]) {
    return addRule((value) {
      if (value == null || value.trim().isEmpty) {
        return message ?? '$_fieldName is required';
      }
      return null;
    }) as StringValidator;
  }

  /// Minimum length.
  StringValidator minLength(int min, [String? message]) {
    return addRule((value) {
      if (value != null && value.length < min) {
        return message ?? '$_fieldName must be at least $min characters';
      }
      return null;
    }) as StringValidator;
  }

  /// Maximum length.
  StringValidator maxLength(int max, [String? message]) {
    return addRule((value) {
      if (value != null && value.length > max) {
        return message ?? '$_fieldName must be at most $max characters';
      }
      return null;
    }) as StringValidator;
  }

  /// Matches a pattern.
  StringValidator pattern(RegExp pattern, [String? message]) {
    return addRule((value) {
      if (value != null && !pattern.hasMatch(value)) {
        return message ?? '$_fieldName is invalid';
      }
      return null;
    }) as StringValidator;
  }

  /// Is a valid email.
  StringValidator email([String? message]) {
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return pattern(emailPattern, message ?? 'Invalid email address');
  }

  /// Is a valid phone number.
  StringValidator phone([String? message]) {
    final phonePattern = RegExp(r'^\+?[\d\s\-()]{10,}$');
    return pattern(phonePattern, message ?? 'Invalid phone number');
  }

  /// Is a valid URL.
  StringValidator url([String? message]) {
    return addRule((value) {
      if (value != null && value.isNotEmpty) {
        final uri = Uri.tryParse(value);
        if (uri == null || !uri.hasAbsolutePath) {
          return message ?? 'Invalid URL';
        }
      }
      return null;
    }) as StringValidator;
  }

  /// Is alphanumeric.
  StringValidator alphanumeric([String? message]) {
    final alphanumericPattern = RegExp(r'^[a-zA-Z0-9]+$');
    return pattern(
      alphanumericPattern,
      message ?? '$_fieldName must be alphanumeric',
    );
  }

  /// Contains only letters.
  StringValidator alpha([String? message]) {
    final alphaPattern = RegExp(r'^[a-zA-Z]+$');
    return pattern(alphaPattern, message ?? '$_fieldName must contain only letters');
  }

  /// Equals another value.
  StringValidator equals(String other, [String? message]) {
    return addRule((value) {
      if (value != other) {
        return message ?? '$_fieldName must match';
      }
      return null;
    }) as StringValidator;
  }

  /// Is one of the allowed values.
  StringValidator oneOf(List<String> allowed, [String? message]) {
    return addRule((value) {
      if (value != null && !allowed.contains(value)) {
        return message ?? '$_fieldName must be one of: ${allowed.join(', ')}';
      }
      return null;
    }) as StringValidator;
  }
}

/// Number validator.
class NumberValidator extends Validator<num> {
  NumberValidator(super.fieldName);

  /// Value is required.
  NumberValidator required([String? message]) {
    return addRule((value) {
      if (value == null) {
        return message ?? '$_fieldName is required';
      }
      return null;
    }) as NumberValidator;
  }

  /// Minimum value.
  NumberValidator min(num min, [String? message]) {
    return addRule((value) {
      if (value != null && value < min) {
        return message ?? '$_fieldName must be at least $min';
      }
      return null;
    }) as NumberValidator;
  }

  /// Maximum value.
  NumberValidator max(num max, [String? message]) {
    return addRule((value) {
      if (value != null && value > max) {
        return message ?? '$_fieldName must be at most $max';
      }
      return null;
    }) as NumberValidator;
  }

  /// Must be positive.
  NumberValidator positive([String? message]) {
    return addRule((value) {
      if (value != null && value <= 0) {
        return message ?? '$_fieldName must be positive';
      }
      return null;
    }) as NumberValidator;
  }

  /// Must be non-negative.
  NumberValidator nonNegative([String? message]) {
    return addRule((value) {
      if (value != null && value < 0) {
        return message ?? '$_fieldName cannot be negative';
      }
      return null;
    }) as NumberValidator;
  }

  /// Must be an integer.
  NumberValidator integer([String? message]) {
    return addRule((value) {
      if (value != null && value != value.toInt()) {
        return message ?? '$_fieldName must be a whole number';
      }
      return null;
    }) as NumberValidator;
  }

  /// Must be within range.
  NumberValidator range(num min, num max, [String? message]) {
    return addRule((value) {
      if (value != null && (value < min || value > max)) {
        return message ?? '$_fieldName must be between $min and $max';
      }
      return null;
    }) as NumberValidator;
  }
}

/// List validator.
class ListValidator<T> extends Validator<List<T>> {
  ListValidator(super.fieldName);

  /// List is required (not null or empty).
  ListValidator<T> required([String? message]) {
    return addRule((value) {
      if (value == null || value.isEmpty) {
        return message ?? '$_fieldName is required';
      }
      return null;
    }) as ListValidator<T>;
  }

  /// Minimum length.
  ListValidator<T> minLength(int min, [String? message]) {
    return addRule((value) {
      if (value != null && value.length < min) {
        return message ?? '$_fieldName must have at least $min items';
      }
      return null;
    }) as ListValidator<T>;
  }

  /// Maximum length.
  ListValidator<T> maxLength(int max, [String? message]) {
    return addRule((value) {
      if (value != null && value.length > max) {
        return message ?? '$_fieldName must have at most $max items';
      }
      return null;
    }) as ListValidator<T>;
  }

  /// All items match condition.
  ListValidator<T> allMatch(bool Function(T item) condition, [String? message]) {
    return addRule((value) {
      if (value != null && !value.every(condition)) {
        return message ?? 'Some items in $_fieldName are invalid';
      }
      return null;
    }) as ListValidator<T>;
  }
}

/// Commerce-specific validators.
class CommerceValidators {
  CommerceValidators._();

  /// Validates an email address.
  static ValidationResult email(String? value, {String field = 'Email'}) {
    return StringValidator(field).required().email().validate(value);
  }

  /// Validates a phone number.
  static ValidationResult phone(String? value, {String field = 'Phone'}) {
    return StringValidator(field).required().phone().validate(value);
  }

  /// Validates a shipping address.
  static ValidationResult shippingAddress({
    required String? name,
    required String? phone,
    required String? addressLine1,
    required String? city,
    String? postalCode,
    String? country,
  }) {
    return ValidationResult.merge([
      StringValidator('Name').required().minLength(2).validate(name),
      StringValidator('Phone').required().phone().validate(phone),
      StringValidator('Address').required().minLength(5).validate(addressLine1),
      StringValidator('City').required().minLength(2).validate(city),
      if (postalCode != null)
        StringValidator('Postal Code').minLength(3).validate(postalCode),
      if (country != null)
        StringValidator('Country').minLength(2).validate(country),
    ]);
  }

  /// Validates a cart quantity.
  static ValidationResult quantity(
    int? value, {
    int min = 1,
    int max = 99,
    String field = 'Quantity',
  }) {
    return NumberValidator(field)
        .required()
        .integer()
        .range(min, max)
        .validate(value);
  }

  /// Validates a coupon code.
  static ValidationResult couponCode(String? value, {String field = 'Coupon code'}) {
    return StringValidator(field)
        .required()
        .minLength(3)
        .maxLength(50)
        .alphanumeric()
        .validate(value);
  }

  /// Validates a review.
  static ValidationResult review({
    required int? rating,
    required String? title,
    required String? body,
  }) {
    return ValidationResult.merge([
      NumberValidator('Rating').required().range(1, 5).integer().validate(rating),
      StringValidator('Title').minLength(3).maxLength(100).validate(title),
      StringValidator('Review').minLength(10).maxLength(2000).validate(body),
    ]);
  }

  /// Validates a credit card number (basic Luhn check).
  static ValidationResult creditCard(String? value, {String field = 'Card number'}) {
    return StringValidator(field)
        .required()
        .minLength(13)
        .maxLength(19)
        .addRule((val) {
          if (val == null) return null;
          final digits = val.replaceAll(RegExp(r'\D'), '');
          if (!_luhnCheck(digits)) {
            return 'Invalid card number';
          }
          return null;
        })
        .validate(value);
  }

  /// Validates a CVV.
  static ValidationResult cvv(String? value, {String field = 'CVV'}) {
    return StringValidator(field)
        .required()
        .pattern(RegExp(r'^\d{3,4}$'), 'CVV must be 3 or 4 digits')
        .validate(value);
  }

  /// Validates card expiry (MM/YY format).
  static ValidationResult cardExpiry(String? value, {String field = 'Expiry date'}) {
    return StringValidator(field)
        .required()
        .pattern(RegExp(r'^\d{2}/\d{2}$'), 'Format must be MM/YY')
        .addRule((val) {
          if (val == null) return null;
          final parts = val.split('/');
          final month = int.tryParse(parts[0]);
          final year = int.tryParse(parts[1]);

          if (month == null || month < 1 || month > 12) {
            return 'Invalid month';
          }

          if (year == null) {
            return 'Invalid year';
          }

          final now = DateTime.now();
          final expiryYear = 2000 + year;
          final expiryDate = DateTime(expiryYear, month + 1, 0);

          if (expiryDate.isBefore(now)) {
            return 'Card has expired';
          }

          return null;
        })
        .validate(value);
  }

  /// Luhn algorithm check for credit card validation.
  static bool _luhnCheck(String digits) {
    if (digits.isEmpty) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }
}
