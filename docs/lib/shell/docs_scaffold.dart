import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;

import '../data/docs_catalog.dart';
import 'docs_search.dart';
import 'sidebar.dart';
import 'top_bar.dart';

/// The persistent docs layout: a fixed sidebar on wide screens (or a drawer
/// on narrow ones), a top bar, and a scrollable content area that hosts the
/// current page.
class DocsScaffold extends StatefulWidget {
  const DocsScaffold({
    super.key,
    required this.catalog,
    required this.currentPath,
    required this.currentTitle,
    required this.onNavigate,
    required this.child,
  });

  final List<KitEntry> catalog;
  final String currentPath;
  final String currentTitle;
  final void Function(String route) onNavigate;
  final Widget child;

  @override
  State<DocsScaffold> createState() => _DocsScaffoldState();
}

class _DocsScaffoldState extends State<DocsScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _searchOpen = false;

  Future<void> _openSearch() async {
    // Guard against ⌘K firing again while the palette is already up.
    if (_searchOpen) return;
    _searchOpen = true;
    final route = await showDocsSearch(context, widget.catalog);
    _searchOpen = false;
    if (route != null) widget.onNavigate(route);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    final sidebar = DocsSidebar(
      catalog: widget.catalog,
      currentPath: widget.currentPath,
      onNavigate: (route) {
        widget.onNavigate(route);
        // Close the drawer if we're in narrow mode.
        if (!isWide) Navigator.of(context).maybePop();
      },
    );

    return CallbackShortcuts(
      bindings: {
        // Both, so the same build serves macOS and Windows/Linux browsers.
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): _openSearch,
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): _openSearch,
      },
      child: Focus(
        autofocus: true,
        child: _buildScaffold(isWide: isWide, sidebar: sidebar),
      ),
    );
  }

  Widget _buildScaffold({required bool isWide, required Widget sidebar}) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: isWide
          ? null
          : Drawer(
              width: 272,
              shape: const RoundedRectangleBorder(),
              child: sidebar,
            ),
      body: Column(
        children: [
          DocsTopBar(
            title: widget.currentTitle,
            onOpenSidebarMobile: () => _scaffoldKey.currentState?.openDrawer(),
            onOpenSearch: _openSearch,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isWide)
                  Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: theme.dividerColor.colorOrDefault(context),
                            ),
                          ),
                        ),
                        child: sidebar,
                      );
                    },
                  ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on Color? {
  Color colorOrDefault(BuildContext context) =>
      this ?? Theme.of(context).dividerColor;
}
