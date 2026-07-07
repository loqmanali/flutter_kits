import 'package:flutter/material.dart';

import '../internal/selection_group_shell.dart';
import '../internal/selection_indicators.dart';
import '../internal/selection_tile.dart';
import '../models/selection_option.dart';
import '../theme/selection_kit_theme.dart';

/// Multi-select group of checkbox tiles.
///
/// Controlled by [groupValues] + [onChanged]. The callback receives a new
/// `Set<T>` each time — the widget never mutates the set passed in.
class AppCheckboxGroup<T> extends StatefulWidget {
  const AppCheckboxGroup({
    super.key,
    required this.options,
    required this.onChanged,
    this.groupValues,
    this.initialValues,
    this.direction = Axis.vertical,
    this.spacing,
    this.runSpacing,
    this.separator,
    this.minSelections,
    this.maxSelections,

    // Style overrides (fall back to SelectionKitTheme).
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
    this.indicatorCornerRadius = 4.0,
    this.checkColor,
    this.animationDuration,
    this.showBorder,
    this.showBackground,
    this.dense,
    this.showRipple,
    this.titleStyle,
    this.subtitleStyle,
    this.descriptionStyle,

    this.indicatorBuilder,

    // Chrome.
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

    this.checkboxAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.onTap,
  });

  final List<SelectionOption<T>> options;
  final ValueChanged<Set<T>> onChanged;
  final Set<T>? groupValues;
  final Set<T>? initialValues;

  final Axis direction;
  final double? spacing;
  final double? runSpacing;
  final Widget? separator;

  /// Optional clamp: ignore taps that would drop below [minSelections].
  final int? minSelections;

  /// Optional clamp: ignore taps that would exceed [maxSelections].
  final int? maxSelections;

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
  final double indicatorCornerRadius;
  final Color? checkColor;
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
  final String? Function(Set<T>)? validator;

  final String? semanticsLabel;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;

  final CrossAxisAlignment checkboxAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final VoidCallback? onTap;

  @override
  State<AppCheckboxGroup<T>> createState() => _AppCheckboxGroupState<T>();
}

class _AppCheckboxGroupState<T> extends State<AppCheckboxGroup<T>> {
  late Set<T> _values;

  @override
  void initState() {
    super.initState();
    _values = {...?(widget.groupValues ?? widget.initialValues)};
  }

  @override
  void didUpdateWidget(covariant AppCheckboxGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = widget.groupValues;
    if (incoming != null && !_setEquals(incoming, _values)) {
      _values = {...incoming};
    }
  }

  bool _setEquals(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    for (final v in a) {
      if (!b.contains(v)) return false;
    }
    return true;
  }

  void _handleTap(SelectionOption<T> option) {
    final next = {..._values};
    final wasSelected = next.contains(option.value);
    if (wasSelected) {
      if (widget.minSelections != null &&
          next.length <= widget.minSelections!) {
        widget.onTap?.call();
        return;
      }
      next.remove(option.value);
    } else {
      if (widget.maxSelections != null &&
          next.length >= widget.maxSelections!) {
        widget.onTap?.call();
        return;
      }
      next.add(option.value);
    }
    setState(() => _values = next);
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
        widget.validator?.call(_values) ?? widget.errorText;

    final tiles = <Widget>[
      for (final option in widget.options)
        SelectionTile<T>(
          option: option,
          selected: _values.contains(option.value),
          onTap: () => _handleTap(option),
          horizontal: horizontal,
          radioAlignment: widget.checkboxAlignment,
          mainAxisAlignment: widget.mainAxisAlignment,
          resolved: resolved,
          indicator: widget.indicatorBuilder != null
              ? widget.indicatorBuilder!(
                  _values.contains(option.value),
                  option.enabled,
                )
              : CheckboxIndicator(
                  selected: _values.contains(option.value),
                  enabled: option.enabled,
                  size: indicatorSize,
                  color: resolved.selectedColor,
                  unselectedColor: resolved.unselectedTextColor,
                  animationDuration: resolved.animationDuration,
                  cornerRadius: widget.indicatorCornerRadius,
                  checkColor: widget.checkColor,
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
