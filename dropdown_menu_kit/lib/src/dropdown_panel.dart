import 'package:flutter/material.dart';

import 'dropdown_entries.dart';
import 'dropdown_item_renderer.dart';
import 'dropdown_theme.dart';

/// Animated, scrollable panel that hosts the rendered dropdown items.
class DropdownPanel extends StatefulWidget {
  const DropdownPanel({
    super.key,
    required this.items,
    required this.triggerKey,
    required this.onClose,
    this.width,
    this.autoWidth = false,
    this.selectedValue,
    this.openUpward = false,
    this.maxHeight,
  });

  final List<CustomDropdownEntry> items;
  final double? width;
  final bool autoWidth;
  final GlobalKey triggerKey;
  final String? selectedValue;
  final bool openUpward;
  final VoidCallback onClose;
  final double? maxHeight;

  @override
  State<DropdownPanel> createState() => _DropdownPanelState();
}

class _DropdownPanelState extends State<DropdownPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final double _effectiveWidth = _resolveWidth();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    final curved =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.95, end: 1.0).animate(curved);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _resolveWidth() {
    if (widget.autoWidth) {
      final box =
          widget.triggerKey.currentContext?.findRenderObject() as RenderBox?;
      return box?.size.width ?? widget.width ?? 200;
    }
    return widget.width ?? 224;
  }

  @override
  Widget build(BuildContext context) {
    final theme = DropdownKitTheme.of(context);
    final radius = theme.panelBorderRadius!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        alignment:
            widget.openUpward ? Alignment.bottomCenter : Alignment.topCenter,
        child: Opacity(opacity: _opacity.value, child: child),
      ),
      child: Material(
        color: theme.panelBackground,
        elevation: theme.panelElevation!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: theme.panelBorderColor!),
        ),
        child: Container(
          width: widget.autoWidth ? _effectiveWidth : null,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 32,
            maxHeight: widget.maxHeight ??
                MediaQuery.of(context).size.height * 0.6,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _DropdownItemsList(
                items: widget.items,
                autoWidth: widget.autoWidth,
                openUpward: widget.openUpward,
                onClose: widget.onClose,
                selectedValue: widget.selectedValue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownItemsList extends StatefulWidget {
  const _DropdownItemsList({
    required this.items,
    required this.autoWidth,
    required this.openUpward,
    required this.onClose,
    this.selectedValue,
  });

  final List<CustomDropdownEntry> items;
  final bool autoWidth;
  final bool openUpward;
  final VoidCallback onClose;
  final String? selectedValue;

  @override
  State<_DropdownItemsList> createState() => _DropdownItemsListState();
}

class _DropdownItemsListState extends State<_DropdownItemsList> {
  final _scrollController = ScrollController();
  String? _radioGroupValue;

  @override
  void initState() {
    super.initState();
    _radioGroupValue = _initialRadioGroupValue();
  }

  String? _initialRadioGroupValue() {
    for (final item in widget.items) {
      if (item is CustomDropdownRadio && item.groupValue != null) {
        return item.groupValue;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in widget.items)
          DropdownItemRenderer(
            item: item,
            onClose: widget.onClose,
            selectedValue: widget.selectedValue,
            radioGroupValueOverride: _radioGroupValue,
            onRadioSelected: (value) =>
                setState(() => _radioGroupValue = value),
          ),
      ],
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (_) => true,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          reverse: widget.openUpward,
          child: widget.autoWidth ? column : IntrinsicWidth(child: column),
        ),
      ),
    );
  }
}
