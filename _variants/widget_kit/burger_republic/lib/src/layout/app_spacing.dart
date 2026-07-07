import 'package:flutter/material.dart';

/// A simple spacing widget that adds gaps in your layout.
///
/// - Use [AppSpacing.height] for vertical space.
/// - Use [AppSpacing.width] for horizontal space.
/// - Use [AppSpacing.flex] for flexible space like [Spacer].
///
/// Values are logical pixels — no viewport scaling. For responsive layouts,
/// use `LayoutBuilder` / `Expanded` / `Flexible` at the call site.
class AppSpacing extends StatelessWidget {
  final double? size;
  final Axis axis;
  final int? flex;

  const AppSpacing({
    super.key,
    required this.size,
    this.axis = Axis.vertical,
  }) : flex = null;

  const AppSpacing.height(double height, {Key? key})
      : this(size: height, axis: Axis.vertical, key: key);

  const AppSpacing.width(double width, {Key? key})
      : this(size: width, axis: Axis.horizontal, key: key);

  const AppSpacing.flex(this.flex, {super.key})
      : size = null,
        axis = Axis.vertical;

  @override
  Widget build(BuildContext context) {
    if (flex != null) {
      return Expanded(flex: flex!, child: const SizedBox.shrink());
    }
    return axis == Axis.vertical
        ? SizedBox(height: size!)
        : SizedBox(width: size!);
  }

  static const small = AppSpacing.height(8);
  static const medium = AppSpacing.height(16);
  static const large = AppSpacing.height(24);
}

/// Convenience accessors for the surrounding window size — backed by
/// `MediaQuery.sizeOf`, which is the recommended way to measure available
/// space (see Flutter responsive-layout guidance).
extension AppSpacingContextExtension on BuildContext {
  double get windowHeight => MediaQuery.sizeOf(this).height;
  double get windowWidth => MediaQuery.sizeOf(this).width;
}
