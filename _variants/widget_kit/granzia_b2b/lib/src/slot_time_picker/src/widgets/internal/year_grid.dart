import 'package:flutter/material.dart';
import '../../theme/slot_picker_theme.dart';

/// A 3-column grid of years rendered when the user taps the month heading.
///
/// Auto-scrolls so the currently displayed year is visible (handy for very
/// wide ranges like 1900-2026 in a DOB picker).
class YearGrid extends StatefulWidget {
  final (int min, int max) bounds;
  final int selectedYear;
  final String locale;
  final SlotPickerTheme theme;
  final ValueChanged<int> onYearSelected;

  const YearGrid({
    super.key,
    required this.bounds,
    required this.selectedYear,
    required this.locale,
    required this.theme,
    required this.onYearSelected,
  });

  @override
  State<YearGrid> createState() => _YearGridState();
}

class _YearGridState extends State<YearGrid> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;
      // Years are rendered newest → oldest, so the index of the selected
      // year is its offset from the top (`max - year`). Scroll to keep the
      // selection a couple of rows below the top so the user sees recent
      // years too, not just the selected one alone at the top.
      final (_, max) = widget.bounds;
      final index = max - widget.selectedYear;
      const rowHeight = 56.0 + 10.0;
      final row = (index / 3).floor();
      final raw = row * rowHeight - 80.0;
      final target = raw.clamp(0.0, _controller.position.maxScrollExtent);
      _controller.jumpTo(target);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final (min, max) = widget.bounds;
    final years = [for (var y = max; y >= min; y--) y]; // newest first

    return SizedBox(
      height: 280,
      child: GridView.builder(
        controller: _controller,
        padding: const EdgeInsets.symmetric(vertical: 4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 56,
        ),
        itemCount: years.length,
        itemBuilder: (_, i) {
          final year = years[i];
          final selected = year == widget.selectedYear;
          final radius = BorderRadius.circular(12);

          return Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              onTap: () => widget.onYearSelected(year),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? t.primaryColor : Colors.transparent,
                  borderRadius: radius,
                  border: Border.all(
                    color: selected
                        ? t.primaryColor
                        : t.grey400.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  year.toString(),
                  style: TextStyle(
                    color: selected ? Colors.white : t.grey900,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
