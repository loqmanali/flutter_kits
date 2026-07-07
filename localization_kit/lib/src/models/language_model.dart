import 'package:equatable/equatable.dart';

/// {@template language_model}
/// Represents a language option.
///
/// - [code]: Full language code sent to the API (e.g. `'ar_EG'`, `'en_US'`).
/// - [name]: Display name (e.g. `'English'`, `'العربية'`).
/// - [isoCode]: ISO language code used by Flutter's [Locale] (e.g. `'ar'`, `'en'`).
/// {@endtemplate}
class LanguageModel extends Equatable {
  const LanguageModel({
    required this.code,
    required this.name,
    required this.isoCode,
  });

  final String code;
  final String name;
  final String isoCode;

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] as String,
      name: json['name'] as String,
      isoCode: json['iso_code'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'iso_code': isoCode,
      };

  static List<LanguageModel> fromJsonList(List<dynamic> jsonList) =>
      jsonList
          .map((json) => LanguageModel.fromJson(json as Map<String, dynamic>))
          .toList();

  @override
  List<Object?> get props => [code, name, isoCode];
}
