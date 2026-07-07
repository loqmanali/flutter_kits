part of '../adaptive_button.dart';

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
    this.style = AppButtonStyleType.filled,
    this.widthMode,
    this.icon,
    this.iconAlignment,
    this.size = AdaptiveButtonSize.medium,
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
    this.enableHapticFeedback = false,
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
          style == AppButtonStyleType.icon ||
                  style == AppButtonStyleType.iconFilled ||
                  style == AppButtonStyleType.iconFilledTonal ||
                  style == AppButtonStyleType.iconOutlined
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
    this.buttonType = FloatingActionButtonType.regular,
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
    this.enableHapticFeedback = false,
    this.semanticLabel,
    this.useCupertinoStyle = false,
    this.loadingIndicatorColor,
    this.loadingIndicatorType = LoadingIndicatorType.fadingCircle,
  })  : style = AppButtonStyleType.fab,
        widthMode = null,
        iconAlignment = null,
        size = AdaptiveButtonSize.medium,
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
  final AppButtonStyleType style;
  final FloatingActionButtonType? buttonType;
  final AppButtonWidthMode? widthMode;
  final Widget? icon;
  final AppIconAlignment? iconAlignment;
  final AdaptiveButtonSize size;

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

  AppButtonWidthMode get _widthMode {
    if (widget.widthMode != null) return widget.widthMode!;
    if (_isIconButton) return AppButtonWidthMode.hug;
    return AppButtonWidthMode.fill;
  }

  AppIconAlignment get _effectiveIconAlignment {
    if (widget.iconAlignment != null) return widget.iconAlignment!;

    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return isRTL ? AppIconAlignment.end : AppIconAlignment.start;
  }

  Color get _effectiveForegroundColor {
    if (widget.foregroundColor != null) return widget.foregroundColor!;

    // Get button style from theme extension for hot reload support
    final buttonTheme = AppButtonThemeExtension.of(context);
    final style = buttonTheme.getStyle(widget.style);

    return style.foregroundColor;
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

  ButtonSizeConfig get _sizeConfig {
    switch (widget.size) {
      case AdaptiveButtonSize.large:
        return const ButtonSizeConfig(
          height: 56.0,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          iconSize: 24.0,
        );
      case AdaptiveButtonSize.medium:
        return const ButtonSizeConfig(
          height: 48.0,
          fontSize: 14.0,
          //fontWeight: FontWeight.w500,
          fontWeight: FontWeight.w600,
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          iconSize: 20.0,
        );
      case AdaptiveButtonSize.small:
        return const ButtonSizeConfig(
          height: 32.0,
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          // fontWeight: FontWeight.w500,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          iconSize: 18.0,
        );
    }
  }

  ButtonTypeConfig get _typeConfig {
    final buttonTheme = AppButtonThemeExtension.of(context);
    final style = buttonTheme.getStyle(widget.style);

    return ButtonTypeConfig(
      backgroundColor: widget.backgroundColor ?? style.backgroundColor,
      foregroundColor: widget.foregroundColor ?? style.foregroundColor,
      overlayColor: style.overlayColor,
      borderSide: widget.borderColor != null
          ? BorderSide(color: widget.borderColor!)
          : style.borderSide,
      defaultForeground: style.foregroundColor,
    );
  }

  ButtonStyle get _buttonStyle {
    final size = _sizeConfig;
    final t = _typeConfig;
    final scheme = Theme.of(context).colorScheme;

    final disabledFg = widget.disabledForegroundColor ??
        scheme.onSurface.withValues(alpha: 0.38);
    final disabledBg = widget.disabledBackgroundColor ??
        scheme.onSurface.withValues(alpha: 0.12);

    final radius = widget.borderRadius ?? 8.0;
    final shape = widget.shape is OutlinedBorder
        ? widget.shape as OutlinedBorder
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          );

    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        Size(
          _widthMode == AppButtonWidthMode.fill ? double.infinity : 0,
          size.height,
        ),
      ),
      padding: WidgetStateProperty.all(
        widget.customPadding ?? size.padding,
      ),
      shape: WidgetStateProperty.all(shape),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return disabledBg;
        return t.backgroundColor;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return disabledFg;
        return t.foregroundColor;
      }),
      iconColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return disabledFg;
        return widget.iconColor ?? t.foregroundColor;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return t.overlayColor;
        }
        return null;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (widget.style == AppButtonStyleType.outlined ||
            widget.style == AppButtonStyleType.iconOutlined) {
          final disabledSide = BorderSide(
            color: scheme.outline.withValues(alpha: 0.12),
          );
          return states.contains(WidgetState.disabled)
              ? disabledSide
              : t.borderSide;
        }
        return t.borderSide;
      }),
      elevation: WidgetStateProperty.resolveWith((states) {
        final base = (widget.elevation ?? 0).toDouble();
        if (widget.style == AppButtonStyleType.filled ||
            widget.style == AppButtonStyleType.elevated) {
          if (states.contains(WidgetState.disabled)) return 0;
          if (states.contains(WidgetState.pressed)) {
            return widget.style == AppButtonStyleType.elevated
                ? base + 2
                : base + 1;
          }
          if (states.contains(WidgetState.hovered)) {
            return widget.style == AppButtonStyleType.elevated
                ? base + 2
                : base;
          }
          return base;
        }
        return 0;
      }),
      shadowColor: widget.shadowColor != null
          ? WidgetStateProperty.all(widget.shadowColor)
          : null,
      surfaceTintColor: widget.surfaceTintColor != null
          ? WidgetStateProperty.all(widget.surfaceTintColor)
          : null,
      textStyle: WidgetStateProperty.all(
        widget.textStyle ??
            TextStyle(
              fontSize: size.fontSize,
              fontWeight: size.fontWeight,
            ),
      ),
      alignment: Alignment.center,
    );
  }

  Widget get _content {
    if (widget.isLoading) {
      return SizedBox(
        height: _sizeConfig.iconSize,
        width: _sizeConfig.iconSize,
        child: LoadingIndicator(
          type: widget.loadingIndicatorType,
          size: _sizeConfig.iconSize,
          strokeWidth: 2,
          color: widget.loadingIndicatorColor ?? _typeConfig.foregroundColor,
        ),
      );
    }

    if (widget.style == AppButtonStyleType.fab) {
      return _buildFABContent();
    }

    if (_isIconButton && widget.icon != null) {
      return widget.icon!;
    }

    if (widget.child != null) {
      return widget.child!;
    }

    return _buildLabelWithIcon();
  }

  bool get _isIconButton {
    return widget.style == AppButtonStyleType.icon ||
        widget.style == AppButtonStyleType.iconFilled ||
        widget.style == AppButtonStyleType.iconFilledTonal ||
        widget.style == AppButtonStyleType.iconOutlined;
  }

  Widget _buildFABContent() {
    final isExtended = widget.buttonType == FloatingActionButtonType.extended;

    if (!isExtended) {
      return widget.icon!;
    }

    // Extended FAB
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.icon!,
        const SizedBox(width: 8),
        if (widget.child != null) widget.child! else Text(widget.label ?? ''),
      ],
    );
  }

  Widget _buildLabelWithIcon() {
    final textStyle = widget.textStyle ??
        TextStyle(
          color: _effectiveForegroundColor,
          fontSize: _sizeConfig.fontSize,
          fontWeight: _sizeConfig.fontWeight,
        );

    final baseText = widget.label != null
        ? Text(widget.label!, style: textStyle)
        : (widget.child ?? const SizedBox.shrink());

    final text = widget.fitLabel
        ? FittedBox(
            fit: BoxFit.scaleDown,
            child: baseText,
          )
        : baseText;

    if (widget.icon == null) {
      return text;
    }

    final alignment = _effectiveIconAlignment;

    return Row(
      mainAxisSize: _widthMode == AppButtonWidthMode.fill
          ? MainAxisSize.max
          : MainAxisSize.min,
      mainAxisAlignment: _widthMode == AppButtonWidthMode.fill
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        if (alignment == AppIconAlignment.start) ...[
          widget.icon!,
          const SizedBox(width: 8),
        ],
        Flexible(child: text),
        if (alignment == AppIconAlignment.end) ...[
          const SizedBox(width: 8),
          widget.icon!,
        ],
      ],
    );
  }

  Widget _buildMaterialButton() {
    if (widget.style == AppButtonStyleType.fab) {
      return _buildFAB();
    }

    if (_isIconButton) {
      return _buildIconButton();
    }

    if (widget.style == AppButtonStyleType.filled ||
        widget.style == AppButtonStyleType.filledTonal) {
      return FilledButton(
        onPressed: widget.isDisabled ? null : _handlePress,
        onLongPress: widget.isDisabled || widget.onLongPress == null
            ? null
            : _handleLongPress,
        style: _buttonStyle,
        focusNode: _effectiveFocusNode,
        autofocus: widget.autoFocus,
        clipBehavior: widget.clipBehavior,
        statesController: widget.statesController,
        child: _content,
      );
    } else if (widget.style == AppButtonStyleType.elevated) {
      return ElevatedButton(
        onPressed: widget.isDisabled ? null : _handlePress,
        onLongPress: widget.isDisabled || widget.onLongPress == null
            ? null
            : _handleLongPress,
        style: _buttonStyle,
        focusNode: _effectiveFocusNode,
        autofocus: widget.autoFocus,
        clipBehavior: widget.clipBehavior,
        statesController: widget.statesController,
        child: _content,
      );
    } else if (widget.style == AppButtonStyleType.outlined) {
      return OutlinedButton(
        onPressed: widget.isDisabled ? null : _handlePress,
        onLongPress: widget.isDisabled || widget.onLongPress == null
            ? null
            : _handleLongPress,
        style: _buttonStyle,
        focusNode: _effectiveFocusNode,
        autofocus: widget.autoFocus,
        clipBehavior: widget.clipBehavior,
        statesController: widget.statesController,
        child: _content,
      );
    } else if (widget.style == AppButtonStyleType.text) {
      return TextButton(
        onPressed: widget.isDisabled ? null : _handlePress,
        onLongPress: widget.isDisabled || widget.onLongPress == null
            ? null
            : _handleLongPress,
        style: _buttonStyle,
        focusNode: _effectiveFocusNode,
        autofocus: widget.autoFocus,
        clipBehavior: widget.clipBehavior,
        statesController: widget.statesController,
        child: _content,
      );
    }

    return FilledButton(
      onPressed: widget.isDisabled ? null : _handlePress,
      style: _buttonStyle,
      child: _content,
    );
  }

  Widget _buildIconButton() {
    final style = _buttonStyle;

    if (widget.style == AppButtonStyleType.iconFilled) {
      return IconButton.filled(
        onPressed: widget.isDisabled ? null : _handlePress,
        icon: _content,
        style: style,
        focusNode: _effectiveFocusNode,
        autofocus: widget.autoFocus,
        tooltip: widget.tooltip,
        isSelected: false,
      );
    } else if (widget.style == AppButtonStyleType.iconFilledTonal) {
      return IconButton.filledTonal(
        onPressed: widget.isDisabled ? null : _handlePress,
        icon: _content,
        style: style,
        focusNode: _effectiveFocusNode,
        autofocus: widget.autoFocus,
        tooltip: widget.tooltip,
        isSelected: false,
      );
    } else if (widget.style == AppButtonStyleType.iconOutlined) {
      return IconButton.outlined(
        onPressed: widget.isDisabled ? null : _handlePress,
        icon: _content,
        style: style,
        focusNode: _effectiveFocusNode,
        autofocus: widget.autoFocus,
        tooltip: widget.tooltip,
        isSelected: false,
      );
    } else {
      // AppButtonStyle.icon or default
      return IconButton(
        onPressed: widget.isDisabled ? null : _handlePress,
        icon: _content,
        style: style,
        focusNode: _effectiveFocusNode,
        autofocus: widget.autoFocus,
        tooltip: widget.tooltip,
      );
    }
  }

  Widget _buildFAB() {
    final onPressed = widget.isDisabled ? null : _handlePress;
    final content = _content;

    switch (widget.buttonType) {
      case FloatingActionButtonType.small:
        return FloatingActionButton.small(
          onPressed: onPressed,
          heroTag: widget.heroTag,
          tooltip: widget.tooltip,
          foregroundColor: widget.foregroundColor,
          backgroundColor: widget.backgroundColor,
          focusColor: widget.focusColor,
          hoverColor: widget.hoverColor,
          splashColor: widget.splashColor,
          elevation: widget.elevation,
          focusElevation: widget.focusElevation,
          hoverElevation: widget.hoverElevation,
          highlightElevation: widget.highlightElevation,
          disabledElevation: widget.disabledElevation,
          shape: widget.shape,
          clipBehavior: widget.clipBehavior,
          focusNode: _effectiveFocusNode,
          autofocus: widget.autoFocus,
          child: content,
        );

      case FloatingActionButtonType.large:
        return FloatingActionButton.large(
          onPressed: onPressed,
          heroTag: widget.heroTag,
          tooltip: widget.tooltip,
          foregroundColor: widget.foregroundColor,
          backgroundColor: widget.backgroundColor,
          focusColor: widget.focusColor,
          hoverColor: widget.hoverColor,
          splashColor: widget.splashColor,
          elevation: widget.elevation,
          focusElevation: widget.focusElevation,
          hoverElevation: widget.hoverElevation,
          highlightElevation: widget.highlightElevation,
          disabledElevation: widget.disabledElevation,
          shape: widget.shape,
          clipBehavior: widget.clipBehavior,
          focusNode: _effectiveFocusNode,
          autofocus: widget.autoFocus,
          child: content,
        );

      case FloatingActionButtonType.extended:
        return FloatingActionButton.extended(
          onPressed: onPressed,
          heroTag: widget.heroTag,
          tooltip: widget.tooltip,
          foregroundColor: widget.foregroundColor,
          backgroundColor: widget.backgroundColor,
          focusColor: widget.focusColor,
          hoverColor: widget.hoverColor,
          splashColor: widget.splashColor,
          elevation: widget.elevation,
          focusElevation: widget.focusElevation,
          hoverElevation: widget.hoverElevation,
          highlightElevation: widget.highlightElevation,
          disabledElevation: widget.disabledElevation,
          shape: widget.shape,
          clipBehavior: widget.clipBehavior,
          focusNode: _effectiveFocusNode,
          autofocus: widget.autoFocus,
          icon: widget.icon,
          label: widget.child ?? Text(widget.label ?? ''),
        );

      case FloatingActionButtonType.regular:
      default:
        return FloatingActionButton(
          onPressed: onPressed,
          heroTag: widget.heroTag,
          tooltip: widget.tooltip,
          foregroundColor: widget.foregroundColor,
          backgroundColor: widget.backgroundColor,
          focusColor: widget.focusColor,
          hoverColor: widget.hoverColor,
          splashColor: widget.splashColor,
          elevation: widget.elevation,
          focusElevation: widget.focusElevation,
          hoverElevation: widget.hoverElevation,
          highlightElevation: widget.highlightElevation,
          disabledElevation: widget.disabledElevation,
          shape: widget.shape,
          clipBehavior: widget.clipBehavior,
          focusNode: _effectiveFocusNode,
          autofocus: widget.autoFocus,
          child: content,
        );
    }
  }

  Widget _buildCupertinoButton() {
    final onPressed = widget.isDisabled ? null : _handlePress;
    final effectiveColor = widget.cupertinoColor ??
        widget.backgroundColor ??
        CupertinoTheme.of(context).primaryColor;

    final effectivePadding =
        widget.cupertinoPadding ?? widget.customPadding ?? _sizeConfig.padding;

    final effectiveBorderRadius = widget.cupertinoBorderRadius ??
        (widget.borderRadius != null
            ? BorderRadius.circular(widget.borderRadius!)
            : const BorderRadius.all(Radius.circular(8.0)));

    if (widget.style == AppButtonStyleType.outlined ||
        widget.style == AppButtonStyleType.text) {
      // Cupertino doesn't have outlined/text variants, use borderless style
      return CupertinoButton(
        onPressed: onPressed,
        padding: effectivePadding,
        pressedOpacity: widget.cupertinoPressedOpacity,
        borderRadius: effectiveBorderRadius,
        alignment: widget.cupertinoAlignment,
        minimumSize: Size(
          widget.cupertinoMinSize,
          widget.cupertinoMinSize,
        ), // Transparent background
        child: DefaultTextStyle(
          style: TextStyle(
            color: effectiveColor,
            fontSize: _sizeConfig.fontSize,
            fontWeight: _sizeConfig.fontWeight,
          ),
          child: _content,
        ),
      );
    }

    return CupertinoButton(
      onPressed: onPressed,
      padding: effectivePadding,
      pressedOpacity: widget.cupertinoPressedOpacity,
      borderRadius: effectiveBorderRadius,
      alignment: widget.cupertinoAlignment,
      color: effectiveColor,
      minimumSize: Size(widget.cupertinoMinSize, widget.cupertinoMinSize),
      disabledColor: widget.disabledBackgroundColor ??
          CupertinoColors.quaternarySystemFill,
      child: _content,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget button = widget.useCupertinoStyle
        ? _buildCupertinoButton()
        : _buildMaterialButton();

    if (widget.tooltip != null &&
        !_isIconButton &&
        widget.style != AppButtonStyleType.fab) {
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
    if (_widthMode == AppButtonWidthMode.fill) {
      button = _RelaxUnboundedWidth(child: button);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: _sizeConfig.height),
      child: button,
    );
  }
}

/// A single-child render box that neutralises an unbounded incoming width
/// before it reaches the child.
///
/// When the maximum incoming width is infinite, the child is laid out with
/// `maxWidth` loosened to its own minimum-intrinsic width (so a button whose
/// style demands `minimumSize.width == infinity` shrink-wraps instead of being
/// forced to an infinite, crashing layout). When the incoming width is bounded
/// the constraints are passed through untouched, so existing layouts are
/// pixel-identical. All intrinsic-dimension and dry-layout queries are
/// delegated to the child, so this widget is safe inside IntrinsicWidth /
/// IntrinsicHeight (unlike LayoutBuilder).
class _RelaxUnboundedWidth extends SingleChildRenderObjectWidget {
  const _RelaxUnboundedWidth({required Widget super.child});

  @override
  _RenderRelaxUnboundedWidth createRenderObject(BuildContext context) =>
      _RenderRelaxUnboundedWidth();
}

class _RenderRelaxUnboundedWidth extends RenderProxyBox {
  BoxConstraints _resolve(BoxConstraints constraints) {
    if (constraints.maxWidth != double.infinity) return constraints;
    final child = this.child;
    final intrinsic =
        child == null ? 0.0 : child.getMinIntrinsicWidth(constraints.maxHeight);
    // Loosen to the child's natural width so the button shrink-wraps; clamp to
    // the (possibly non-zero) incoming minWidth to stay a valid constraint.
    final maxWidth = math.max(intrinsic, constraints.minWidth);
    return constraints.copyWith(maxWidth: maxWidth);
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_resolve(constraints), parentUsesSize: true);
    size = child.size;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    return child.getDryLayout(_resolve(constraints));
  }
}
