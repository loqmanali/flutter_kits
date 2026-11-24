// widget_kit gallery — a living catalogue that documents every widget in the
// package with a live, interactive demo, a short description, and copy-able code.
//
// Structure:
//   gallery/   shared scaffolding (DemoSection, CodeBlock, GalleryScaffold) +
//              the category registry (single source of truth for home + routing)
//   pages/     one page per widget category, each composed of DemoSections.
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
// ToastificationWrapper + WidgetKitTheme + every widget come from the barrel,
// which re-exports toastification.
import 'package:widget_kit/widget_kit.dart';

import 'gallery/categories.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The slot picker formats dates via intl; initialise locale data up-front.
  await initializeDateFormatting();
  runApp(const GalleryApp());
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ToastificationWrapper hosts UIHelper.showToast. WidgetKitTheme registers
    // the kit's design tokens.
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'widget_kit gallery',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFFDC1213),
          useMaterial3: true,
          extensions: const [
            WidgetKitTheme(inputBorderRadius: 12, buttonHeight: 52),
          ],
        ),
        home: const HomePage(),
      ),
    );
  }
}

/// The catalogue home: a card per widget category, driven by [galleryCategories].
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('widget_kit'),
            backgroundColor: theme.colorScheme.surface,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'A living catalogue of every widget in the kit. '
                'Tap a category to see live demos, descriptions, and code.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _CategoryCard(category: galleryCategories[i]),
                childCount: galleryCategories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});
  final GalleryCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => category.build())),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(category.icon, color: category.color, size: 22),
              ),
              const Spacer(),
              Text(
                category.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                category.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
