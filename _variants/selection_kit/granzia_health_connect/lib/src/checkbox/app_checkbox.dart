import 'package:flutter/material.dart';

import '../internal/selection_indicators.dart';
import '../models/selection_option.dart';
import 'app_checkbox_group.dart';

/// Single checkbox tile — useful for one-off booleans (e.g. "I agree to terms").
///
/// Uses [AppCheckboxGroup] under the hood with a single option. The [value]
/// is the option's payload (defaults to `true`), and [selected] controls
/// whether it is checked.
class AppCheckbox<T> extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.selected,
    required this.onChanged,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.description,
    this.descriptionWidget,
    this.icon,
    this.trailing,
    this.enabled = true,
    this.indicatorBuilder,
    this.selectedColor,
    this.contentPadding,
    this.onTap,
    this.checkboxAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
  }) : assert(
          title != null || titleWidget != null,
          'Either `title` or `titleWidget` must be provided',
        );

  final T value;
  final bool selected;

  /// Fires with `value` when checked, `null` when unchecked.
  final ValueChanged<T?> onChanged;

  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? subtitleWidget;
  final String? description;
  final Widget? descriptionWidget;
  final Widget? icon;
  final Widget? trailing;
  final bool enabled;

  final SelectionIndicatorBuilder? indicatorBuilder;
  final Color? selectedColor;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;
  final CrossAxisAlignment checkboxAlignment;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return AppCheckboxGroup<T>(
      groupValues: selected ? {value} : <T>{},
      onChanged: (next) => onChanged(next.contains(value) ? value : null),
      indicatorBuilder: indicatorBuilder,
      selectedColor: selectedColor,
      contentPadding: contentPadding,
      onTap: onTap,
      checkboxAlignment: checkboxAlignment,
      mainAxisAlignment: mainAxisAlignment,
      options: [
        SelectionOption<T>(
          value: value,
          title: title,
          titleWidget: titleWidget,
          subtitle: subtitle,
          subtitleWidget: subtitleWidget,
          description: description,
          descriptionWidget: descriptionWidget,
          icon: icon,
          trailing: trailing,
          enabled: enabled,
        ),
      ],
    );
  }
}
