import 'package:adaptive_kit/src/adaptive.dart';
import 'package:flutter/widgets.dart';

/// Feeds [Adaptive] from MediaQuery. Mount it ONCE, at the app root — the
/// `builder:` of your `MaterialApp` is the natural place:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => AdaptiveBuilder(child: child!),
/// )
/// ```
///
/// Because it sits inside the app, it rebuilds on every window resize or
/// rotation and keeps the singleton current before any descendant builds.
class AdaptiveBuilder extends StatelessWidget {
  const AdaptiveBuilder({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    Adaptive.i.update(
      width: size.width,
      height: size.height,
      orientation: MediaQuery.orientationOf(context),
    );
    return child;
  }
}
