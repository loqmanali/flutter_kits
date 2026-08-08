import 'package:flutter/material.dart';

import 'data/catalog.dart';
import 'data/docs_catalog.dart';

/// Resolves a route path to the widget + title to display, against [catalog].
///
/// Routes are flat:
///   `/`                → the home (kits index)
///   `/<kitSlug>`       → a kit landing page
///   `/<kitSlug>/<pageSlug>` → a component page
RouteResolution resolveRoute(String path) {
  // Normalize: strip trailing slash, strip leading slash for splitting.
  final clean = path.endsWith('/') && path.length > 1
      ? path.substring(0, path.length - 1)
      : path;
  final segments = clean.split('/').where((s) => s.isNotEmpty).toList();

  if (segments.isEmpty) return const RouteResolution.home();

  // A route string arrives straight from the address bar, so an unknown slug is
  // ordinary user input (a stale bookmark, a typo), not a programmer error.
  final kit = catalog.where((k) => k.slug == segments.first).firstOrNull;
  if (kit == null) return RouteResolution.notFound(path);

  if (segments.length == 1) {
    return RouteResolution(
      path: path,
      title: kit.title,
      child: kit.landing(),
      kind: RouteKind.kitLanding,
    );
  }

  final page = kit.pages.where((p) => p.slug == segments[1]).firstOrNull;
  if (page == null) return RouteResolution.notFound(path);

  return RouteResolution(
    path: path,
    title: page.title,
    child: page.build(),
    kind: RouteKind.page,
  );
}

enum RouteKind { home, kitLanding, page, notFound }

class RouteResolution {
  const RouteResolution({
    required this.path,
    required this.title,
    required this.child,
    required this.kind,
  });

  const RouteResolution.home()
      : path = '/',
        title = 'flutter_kits',
        child = null,
        kind = RouteKind.home;

  /// A route that matched no kit or page — a stale bookmark or a typo.
  const RouteResolution.notFound(this.path)
      : title = 'Page not found',
        child = null,
        kind = RouteKind.notFound;

  final String path;
  final String title;
  final Widget? child;
  final RouteKind kind;
}

/// Builds the home page (kits index) from the catalog.
Widget buildHomePage(void Function(String route) onNavigate) {
  return _HomePage(onNavigate: onNavigate);
}

/// Shown when a URL names a kit or page that doesn't exist.
Widget buildNotFoundPage(String path, void Function(String route) onNavigate) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.explore_off_rounded,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text('Page not found', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Nothing is documented at "$path". It may have been renamed '
                'since this link was saved.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => onNavigate('/'),
                icon: const Icon(Icons.home_rounded, size: 16),
                label: const Text('Back to all kits'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.onNavigate});
  final void Function(String route) onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 56, 40, 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'flutter_kits',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 44),
              ),
              const SizedBox(height: 14),
              Text(
                'A monorepo of focused Flutter packages. Each kit is documented '
                'with a live preview and copyable code — pick one to begin.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 36),
              for (final kit in catalog) ...[
                _KitCard(kit: kit, onTap: () => onNavigate('/${kit.slug}')),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _KitCard extends StatelessWidget {
  const _KitCard({required this.kit, required this.onTap});
  final KitEntry kit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(kit.icon, color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        kit.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          kit.version,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kit.blurb,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
