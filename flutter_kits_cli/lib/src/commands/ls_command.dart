import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../catalog.g.dart';
import '../project.dart';

/// `fkit ls` — every kit, and which of them this project already uses.
class LsCommand extends Command<int> {
  LsCommand(this._logger) {
    argParser.addFlag(
      'installed',
      abbr: 'i',
      negatable: false,
      help: 'Only show kits this project already depends on.',
    );
  }

  final Logger _logger;

  @override
  String get name => 'ls';

  @override
  List<String> get aliases => ['list'];

  @override
  String get description => 'List the available kits.';

  @override
  int run() {
    // Listing must work outside a project too, so a missing pubspec is not an
    // error here — it just means nothing can be marked as installed.
    Set<String> installed;
    try {
      installed = Project.locate().installedKits.keys.toSet();
    } on CliException {
      installed = {};
    }

    final onlyInstalled = argResults!.flag('installed');
    final kits = onlyInstalled
        ? kCatalog.where((k) => installed.contains(k.name)).toList()
        : kCatalog;

    if (kits.isEmpty) {
      _logger.info(
        onlyInstalled
            ? 'This project does not depend on any kit yet. Try "fkit add".'
            : 'The catalog is empty.',
      );
      return ExitCode.success.code;
    }

    final width = kits.map((k) => k.name.length).reduce((a, b) => a > b ? a : b);

    _logger
      ..info('')
      ..info('  ${styleBold.wrap('flutter_kits')}  ${darkGray.wrap('pinned at $kDefaultRef')}')
      ..info('');

    for (final kit in kits) {
      final mark = installed.contains(kit.name)
          ? green.wrap('●')
          : darkGray.wrap('○');
      final padded = kit.name.padRight(width);
      _logger.info(
        '  $mark ${cyan.wrap(padded)}  '
        '${darkGray.wrap(kit.version.padRight(7))}  '
        '${kit.description}',
      );
    }

    _logger
      ..info('')
      ..info(
        '  ${darkGray.wrap('● installed   ○ available   —   fkit add <kit> to install')}',
      )
      ..info('');

    return ExitCode.success.code;
  }
}
