import 'package:flutter/material.dart';

import '../data/docs_catalog.dart';

/// The left navigation rail.
///
/// A forui/shadnc-style sidebar: brand at the top, then a tree of
/// kits → pages. The current route is highlighted; everything else is a
/// quiet, dense list.
class DocsSidebar extends StatelessWidget {
  const DocsSidebar({
    super.key,
    required this.catalog,
    required this.currentPath,
    required this.onNavigate,
  });

  /// The full docs catalog (kits + their pages).
  final List<KitEntry> catalog;

  /// The current route path (e.g. '/otp_kit/text-field'); used for highlight.
  final String currentPath;

  /// Called with a route path when a nav item is tapped.
  final void Function(String route) onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 272,
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Brand row.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Center(
                    child: Text(
                      'f',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'flutter_kits',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: theme.dividerColor.colorOrDefault(context),
          ),
          // Nav tree.
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                for (final kit in catalog) ...[
                  _KitHeader(
                    slug: kit.slug,
                    title: kit.title,
                    icon: kit.icon,
                    isActive: currentPath == '/${kit.slug}',
                    onTap: () => onNavigate('/${kit.slug}'),
                  ),
                  for (final page in kit.pages)
                    _PageTile(
                      title: page.title,
                      isActive: currentPath == '/${kit.slug}/${page.slug}',
                      onTap: () => onNavigate('/${kit.slug}/${page.slug}'),
                    ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KitHeader extends StatelessWidget {
  const _KitHeader({
    required this.slug,
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String slug;
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 12, top: 6, bottom: 2),
      child: Material(
        color: isActive
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageTile extends StatelessWidget {
  const _PageTile({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 34, right: 12),
      child: Material(
        color: isActive
            ? theme.colorScheme.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13.5,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small helper: [Divider.color] may be null; fall back to theme.
extension on Color? {
  Color colorOrDefault(BuildContext context) =>
      this ?? Theme.of(context).dividerColor;
}
