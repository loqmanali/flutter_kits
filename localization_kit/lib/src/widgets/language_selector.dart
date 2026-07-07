import 'package:flutter/material.dart';

import '../localization.dart';

/// A list-style language picker, typically embedded in a settings page.
///
/// Pass the `supportedLocales` your app supports (usually
/// `AppLocalizations.supportedLocales` from `flutter gen-l10n`) — the kit
/// doesn't presume which locales your app ships with.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.supportedLocales,
    required this.onChanged,
    this.title = 'Language',
  });

  final List<Locale> supportedLocales;
  final ValueChanged<Locale> onChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        ...supportedLocales.map((locale) {
          final isSelected = currentLocale.languageCode == locale.languageCode;
          return ListTile(
            leading: Text(
              Localization.getLanguageFlag(locale.languageCode),
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(Localization.getLanguageName(locale.languageCode)),
            trailing: isSelected
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () {
              if (!isSelected) onChanged(locale);
            },
          );
        }),
      ],
    );
  }
}

/// A compact toggle that cycles through supportedLocales — drop into an
/// `AppBar`'s `actions`.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({
    super.key,
    required this.supportedLocales,
    required this.onChanged,
    this.tooltip = 'Language',
  });

  final List<Locale> supportedLocales;
  final ValueChanged<Locale> onChanged;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    return IconButton(
      icon: Text(
        Localization.getLanguageFlag(currentLocale.languageCode),
        style: const TextStyle(fontSize: 24),
      ),
      tooltip: tooltip,
      onPressed: () {
        if (supportedLocales.isEmpty) return;
        final currentIndex = supportedLocales.indexWhere(
          (locale) => locale.languageCode == currentLocale.languageCode,
        );
        final nextIndex = (currentIndex + 1) % supportedLocales.length;
        onChanged(supportedLocales[nextIndex]);
      },
    );
  }
}
