import 'package:flutter/material.dart';

import '../models/selection_option.dart';
import '../theme/selection_kit_theme.dart';

/// Internal tile shared by the radio and checkbox groups. Renders the option's
/// content (icon, title, subtitle, description, trailing) next to an
/// indicator widget provided by the caller.
class SelectionTile<T> extends StatelessWidget {
  const SelectionTile({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
    required this.indicator,
    required this.resolved,
    required this.horizontal,
    required this.radioAlignment,
    required this.mainAxisAlignment,
  });

  final SelectionOption<T> option;
  final bool selected;
  final VoidCallback? onTap;
  final Widget indicator;
  final ResolvedTileStyle resolved;
  final bool horizontal;
  final CrossAxisAlignment radioAlignment;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final isEnabled = option.enabled;
    final radius = BorderRadius.circular(resolved.borderRadius);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: resolved.showRipple && isEnabled
            ? () {
                onTap?.call();
                option.onTap?.call();
              }
            : null,
        child: AnimatedContainer(
          duration: resolved.animationDuration,
          padding: resolved.contentPadding,
          decoration: resolved.showBackground
              ? BoxDecoration(
                  color: selected
                      ? resolved.selectedBackgroundColor
                      : resolved.backgroundColor,
                  border: resolved.showBorder
                      ? Border.all(
                          color: selected
                              ? resolved.selectedBorderColor
                              : resolved.borderColor,
                          width: selected
                              ? resolved.selectedBorderWidth
                              : resolved.borderWidth,
                        )
                      : null,
                  borderRadius: radius,
                )
              : null,
          child: Row(
            mainAxisSize:
                horizontal ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: radioAlignment,
            children: [
              indicator,
              SizedBox(width: resolved.dense ? 8 : 12),
              if (option.icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: selected
                        ? resolved.selectedColor
                        : resolved.unselectedTextColor,
                    opacity: isEnabled ? 1.0 : 0.5,
                  ),
                  child: option.icon!,
                ),
                SizedBox(width: resolved.dense ? 8 : 12),
              ],
              if (horizontal)
                Flexible(child: _buildContent(context, isEnabled))
              else
                Expanded(child: _buildContent(context, isEnabled)),
              if (option.trailing != null) ...[
                const SizedBox(width: 8),
                option.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isEnabled) {
    final theme = Theme.of(context);
    final maxLines = horizontal ? 1 : null;
    final overflow = horizontal ? TextOverflow.ellipsis : null;
    final descMaxLines = horizontal ? 2 : null;
    final disabledColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final disabledFaintColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        option.titleWidget ??
            Text(
              option.title!,
              style: (resolved.titleStyle ?? theme.textTheme.bodyMedium)
                  ?.copyWith(
                    color: selected
                        ? resolved.selectedColor
                        : resolved.unselectedTextColor,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  )
                  .apply(color: isEnabled ? null : disabledColor),
              maxLines: maxLines,
              overflow: overflow,
            ),
        if (option.hasSubtitle) ...[
          const SizedBox(height: 2),
          option.subtitleWidget ??
              Text(
                option.subtitle!,
                style: (resolved.subtitleStyle ?? theme.textTheme.bodySmall)
                    ?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    )
                    .apply(color: isEnabled ? null : disabledFaintColor),
                maxLines: maxLines,
                overflow: overflow,
              ),
        ],
        if (option.hasDescription) ...[
          const SizedBox(height: 4),
          option.descriptionWidget ??
              Text(
                option.description!,
                style: (resolved.descriptionStyle ?? theme.textTheme.bodySmall)
                    ?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    )
                    .apply(color: isEnabled ? null : disabledFaintColor),
                maxLines: descMaxLines,
                overflow: overflow,
              ),
        ],
      ],
    );
  }
}

/// Concrete style values used by a [SelectionTile], resolved from the
/// surrounding [SelectionKitTheme] and per-group overrides. Caller resolves
/// once and reuses across tiles to avoid duplicate work.
class ResolvedTileStyle {
  const ResolvedTileStyle({
    required this.selectedColor,
    required this.unselectedTextColor,
    required this.backgroundColor,
    required this.selectedBackgroundColor,
    required this.borderColor,
    required this.selectedBorderColor,
    required this.borderRadius,
    required this.borderWidth,
    required this.selectedBorderWidth,
    required this.contentPadding,
    required this.showBorder,
    required this.showBackground,
    required this.dense,
    required this.showRipple,
    required this.animationDuration,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.descriptionStyle,
  });

  final Color selectedColor;
  final Color unselectedTextColor;
  final Color backgroundColor;
  final Color selectedBackgroundColor;
  final Color borderColor;
  final Color selectedBorderColor;
  final double borderRadius;
  final double borderWidth;
  final double selectedBorderWidth;
  final EdgeInsetsGeometry contentPadding;
  final bool showBorder;
  final bool showBackground;
  final bool dense;
  final bool showRipple;
  final Duration animationDuration;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? descriptionStyle;
}

/// Build a resolved style from theme + per-group overrides.
ResolvedTileStyle resolveTileStyle({
  required BuildContext context,
  Color? selectedColor,
  Color? unselectedColor,
  Color? backgroundColor,
  Color? selectedBackgroundColor,
  Color? borderColor,
  Color? selectedBorderColor,
  double? borderRadius,
  double? borderWidth,
  double? selectedBorderWidth,
  EdgeInsetsGeometry? contentPadding,
  bool? showBorder,
  bool? showBackground,
  bool? dense,
  bool? showRipple,
  Duration? animationDuration,
  TextStyle? titleStyle,
  TextStyle? subtitleStyle,
  TextStyle? descriptionStyle,
}) {
  final theme = SelectionKitTheme.of(context);
  final scheme = Theme.of(context).colorScheme;

  final resolvedSelected =
      selectedColor ?? theme.selectedColor ?? scheme.primary;
  final resolvedUnselected =
      unselectedColor ?? theme.unselectedColor ?? scheme.onSurface;

  return ResolvedTileStyle(
    selectedColor: resolvedSelected,
    unselectedTextColor: resolvedUnselected,
    backgroundColor:
        backgroundColor ?? theme.backgroundColor ?? Colors.transparent,
    selectedBackgroundColor: selectedBackgroundColor ??
        theme.selectedBackgroundColor ??
        resolvedSelected.withValues(alpha: 0.1),
    borderColor: borderColor ?? theme.borderColor ?? scheme.outline,
    selectedBorderColor:
        selectedBorderColor ?? theme.selectedBorderColor ?? resolvedSelected,
    borderRadius: borderRadius ?? theme.borderRadius,
    borderWidth: borderWidth ?? theme.borderWidth,
    selectedBorderWidth: selectedBorderWidth ?? theme.selectedBorderWidth,
    contentPadding: contentPadding ?? theme.contentPadding,
    showBorder: showBorder ?? theme.showBorder,
    showBackground: showBackground ?? theme.showBackground,
    dense: dense ?? theme.dense,
    showRipple: showRipple ?? theme.showRipple,
    animationDuration: animationDuration ?? theme.animationDuration,
    titleStyle: titleStyle ?? theme.titleStyle,
    subtitleStyle: subtitleStyle ?? theme.subtitleStyle,
    descriptionStyle: descriptionStyle ?? theme.descriptionStyle,
  );
}
