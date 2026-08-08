import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/docs_catalog.dart';

/// One hit in the search list: a kit landing page, or a page inside a kit.
class _Hit {
  const _Hit({
    required this.route,
    required this.title,
    required this.subtitle,
    required this.breadcrumb,
    required this.icon,
    required this.score,
  });

  final String route;
  final String title;
  final String subtitle;
  final String breadcrumb;
  final IconData icon;
  final int score;
}

/// Ranks catalog entries against [query]. Empty query lists everything, so the
/// dialog doubles as a full index when opened with no typing.
List<_Hit> _search(List<KitEntry> catalog, String query) {
  final q = query.trim().toLowerCase();
  final hits = <_Hit>[];

  // A title match outranks a description match, and a prefix outranks a
  // mid-word hit — so typing "app" puts "AppButton" above "Adaptive app bar".
  int? rank(String title, String subtitle) {
    if (q.isEmpty) return 0;
    final t = title.toLowerCase();
    if (t.startsWith(q)) return 3;
    if (t.contains(q)) return 2;
    if (subtitle.toLowerCase().contains(q)) return 1;
    return null;
  }

  for (final kit in catalog) {
    final kitScore = rank(kit.title, kit.blurb);
    if (kitScore != null) {
      hits.add(_Hit(
        route: '/${kit.slug}',
        title: kit.title,
        subtitle: kit.blurb,
        breadcrumb: 'Overview',
        icon: kit.icon,
        score: kitScore,
      ));
    }

    for (final page in kit.pages) {
      final pageScore = rank(page.title, page.description);
      if (pageScore != null) {
        hits.add(_Hit(
          route: page.routeFor(kit.slug),
          title: page.title,
          subtitle: page.description,
          breadcrumb: kit.title,
          icon: kit.icon,
          score: pageScore,
        ));
      }
    }
  }

  hits.sort((a, b) => b.score.compareTo(a.score));
  return hits;
}

/// Opens the command-palette search. Returns the chosen route, or null.
Future<String?> showDocsSearch(BuildContext context, List<KitEntry> catalog) {
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (context) => _SearchDialog(catalog: catalog),
  );
}

class _SearchDialog extends StatefulWidget {
  const _SearchDialog({required this.catalog});
  final List<KitEntry> catalog;

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late List<_Hit> _hits = _search(widget.catalog, '');
  int _selected = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() {
      _hits = _search(widget.catalog, value);
      _selected = 0;
    });
  }

  void _move(int delta) {
    if (_hits.isEmpty) return;
    setState(() {
      _selected = (_selected + delta).clamp(0, _hits.length - 1);
    });
    // Keep the highlighted row on screen while arrowing through a long list.
    _scrollController.animateTo(
      (_selected * _rowHeight)
          .clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
  }

  void _submit() {
    if (_hits.isEmpty) return;
    Navigator.of(context).pop(_hits[_selected].route);
  }

  static const _rowHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: const Alignment(0, -0.55),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            elevation: 12,
            shadowColor: Colors.black.withValues(alpha: 0.3),
            child: Shortcuts(
              shortcuts: const {
                SingleActivator(LogicalKeyboardKey.arrowDown): _MoveIntent(1),
                SingleActivator(LogicalKeyboardKey.arrowUp): _MoveIntent(-1),
              },
              child: Actions(
                actions: {
                  _MoveIntent: CallbackAction<_MoveIntent>(
                    onInvoke: (intent) {
                      _move(intent.delta);
                      return null;
                    },
                  ),
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _queryField(theme),
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                    if (_hits.isEmpty)
                      _emptyState(theme)
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 340),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shrinkWrap: true,
                          itemCount: _hits.length,
                          itemBuilder: (context, i) => _ResultTile(
                            hit: _hits[i],
                            selected: i == _selected,
                            onHover: () => setState(() => _selected = i),
                            onTap: () =>
                                Navigator.of(context).pop(_hits[i].route),
                          ),
                        ),
                      ),
                    _footer(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _queryField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onQueryChanged,
              onSubmitted: (_) => _submit(),
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Search kits and components…',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          _Kbd(label: 'Esc', onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 26,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            'No matches for "${_controller.text.trim()}"',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 11,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        child: Row(
          children: [
            const _KeyHint(keys: ['↑', '↓'], label: 'navigate'),
            const SizedBox(width: 16),
            const _KeyHint(keys: ['↵'], label: 'open'),
            const Spacer(),
            Text('${_hits.length} result${_hits.length == 1 ? '' : 's'}'),
          ],
        ),
      ),
    );
  }
}

class _MoveIntent extends Intent {
  const _MoveIntent(this.delta);
  final int delta;
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.hit,
    required this.selected,
    required this.onTap,
    required this.onHover,
  });

  final _Hit hit;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => onHover(),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  hit.icon,
                  size: 16,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              hit.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hit.breadcrumb,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hit.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.subdirectory_arrow_left_rounded,
                    size: 15,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyHint extends StatelessWidget {
  const _KeyHint({required this.keys, required this.label});
  final List<String> keys;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final k in keys) ...[
          _Kbd(label: k),
          const SizedBox(width: 3),
        ],
        const SizedBox(width: 3),
        Text(label),
      ],
    );
  }
}

/// A keycap-looking chip. Tappable when [onTap] is given (the Esc affordance —
/// keyboard hints alone leave touch users with no way to dismiss).
class _Kbd extends StatelessWidget {
  const _Kbd({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );

    if (onTap == null) return chip;
    return Tooltip(
      message: 'Close search',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(padding: const EdgeInsets.all(6), child: chip),
      ),
    );
  }
}
