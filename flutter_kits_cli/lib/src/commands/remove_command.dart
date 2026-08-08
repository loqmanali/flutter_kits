import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../project.dart';

/// `fkit remove <kit...>` — drops kit dependencies from pubspec.yaml.
class RemoveCommand extends Command<int> {
  RemoveCommand(this._logger) {
    argParser.addFlag(
      'pub-get',
      defaultsTo: true,
      help: 'Run "flutter pub get" after editing.',
    );
  }

  final Logger _logger;

  @override
  String get name => 'remove';

  @override
  List<String> get aliases => ['rm'];

  @override
  String get description => 'Remove one or more kits from this project.';

  @override
  String get invocation => 'fkit remove <kit...>';

  @override
  Future<int> run() async {
    final project = Project.locate();
    final installed = project.installedKits.keys.toSet();
    var targets = argResults!.rest;

    if (targets.isEmpty) {
      if (installed.isEmpty) {
        _logger.info('This project does not depend on any kit.');
        return ExitCode.success.code;
      }
      if (!stdin.hasTerminal) {
        throw CliException('Usage: fkit remove <kit...>');
      }
      targets = _logger.chooseAny<String>(
        'Remove which kits?',
        choices: installed.toList()..sort(),
      );
    }

    var removed = 0;
    for (final kit in targets) {
      if (project.removeKit(kit)) {
        _logger.success('Removed $kit');
        removed++;
      } else {
        _logger.warn('$kit is not a dependency of this project.');
      }
    }

    if (removed == 0) return ExitCode.success.code;

    project.save();

    // Leaving stale entries in pubspec.lock and .dart_tool is what produces
    // "package not found" on the next build, so refresh unless told not to.
    if (argResults!.flag('pub-get')) {
      final progress = _logger.progress('flutter pub get');
      try {
        final result = await Process.run(
          'flutter',
          ['pub', 'get'],
          workingDirectory: project.root,
        );
        result.exitCode == 0
            ? progress.complete('flutter pub get')
            : progress.fail('flutter pub get failed');
      } on ProcessException {
        progress.fail('flutter not found on PATH');
      }
    }

    return ExitCode.success.code;
  }
}
