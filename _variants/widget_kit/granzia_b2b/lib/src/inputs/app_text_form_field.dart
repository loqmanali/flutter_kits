import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/widget_kit_theme.dart';

/// Themed text form field. All visual properties have working defaults so
/// you can drop it in without passing anything; pass overrides per-instance,
/// or register a [WidgetKitTheme] on your `ThemeData` to set app-wide
/// defaults for every input.
class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    this.keyName,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 10),
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.borderColor,
    this.focusedBorderColor,
    this.textColor,
    this.hintColor,
    this.errorColor,
    this.fontSize,
    this.hintFontSize,
    this.borderRadius,
    this.borderWidth,
    this.focusedBorderWidth,
    this.backgroundColor,
    this.inputFormatters,
    this.validator,
    this.onSaved,
    this.onTapOutside,
    this.onTap,
    this.textAlign = TextAlign.start,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.enabled,
    this.autofillHints,
    this.keyboardAppearance,
    this.autofocus = false,
    this.textAlignVertical,
    this.cursorColor,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorWidth = 2.0,
    this.showCursor,
    this.magnifierConfiguration,
    this.minLines,
    this.expands = false,
    this.maxLengthEnforcement,
    this.buildCounter,
    this.decorationOverride,
    this.textStyle,
  }) : assert(
          controller == null || initialValue == null,
          'do not use initialValue with controller',
        );

  final String? keyName;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;

  final String? labelText;
  final String? hintText;
  final String? errorText;

  final bool obscureText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final VoidCallback? onEditingComplete;
  final void Function(String)? onFieldSubmitted;

  final EdgeInsets contentPadding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? maxLength;
  final bool readOnly;

  // All visual fields are nullable: resolved against [WidgetKitTheme] in
  // [build], so they fall back gracefully when not set.
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? errorColor;

  final double? fontSize;
  final double? hintFontSize;
  final double? borderRadius;
  final double? borderWidth;
  final double? focusedBorderWidth;

  final Color? backgroundColor;

  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final String? Function(String?)? onSaved;

  final Function(PointerDownEvent)? onTapOutside;
  final VoidCallback? onTap;
  final TextAlign textAlign;
  final AutovalidateMode autovalidateMode;

  final bool? enabled;
  final Iterable<String>? autofillHints;
  final Brightness? keyboardAppearance;
  final bool autofocus;
  final TextAlignVertical? textAlignVertical;

  final Color? cursorColor;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final double cursorWidth;
  final bool? showCursor;
  final TextMagnifierConfiguration? magnifierConfiguration;

  final int? minLines;
  final bool expands;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final InputCounterWidgetBuilder? buildCounter;

  final InputDecoration? decorationOverride;

  final TextStyle? textStyle;

  InputDecoration _decoration(BuildContext context) {
    final kit = WidgetKitTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    final effectiveBorderRadius =
        borderRadius ?? kit.inputBorderRadius ?? 8.0;
    final effectiveBorderWidth = borderWidth ?? kit.inputBorderWidth ?? 1.0;
    final effectiveFocusedBorderWidth =
        focusedBorderWidth ?? kit.inputFocusedBorderWidth ?? 2.0;
    final effectiveBorderColor =
        borderColor ?? kit.inputBorderColor ?? scheme.outline;
    final effectiveFocusedBorderColor =
        focusedBorderColor ?? kit.inputFocusedBorderColor ?? scheme.primary;
    final effectiveBackground =
        backgroundColor ?? kit.inputBackgroundColor ?? Colors.transparent;
    final effectiveErrorColor =
        errorColor ?? kit.inputErrorColor ?? scheme.error;
    final effectiveHintColor =
        hintColor ?? kit.inputHintColor ?? scheme.onSurfaceVariant;
    final effectiveHintFontSize = hintFontSize ?? kit.inputHintFontSize ?? 12;

    return InputDecoration(
      alignLabelWithHint: (maxLines ?? 1) > 1,
      filled: true,
      fillColor: effectiveBackground,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding,
      hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: effectiveHintFontSize,
            color: effectiveHintColor,
            height: 2,
            leadingDistribution: TextLeadingDistribution.even,
          ),
      errorStyle: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(fontSize: 12, color: effectiveErrorColor, height: 1.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        borderSide: BorderSide(
          color: effectiveBorderColor,
          width: effectiveBorderWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        borderSide: BorderSide(
          color: effectiveBorderColor,
          width: effectiveBorderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        borderSide: BorderSide(
          color: effectiveFocusedBorderColor,
          width: effectiveFocusedBorderWidth,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kit = WidgetKitTheme.of(context);
    final effectiveDecoration = decorationOverride ?? _decoration(context);
    final isMultiLine = expands || (maxLines ?? 1) > 1 || (minLines ?? 1) > 1;

    final effectiveFontSize = fontSize ?? kit.inputFontSize ?? 14;
    final effectiveTextColor = textColor ?? kit.inputTextColor;

    final effectiveStyle = textStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: effectiveFontSize,
              color: effectiveTextColor,
            );

    return TextFormField(
      key: keyName != null ? ValueKey(keyName) : null,
      controller: controller,
      onTapOutside: onTapOutside ??
          (event) {
            FocusScope.of(context).unfocus();
          },
      focusNode: focusNode,
      initialValue: controller == null ? initialValue : null,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      expands: expands,
      readOnly: readOnly,
      enabled: enabled,
      onTap: onTap,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical ??
          (isMultiLine ? TextAlignVertical.top : TextAlignVertical.center),
      style: effectiveStyle,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      autovalidateMode: autovalidateMode,
      autofillHints: autofillHints,
      keyboardAppearance: keyboardAppearance,
      autofocus: autofocus,
      cursorColor: cursorColor,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorWidth: cursorWidth,
      showCursor: showCursor,
      magnifierConfiguration: magnifierConfiguration,
      maxLengthEnforcement: maxLengthEnforcement,
      buildCounter: buildCounter,
      decoration: effectiveDecoration,
    );
  }
}
