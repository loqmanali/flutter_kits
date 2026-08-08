import 'package:mason_logger/mason_logger.dart';

import '../templates.g.dart';
import 'template_command.dart';

/// `fkit style` — per-widget theming boilerplate.
///
/// Where `fkit theme` writes one file wiring the whole kit to a brand colour,
/// this writes the styles for a single widget with every value spelled out, so
/// one widget can be customised without reconstructing the rest.
class StyleCommand extends TemplateGroupCommand {
  StyleCommand(Logger logger)
      : super(
          name: 'style',
          aliases: const ['st'],
          description: "Generate a widget's style boilerplate for customization.",
          templates: kStyles,
          noun: 'style',
          logger: logger,
        );
}
