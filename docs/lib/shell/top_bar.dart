import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'theme_controller.dart';

/// The slim top bar: breadcrumb/title on the left, search + theme toggle on the right.
class DocsTopBar extends StatelessWidget implements PreferredSizeWidget {
  const DocsTopBar({
    super.key,
    required this.title,
    required this.onOpenSidebarMobile,
    required this.onOpenSearch,
  });

  /// Heading text shown top-left (current page title, or brand on the home).
  final String title;

  /// Opens the sidebar as a drawer on narrow screens.
  final VoidCallback onOpenSidebarMobile;

  /// Opens the command-palette search.
  final VoidCallback onOpenSearch;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeModeController.of(context) == ThemeMode.dark;
    final isNarrow = MediaQuery.sizeOf(context).width < 900;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.colorOrDefault(context),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (isNarrow)
            IconButton(
              icon: const Icon(Icons.menu_rounded, size: 20),
              onPressed: onOpenSidebarMobile,
              tooltip: 'Navigation',
            ),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _SearchTrigger(onTap: onOpenSearch),
          const SizedBox(width: 8),
          // Theme toggle.
          _ThemeToggleButton(isDark: isDark),
        ],
      ),
    );
  }
}

/// macOS users expect ⌘K; everyone else expects Ctrl K. The shortcut itself
/// accepts either, so this only affects the label.
String _metaKeyLabel() =>
    defaultTargetPlatform == TargetPlatform.macOS ? '⌘' : 'Ctrl ';

class _SearchTrigger extends StatelessWidget {
  const _SearchTrigger({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNarrow = MediaQuery.sizeOf(context).width < 700;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.search_rounded, size: 16),
      label: isNarrow
          ? const SizedBox.shrink()
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Search'),
                const SizedBox(width: 28),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${_metaKeyLabel()}K',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurfaceVariant,
        backgroundColor: theme.colorScheme.surface,
        side: BorderSide(color: theme.dividerColor.colorOrDefault(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 10 : 14,
          vertical: 8,
        ),
        textStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
        minimumSize: const Size(0, 36),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => ThemeModeController.toggle(context),
      icon: Icon(
        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        size: 18,
      ),
      tooltip: isDark ? 'Switch to light' : 'Switch to dark',
      style: IconButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(36, 36),
      ),
    );
  }
}

extension on Color? {
  Color colorOrDefault(BuildContext context) =>
      this ?? Theme.of(context).dividerColor;
}
