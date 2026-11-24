import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;

import '../project.dart';
import '../templates.g.dart';

/// Shared implementation behind `fkit snippet` and `fkit style`.
///
/// Both copy a file into the project and then forget about it; only the
/// catalogue and the wording differ, so the behaviour lives here once rather
/// than in two files that would drift.
class TemplateGroupCommand extends Command<int> {
  TemplateGroupCommand({
    required this.name,
    required this.aliases,
    required this.description,
    required List<Template> templates,
    required String noun,
    required Logger logger,
  }) {
    addSubcommand(TemplateLsCommand(
      templates: templates,
      noun: noun,
      group: name,
      logger: logger,
    ));
    addSubcommand(TemplateCreateCommand(
      templates: templates,
      noun: noun,
      group: name,
      logger: logger,
    ));
  }

  @override
  final String name;

  @override
  final List<String> aliases;

  @override
  final String description;
}

/// `fkit <group> ls`
class TemplateLsCommand extends Command<int> {
  TemplateLsCommand({
    required this.templates,
    required this.noun,
    required this.group,
    required Logger logger,
  }) : _logger = logger;

  final List<Template> templates;
  final String noun;
  final String group;
  final Logger _logger;

  @override
  String get name => 'ls';

  @override
  List<String> get aliases => ['list'];

  @override
  String get description => 'List the available ${noun}s.';

  @override
  int run() {
    final width =
        templates.map((t) => t.name.length).reduce((a, b) => a > b ? a : b);

    _logger.info('');
    for (final t in templates) {
      final needs = [...t.kits, ...t.pub].join(', ');
      _logger
        ..info('  ${cyan.wrap(t.name.padRight(width))}  ${t.description}')
        ..info(
          '  ${' ' * width}  ${darkGray.wrap('→ ${t.output}'
              '${needs.isEmpty ? '' : '   needs $needs'}')}',
        );
    }
    _logger
      ..info('')
      ..info(darkGray.wrap('  fkit $group create <name> to add one')!)
      ..info('');

    return ExitCode.success.code;
  }
}

/// `fkit <group> create <name...>`
class TemplateCreateCommand extends Command<int> {
  TemplateCreateCommand({
    required this.templates,
    required this.noun,
    required this.group,
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addFlag(
        'all',
        abbr: 'a',
        negatable: false,
        help: 'Create every $noun.',
      )
      ..addFlag(
        'force',
        abbr: 'f',
        negatable: false,
        help: 'Overwrite the destination file if it exists.',
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Write here instead of the default path for this $noun. ' 
            'Only valid with a single $noun.',
      );
  }

  final List<Template> templates;
  final String noun;
  final String group;
  final Logger _logger;

  @override
  String get name => 'create';

  @override
  List<String> get aliases => ['c'];

  @override
  String get description => 'Create one or more $noun files.';

  @override
  String get invocation => 'fkit $group create [name...]';

  @override
  int run() {
    final project = Project.locate();
    final requested = argResults!.rest;
    final output = argResults!.option('output');
    final all = argResults!.flag('all');

    if (all && requested.isNotEmpty) {
      throw CliException('Pass --all or a list of names, not both.');
    }

    final selection = all
        ? templates
        : requested.isEmpty
            ? _prompt()
            : _resolve(requested);

    if (selection.length > 1 && output != null) {
      throw CliException(
        'Cannot write several ${noun}s to one path. Drop --output, or create '
        'them one at a time.',
      );
    }

    if (selection.isEmpty) {
      _logger.info('Nothing to create.');
      return ExitCode.success.code;
    }

    final installed = project.installedKits.keys.toSet();
    final force = argResults!.flag('force');

    for (final template in selection) {
      final relative = output ?? template.output;
      final file = File(p.join(project.root, relative));

      if (file.existsSync() && !force) {
        _logger.warn(
          '${file.path} already exists — pass --force to overwrite it.',
        );
        continue;
      }

      file
        ..createSync(recursive: true)
        ..writeAsStringSync(template.body);

      _logger.success('Created $relative');

      // A template importing something the project lacks produces a wall of
      // "target of URI doesn't exist". Say so first — and give the right fix
      // for each kind, since kits and pub packages install differently.
      final missingKits =
          template.kits.where((k) => !installed.contains(k)).toList();
      final missingPub =
          template.pub.where((k) => !project.hasDependency(k)).toList();

      if (missingKits.isNotEmpty || missingPub.isNotEmpty) {
        _logger.info('');
        if (missingKits.isNotEmpty) {
          _logger
            ..info(yellow.wrap('  ! needs ${missingKits.join(', ')}')!)
            ..info('    ${darkGray.wrap('fkit add ${missingKits.join(' ')}')}');
        }
        if (missingPub.isNotEmpty) {
          _logger
            ..info(yellow.wrap('  ! needs ${missingPub.join(', ')}')!)
            ..info(
              '    ${darkGray.wrap('flutter pub add ${missingPub.join(' ')}')}',
            );
        }
        _logger.info('');
      }
    }

    return ExitCode.success.code;
  }

  List<Template> _resolve(List<String> names) {
    final unknown = <String>[];
    final found = <Template>[];

    for (final name in names) {
      // Fold case and separators so "AppButton" and "app_button" both resolve.
      final wanted = _fold(name);
      final match = templates.where((t) => _fold(t.name) == wanted).firstOrNull;
      if (match == null) {
        unknown.add(name);
      } else if (!found.contains(match)) {
        found.add(match);
      }
    }

    if (unknown.isNotEmpty) {
      throw CliException(
        'Unknown $noun${unknown.length == 1 ? '' : 's'}: ${unknown.join(', ')}.\n'
        'Run "fkit $group ls" to see them all.',
      );
    }

    return found;
  }

  static String _fold(String value) =>
      value.toLowerCase().replaceAll(RegExp('[-_ ]'), '');

  List<Template> _prompt() {
    if (!stdin.hasTerminal) {
      throw CliException(
        'No $noun named and no terminal to prompt from.\n'
        'Usage: fkit $group create <name>  —  see "fkit $group ls".',
      );
    }

    return _logger.chooseAny<Template>(
      'Which ${noun}s?',
      choices: templates,
      display: (t) =>
          '${t.name.padRight(16)} ${darkGray.wrap(t.description)}',
    );
  }
}
