import 'package:flutter/widgets.dart';

/// A single selectable entry shared by [AppRadioGroup] and [AppCheckboxGroup].
///
/// Provide either a [title] string or a [titleWidget]. [subtitle] / [description]
/// follow the same string-or-widget pattern.
@immutable
class SelectionOption<T> {
  const SelectionOption({
    required this.value,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.description,
    this.descriptionWidget,
    this.icon,
    this.trailing,
    this.enabled = true,
    this.onTap,
  }) : assert(
          title != null || titleWidget != null,
          'Either `title` or `titleWidget` must be provided',
        );

  final T value;

  final String? title;
  final Widget? titleWidget;

  final String? subtitle;
  final Widget? subtitleWidget;

  final String? description;
  final Widget? descriptionWidget;

  final Widget? icon;
  final Widget? trailing;
  final bool enabled;
  final VoidCallback? onTap;

  bool get hasSubtitle => subtitle != null || subtitleWidget != null;
  bool get hasDescription => description != null || descriptionWidget != null;
}
