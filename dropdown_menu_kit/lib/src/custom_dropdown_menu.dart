import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'dropdown_entries.dart';
import 'dropdown_manager.dart';
import 'dropdown_panel.dart';

/// A flexible dropdown menu widget with overlay-based positioning.
///
/// - Multiple item types: items, labels, separators, checkboxes, radios.
/// - Auto-width matches the trigger width.
/// - Alignment (start, center, end), with automatic edge clamping.
/// - Opens upward when there isn't enough room below.
/// - Optional close-on-tap-outside barrier.
/// - Singleton-managed: opening one dropdown closes any other.
class CustomDropdownMenu extends HookWidget {
  const CustomDropdownMenu({
    super.key,
    required this.trigger,
    required this.items,
    this.width,
    this.align = CustomDropdownAlignment.center,
    this.autoWidth = true,
    this.selectedValue,
    this.closeOnTapOutside = true,
    this.maxHeight,
  });

  final Widget trigger;
  final List<CustomDropdownEntry> items;

  /// Fixed panel width. Ignored when [autoWidth] is true.
  final double? width;

  /// Horizontal alignment relative to the trigger.
  final CustomDropdownAlignment align;

  /// When true, the panel matches the trigger width.
  final bool autoWidth;

  /// Adds a checkmark next to the item whose value matches.
  final String? selectedValue;

  /// Tapping outside the panel closes it. Defaults to true.
  final bool closeOnTapOutside;

  /// Maximum height of the panel. Defaults to 60% of screen height.
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final isOpen = useState(false);
    final overlayEntry = useRef<OverlayEntry?>(null);
    final layerLink = useMemoized(LayerLink.new);
    final triggerKey = useMemoized(GlobalKey.new);

    void closeMenu() {
      overlayEntry.value?.remove();
      overlayEntry.value = null;
      if (isOpen.value) {
        DropdownManager().unregister(closeMenu);
        isOpen.value = false;
      }
    }

    void openMenu() {
      if (overlayEntry.value != null) return;

      final renderBox =
          triggerKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      DropdownManager().register(closeMenu);

      final triggerSize = renderBox.size;
      final screenSize = MediaQuery.of(context).size;
      final triggerPosition = renderBox.localToGlobal(Offset.zero);

      final maxDropdownHeight = maxHeight ?? screenSize.height * 0.6;
      final estimatedHeight =
          (items.length * 40.0).clamp(0.0, maxDropdownHeight);
      final spaceBelow =
          screenSize.height - (triggerPosition.dy + triggerSize.height);
      final spaceAbove = triggerPosition.dy;

      final openUpward = spaceBelow < estimatedHeight &&
          (spaceAbove >= estimatedHeight || spaceAbove > spaceBelow);

      final dropdownWidth =
          autoWidth ? triggerSize.width : (width ?? 224);

      double x = switch (align) {
        CustomDropdownAlignment.start => 0,
        CustomDropdownAlignment.end => triggerSize.width - dropdownWidth,
        CustomDropdownAlignment.center =>
          (triggerSize.width - dropdownWidth) / 2,
      };

      final rightEdge = triggerPosition.dx + x + dropdownWidth;
      if (rightEdge > screenSize.width - 16) {
        x = screenSize.width - 16 - triggerPosition.dx - dropdownWidth;
      }
      if (triggerPosition.dx + x < 16) {
        x = 16 - triggerPosition.dx;
      }

      final offset = Offset(x, openUpward ? -8 : triggerSize.height + 8);

      overlayEntry.value = OverlayEntry(
        builder: (_) => Stack(
          children: [
            if (closeOnTapOutside)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: closeMenu,
                  child: const SizedBox.expand(),
                ),
              ),
            CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: offset,
              child: DropdownPanel(
                items: items,
                width: width,
                autoWidth: autoWidth,
                triggerKey: triggerKey,
                selectedValue: selectedValue,
                openUpward: openUpward,
                onClose: closeMenu,
                maxHeight: maxHeight,
              ),
            ),
          ],
        ),
      );

      Overlay.of(context).insert(overlayEntry.value!);
      isOpen.value = true;
    }

    useEffect(() {
      return () {
        overlayEntry.value?.remove();
        overlayEntry.value = null;
        if (isOpen.value) DropdownManager().unregister(closeMenu);
      };
    }, const []);

    return CompositedTransformTarget(
      link: layerLink,
      child: GestureDetector(
        key: triggerKey,
        onTap: isOpen.value ? closeMenu : openMenu,
        child: trigger,
      ),
    );
  }
}
