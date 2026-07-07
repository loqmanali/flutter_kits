/// All user-facing strings rendered by the default screen / banner /
/// dialog.
///
/// Pass localized strings here when constructing
/// [ForceUpdateConfig] — the package ships with English defaults plus a
/// handful of factory constructors for common languages.
class ForceUpdateLabels {
  const ForceUpdateLabels({
    this.title = 'Update available',
    this.message =
        'Please update to the latest version of our app to continue using it.',
    this.updateButton = 'Update',
    this.laterButton = 'Later',
    this.skipVersionButton = 'Skip this version',
    this.releaseNotesTitle = 'What\'s new',
    this.versionPrefix,
  });

  factory ForceUpdateLabels.en() => const ForceUpdateLabels();

  factory ForceUpdateLabels.ar() => const ForceUpdateLabels(
    title: 'تحديث متوفر',
    message: 'يرجى التحديث إلى أحدث إصدار من تطبيقنا لمواصلة استخدامه.',
    updateButton: 'تحديث',
    laterButton: 'لاحقاً',
    skipVersionButton: 'تخطّي هذا الإصدار',
    releaseNotesTitle: 'الجديد في هذا الإصدار',
  );

  factory ForceUpdateLabels.fr() => const ForceUpdateLabels(
    title: 'Mise à jour disponible',
    message:
        'Veuillez installer la dernière version pour continuer à utiliser l\'application.',
    updateButton: 'Mettre à jour',
    laterButton: 'Plus tard',
    skipVersionButton: 'Ignorer cette version',
    releaseNotesTitle: 'Nouveautés',
  );

  factory ForceUpdateLabels.es() => const ForceUpdateLabels(
    title: 'Actualización disponible',
    message:
        'Actualiza a la última versión para seguir usando la aplicación.',
    updateButton: 'Actualizar',
    laterButton: 'Más tarde',
    skipVersionButton: 'Omitir esta versión',
    releaseNotesTitle: 'Novedades',
  );

  factory ForceUpdateLabels.de() => const ForceUpdateLabels(
    title: 'Update verfügbar',
    message:
        'Bitte aktualisieren Sie auf die neueste Version, um die App weiterhin nutzen zu können.',
    updateButton: 'Aktualisieren',
    laterButton: 'Später',
    skipVersionButton: 'Diese Version überspringen',
    releaseNotesTitle: 'Was ist neu',
  );

  factory ForceUpdateLabels.tr() => const ForceUpdateLabels(
    title: 'Güncelleme mevcut',
    message:
        'Uygulamayı kullanmaya devam etmek için lütfen en son sürüme güncelleyin.',
    updateButton: 'Güncelle',
    laterButton: 'Daha sonra',
    skipVersionButton: 'Bu sürümü atla',
    releaseNotesTitle: 'Yenilikler',
  );

  final String title;
  final String message;
  final String updateButton;
  final String laterButton;

  /// Used when [ForceUpdateConfig.skipMode] is
  /// [ForceUpdateSkipMode.version] — the dismissal button reads
  /// "Skip this version" instead of "Later".
  final String skipVersionButton;

  /// Heading displayed above the release notes when
  /// [ForceUpdateConfig.includeReleaseNotes] is `true`.
  final String releaseNotesTitle;

  /// Optional prefix shown before the latest version string,
  /// e.g. `"MyApp"` renders `"MyApp 1.0.1"`. When `null`, the version is
  /// rendered as `"v1.0.1"`.
  final String? versionPrefix;

  ForceUpdateLabels copyWith({
    String? title,
    String? message,
    String? updateButton,
    String? laterButton,
    String? skipVersionButton,
    String? releaseNotesTitle,
    String? versionPrefix,
  }) {
    return ForceUpdateLabels(
      title: title ?? this.title,
      message: message ?? this.message,
      updateButton: updateButton ?? this.updateButton,
      laterButton: laterButton ?? this.laterButton,
      skipVersionButton: skipVersionButton ?? this.skipVersionButton,
      releaseNotesTitle: releaseNotesTitle ?? this.releaseNotesTitle,
      versionPrefix: versionPrefix ?? this.versionPrefix,
    );
  }
}
