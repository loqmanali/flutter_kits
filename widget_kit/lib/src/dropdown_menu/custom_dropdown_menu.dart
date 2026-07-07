import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dropdown_entries.dart';
import 'dropdown_manager.dart';
import 'dropdown_panel.dart';

// ============================================================================
// CustomDropdownMenu
// ============================================================================

/// A flexible dropdown menu widget with overlay-based positioning.
///
/// Features:
/// - Multiple item types: items, labels, separators, checkboxes, radios
/// - Auto-width matching the trigger width
/// - Alignment options (start, center, end)
/// - Smooth open/close animations
/// - Auto-positioning (opens upward when space below is limited)
/// - Optional close-on-tap-outside barrier
/// - Auto-close when another dropdown opens
class CustomDropdownMenu extends HookWidget {
  final Widget trigger;
  final List<CustomDropdownEntry> items;

  /// Fixed width for the dropdown panel. Ignored when [autoWidth] is true.
  final double? width;

  /// Horizontal alignment of the panel relative to the trigger.
  final CustomDropdownAlignment align;

  /// When true the panel matches the trigger's width.
  final bool autoWidth;

  /// Currently selected value — adds a checkmark next to the matching item.
  final String? selectedValue;

  /// Whether tapping outside the panel closes it. Defaults to true.
  final bool closeOnTapOutside;

  /// Maximum height of the dropdown panel. Defaults to 60% of screen height.
  final double? maxHeight;

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

  @override
  Widget build(BuildContext context) {
    final isOpen = useState(false);
    final overlayEntry = useRef<OverlayEntry?>(null);
    final layerLink = useMemoized(() => LayerLink());
    final triggerKey = useMemoized(() => GlobalKey());

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

      // Register — closes any other open dropdowns first
      DropdownManager().register(closeMenu);

      final triggerSize = renderBox.size;
      final screenSize = MediaQuery.of(context).size;
      final triggerPosition = renderBox.localToGlobal(Offset.zero);

      // Determine open direction
      final maxDropdownHeight = maxHeight ?? screenSize.height * 0.6;
      final estimatedHeight =
          (items.length * 40.0).clamp(0.0, maxDropdownHeight);
      final spaceBelow =
          screenSize.height - (triggerPosition.dy + triggerSize.height);
      final spaceAbove = triggerPosition.dy;

      final openUpward = spaceBelow < estimatedHeight &&
          (spaceAbove >= estimatedHeight || spaceAbove > spaceBelow);

      // Horizontal offset
      final dropdownWidth = autoWidth ? triggerSize.width : (width ?? 224);

      double x = switch (align) {
        CustomDropdownAlignment.start => 0,
        CustomDropdownAlignment.end => triggerSize.width - dropdownWidth,
        CustomDropdownAlignment.center =>
          (triggerSize.width - dropdownWidth) / 2,
      };

      // Clamp to screen edges
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
            // ----------------------------------------------------------------
            // Full-screen barrier — closes the menu on outside tap.
            // Placed OUTSIDE CompositedTransformFollower so it truly
            // covers the entire screen, not just the dropdown area.
            // ----------------------------------------------------------------
            if (closeOnTapOutside)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: closeMenu,
                  child: const SizedBox.expand(),
                ),
              ),

            // ----------------------------------------------------------------
            // Dropdown panel, positioned relative to the trigger
            // ----------------------------------------------------------------
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
                closeOnTapOutside: closeOnTapOutside,
                maxHeight: maxHeight,
              ),
            ),
          ],
        ),
      );

      Overlay.of(context).insert(overlayEntry.value!);
      isOpen.value = true;
    }

    // Cleanup on widget dispose
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
