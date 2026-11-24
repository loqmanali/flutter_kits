import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../catalog.g.dart';
import '../kit.dart';
import '../project.dart';

/// `fkit add [kit...]` — writes the git dependency block(s) into pubspec.yaml.
///
/// This is the command the CLI exists for. Adding a kit by hand means six lines
/// of YAML per kit and remembering that the `ref` is a monorepo tag rather than
/// the kit's own version — the mistake that produces a `ref` that doesn't
/// resolve.
class AddCommand extends Command<int> {
  AddCommand(this._logger) {
    argParser
      ..addFlag(
        'force',
        abbr: 'f',
        negatable: false,
        help: 'Overwrite a kit that is already in pubspec.yaml.',
      )
      ..addFlag(
        'dry-run',
        negatable: false,
        help: 'Print the resulting pubspec.yaml without writing it.',
      )
      ..addFlag(
        'pub-get',
        defaultsTo: true,
        help: 'Run "flutter pub get" after editing.',
      )
      ..addOption(
        'ref',
        help: 'Git tag, branch, or commit to pin to.',
        defaultsTo: kDefaultRef,
      )
      ..addOption(
        'path',
        help: 'Use local path dependencies rooted here instead of git '
            '(for developing the kits themselves).',
      );
  }

  final Logger _logger;

  @override
  String get name => 'add';

  @override
  List<String> get aliases => ['a'];

  @override
  String get description => 'Add one or more kits to this project.';

  @override
  String get invocation => 'fkit add [kit...]';

  @override
  Future<int> run() async {
    final project = Project.locate();
    final requested = argResults!.rest;
    final localPath = argResults!.option('path');
    final source = localPath == null ? InstallSource.git : InstallSource.path;

    final selection = requested.isEmpty
        ? _promptForKits(project)
        : _resolveNames(requested);

    if (selection.isEmpty) {
      _logger.info('Nothing to add.');
      return ExitCode.success.code;
    }

    final force = argResults!.flag('force');
    final ref = argResults!.option('ref')!;

    final added = <Kit>[];
    final skipped = <Kit>[];

    for (final kit in selection) {
      final changed = project.addKit(
        kit.name,
        source: source,
        ref: ref,
        localPath: localPath,
        overwrite: force,
      );
      (changed ? added : skipped).add(kit);
    }

    for (final kit in skipped) {
      _logger.warn(
        '${kit.name} is already in pubspec.yaml — pass --force to replace it.',
      );
    }

    if (added.isEmpty) return ExitCode.success.code;

    if (argResults!.flag('dry-run')) {
      _logger
        ..info('')
        ..info(darkGray.wrap('--- ${project.pubspecPath} (dry run) ---')!)
        ..info(project.pubspecText);
      return ExitCode.success.code;
    }

    project.save();
    for (final kit in added) {
      _logger.success('Added ${kit.name} ${darkGray.wrap(kit.version)}');
    }

    _printSetupNotes(added);

    if (argResults!.flag('pub-get')) {
      return _pubGet(project);
    }

    _logger.info(darkGray.wrap('Run "flutter pub get" to fetch it.')!);
    return ExitCode.success.code;
  }

  /// Maps CLI arguments to catalog entries, failing on the first unknown name
  /// rather than silently installing a subset.
  List<Kit> _resolveNames(List<String> names) {
    final unknown = <String>[];
    final kits = <Kit>[];

    for (final name in names) {
      final kit = kCatalog.where((k) => k.name == name).firstOrNull;
      if (kit == null) {
        unknown.add(name);
      } else if (!kits.contains(kit)) {
        kits.add(kit);
      }
    }

    if (unknown.isNotEmpty) {
      final suggestions = unknown
          .map((n) => _closest(n))
          .whereType<String>()
          .toSet();

      throw CliException(
        'Unknown kit${unknown.length == 1 ? '' : 's'}: ${unknown.join(', ')}.'
        '${suggestions.isEmpty ? '' : '\nDid you mean: ${suggestions.join(', ')}?'}'
        '\nRun "fkit ls" to see them all.',
      );
    }

    return kits;
  }

  /// A cheap substring-based suggestion — enough to catch `widgetkit` for
  /// `widget_kit` without pulling in an edit-distance implementation.
  String? _closest(String typo) {
    final needle = typo.toLowerCase().replaceAll(RegExp(r'[_\-\s]'), '');
    for (final kit in kCatalog) {
      final hay = kit.name.replaceAll('_', '');
      if (hay.contains(needle) || needle.contains(hay)) return kit.name;
    }
    return null;
  }

  List<Kit> _promptForKits(Project project) {
    if (!stdin.hasTerminal) {
      throw CliException(
        'No kit named and no terminal to prompt from.\n'
        'Usage: fkit add <kit> [kit...]  —  see "fkit ls".',
      );
    }

    final installed = project.installedKits.keys.toSet();
    final available =
        kCatalog.where((k) => !installed.contains(k.name)).toList();

    if (available.isEmpty) {
      _logger.info('This project already depends on every kit.');
      return const [];
    }

    return _logger.chooseAny<Kit>(
      'Which kits?',
      choices: available,
      display: (kit) =>
          '${kit.name.padRight(20)} ${darkGray.wrap(kit.description)}',
    );
  }

  void _printSetupNotes(List<Kit> kits) {
    final notes = kits.where((k) => k.setupNote != null);
    if (notes.isEmpty) return;

    _logger.info('');
    for (final kit in notes) {
      _logger
        ..info(yellow.wrap('  ! ${kit.name}')!)
        ..info('    ${kit.setupNote}');
    }
  }

  Future<int> _pubGet(Project project) async {
    final progress = _logger.progress('flutter pub get');

    // `flutter` may be absent (a pure Dart package, or a bare CI image); that's
    // a soft failure — the pubspec edit already succeeded.
    final ProcessResult result;
    try {
      result = await Process.run(
        'flutter',
        ['pub', 'get'],
        workingDirectory: project.root,
      );
    } on ProcessException {
      progress.fail('flutter not found on PATH');
      _logger.info(darkGray.wrap('Run "flutter pub get" yourself.')!);
      return ExitCode.success.code;
    }

    if (result.exitCode != 0) {
      progress.fail('flutter pub get failed');
      _logger.err((result.stderr as String).trim());
      return ExitCode.software.code;
    }

    progress.complete('flutter pub get');
    return ExitCode.success.code;
  }
}
