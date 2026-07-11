import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

/// {@template picker_sheet_search_field}
/// The boxed search field used as a [PickerSheetScaffold] header. Mirrors the
/// look every picker shared before: a rounded surface-alt box with a leading
/// icon and an [AppTextFormField] inside.
///
/// Stateless and controlled — the host owns the [controller], the debounce, and
/// what [onChanged] does (filter a provider, fire a server search, …).
/// {@endtemplate}
class PickerSheetSearchField extends StatelessWidget {
  /// {@macro picker_sheet_search_field}
  const PickerSheetSearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.leadingIcon = Icons.search_rounded,
    this.trailing,
    this.autofocus = true,
    super.key,
  });

  /// The text controller owned by the host sheet.
  final TextEditingController controller;

  /// Placeholder shown when the field is empty.
  final String hintText;

  /// Fired on every keystroke (raw). Debounce in the host as needed.
  final ValueChanged<String> onChanged;

  /// Leading icon — defaults to a search glyph; payment uses a business glyph.
  final IconData leadingIcon;

  /// Optional trailing widget (e.g. an in-flight progress spinner).
  final Widget? trailing;

  /// Whether to focus the field as soon as the sheet opens.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: colors.outlineVariant.withValues(alpha: 0.12)),
        ),
        child: AppTextFormField(
          controller: controller,
          autofocus: autofocus,
          textStyle: TextStyle(fontSize: 14, color: colors.onSurface),
          hintText: hintText,
          prefixIcon:
              Icon(leadingIcon, size: 18, color: colors.onSurfaceVariant),
          suffixIcon: trailing,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
