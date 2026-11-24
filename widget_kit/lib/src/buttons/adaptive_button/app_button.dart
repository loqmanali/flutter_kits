part of 'adaptive_button.dart';

/// ---------------------------------------------------------------------------
/// AppButton - Material 3 & Cupertino Support
/// ---------------------------------------------------------------------------
/// Supports all Material 3 button variants:
/// - Filled, FilledTonal, Elevated, Outlined, Text
/// - Icon (standard, filled, filledTonal, outlined)
/// - FloatingActionButton (regular, small, large, extended)
///
/// Also supports iOS/Cupertino style buttons when [useCupertinoStyle] is true
/// ---------------------------------------------------------------------------

@immutable
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    this.label,
    this.child,
    this.style = AppButtonVariant.filled,
    this.widthMode,
    this.icon,
    this.iconAlignment,
    this.size = AppButtonSize.medium,
    this.customPadding,
    this.isLoading = false,
    this.isDisabled = false,
    this.fitLabel = true,
    this.onPressed,
    this.onLongPress,
    this.foregroundColor,
    this.backgroundColor,
    this.disabledForegroundColor,
    this.disabledBackgroundColor,
    this.shadowColor,
    this.surfaceTintColor,
    this.iconColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.textStyle,
    this.semanticLabel,
    this.tooltip,
    this.enableHapticFeedback = true,
    this.animationDuration = const Duration(milliseconds: 120),
    this.loadingIndicatorType = LoadingIndicatorType.fadingCircle,
    this.autoFocus = false,
    this.loadingIndicatorColor,
    this.focusNode,
    this.clipBehavior = Clip.none,
    this.statesController,
    this.useCupertinoStyle = false,
    this.cupertinoColor,
    this.cupertinoPadding,
    this.cupertinoMinSize = kMinInteractiveDimensionCupertino,
    this.cupertinoPressedOpacity = 0.4,
    this.cupertinoBorderRadius,
    this.cupertinoAlignment = Alignment.center,
  })  : buttonType = null,
        focusColor = null,
        hoverColor = null,
        splashColor = null,
        focusElevation = null,
        hoverElevation = null,
        highlightElevation = null,
        disabledElevation = null,
        shape = null,
        heroTag = null,
        assert(
          style == AppButtonVariant.icon ||
                  style == AppButtonVariant.iconFilled ||
                  style == AppButtonVariant.iconFilledTonal ||
                  style == AppButtonVariant.iconOutlined
              ? icon != null
              : (label != null || child != null),
          'Icon is required for icon style; label or child is required for other styles.',
        );

  /// FAB Constructor
  const AppButton.fab({
    super.key,
    this.label,
    this.child,
    required this.icon,
    this.heroTag,
    this.fitLabel = true,
    this.buttonType = AppFabVariant.regular,
    this.onPressed,
    this.onLongPress,
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.elevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.disabledElevation,
    this.shadowColor,
    this.shape,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autoFocus = false,
    this.isDisabled = false,
    this.isLoading = false,
    this.enableHapticFeedback = true,
    this.semanticLabel,
    this.useCupertinoStyle = false,
    this.loadingIndicatorColor,
    this.loadingIndicatorType = LoadingIndicatorType.fadingCircle,
  })  : style = AppButtonVariant.fab,
        widthMode = null,
        iconAlignment = null,
        size = AppButtonSize.medium,
        customPadding = null,
        disabledForegroundColor = null,
        disabledBackgroundColor = null,
        surfaceTintColor = null,
        iconColor = null,
        borderColor = null,
        borderRadius = null,
        textStyle = null,
        animationDuration = const Duration(milliseconds: 120),
        statesController = null,
        cupertinoColor = null,
        cupertinoPadding = null,
        cupertinoMinSize = kMinInteractiveDimensionCupertino,
        cupertinoPressedOpacity = 0.4,
        cupertinoBorderRadius = null,
        cupertinoAlignment = Alignment.center;

  // Content
  final String? label;
  final Widget? child;
  final bool fitLabel;

  // Core properties
  final AppButtonVariant style;
  final AppFabVariant? buttonType;
  final AppButtonWidthMode? widthMode;
  final Widget? icon;
  final AppIconAlignment? iconAlignment;
  final AppButtonSize size;

  // State
  final bool isLoading;
  final bool isDisabled;

  // Callbacks
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  // Colors (Material 3 naming)
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? disabledForegroundColor;
  final Color? disabledBackgroundColor;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final Color? iconColor;
  final Color? borderColor;

  // FAB specific colors
  final Color? focusColor;
  final Color? hoverColor;
  final Color? splashColor;

  // Style
  final double? elevation;
  final double? focusElevation;
  final double? hoverElevation;
  final double? highlightElevation;
  final double? disabledElevation;
  final double? borderRadius;
  final TextStyle? textStyle;
  final EdgeInsets? customPadding;
  final ShapeBorder? shape;

  // Loading
  final LoadingIndicatorType loadingIndicatorType;
  final Color? loadingIndicatorColor;

  // Accessibility
  final String? semanticLabel;
  final String? tooltip;

  /// Hero tag for FAB variants. A [FloatingActionButton] uses a Hero animation
  /// with a default tag, so two FABs on the same route crash with a tag clash.
  /// Set a distinct [heroTag] per FAB (or `null` to opt out of the Hero).
  final Object? heroTag;

  // Behavior
  final bool enableHapticFeedback;
  final Duration animationDuration;
  final bool autoFocus;
  final FocusNode? focusNode;
  final Clip clipBehavior;
  final WidgetStatesController? statesController;

  // Cupertino Style
  final bool useCupertinoStyle;
  final Color? cupertinoColor;
  final EdgeInsetsGeometry? cupertinoPadding;
  final double cupertinoMinSize;
  final double cupertinoPressedOpacity;
  final BorderRadius? cupertinoBorderRadius;
  final AlignmentGeometry cupertinoAlignment;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  FocusNode? _internalFocusNode;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (widget.isDisabled || widget.isLoading) return;
    if (widget.enableHapticFeedback) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.iOS:
        case TargetPlatform.fuchsia:
          HapticFeedback.lightImpact();
          break;
        default:
          break;
      }
    }

    widget.onPressed?.call();
  }

  void _handleLongPress() {
    if (widget.isDisabled || widget.isLoading) return;
    if (widget.enableHapticFeedback) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.iOS:
        case TargetPlatform.fuchsia:
          HapticFeedback.mediumImpact();
          break;
        default:
          break;
      }
    }
    widget.onLongPress?.call();
  }

  /// The button's inner tree. Every branch is a widget class, so Flutter can
  /// skip the ones that did not change.
  Widget get _content {
    if (widget.isLoading) {
      return SizedBox(
        height: _r.metrics.iconSize,
        width: _r.metrics.iconSize,
        child: LoadingIndicator(
          type: widget.loadingIndicatorType,
          size: _r.metrics.iconSize,
          strokeWidth: 2,
          color: widget.loadingIndicatorColor ?? _r.colors.foregroundColor,
        ),
      );
    }

    if (widget.style == AppButtonVariant.fab) {
      return _FabContent(
        extended: widget.buttonType == AppFabVariant.extended,
        icon: widget.icon!,
        label: widget.label,
        child: widget.child,
      );
    }

    if (_r.isIconButton && widget.icon != null) {
      return widget.icon!;
    }

    if (widget.child != null) {
      return widget.child!;
    }

    return _LabelWithIcon(
      label: widget.label,
      textStyle: widget.textStyle ??
          TextStyle(
            color: _r.foregroundColor,
            fontSize: _r.metrics.fontSize,
            fontWeight: _r.metrics.fontWeight,
          ),
      icon: widget.icon,
      iconAlignment: _r.iconAlignment,
      fitLabel: widget.fitLabel,
      fillWidth: _r.widthMode == AppButtonWidthMode.fill,
      child: widget.child,
    );
  }

  /// Rebuilt per frame: it holds no state, only the arithmetic that turns
  /// this button's properties plus the theme into concrete values.
  AppButtonResolver get _r => AppButtonResolver(widget, context);

  @override
  Widget build(BuildContext context) {
    Widget button = widget.useCupertinoStyle
        ? _CupertinoAppButton(
            button: widget,
            resolver: _r,
            onPressed: widget.isDisabled ? null : _handlePress,
            content: _content,
          )
        : _MaterialAppButton(
            button: widget,
            resolver: _r,
            onPressed: widget.isDisabled ? null : _handlePress,
            onLongPress: widget.isDisabled || widget.onLongPress == null
                ? null
                : _handleLongPress,
            focusNode: _effectiveFocusNode,
            content: _content,
          );

    if (widget.tooltip != null &&
        !_r.isIconButton &&
        widget.style != AppButtonVariant.fab) {
      button = Tooltip(message: widget.tooltip, child: button);
    }

    if (widget.semanticLabel != null) {
      button = Semantics(
        label: widget.semanticLabel,
        button: true,
        enabled: !widget.isDisabled && !widget.isLoading,
        child: button,
      );
    }

    // A `fill` button derives its full-width look from `minimumSize.width ==
    // infinity`. That is correct when the parent gives a bounded width, but in
    // an unbounded-width slot (a non-flex child of a Row, i.e. after a
    // Spacer/Expanded) it forces an infinite layout and crashes. This guard
    // relaxes ONLY that case to bounded so the button hugs its content instead;
    // bounded layouts pass through byte-for-byte, and intrinsic queries are
    // forwarded to the child so widgets like IntrinsicHeight keep working.
    if (_r.widthMode == AppButtonWidthMode.fill) {
      button = _RelaxUnboundedWidth(child: button);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: _r.metrics.height),
      child: button,
    );
  }
}
