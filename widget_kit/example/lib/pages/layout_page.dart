import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

import '../gallery/demo_section.dart';
import '../gallery/gallery_scaffold.dart';

/// Documents Accordion, AppSpacing, PageTopBar and ProfilePageLayout.
class LayoutPage extends StatelessWidget {
  const LayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryScaffold(
      title: 'Layout',
      intro:
          'Structural building blocks: expandable panels, spacing, top bars '
          'and a ready-made profile scaffold.',
      sections: [
        DemoSection(
          title: 'Accordion',
          description:
              'Expandable panels. Set allowMultipleOpen to keep more '
              'than one section open at a time.',
          demoBackground: false,
          demo: Accordion(
            allowMultipleOpen: false,
            items: [
              for (final entry in const {
                'What is widget_kit?':
                    'A project-agnostic collection of reusable Flutter widgets.',
                'Is it themable?':
                    'Yes — via WidgetKitTheme plus per-widget overrides.',
                'Does it need Riverpod?': 'No — the kit is framework-agnostic.',
              }.entries)
                AccordionItemData(
                  header: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  content: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(entry.value),
                  ),
                ),
            ],
          ),
          code: '''
Accordion(
  allowMultipleOpen: false,
  items: [
    AccordionItemData(header: Text('Title'), content: Text('Body')),
  ],
)''',
        ),
        DemoSection(
          title: 'AppSpacing',
          description:
              'Declarative gaps: height, width, flex, plus small / '
              'medium / large presets.',
          demoBackground: false,
          demo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _spacerRow(
                context,
                'AppSpacing.height(8)',
                const AppSpacing.height(8),
              ),
              _spacerRow(
                context,
                'AppSpacing.height(24)',
                const AppSpacing.height(24),
              ),
            ],
          ),
          code: '''
const AppSpacing.height(16)   // vertical gap
const AppSpacing.width(8)     // horizontal gap
const AppSpacing.flex(1)      // Spacer-like
AppSpacing.medium             // preset = height(16)''',
        ),
        DemoSection(
          title: 'PageTopBar',
          description:
              'A lightweight custom app-bar row: back affordance, '
              'title, and trailing actions.',
          demoBackground: false,
          demo: Material(
            elevation: 1,
            borderRadius: BorderRadius.circular(12),
            child: PageTopBar(
              title: 'Profile',
              onBackPressed: () {},
              actions: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
              ],
            ),
          ),
          code: '''
PageTopBar(
  title: 'Profile',
  onBackPressed: () => Navigator.pop(context),
  actions: [IconButton(icon: Icon(Icons.edit), onPressed: _edit)],
)''',
        ),
        DemoSection(
          title: 'ProfilePageLayout',
          description:
              'A full page scaffold (top bar + safe-area body) for '
              'profile-style screens. Opens full-screen.',
          demo: Builder(
            builder: (context) => AppButton(
              label: 'Open ProfilePageLayout',
              style: AppButtonStyleType.outlined,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProfilePageLayout(
                    title: 'My Profile',
                    child: ListView(
                      children: const [
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text('Account'),
                        ),
                        ListTile(
                          leading: Icon(Icons.lock),
                          title: Text('Security'),
                        ),
                        ListTile(
                          leading: Icon(Icons.logout),
                          title: Text('Sign out'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          code: '''
ProfilePageLayout(
  title: 'My Profile',
  child: ListView(children: [...]),
)''',
        ),
      ],
    );
  }

  Widget _spacerRow(BuildContext context, String label, Widget spacer) {
    final color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Container(color: color, child: spacer),
        const SizedBox(height: 8),
      ],
    );
  }
}
