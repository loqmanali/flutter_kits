import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_kits_cli/src/commands/add_command.dart';
import 'package:flutter_kits_cli/src/commands/doctor_command.dart';
import 'package:flutter_kits_cli/src/commands/ls_command.dart';
import 'package:flutter_kits_cli/src/commands/remove_command.dart';
import 'package:flutter_kits_cli/src/commands/snippet_command.dart';
import 'package:flutter_kits_cli/src/commands/style_command.dart';
import 'package:flutter_kits_cli/src/commands/theme_command.dart';
import 'package:flutter_kits_cli/src/project.dart';
import 'package:mason_logger/mason_logger.dart';

Future<void> main(List<String> arguments) async {
  final logger = Logger();

  final runner = CommandRunner<int>(
    'fkit',
    'Manage flutter_kits packages in a Flutter project.',
  )
    ..addCommand(LsCommand(logger))
    ..addCommand(AddCommand(logger))
    ..addCommand(RemoveCommand(logger))
    ..addCommand(SnippetCommand(logger))
    ..addCommand(StyleCommand(logger))
    ..addCommand(ThemeCommand(logger))
    ..addCommand(DoctorCommand(logger));

  try {
    exit(await runner.run(arguments) ?? ExitCode.success.code);
  } on CliException catch (e) {
    // Expected failures — a missing pubspec, an unknown kit name. The message
    // is the whole output; a stack trace here would only be noise.
    logger.err(e.message);
    exit(ExitCode.usage.code);
  } on UsageException catch (e) {
    logger.err(e.toString());
    exit(ExitCode.usage.code);
  }
}
