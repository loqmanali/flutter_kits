import 'package:flutter/widgets.dart';

/// One highlight in the tour: the widget to spotlight plus its copy.
///
/// [key] must be the same key handed to the [ShowcaseTarget] wrapping the
/// widget — that is how the tour finds the target's position on screen.
class ShowcaseStep {
  const ShowcaseStep({
    required this.key,
    required this.title,
    required this.body,
  });

  final GlobalKey key;
  final String title;
  final String body;

  @override
  String toString() => 'ShowcaseStep(key: $key, title: $title, body: $body)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShowcaseStep &&
          key == other.key &&
          title == other.title &&
          body == other.body;

  @override
  int get hashCode => Object.hash(key, title, body);
}
