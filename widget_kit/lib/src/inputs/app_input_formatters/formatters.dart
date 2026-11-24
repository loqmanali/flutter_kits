part of '../app_input_formatters.dart';

// The individual TextInputFormatter implementations.
/// Capitalizes first letter of each word
class CapitalizeFirstLetterFormatter extends TextInputFormatter {
  const CapitalizeFirstLetterFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final buffer = StringBuffer();
    bool capitalizeNext = true;

    for (int i = 0; i < newValue.text.length; i++) {
      final char = newValue.text[i];
      buffer.write(capitalizeNext ? char.toUpperCase() : char);
      capitalizeNext = char == ' ';
    }

    return newValue.copyWith(text: buffer.toString());
  }
}

/// Converts to lowercase
class LowercaseFormatter extends TextInputFormatter {
  const LowercaseFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}

/// Converts to uppercase
class UppercaseFormatter extends TextInputFormatter {
  const UppercaseFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🔨 Custom Builder
// ─────────────────────────────────────────────────────────────────────────────
