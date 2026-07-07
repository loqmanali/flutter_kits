import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../utils/widget_kit_localization.dart';

/// Data model for a single accordion entry (trigger + content).
class AccordionItemData {
  final Widget header;
  final Widget content;

  const AccordionItemData({
    required this.header,
    required this.content,
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

  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;

  final double innerGap;
  final double borderRadius;
  final bool showDivider;
  final bool showInnerDivider;

  final AccordionBorderMode borderMode;

  const Accordion({
    super.key,
    required this.items,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeIn,
    this.reverseCurve = Curves.easeOut,
    this.allowMultipleOpen = false,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFBDBDBD),
    this.borderWidth = 1.0,
    this.innerGap = 0,
    this.borderRadius = 6,
    this.showDivider = false,
    this.showInnerDivider = false,
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
            borderColor: borderColor,
            borderWidth: borderWidth,
            innerGap: innerGap,
            borderRadius: borderRadius,
            borderMode: borderMode,
            showInnerDivider: showInnerDivider,
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
  final Color borderColor;
  final double borderWidth;
  final double innerGap;
  final double borderRadius;

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
    required this.borderColor,
    required this.borderWidth,
    required this.innerGap,
    required this.borderRadius,
    required this.borderMode,
    required this.showInnerDivider,
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

    final header = GestureDetector(
      onTap: () {
        onToggle();
        HapticFeedback.mediumImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Directionality(
          textDirection:
              context.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Row(
            children: [
              Expanded(child: data.header),
              RotationTransition(
                turns: Tween<double>(begin: 0, end: 0.5).animate(animation),
                child: const Icon(CupertinoIcons.down_arrow),
              ),
            ],
          ),
        ),
      ),
    );

    final content = SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor,
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
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor,
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
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(color: borderColor, width: borderWidth),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: header,
            ),
            if (innerGap > 0) SizedBox(height: innerGap),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(color: borderColor, width: borderWidth),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: content,
            ),
          ],
        );

      case AccordionBorderMode.shared:
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor,
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
