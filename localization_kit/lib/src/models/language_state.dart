import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'language_model.dart';

/// Immutable state of the current language.
class LanguageState extends Equatable {
  const LanguageState({
    this.languages = const [],
    this.locale = const Locale('en'),
    this.apiCode = 'en_US',
    this.isLoading = false,
    this.errorMessage,
  });

  /// Languages currently known to the kit (local list or fetched from API).
  final List<LanguageModel> languages;

  /// Current locale for Flutter UI.
  final Locale locale;

  /// Current API language code.
  final String apiCode;

  final bool isLoading;
  final String? errorMessage;

  bool get isArabic => locale.languageCode == 'ar';
  bool get isEnglish => locale.languageCode == 'en';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  LanguageState copyWith({
    List<LanguageModel>? languages,
    Locale? locale,
    String? apiCode,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LanguageState(
      languages: languages ?? this.languages,
      locale: locale ?? this.locale,
      apiCode: apiCode ?? this.apiCode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        languages,
        locale.languageCode,
        apiCode,
        isLoading,
        errorMessage,
      ];
}
