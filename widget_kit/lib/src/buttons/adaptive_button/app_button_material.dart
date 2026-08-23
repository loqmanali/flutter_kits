part of 'adaptive_button.dart';

/// The Material side of [AppButton]: picks the framework button that matches
/// the requested variant and hands it the resolved style.
class _MaterialAppButton extends StatelessWidget {
  const _MaterialAppButton({
    required this.button,
    required this.resolver,
    required this.onPressed,
    required this.onLongPress,
    required this.focusNode,
    required this.content,
  });

  final AppButton button;
  final AppButtonResolver resolver;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final FocusNode focusNode;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    if (button.style == AppButtonVariant.fab) {
      return _FabAppButton(
        button: button,
        resolver: resolver,
        onPressed: onPressed,
        focusNode: focusNode,
        content: content,
      );
    }

    if (resolver.isIconButton) {
      return _IconAppButton(
        button: button,
        resolver: resolver,
        onPressed: onPressed,
        focusNode: focusNode,
        content: content,
      );
    }

    if (button.style == AppButtonVariant.filled ||
        button.style == AppButtonVariant.filledTonal) {
      return FilledButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        style: resolver.buttonStyle,
        focusNode: focusNode,
        autofocus: button.autoFocus,
        clipBehavior: button.clipBehavior,
        statesController: button.statesController,
        child: content,
      );
    } else if (button.style == AppButtonVariant.elevated) {
      return ElevatedButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        style: resolver.buttonStyle,
        focusNode: focusNode,
        autofocus: button.autoFocus,
        clipBehavior: button.clipBehavior,
        statesController: button.statesController,
        child: content,
      );
    } else if (button.style == AppButtonVariant.outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        style: resolver.buttonStyle,
        focusNode: focusNode,
        autofocus: button.autoFocus,
        clipBehavior: button.clipBehavior,
        statesController: button.statesController,
        child: content,
      );
    } else if (button.style == AppButtonVariant.text) {
      return TextButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        style: resolver.buttonStyle,
        focusNode: focusNode,
        autofocus: button.autoFocus,
        clipBehavior: button.clipBehavior,
        statesController: button.statesController,
        child: content,
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: resolver.buttonStyle,
      child: content,
    );
  }
}

/// The four icon-only variants.
class _IconAppButton extends StatelessWidget {
  const _IconAppButton({
    required this.button,
    required this.resolver,
    required this.onPressed,
    required this.focusNode,
    required this.content,
  });

  final AppButton button;
  final AppButtonResolver resolver;
  final VoidCallback? onPressed;
  final FocusNode focusNode;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final style = resolver.buttonStyle;

    if (button.style == AppButtonVariant.iconFilled) {
      return IconButton.filled(
        onPressed: onPressed,
        icon: content,
        style: style,
        focusNode: focusNode,
        autofocus: button.autoFocus,
        tooltip: button.tooltip,
        isSelected: false,
      );
    } else if (button.style == AppButtonVariant.iconFilledTonal) {
      return IconButton.filledTonal(
        onPressed: onPressed,
        icon: content,
        style: style,
        focusNode: focusNode,
        autofocus: button.autoFocus,
        tooltip: button.tooltip,
        isSelected: false,
      );
    } else if (button.style == AppButtonVariant.iconOutlined) {
      return IconButton.outlined(
        onPressed: onPressed,
        icon: content,
        style: style,
        focusNode: focusNode,
        autofocus: button.autoFocus,
        tooltip: button.tooltip,
        isSelected: false,
      );
    } else {
      // AppButtonStyle.icon or default
      return IconButton(
        onPressed: onPressed,
        icon: content,
        style: style,
        focusNode: focusNode,
        autofocus: button.autoFocus,
        tooltip: button.tooltip,
      );
    }
  }
}
