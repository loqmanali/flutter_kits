import 'dart:math';

import 'package:flutter/services.dart';

/// Utility functions for OTP module
class OTPUtils {
  static final _random = Random.secure();

  /// Private constructor to prevent instantiation
  OTPUtils._();

  /// Format OTP value for display
  ///
  /// Example:
  /// ```dart
  /// final formatted = OTPUtils.formatOTP('1234', separator: '-');
  /// // Returns: '1-2-3-4'
  /// ```
  static String formatOTP(String value, {String separator = ' '}) {
    if (value.isEmpty) return '';
    return value.split('').join(separator);
  }

  /// Generate a random OTP for testing.
  ///
  /// Uses [Random.secure]; each call returns a fresh random value (the
  /// previous version seeded once from `DateTime.now()` and was effectively
  /// deterministic).
  ///
  /// Example:
  /// ```dart
  /// final testOTP = OTPUtils.generateTestOTP(length: 6);
  /// // Returns: '847291' (random each call)
  /// ```
  static String generateTestOTP({
    int length = 4,
    bool numericOnly = true,
  }) {
    const numericChars = '0123456789';
    const alphanumericChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    final chars = numericOnly ? numericChars : alphanumericChars;
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(chars[_random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  /// Copy OTP to clipboard
  ///
  /// Example:
  /// ```dart
  /// await OTPUtils.copyToClipboard('1234');
  /// ```
  static Future<void> copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
  }

  /// Get OTP from clipboard if available
  ///
  /// Example:
  /// ```dart
  /// final otp = await OTPUtils.getFromClipboard();
  /// ```
  static Future<String?> getFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text;
    } catch (e) {
      return null;
    }
  }

  /// Extract an OTP from a text (e.g. an SMS body).
  ///
  /// Matches an exact-length run of ASCII digits (`0-9`) **and** Arabic-Indic
  /// digits (`٠-٩`) that isn't surrounded by other digits — so `1234` is
  /// matched out of `Your code: 1234.`, but `12345` is correctly skipped
  /// when `length: 4`. Arabic-Indic digits are normalized to ASCII before
  /// being returned.
  ///
  /// Returns `null` when no match is found.
  ///
  /// Example:
  /// ```dart
  /// OTPUtils.extractOTPFromText('Your OTP is 1234. Valid for 5 minutes.');
  /// // → '1234'
  /// OTPUtils.extractOTPFromText('رمز التحقق: ٤٢٧٩');
  /// // → '4279'
  /// ```
  static String? extractOTPFromText(String text, {int length = 4}) {
    final pattern = RegExp(
      '(?<![0-9٠-٩])([0-9٠-٩]{$length})(?![0-9٠-٩])',
    );
    final match = pattern.firstMatch(text);
    if (match == null) return null;
    final raw = match.group(1)!;
    // Normalize Arabic-Indic digits (U+0660..U+0669) to ASCII (0..9).
    final normalized = StringBuffer();
    for (final code in raw.codeUnits) {
      if (code >= 0x0660 && code <= 0x0669) {
        normalized.writeCharCode(0x30 + (code - 0x0660));
      } else {
        normalized.writeCharCode(code);
      }
    }
    return normalized.toString();
  }

  /// Check if OTP format is valid
  ///
  /// Example:
  /// ```dart
  /// final isValid = OTPUtils.isValidFormat('1234', length: 4);
  /// ```
  static bool isValidFormat(String value, {required int length}) {
    if (value.length != length) return false;
    return RegExp(r'^\d+$').hasMatch(value);
  }

  /// Mask OTP for display (show only first and last digit)
  ///
  /// Example:
  /// ```dart
  /// final masked = OTPUtils.maskOTP('123456');
  /// // Returns: '1****6'
  /// ```
  static String maskOTP(String value, {String maskChar = '*'}) {
    if (value.length <= 2) return value;

    final first = value[0];
    final last = value[value.length - 1];
    final middle = maskChar * (value.length - 2);

    return '$first$middle$last';
  }

  /// Convert OTP to integer safely
  ///
  /// Example:
  /// ```dart
  /// final number = OTPUtils.toInt('1234');
  /// // Returns: 1234
  /// ```
  static int? toInt(String value) {
    return int.tryParse(value);
  }

  /// Validate OTP expiry
  ///
  /// Example:
  /// ```dart
  /// final expiryTime = DateTime.now().add(Duration(minutes: 5));
  /// final isExpired = OTPUtils.isExpired(expiryTime);
  /// ```
  static bool isExpired(DateTime expiryTime) {
    return DateTime.now().isAfter(expiryTime);
  }

  /// Calculate remaining time until expiry
  ///
  /// Example:
  /// ```dart
  /// final expiryTime = DateTime.now().add(Duration(minutes: 5));
  /// final remaining = OTPUtils.remainingTime(expiryTime);
  /// ```
  static Duration remainingTime(DateTime expiryTime) {
    final now = DateTime.now();
    if (now.isAfter(expiryTime)) {
      return Duration.zero;
    }
    return expiryTime.difference(now);
  }

  /// Format remaining time as string
  ///
  /// Example:
  /// ```dart
  /// final expiryTime = DateTime.now().add(Duration(minutes: 5, seconds: 30));
  /// final formatted = OTPUtils.formatRemainingTime(expiryTime);
  /// // Returns: '5:30'
  /// ```
  static String formatRemainingTime(DateTime expiryTime) {
    final remaining = remainingTime(expiryTime);
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Sanitize OTP input (remove non-numeric characters)
  ///
  /// Example:
  /// ```dart
  /// final clean = OTPUtils.sanitizeNumeric('12-34-56');
  /// // Returns: '123456'
  /// ```
  static String sanitizeNumeric(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Sanitize alphanumeric input
  ///
  /// Example:
  /// ```dart
  /// final clean = OTPUtils.sanitizeAlphanumeric('A1-B2-C3!');
  /// // Returns: 'A1B2C3'
  /// ```
  static String sanitizeAlphanumeric(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }

  /// Check if string contains only digits
  static bool isNumeric(String value) {
    return RegExp(r'^\d+$').hasMatch(value);
  }

  /// Check if string contains only letters
  static bool isAlphabetic(String value) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(value);
  }

  /// Check if string is alphanumeric
  static bool isAlphanumeric(String value) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value);
  }

  /// Calculate OTP strength (0.0 to 1.0)
  ///
  /// Based on uniqueness of digits
  static double calculateStrength(String value) {
    if (value.isEmpty) return 0.0;

    final uniqueChars = value.split('').toSet().length;
    final maxUnique = value.length;

    return uniqueChars / maxUnique;
  }

  /// Get strength label
  static String getStrengthLabel(double strength) {
    if (strength < 0.3) return 'Weak';
    if (strength < 0.6) return 'Medium';
    if (strength < 0.8) return 'Strong';
    return 'Very Strong';
  }
}
