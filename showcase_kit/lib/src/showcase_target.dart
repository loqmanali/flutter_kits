import 'package:flutter/widgets.dart';

/// Attaches the step's [GlobalKey] to the widget it wraps so the tour can
/// measure it. Adds no layout of its own.
class ShowcaseTarget extends StatelessWidget {
  const ShowcaseTarget({
    super.key,
    required this.showcaseKey,
    required this.child,
  });

  final GlobalKey showcaseKey;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: showcaseKey, child: child);
}
