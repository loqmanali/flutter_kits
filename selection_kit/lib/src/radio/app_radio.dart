import 'package:flutter/material.dart';

import '../internal/selection_indicators.dart';
import '../models/selection_option.dart';
import 'app_radio_group.dart';

/// Single radio tile — thin wrapper over [AppRadioGroup] with one option.
class AppRadio<T> extends StatelessWidget {
  const AppRadio({
    super.key,
    required this.value,
    required this.groupValue,
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
    this.allowDeselect = false,
    this.indicatorBuilder,
    this.selectedColor,
    this.contentPadding,
    this.onTap,
    this.radioAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
  }) : assert(
          title != null || titleWidget != null,
          'Either `title` or `titleWidget` must be provided',
        );

  final T value;
  final T? groupValue;
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

  final bool allowDeselect;
  final SelectionIndicatorBuilder? indicatorBuilder;
  final Color? selectedColor;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;
  final CrossAxisAlignment radioAlignment;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return AppRadioGroup<T>(
      groupValue: groupValue,
      onChanged: onChanged,
      allowDeselect: allowDeselect,
      indicatorBuilder: indicatorBuilder,
      selectedColor: selectedColor,
      contentPadding: contentPadding,
      onTap: onTap,
      radioAlignment: radioAlignment,
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
