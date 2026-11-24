import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../catalog.g.dart';
import '../project.dart';

/// `fkit doctor` — checks how the kits are wired into this project.
///
/// The checks are the mistakes that actually happen: pinning `ref:` to a kit's
/// own version (there is no such tag, so `pub get` fails), leaving a local
/// `path:` dependency in a committed pubspec, and using widget_kit without
/// registering `AppButtonThemeExtension` — which silently ships every button in
/// the kit's built-in brand red.
class DoctorCommand extends Command<int> {
  DoctorCommand(this._logger);

  final Logger _logger;

  @override
  String get name => 'doctor';

  @override
  String get description => 'Check this project\'s kit setup for known problems.';

  @override
  int run() {
    final project = Project.locate();
    final kits = project.installedKits;

    _logger.info('');

    if (kits.isEmpty) {
      _logger
        ..info('  ${darkGray.wrap('No kits in ${p.basename(project.pubspecPath)}.')}')
        ..info('');
      return ExitCode.success.code;
    }

    final problems = <String>[];

    for (final entry in kits.entries) {
      problems.addAll(_checkDependency(entry.key, entry.value));
    }
    problems.addAll(_checkButtonTheme(project, kits.keys.toSet()));

    if (problems.isEmpty) {
      _logger
        ..info('  ${green.wrap('✓')} ${kits.length} kit'
            '${kits.length == 1 ? '' : 's'}, nothing to fix.')
        ..info('');
      return ExitCode.success.code;
    }

    for (final problem in problems) {
      _logger.info('  ${yellow.wrap('!')} $problem');
    }
    _logger.info('');

    // Findings are advisory: a path dep during development is legitimate, so
    // don't fail a build over them.
    return ExitCode.success.code;
  }

  List<String> _checkDependency(String kit, YamlNode node) {
    final value = node.value;

    if (value is! Map) {
      return [
        '$kit is declared as "$value". Kits are not on pub.dev — '
            'use a git dependency, or run "fkit add $kit --force".',
      ];
    }

    if (value.containsKey('path')) {
      return [
        '$kit uses a local path dependency (${value['path']}). '
            'Fine while developing the kits; switch to git before committing: '
            'fkit add $kit --force',
      ];
    }

    final git = value['git'];
    if (git is! Map) {
      return ['$kit has no git source. Run "fkit add $kit --force".'];
    }

    final problems = <String>[];
    final ref = git['ref']?.toString();
    final path = git['path']?.toString();

    if (path != kit) {
      problems.add(
        '$kit points at path "$path" inside the repo; it should be "$kit".',
      );
    }

    if (ref == null) {
      problems.add(
        '$kit has no ref — it will float on the default branch. '
            'Pin it: fkit add $kit --force',
      );
    } else if (ref != kDefaultRef) {
      // The classic mistake: pinning to the kit's own version. Those tags do
      // not exist, so `pub get` fails with a confusing git error.
      final matchesOwnVersion = kCatalog
          .where((k) => k.name == kit)
          .any((k) => ref == 'v${k.version}' || ref == k.version);

      problems.add(
        matchesOwnVersion
            ? '$kit is pinned to "$ref", which looks like the package version. '
                'Tags are monorepo releases — there is no $ref tag. '
                'Use $kDefaultRef: fkit add $kit --force'
            : '$kit is pinned to "$ref"; the current release is $kDefaultRef.',
      );
    }

    return problems;
  }

  /// widget_kit without AppButtonThemeExtension is the expensive silent one.
  List<String> _checkButtonTheme(Project project, Set<String> kits) {
    if (!kits.contains('widget_kit')) return const [];

    final lib = Directory(p.join(project.root, 'lib'));
    if (!lib.existsSync()) return const [];

    final registered = lib
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .any((f) => f.readAsStringSync().contains('AppButtonThemeExtension'));

    if (registered) return const [];

    return [
      'widget_kit is installed but no AppButtonThemeExtension was found in '
          'lib/. AppButton ignores WidgetKitTheme and falls back to its '
          'built-in brand red. Generate one: fkit theme --primary <hex>',
    ];
  }
}
