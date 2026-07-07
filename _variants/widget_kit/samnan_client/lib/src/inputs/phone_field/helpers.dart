import 'dart:async';

import 'package:flutter/material.dart';

import 'countries.dart';
import 'phone_number.dart';

bool isNumeric(String s) =>
    s.isNotEmpty && int.tryParse(s.replaceAll('+', '')) != null;

String removeDiacritics(String str) {
  const withDia =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  const withoutDia =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }

  return str;
}

extension CountryExtensions on List<Country> {
  List<Country> stringSearch(String search) {
    search = removeDiacritics(search.toLowerCase());
    return where(
      (country) => isNumeric(search) || search.startsWith('+')
          ? country.dialCode.contains(search)
          : removeDiacritics(country.name.replaceAll('+', '').toLowerCase())
                  .contains(search) ||
              country.nameTranslations.values.any(
                (element) =>
                    removeDiacritics(element.toLowerCase()).contains(search),
              ),
    ).toList();
  }
}

extension RemoveCountryCode on String {
  // remove country code from the initial number value
  String removeCountryCode(
    String? countryCode,
    Country selectedCountry,
    List<Country> countryList,
  ) {
    String number = this;
    debugPrint('number: $number');
    if (countryCode == null && number.startsWith('+')) {
      number = number.substring(1);
      // parse initial value
      selectedCountry = countries.firstWhere(
        (country) => number.startsWith(country.fullCountryCode),
        orElse: () => countryList.first,
      );
      debugPrint('selectedCountry: $selectedCountry');
      // remove country code from the initial number value
      number = number.replaceFirst(
        RegExp('^${selectedCountry.fullCountryCode}'),
        '',
      );
      return number;
    } else {
      selectedCountry = countryList.firstWhere(
        (item) => item.code == (countryCode ?? 'IN'),
        orElse: () => countryList.first,
      );

      // remove country code from the initial number value
      if (number.startsWith('+')) {
        number = number.replaceFirst(
          RegExp('^\\+${selectedCountry.fullCountryCode}'),
          '',
        );
      } else {
        number = number.replaceFirst(
          RegExp('^${selectedCountry.fullCountryCode}'),
          '',
        );
      }
      return number;
    }
  }
}

/// Custom validator function for phone number fields
String? phoneNumberValidator(
  String? value,
  Country selectedCountry, {
  FutureOr<String?> Function(PhoneNumber?)? customValidator,
  String? validatorMessage,
  bool disableLengthCheck = false,
  int? maxLength,
  String? invalidMessage,
  String? phoneNumberRequired,
}) {
  if (value == null || value.isEmpty) {
    return validatorMessage ??
        phoneNumberRequired ??
        'Phone number is required';
  }

  if (!isNumeric(value)) {
    return validatorMessage ?? invalidMessage ?? 'Invalid phone number';
  }

  if (!disableLengthCheck) {
    final maxLen = maxLength ?? selectedCountry.maxLength;
    if (value.length < selectedCountry.minLength || value.length > maxLen) {
      return invalidMessage ?? 'Invalid phone number length';
    }
  }

  return validatorMessage;
}

/// Async validator wrapper for custom phone number validation
Future<String?> customPhoneNumberValidator(
  String? value,
  Country selectedCountry,
  FutureOr<String?> Function(PhoneNumber?) customValidator, {
  String? validatorMessage,
}) async {
  final initialPhoneNumber = PhoneNumber(
    countryISOCode: selectedCountry.code,
    countryCode: '+${selectedCountry.dialCode}',
    number: value ?? '',
  );

  final result = await customValidator(initialPhoneNumber);
  if (result is String) {
    validatorMessage = result;
    return result;
  }

  return null;
}
