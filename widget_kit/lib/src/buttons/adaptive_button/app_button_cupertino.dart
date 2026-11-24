part of 'adaptive_button.dart';

/// The iOS side of [AppButton], used when `useCupertinoStyle` is set.
class _CupertinoAppButton extends StatelessWidget {
  const _CupertinoAppButton({
    required this.button,
    required this.resolver,
    required this.onPressed,
    required this.content,
  });

  final AppButton button;
  final AppButtonResolver resolver;
  final VoidCallback? onPressed;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = button.cupertinoColor ??
        button.backgroundColor ??
        CupertinoTheme.of(context).primaryColor;

    final effectivePadding = button.cupertinoPadding ??
        button.customPadding ??
        resolver.metrics.padding;

    final effectiveBorderRadius = button.cupertinoBorderRadius ??
        (button.borderRadius != null
            ? BorderRadius.circular(button.borderRadius!)
            : const BorderRadius.all(Radius.circular(8.0)));

    if (button.style == AppButtonVariant.outlined ||
        button.style == AppButtonVariant.text) {
      // Cupertino doesn't have outlined/text variants, use borderless style
      return CupertinoButton(
        onPressed: onPressed,
        padding: effectivePadding,
        pressedOpacity: button.cupertinoPressedOpacity,
        borderRadius: effectiveBorderRadius,
        alignment: button.cupertinoAlignment,
        minimumSize: Size(
          button.cupertinoMinSize,
          button.cupertinoMinSize,
        ), // Transparent background
        child: DefaultTextStyle(
          style: TextStyle(
            color: effectiveColor,
            fontSize: resolver.metrics.fontSize,
            fontWeight: resolver.metrics.fontWeight,
          ),
          child: content,
        ),
      );
    }

    return CupertinoButton(
      onPressed: onPressed,
      padding: effectivePadding,
      pressedOpacity: button.cupertinoPressedOpacity,
      borderRadius: effectiveBorderRadius,
      alignment: button.cupertinoAlignment,
      color: effectiveColor,
      minimumSize: Size(button.cupertinoMinSize, button.cupertinoMinSize),
      disabledColor: button.disabledBackgroundColor ??
          CupertinoColors.quaternarySystemFill,
      child: content,
    );
  }
}
