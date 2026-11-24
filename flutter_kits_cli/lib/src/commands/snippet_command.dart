import 'package:mason_logger/mason_logger.dart';

import '../templates.g.dart';
import 'template_command.dart';

/// `fkit snippet` — ready-made screens and widgets, copied in and then yours.
class SnippetCommand extends TemplateGroupCommand {
  SnippetCommand(Logger logger)
      : super(
          name: 'snippet',
          aliases: const ['sn'],
          description: 'Copy ready-made code into this project.',
          templates: kSnippets,
          noun: 'snippet',
          logger: logger,
        );
}
