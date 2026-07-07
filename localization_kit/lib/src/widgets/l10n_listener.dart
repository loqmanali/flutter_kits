import 'package:flutter/widgets.dart';

/// Forces the subtree to rebuild whenever the ambient [Locale] changes by
/// keying it on the locale's language tag.
///
/// Useful when you cache localized strings outside of `AppLocalizations.of`
/// (e.g. in a global `L10n` forwarder generated from your ARB files): wrap
/// such caches with this widget so they get re-initialised after a language
/// switch.
///
/// ```dart
/// MaterialApp(
///   locale: ref.watch(currentLocaleProvider),
///   supportedLocales: AppLocalizations.supportedLocales,
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   builder: (context, child) => L10nListener(
///     onLocaleChanged: (locale) => L10n.init(context),
///     child: child!,
///   ),
/// );
/// ```
class L10nListener extends StatefulWidget {
  const L10nListener({
    super.key,
    required this.child,
    this.onLocaleChanged,
  });

  final Widget child;

  /// Optional callback fired when the [Locale] changes.
  ///
  /// Typical use: re-initialize a global localization forwarder (e.g.
  /// `L10n.init(context)`).
  final void Function(Locale locale)? onLocaleChanged;

  @override
  State<L10nListener> createState() => _L10nListenerState();
}

class _L10nListenerState extends State<L10nListener> {
  Locale? _cachedLocale;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (_cachedLocale != locale) {
      _cachedLocale = locale;
      widget.onLocaleChanged?.call(locale);
    }
    return KeyedSubtree(
      key: ValueKey(locale.toLanguageTag()),
      child: widget.child,
    );
  }
}
