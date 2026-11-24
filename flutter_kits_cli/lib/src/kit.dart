/// One package in the flutter_kits monorepo.
class Kit {
  const Kit({
    required this.name,
    required this.version,
    required this.description,
  });

  /// Package name, which is also its directory in the monorepo (`widget_kit`).
  final String name;

  /// The package's own version from its pubspec — *not* a git tag. Tags in this
  /// repo are monorepo releases, so this is only shown, never used as a `ref`.
  final String version;

  /// One line, taken from the package's `description`.
  final String description;

  /// A short setup warning shown after `fkit add`, or null if there is none.
  String? get setupNote => kitSetupNotes[name];
}

/// Extra setup a kit needs that its README can't be relied on to convey.
///
/// Hand-written and kept out of the generated catalog on purpose: regenerating
/// from pubspecs must never wipe these.
const kitSetupNotes = <String, String>{
  'widget_kit':
      'AppButton reads AppButtonThemeExtension, not WidgetKitTheme, and its '
          'defaults are the brand red/orange of the app it was extracted from. '
          "Run 'fkit theme' to generate both extensions, or every button ships red.",
  'otp_kit':
      'Built on hooks_riverpod — wrap your app in a ProviderScope before using it.',
  'notify_kit':
      'Needs platform setup: the google-services / GoogleService-Info files and '
          'notification permissions before init() will deliver anything.',
  'firebase_kit':
      'Requires a configured Firebase project (flutterfire configure) before use.',
  'map_kit':
      'Needs location permissions in the iOS and Android manifests, plus a map '
          'provider key if you use the tile layers.',
  'deep_link_kit':
      'Register your custom scheme / universal-link domains in the platform '
          'manifests — the kit parses links but cannot receive them otherwise.',
  'local_db_kit':
      'Drift-backed: add your own drift_dev build_runner step to generate the '
          'tables this kit opens.',
};
