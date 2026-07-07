import 'package:flutter/material.dart';

/// The standard page shell for every category page in the gallery.
///
/// Provides the app bar (with title + back), a constrained, padded, scrollable
/// body, and consistent spacing between the demo sections passed in [sections].
class GalleryScaffold extends StatelessWidget {
  const GalleryScaffold({
    super.key,
    required this.title,
    required this.sections,
    this.intro,
  });

  /// Page title, shown in the app bar.
  final String title;

  /// Optional one-line intro shown above the first section.
  final String? intro;

  /// The demo sections / groups that make up the page body.
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
            children: [
              if (intro != null) ...[
                Text(
                  intro!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              for (var i = 0; i < sections.length; i++) ...[
                sections[i],
                if (i != sections.length - 1) const SizedBox(height: 36),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
