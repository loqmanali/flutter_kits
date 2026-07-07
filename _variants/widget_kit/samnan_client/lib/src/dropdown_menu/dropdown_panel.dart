import 'package:flutter/material.dart';

import 'dropdown_entries.dart';
import 'dropdown_item_renderer.dart';

// ============================================================================
// Animated Dropdown Panel
// ============================================================================

class DropdownPanel extends StatefulWidget {
  final List<CustomDropdownEntry> items;
  final double? width;
  final bool autoWidth;
  final GlobalKey triggerKey;
  final String? selectedValue;
  final bool openUpward;
  final VoidCallback onClose;
  final bool closeOnTapOutside;

  /// Maximum height of the dropdown panel. Defaults to 60% of screen height.
  final double? maxHeight;

  const DropdownPanel({
    super.key,
    required this.items,
    required this.triggerKey,
    required this.onClose,
    this.width,
    this.autoWidth = false,
    this.selectedValue,
    this.openUpward = false,
    this.closeOnTapOutside = true,
    this.maxHeight,
  });

  @override
  State<DropdownPanel> createState() => _DropdownPanelState();
}

class _DropdownPanelState extends State<DropdownPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final double _effectiveWidth;

  @override
  void initState() {
    super.initState();
    _effectiveWidth = _resolveWidth();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
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
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        alignment: widget.openUpward
            ? Alignment.bottomCenter
            : Alignment.topCenter,
        child: Opacity(opacity: _opacity.value, child: child),
      ),
      child: Material(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: Container(
          width: widget.autoWidth ? _effectiveWidth : null,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 32,
            maxHeight:
                widget.maxHeight ?? MediaQuery.of(context).size.height * 0.6,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
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

// ============================================================================
// Items List
// ============================================================================

class _DropdownItemsList extends StatefulWidget {
  final List<CustomDropdownEntry> items;
  final bool autoWidth;
  final bool openUpward;
  final VoidCallback onClose;
  final String? selectedValue;

  const _DropdownItemsList({
    required this.items,
    required this.autoWidth,
    required this.openUpward,
    required this.onClose,
    this.selectedValue,
  });

  @override
  State<_DropdownItemsList> createState() => _DropdownItemsListState();
}

class _DropdownItemsListState extends State<_DropdownItemsList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.items
        .map(
          (item) => DropdownItemRenderer(
            item: item,
            onClose: widget.onClose,
            selectedValue: widget.selectedValue,
          ),
        )
        .toList();

    final column = Column(mainAxisSize: MainAxisSize.min, children: children);

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
