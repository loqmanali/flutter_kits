import 'package:flutter/material.dart';

import '../internal/selection_group_shell.dart';
import '../internal/selection_indicators.dart';
import '../internal/selection_tile.dart';
import '../models/selection_option.dart';
import '../theme/selection_kit_theme.dart';

/// Single-select group of radio tiles.
///
/// Controlled by [groupValue] + [onChanged]. Pass [initialValue] for an
/// uncontrolled initial state; subsequent changes to [groupValue] are
/// reflected automatically.
class AppRadioGroup<T> extends StatefulWidget {
  const AppRadioGroup({
    super.key,
    required this.options,
    required this.onChanged,
    this.groupValue,
    this.initialValue,
    this.direction = Axis.vertical,
    this.spacing,
    this.runSpacing,
    this.separator,
    this.allowDeselect = false,

    // Style overrides (each falls back to SelectionKitTheme).
    this.selectedColor,
    this.unselectedColor,
    this.borderColor,
    this.selectedBorderColor,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.borderRadius,
    this.borderWidth,
    this.selectedBorderWidth,
    this.contentPadding,
    this.indicatorSize,
    this.animationDuration,
    this.showBorder,
    this.showBackground,
    this.dense,
    this.showRipple,
    this.titleStyle,
    this.subtitleStyle,
    this.descriptionStyle,

    // Custom indicator.
    this.indicatorBuilder,

    // Validation / chrome.
    this.label,
    this.labelStyle,
    this.isRequired = false,
    this.helperText,
    this.helperStyle,
    this.errorText,
    this.errorStyle,
    this.validator,

    // Accessibility / focus.
    this.semanticsLabel,
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,

    // Layout alignment.
    this.radioAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,

    // Tap hook fired before option.onTap.
    this.onTap,
  });

  final List<SelectionOption<T>> options;
  final ValueChanged<T?> onChanged;
  final T? groupValue;
  final T? initialValue;

  final Axis direction;
  final double? spacing;
  final double? runSpacing;
  final Widget? separator;
  final bool allowDeselect;

  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? borderColor;
  final Color? selectedBorderColor;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final double? borderRadius;
  final double? borderWidth;
  final double? selectedBorderWidth;
  final EdgeInsetsGeometry? contentPadding;
  final double? indicatorSize;
  final Duration? animationDuration;
  final bool? showBorder;
  final bool? showBackground;
  final bool? dense;
  final bool? showRipple;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? descriptionStyle;

  final SelectionIndicatorBuilder? indicatorBuilder;

  final String? label;
  final TextStyle? labelStyle;
  final bool isRequired;
  final String? helperText;
  final TextStyle? helperStyle;
  final String? errorText;
  final TextStyle? errorStyle;
  final String? Function(T?)? validator;

  final String? semanticsLabel;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;

  final CrossAxisAlignment radioAlignment;
  final MainAxisAlignment mainAxisAlignment;

  final VoidCallback? onTap;

  @override
  State<AppRadioGroup<T>> createState() => _AppRadioGroupState<T>();
}

class _AppRadioGroupState<T> extends State<AppRadioGroup<T>> {
  late T? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.groupValue ?? widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant AppRadioGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.groupValue != oldWidget.groupValue &&
        widget.groupValue != _value) {
      _value = widget.groupValue;
    }
  }

  void _handleTap(SelectionOption<T> option) {
    final isCurrentlySelected = _value == option.value;
    final T? next =
        widget.allowDeselect && isCurrentlySelected ? null : option.value;
    if (next == _value) {
      widget.onTap?.call();
      return;
    }
    setState(() => _value = next);
    widget.onTap?.call();
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final kitTheme = SelectionKitTheme.of(context);
    final resolved = resolveTileStyle(
      context: context,
      selectedColor: widget.selectedColor,
      unselectedColor: widget.unselectedColor,
      backgroundColor: widget.backgroundColor,
      selectedBackgroundColor: widget.selectedBackgroundColor,
      borderColor: widget.borderColor,
      selectedBorderColor: widget.selectedBorderColor,
      borderRadius: widget.borderRadius,
      borderWidth: widget.borderWidth,
      selectedBorderWidth: widget.selectedBorderWidth,
      contentPadding: widget.contentPadding,
      showBorder: widget.showBorder,
      showBackground: widget.showBackground,
      dense: widget.dense,
      showRipple: widget.showRipple,
      animationDuration: widget.animationDuration,
      titleStyle: widget.titleStyle,
      subtitleStyle: widget.subtitleStyle,
      descriptionStyle: widget.descriptionStyle,
    );

    final indicatorSize = widget.indicatorSize ?? kitTheme.indicatorSize;
    final spacing = widget.spacing ?? kitTheme.spacing;
    final runSpacing = widget.runSpacing ?? kitTheme.runSpacing;
    final horizontal = widget.direction == Axis.horizontal;

    final errorMessage =
        widget.validator?.call(_value) ?? widget.errorText;

    final tiles = <Widget>[
      for (final option in widget.options)
        SelectionTile<T>(
          option: option,
          selected: _value == option.value,
          onTap: () => _handleTap(option),
          horizontal: horizontal,
          radioAlignment: widget.radioAlignment,
          mainAxisAlignment: widget.mainAxisAlignment,
          resolved: resolved,
          indicator: widget.indicatorBuilder != null
              ? widget.indicatorBuilder!(
                  _value == option.value,
                  option.enabled,
                )
              : RadioIndicator(
                  selected: _value == option.value,
                  enabled: option.enabled,
                  size: indicatorSize,
                  color: _value == option.value
                      ? resolved.selectedColor
                      : resolved.unselectedTextColor,
                  animationDuration: resolved.animationDuration,
                ),
        ),
    ];

    Widget body;
    if (horizontal) {
      body = Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: tiles,
      );
    } else if (widget.separator != null) {
      final children = <Widget>[];
      for (var i = 0; i < tiles.length; i++) {
        children.add(tiles[i]);
        if (i < tiles.length - 1) children.add(widget.separator!);
      }
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    } else {
      final children = <Widget>[];
      for (var i = 0; i < tiles.length; i++) {
        children.add(tiles[i]);
        if (i < tiles.length - 1) children.add(SizedBox(height: spacing));
      }
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    return SelectionGroupShell(
      label: widget.label,
      labelStyle: widget.labelStyle,
      isRequired: widget.isRequired,
      helperText: widget.helperText,
      helperStyle: widget.helperStyle,
      errorText: errorMessage,
      errorStyle: widget.errorStyle,
      semanticsLabel: widget.semanticsLabel,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onFocusChange: widget.onFocusChange,
      child: body,
    );
  }
}
