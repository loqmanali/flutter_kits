part of '../app_input_formatters.dart';

// User-facing strings, validation callbacks, and the shared regex table.
/// Project-agnostic messages used by [AppInputFormatters].
///
/// Use [english], [arabic], [fromLanguageCode], or provide custom messages.
class InputFormatterMessages {
  const InputFormatterMessages({
    required this.lettersAndSpacesOnly,
    required this.arabicLettersOnly,
    required this.englishLettersOnly,
    required this.numbersOnly,
    required this.numbersAndDecimalOnly,
    required this.invalidPhoneFormat,
    required this.invalidEmailFormat,
    required this.emailCannotStartWithNumber,
    required this.spacesNotAllowed,
    required this.specialCharsNotAllowed,
    required this.alphanumericWithUnderscoreAndDash,
    required this.dateFormat,
    required this.maxLengthExceeded,
    required this.invalidNationalAddress,
  });

  final String lettersAndSpacesOnly;
  final String arabicLettersOnly;
  final String englishLettersOnly;
  final String numbersOnly;
  final String numbersAndDecimalOnly;
  final String invalidPhoneFormat;
  final String invalidEmailFormat;
  final String emailCannotStartWithNumber;
  final String spacesNotAllowed;
  final String specialCharsNotAllowed;
  final String alphanumericWithUnderscoreAndDash;
  final String dateFormat;
  final String Function(int maxLength) maxLengthExceeded;
  final String invalidNationalAddress;

  static const english = InputFormatterMessages(
    lettersAndSpacesOnly: 'Only letters and spaces are allowed',
    arabicLettersOnly: 'Only Arabic letters are allowed',
    englishLettersOnly: 'Only English letters are allowed',
    numbersOnly: 'Only numbers are allowed',
    numbersAndDecimalOnly: 'Only numbers and a decimal point are allowed',
    invalidPhoneFormat: 'Invalid phone number format',
    invalidEmailFormat: 'Invalid email format',
    emailCannotStartWithNumber: 'Email cannot start with a number',
    spacesNotAllowed: 'Spaces are not allowed',
    specialCharsNotAllowed: 'Special characters are not allowed',
    alphanumericWithUnderscoreAndDash:
        'Only letters, numbers, underscores, and hyphens are allowed',
    dateFormat: 'Use date format DD/MM/YYYY',
    maxLengthExceeded: _englishMaxLengthExceeded,
    invalidNationalAddress:
        'National address must be 4 letters followed by 4 numbers',
  );

  static const arabic = InputFormatterMessages(
    lettersAndSpacesOnly: 'يُسمح بالحروف والمسافات فقط',
    arabicLettersOnly: 'يُسمح بالحروف العربية فقط',
    englishLettersOnly: 'يُسمح بالحروف الإنجليزية فقط',
    numbersOnly: 'يُسمح بالأرقام فقط',
    numbersAndDecimalOnly: 'يُسمح بالأرقام وعلامة عشرية واحدة فقط',
    invalidPhoneFormat: 'صيغة رقم الهاتف غير صحيحة',
    invalidEmailFormat: 'صيغة البريد الإلكتروني غير صحيحة',
    emailCannotStartWithNumber: 'لا يمكن أن يبدأ البريد الإلكتروني برقم',
    spacesNotAllowed: 'المسافات غير مسموحة',
    specialCharsNotAllowed: 'الرموز الخاصة غير مسموحة',
    alphanumericWithUnderscoreAndDash:
        'يُسمح بالحروف والأرقام والشرطة السفلية والشرطة فقط',
    dateFormat: 'استخدم صيغة التاريخ يوم/شهر/سنة',
    maxLengthExceeded: _arabicMaxLengthExceeded,
    invalidNationalAddress: 'يجب أن يتكون العنوان الوطني من 4 حروف ثم 4 أرقام',
  );

  /// Resolves Arabic for `ar`, `ar_EG`, and `ar-EG`; English otherwise.
  static InputFormatterMessages fromLanguageCode(String languageCode) {
    final normalized = languageCode.toLowerCase().split(RegExp('[-_]')).first;
    return normalized == 'ar' ? arabic : english;
  }

  static String _englishMaxLengthExceeded(int maxLength) =>
      'Maximum length is $maxLength characters';

  static String _arabicMaxLengthExceeded(int maxLength) =>
      'الحد الأقصى هو $maxLength حرفًا';
}

/// Simple error callback with message
typedef OnErrorCallback = void Function(String message);

/// Validation callback without parameters (for specific validation types)
typedef ValidationCallback = void Function();

/// Holds all possible validation callbacks
class InputValidationCallbacks {
  final ValidationCallback? onArabicInput;
  final ValidationCallback? onEnglishInput;
  final ValidationCallback? onNumberInput;
  final ValidationCallback? onSpecialCharacter;
  final ValidationCallback? onMaxLengthReached;
  final ValidationCallback? onEmailStartsWithNumber;

  /// Combined callback that gets called for any invalid input
  final ValidationCallback? onAnyInvalidInput;

  const InputValidationCallbacks({
    this.onArabicInput,
    this.onEnglishInput,
    this.onNumberInput,
    this.onSpecialCharacter,
    this.onMaxLengthReached,
    this.onEmailStartsWithNumber,
    this.onAnyInvalidInput,
  });
}

class _Patterns {
  const _Patterns();
  static const arabic = r'[\u0600-\u06FF]';
  static const english = r'[a-zA-Z]';
  static const numbers = r'[0-9]';
  static const special = r'[!@#$%^&*(),.?":{}|<>]';
  static const emailStartWithNumber = r'^[0-9]';
}
