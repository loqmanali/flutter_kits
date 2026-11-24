part of 'adaptive_button.dart';

/// A FAB's inner content: the bare icon, or icon + label when extended.
class _FabContent extends StatelessWidget {
  const _FabContent({
    required this.extended,
    required this.icon,
    required this.label,
    required this.child,
  });

  final bool extended;
  final Widget icon;
  final String? label;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (!extended) return icon;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 8),
        if (child != null) child! else Text(label ?? ''),
      ],
    );
  }
}

/// A text label with an optional icon on either side.
class _LabelWithIcon extends StatelessWidget {
  const _LabelWithIcon({
    required this.label,
    required this.textStyle,
    required this.icon,
    required this.iconAlignment,
    required this.fitLabel,
    required this.fillWidth,
    required this.child,
  });

  final String? label;
  final TextStyle textStyle;
  final Widget? icon;
  final AppIconAlignment iconAlignment;
  final bool fitLabel;
  final bool fillWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final baseText = label != null
        ? Text(label!, style: textStyle)
        : (child ?? const SizedBox.shrink());

    final text =
        fitLabel ? FittedBox(fit: BoxFit.scaleDown, child: baseText) : baseText;

    if (icon == null) return text;

    return Row(
      mainAxisSize: fillWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          fillWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (iconAlignment == AppIconAlignment.start) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Flexible(child: text),
        if (iconAlignment == AppIconAlignment.end) ...[
          const SizedBox(width: 8),
          icon!,
        ],
      ],
    );
  }
}
