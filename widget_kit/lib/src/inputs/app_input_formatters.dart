import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'app_input_formatters/formatter_messages.dart';
part 'app_input_formatters/formatters.dart';
part 'app_input_formatters/formatter_builder.dart';

/// Smart input formatter with error callbacks and debouncing
class SmartInputFormatter extends TextInputFormatter {
  SmartInputFormatter({
    required this.allowedPattern,
    this.deniedPattern,
    this.errorMessage,
    this.onError,
    this.callbacks,
    this.validationType,
  });

  final RegExp allowedPattern;
  final RegExp? deniedPattern;
  final String? errorMessage;
  final OnErrorCallback? onError;
  final InputValidationCallbacks? callbacks;
  final String? validationType; // 'arabic', 'english', 'number', 'special'

  DateTime? _lastErrorTime;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty value
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Check denied pattern first
    if (deniedPattern != null && deniedPattern!.hasMatch(newValue.text)) {
      _triggerCallback();
      return oldValue;
    }

    // Check allowed pattern
    if (!allowedPattern.hasMatch(newValue.text)) {
      _triggerCallback();
      return oldValue;
    }

    return newValue;
  }

  void _triggerCallback() {
    // Debounce - max 1 callback per second
    final now = DateTime.now();
    if (_lastErrorTime != null &&
        now.difference(_lastErrorTime!).inMilliseconds < 1000) {
      return;
    }
    _lastErrorTime = now;

    // Call simple error callback
    if (errorMessage != null && onError != null) {
      onError!(errorMessage!);
    }

    // Call specific validation callback
    callbacks?._callCallback(validationType);
  }
}

/// Extension to easily call the right callback based on validation type
extension InputValidationCallbacksExtension on InputValidationCallbacks {
  void _callCallback(String? type) {
    // First try the generic callback
    if (onAnyInvalidInput != null) {
      onAnyInvalidInput!();
      return;
    }

    // Then try specific callbacks
    switch (type) {
      case 'arabic':
        onArabicInput?.call();
        break;
      case 'english':
        onEnglishInput?.call();
        break;
      case 'number':
        onNumberInput?.call();
        break;
      case 'special':
        onSpecialCharacter?.call();
        break;
      case 'emailStartNumber':
        onEmailStartsWithNumber?.call();
        break;
      case 'maxLength':
        onMaxLengthReached?.call();
        break;
    }
  }
}

class AppInputFormatters {
  AppInputFormatters._();

  /// Letters only (Arabic + English + spaces)
  static List<TextInputFormatter> lettersOnly({
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
    InputFormatterMessages messages = InputFormatterMessages.english,
  }) =>
      [
        SmartInputFormatter(
          allowedPattern: RegExp(r'^[\u0600-\u06FFa-zA-Z\s]*$'),
          deniedPattern: RegExp(r'[\u0660-\u0669]'), // Arabic-Indic numerals
          errorMessage: messages.lettersAndSpacesOnly,
          onError: onError,
          callbacks: callbacks,
        ),
      ];

  /// Arabic letters only
  static List<TextInputFormatter> arabicOnly({
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
    bool preventSpaces = true,
    InputFormatterMessages messages = InputFormatterMessages.english,
  }) {
    final pattern =
        preventSpaces ? r'^[\u0600-\u06FF]*$' : r'^[\u0600-\u06FF\s]*$';
    final formatters = <TextInputFormatter>[
      SmartInputFormatter(
        allowedPattern: RegExp(pattern),
        deniedPattern: RegExp('${_Patterns.english}|${_Patterns.numbers}'),
        errorMessage: messages.arabicLettersOnly,
        onError: onError,
        callbacks: callbacks,
        validationType: 'english',
      ),
    ];

    if (preventSpaces) {
      formatters.add(FilteringTextInputFormatter.deny(RegExp(r'\s')));
    }

    return formatters;
  }

  /// English letters only
  static List<TextInputFormatter> englishOnly({
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
    bool preventSpaces = true,
    InputFormatterMessages messages = InputFormatterMessages.english,
  }) {
    final pattern = preventSpaces ? r'^[a-zA-Z]*$' : r'^[a-zA-Z\s]*$';
    final formatters = <TextInputFormatter>[
      SmartInputFormatter(
        allowedPattern: RegExp(pattern),
        deniedPattern: RegExp('${_Patterns.arabic}|${_Patterns.numbers}'),
        errorMessage: messages.englishLettersOnly,
        onError: onError,
        callbacks: callbacks,
        validationType: 'arabic',
      ),
    ];

    if (preventSpaces) {
      formatters.add(FilteringTextInputFormatter.deny(RegExp(r'\s')));
    }

    return formatters;
  }

  /// English letters only with spaces (alias for englishOnly with preventSpaces: false)
  static List<TextInputFormatter> lettersOnlyEnglish({
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
    InputFormatterMessages messages = InputFormatterMessages.english,
  }) =>
      englishOnly(
        onError: onError,
        callbacks: callbacks,
        preventSpaces: false,
        messages: messages,
      );

  /// Numbers only
  static List<TextInputFormatter> numbersOnly({
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
    InputFormatterMessages messages = InputFormatterMessages.english,
  }) =>
      [
        SmartInputFormatter(
          allowedPattern: RegExp(r'^[0-9]*$'),
          errorMessage: messages.numbersOnly,
          onError: onError,
          callbacks: callbacks,
          validationType: 'number',
        ),
      ];

  /// Numbers with decimal point
  static List<TextInputFormatter> decimalNumber({
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
    InputFormatterMessages messages = InputFormatterMessages.english,
  }) =>
      [
        SmartInputFormatter(
          allowedPattern: RegExp(r'^[0-9.]*$'),
          errorMessage: messages.numbersAndDecimalOnly,
          onError: onError,
          callbacks: callbacks,
        ),
      ];

  /// Phone number (numbers, +, -, spaces, parentheses)
  static List<TextInputFormatter> phoneNumber({
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
    InputFormatterMessages messages = InputFormatterMessages.english,
  }) =>
      [
        SmartInputFormatter(
          allowedPattern: RegExp(r'^[0-9\s\-\(\)\+]*$'),
          errorMessage: messages.invalidPhoneFormat,
          onError: onError,
          callbacks: callbacks,
        ),
      ];

  /// Email formatter
  static List<TextInputFormatter> email({
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
    bool allowStartWithNumber = true,
    int? maxLength,
    InputFormatterMessages messages = InputFormatterMessages.english,
  }) {
    final formatters = <TextInputFormatter>[
      SmartInputFormatter(
        allowedPattern: RegExp(r'^[a-zA-Z0-9@._\-*]*$'),
        errorMessage: messages.invalidEmailFormat,
        onError: onError,
        callbacks: callbacks,
      ),
    ];

    if (!allowStartWithNumber) {
      formatters.add(
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isNotEmpty &&
              RegExp(_Patterns.emailStartWithNumber).hasMatch(newValue.text)) {
            callbacks?._callCallback('emailStartNumber');
            onError?.call(messages.emailCannotStartWithNumber);
            return oldValue;
          }
          return newValue;
        }),
      );
    }

    if (maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(maxLength));
    }

    return formatters;
  }

  /// No spaces
  static List<TextInputFormatter> noSpaces({
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
    InputFormatterMessages messages = InputFormatterMessages.english,
  }) =>
      [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
        if (onError != null)
          SmartInputFormatter(
            allowedPattern: RegExp(r'^\S*$'),
            errorMessage: messages.spacesNotAllowed,
            onError: onError,
            callbacks: callbacks,
          ),
      ];

  /// No special characters
  static List<TextInputFormatter> noSpecialCharacters({
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
    InputFormatterMessages messages = InputFormatterMessages.english,
  }) =>
      [
        SmartInputFormatter(
          allowedPattern: RegExp(r'^[\u0600-\u06FFa-zA-Z0-9\s]*$'),
          deniedPattern: RegExp(_Patterns.special),
          errorMessage: messages.specialCharsNotAllowed,
          onError: onError,
          callbacks: callbacks,
          validationType: 'special',
        ),
      ];

  /// Username (letters, numbers, underscore, hyphen)
  static List<TextInputFormatter> username({
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
    InputFormatterMessages messages = InputFormatterMessages.english,
  }) =>
      [
        SmartInputFormatter(
          allowedPattern: RegExp(r'^[a-zA-Z0-9_-]*$'),
          errorMessage: messages.alphanumericWithUnderscoreAndDash,
          onError: onError,
          callbacks: callbacks,
        ),
      ];

  /// Date format (DD/MM/YYYY)
  static List<TextInputFormatter> date({
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
    InputFormatterMessages messages = InputFormatterMessages.english,
  }) =>
      [
        SmartInputFormatter(
          allowedPattern: RegExp(r'^[0-9/]*$'),
          errorMessage: messages.dateFormat,
          onError: onError,
          callbacks: callbacks,
        ),
      ];

  /// With max length
  static List<TextInputFormatter> withMaxLength(
    int max, {
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
    InputFormatterMessages messages = InputFormatterMessages.english,
  }) =>
      [
        LengthLimitingTextInputFormatter(max),
        if (callbacks?.onMaxLengthReached != null || onError != null)
          TextInputFormatter.withFunction((oldValue, newValue) {
            if (newValue.text.length > max) {
              callbacks?._callCallback('maxLength');
              onError?.call(messages.maxLengthExceeded(max));
            }
            return newValue;
          }),
      ];

  // ─────────────────────────────────────────────────────────────────────────
  // Utility Formatters
  // ─────────────────────────────────────────────────────────────────────────

  /// Capitalize first letter of each word
  static const CapitalizeFirstLetterFormatter capitalizeFirstLetter =
      CapitalizeFirstLetterFormatter();

  /// Lowercase converter
  static const LowercaseFormatter lowercase = LowercaseFormatter();

  /// Uppercase converter
  static const UppercaseFormatter uppercase = UppercaseFormatter();

  /// National address formatter (4 letters + 4 numbers)
  static List<TextInputFormatter> nationalAddress({
    OnErrorCallback? onError,
    InputValidationCallbacks? callbacks,
    InputFormatterMessages messages = InputFormatterMessages.english,
  }) =>
      [
        TextInputFormatter.withFunction((oldValue, newValue) {
          final text = newValue.text.toUpperCase();
          // Allow only English letters in first 4 positions
          for (int i = 0; i < text.length && i < 4; i++) {
            if (!RegExp(r'[a-zA-Z]').hasMatch(text[i])) {
              onError?.call(messages.invalidNationalAddress);
              return oldValue;
            }
          }
          // Allow only numbers in positions 4-7
          for (int i = 4; i < text.length && i < 8; i++) {
            if (!RegExp(r'[0-9]').hasMatch(text[i])) {
              onError?.call(messages.invalidNationalAddress);
              return oldValue;
            }
          }
          // Don't allow more than 8 characters
          if (text.length > 8) {
            onError?.call(messages.invalidNationalAddress);
            return oldValue;
          }
          return newValue.copyWith(text: text);
        }),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎨 Text Transformation Formatters
// ─────────────────────────────────────────────────────────────────────────────
