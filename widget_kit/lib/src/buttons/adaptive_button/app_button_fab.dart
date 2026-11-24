part of 'adaptive_button.dart';

/// The floating action button variants (regular / small / large / extended).
class _FabAppButton extends StatelessWidget {
  const _FabAppButton({
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
    switch (button.buttonType) {
      case AppFabVariant.small:
        return FloatingActionButton.small(
          onPressed: onPressed,
          heroTag: button.heroTag,
          tooltip: button.tooltip,
          foregroundColor: button.foregroundColor,
          backgroundColor: button.backgroundColor,
          focusColor: button.focusColor,
          hoverColor: button.hoverColor,
          splashColor: button.splashColor,
          elevation: button.elevation,
          focusElevation: button.focusElevation,
          hoverElevation: button.hoverElevation,
          highlightElevation: button.highlightElevation,
          disabledElevation: button.disabledElevation,
          shape: button.shape,
          clipBehavior: button.clipBehavior,
          focusNode: focusNode,
          autofocus: button.autoFocus,
          child: content,
        );

      case AppFabVariant.large:
        return FloatingActionButton.large(
          onPressed: onPressed,
          heroTag: button.heroTag,
          tooltip: button.tooltip,
          foregroundColor: button.foregroundColor,
          backgroundColor: button.backgroundColor,
          focusColor: button.focusColor,
          hoverColor: button.hoverColor,
          splashColor: button.splashColor,
          elevation: button.elevation,
          focusElevation: button.focusElevation,
          hoverElevation: button.hoverElevation,
          highlightElevation: button.highlightElevation,
          disabledElevation: button.disabledElevation,
          shape: button.shape,
          clipBehavior: button.clipBehavior,
          focusNode: focusNode,
          autofocus: button.autoFocus,
          child: content,
        );

      case AppFabVariant.extended:
        return FloatingActionButton.extended(
          onPressed: onPressed,
          heroTag: button.heroTag,
          tooltip: button.tooltip,
          foregroundColor: button.foregroundColor,
          backgroundColor: button.backgroundColor,
          focusColor: button.focusColor,
          hoverColor: button.hoverColor,
          splashColor: button.splashColor,
          elevation: button.elevation,
          focusElevation: button.focusElevation,
          hoverElevation: button.hoverElevation,
          highlightElevation: button.highlightElevation,
          disabledElevation: button.disabledElevation,
          shape: button.shape,
          clipBehavior: button.clipBehavior,
          focusNode: focusNode,
          autofocus: button.autoFocus,
          icon: button.icon,
          label: button.child ?? Text(button.label ?? ''),
        );

      case AppFabVariant.regular:
      default:
        return FloatingActionButton(
          onPressed: onPressed,
          heroTag: button.heroTag,
          tooltip: button.tooltip,
          foregroundColor: button.foregroundColor,
          backgroundColor: button.backgroundColor,
          focusColor: button.focusColor,
          hoverColor: button.hoverColor,
          splashColor: button.splashColor,
          elevation: button.elevation,
          focusElevation: button.focusElevation,
          hoverElevation: button.hoverElevation,
          highlightElevation: button.highlightElevation,
          disabledElevation: button.disabledElevation,
          shape: button.shape,
          clipBehavior: button.clipBehavior,
          focusNode: focusNode,
          autofocus: button.autoFocus,
          child: content,
        );
    }
  }
}
