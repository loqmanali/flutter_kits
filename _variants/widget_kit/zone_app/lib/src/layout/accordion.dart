import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../utils/widget_kit_localization.dart';

/// Data model for a single accordion entry (trigger + content).
///
/// Per-item overrides take precedence over the parent [Accordion]'s values.
class AccordionItemData {
  final Widget header;
  final Widget content;

  /// Optional override for header background. Falls back to the
  /// [Accordion.headerBackgroundColor] or [Accordion.backgroundColor].
  final Color? headerBackgroundColor;

  /// Optional override for the foreground color used by the trailing icon
  /// (and any [IconTheme] / [DefaultTextStyle] descendants in the header).
  final Color? headerForegroundColor;

  /// Optional trailing widget that replaces the default rotating chevron.
  /// Provide this when the row needs a different affordance (e.g. a custom
  /// icon). The widget will still be rotated when the panel opens.
  final Widget? trailing;

  const AccordionItemData({
    required this.header,
    required this.content,
    this.headerBackgroundColor,
    this.headerForegroundColor,
    this.trailing,
  });
}

enum AccordionBorderMode {
  none,
  headerOnly,
  contentOnly,
  all,
  shared,
}

class Accordion extends HookWidget {
  final List<AccordionItemData> items;
  final Duration duration;
  final Curve curve;
  final Curve reverseCurve;
  final bool allowMultipleOpen;

  /// Background color used for borders / panel chrome. In [AccordionBorderMode.shared]
  /// it also paints the panel surface unless [headerBackgroundColor] /
  /// [contentBackgroundColor] are provided.
  final Color backgroundColor;

  /// Optional dedicated background for the header strip. When supplied, the
  /// header is painted with this color while the rest of the panel keeps
  /// [backgroundColor] (or [contentBackgroundColor] if set).
  final Color? headerBackgroundColor;

  /// Optional dedicated background for the content area in
  /// [AccordionBorderMode.shared].
  final Color? contentBackgroundColor;

  /// Foreground color applied to the trailing chevron and inherited by the
  /// header via [IconTheme] / [DefaultTextStyle]. When null, the icon uses
  /// the ambient [IconThemeData].
  final Color? headerForegroundColor;

  final Color borderColor;
  final double borderWidth;

  final double innerGap;
  final double borderRadius;
  final bool showDivider;
  final bool showInnerDivider;

  /// Padding applied to the row that wraps [AccordionItemData.header].
  final EdgeInsetsGeometry headerPadding;

  /// Padding applied to [AccordionItemData.content].
  final EdgeInsetsGeometry contentPadding;

  /// Outer margin applied around each panel. The default leaves room for a
  /// floating card style; pass [EdgeInsets.zero] when the parent already
  /// provides its own padding.
  final EdgeInsetsGeometry panelMargin;

  /// Optional replacement for the trailing chevron used in every item that
  /// does not provide its own [AccordionItemData.trailing].
  final Widget? trailingIcon;

  final AccordionBorderMode borderMode;

  const Accordion({
    super.key,
    required this.items,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeIn,
    this.reverseCurve = Curves.easeOut,
    this.allowMultipleOpen = false,
    this.backgroundColor = Colors.white,
    this.headerBackgroundColor,
    this.contentBackgroundColor,
    this.headerForegroundColor,
    this.borderColor = const Color(0xFFBDBDBD),
    this.borderWidth = 1.0,
    this.innerGap = 0,
    this.borderRadius = 6,
    this.showDivider = false,
    this.showInnerDivider = false,
    this.headerPadding =
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.panelMargin =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.trailingIcon,
    this.borderMode = AccordionBorderMode.shared,
  });

  @override
  Widget build(BuildContext context) {
    final expanded = useState<Set<int>>({});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0 && showDivider) const Divider(height: 1),
          _AccordionPanel(
            key: ValueKey(i),
            data: items[i],
            isOpen: expanded.value.contains(i),
            duration: duration,
            curve: curve,
            reverseCurve: reverseCurve,
            backgroundColor: backgroundColor,
            headerBackgroundColor:
                items[i].headerBackgroundColor ?? headerBackgroundColor,
            contentBackgroundColor: contentBackgroundColor,
            headerForegroundColor:
                items[i].headerForegroundColor ?? headerForegroundColor,
            borderColor: borderColor,
            borderWidth: borderWidth,
            innerGap: innerGap,
            borderRadius: borderRadius,
            borderMode: borderMode,
            showInnerDivider: showInnerDivider,
            headerPadding: headerPadding,
            contentPadding: contentPadding,
            panelMargin: panelMargin,
            trailingIcon: items[i].trailing ?? trailingIcon,
            onToggle: () {
              if (allowMultipleOpen) {
                final next = {...expanded.value};
                if (!next.remove(i)) next.add(i);
                expanded.value = next;
              } else {
                expanded.value = expanded.value.contains(i) ? {} : {i};
              }
            },
          ),
        ],
      ],
    );
  }
}

class _AccordionPanel extends HookWidget {
  final AccordionItemData data;
  final bool isOpen;
  final VoidCallback onToggle;
  final Duration duration;
  final Curve curve;
  final Curve reverseCurve;

  final Color backgroundColor;
  final Color? headerBackgroundColor;
  final Color? contentBackgroundColor;
  final Color? headerForegroundColor;
  final Color borderColor;
  final double borderWidth;
  final double innerGap;
  final double borderRadius;

  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry panelMargin;
  final Widget? trailingIcon;

  final AccordionBorderMode borderMode;
  final bool showInnerDivider;

  const _AccordionPanel({
    super.key,
    required this.data,
    required this.isOpen,
    required this.onToggle,
    required this.duration,
    required this.curve,
    required this.reverseCurve,
    required this.backgroundColor,
    required this.headerBackgroundColor,
    required this.contentBackgroundColor,
    required this.headerForegroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.innerGap,
    required this.borderRadius,
    required this.borderMode,
    required this.showInnerDivider,
    required this.headerPadding,
    required this.contentPadding,
    required this.panelMargin,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: duration,
      initialValue: isOpen ? 1 : 0,
    );

    useEffect(
      () {
        if (isOpen) {
          controller.forward();
        } else {
          controller.reverse();
        }
        return null;
      },
      [isOpen],
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: curve,
      reverseCurve: reverseCurve,
    );

    final trailing = RotationTransition(
      turns: Tween<double>(begin: 0, end: 0.5).animate(animation),
      child: trailingIcon ?? const Icon(CupertinoIcons.down_arrow),
    );

    final headerForeground = headerForegroundColor;
    final headerBg = headerBackgroundColor;
    final contentBg = contentBackgroundColor;

    Widget headerRow = Padding(
      padding: headerPadding,
      child: Directionality(
        textDirection: context.isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Row(
          children: [
            Expanded(child: data.header),
            trailing,
          ],
        ),
      ),
    );

    // Apply foreground color via IconTheme + DefaultTextStyle so consumers
    // don't have to thread the color through every descendant.
    if (headerForeground != null) {
      headerRow = IconTheme.merge(
        data: IconThemeData(color: headerForeground),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: headerForeground),
          child: headerRow,
        ),
      );
    }

    final header = Material(
      color: headerBg ?? Colors.transparent,
      child: InkWell(
        onTap: () {
          onToggle();
          HapticFeedback.mediumImpact();
        },
        child: headerRow,
      ),
    );

    final content = SizeTransition(
      sizeFactor: animation,
      alignment: const AlignmentDirectional(0, -1),
      child: Container(
        width: double.infinity,
        color: contentBg,
        padding: contentPadding,
        child: data.content,
      ),
    );

    // === Handling border modes ===
    switch (borderMode) {
      case AccordionBorderMode.none:
        return Column(
          children: [
            header,
            if (innerGap > 0) SizedBox(height: innerGap),
            content,
          ],
        );

      case AccordionBorderMode.headerOnly:
        return Column(
          children: [
            Container(
              margin: panelMargin,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: headerBg ?? backgroundColor,
                border: Border.all(color: borderColor, width: borderWidth),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: header,
            ),
            if (innerGap > 0) SizedBox(height: innerGap),
            content,
          ],
        );

      case AccordionBorderMode.contentOnly:
        return Column(
          children: [
            header,
            if (innerGap > 0) SizedBox(height: innerGap),
            Container(
              margin: panelMargin,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: contentBg ?? backgroundColor,
                border: Border.all(color: borderColor, width: borderWidth),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: content,
            ),
          ],
        );

      case AccordionBorderMode.all:
        return Column(
          children: [
            Container(
              margin: panelMargin,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: headerBg ?? backgroundColor,
                border: Border.all(color: borderColor, width: borderWidth),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: header,
            ),
            if (innerGap > 0) SizedBox(height: innerGap),
            Container(
              margin: panelMargin,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: contentBg ?? backgroundColor,
                border: Border.all(color: borderColor, width: borderWidth),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: content,
            ),
          ],
        );

      case AccordionBorderMode.shared:
        return Container(
          margin: panelMargin,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: contentBg ?? backgroundColor,
            border: Border.all(color: borderColor, width: borderWidth),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Column(
            children: [
              header,
              if (showInnerDivider && isOpen)
                Divider(height: 1, color: borderColor.withValues(alpha: 0.7)),
              if (innerGap > 0) SizedBox(height: innerGap),
              content,
            ],
          ),
        );
    }
  }
}
