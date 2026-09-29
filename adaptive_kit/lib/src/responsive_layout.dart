import 'package:flutter/material.dart';

import 'package:adaptive_kit/src/responsive_breakpoints.dart';

typedef ResponsiveWidgetBuilder = Widget Function(BuildContext context);

/// {@template responsive_builder}
/// Listens to layout constraints and exposes both the resolved [DisplaySize]
/// and incoming [BoxConstraints] so screens can branch their UI efficiently.
///
/// This is the most flexible entry point when a single widget needs to render
/// different trees per breakpoint.
/// {@endtemplate}
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    DisplaySize size,
    BoxConstraints constraints,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => builder(
        context,
        context.displaySize,
        constraints,
      ),
    );
  }
}

/// {@template responsive_layout}
/// Declares a mobile/tablet/desktop triad and returns the appropriate builder
/// using the shared [ContextBreakpoints]. Only the chosen layout is built.
/// {@endtemplate}
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Builder used for <600 px widths.
  final ResponsiveWidgetBuilder mobile;

  /// Builder used for 600–1024 px widths. Falls back to [mobile].
  final ResponsiveWidgetBuilder? tablet;

  /// Builder used for ≥1024 px widths. Falls back to [tablet] then [mobile].
  final ResponsiveWidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    final DisplaySize size = context.displaySize;

    final ResponsiveWidgetBuilder resolvedBuilder;
    switch (size) {
      case DisplaySize.desktop:
        resolvedBuilder = desktop ?? tablet ?? mobile;
      case DisplaySize.tablet:
        resolvedBuilder = tablet ?? mobile;
      case DisplaySize.mobile:
        resolvedBuilder = mobile;
    }

    return resolvedBuilder(context);
  }
}

/// {@template responsive_content}
/// Constrains wide content to a readable max-width while keeping mobile layouts
/// full bleed. Helpful for forms and detail pages on desktop screens.
/// {@endtemplate}
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
    this.padding,
  });

  final Widget child;
  final Alignment alignment;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final double maxWidth = context.maxContentWidth;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

/// {@template responsive_grid}
/// A convenience grid that automatically chooses sensible column counts per
/// breakpoint. Great for cards, product tiles, or information panels.
/// {@endtemplate}
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.childAspectRatio = 1,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = context.responsiveColumns(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    final double spacing = context.responsiveSpacing(
      mobile: mainAxisSpacing,
      tablet: mainAxisSpacing + 4,
      desktop: mainAxisSpacing + 8,
    );

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding ?? context.responsivePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// {@template responsive_visibility}
/// Shows [child] only on the specified breakpoints. Use this to expose desktop
/// sidebars, tablet summary panels, or mobile-only floating buttons.
/// {@endtemplate}
class ResponsiveVisibility extends StatelessWidget {
  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOnMobile = true,
    this.visibleOnTablet = true,
    this.visibleOnDesktop = true,
    this.replacement = const SizedBox.shrink(),
  });

  final Widget child;
  final Widget replacement;
  final bool visibleOnMobile;
  final bool visibleOnTablet;
  final bool visibleOnDesktop;

  @override
  Widget build(BuildContext context) {
    final displaySize = context.displaySize;

    final bool isVisible = switch (displaySize) {
      DisplaySize.mobile => visibleOnMobile,
      DisplaySize.tablet => visibleOnTablet,
      DisplaySize.desktop => visibleOnDesktop,
    };

    return isVisible ? child : replacement;
  }
}

/// Extension helpers so any widget can define breakpoint-specific versions.
extension ResponsiveWidget on Widget {
  Widget responsive({
    Widget? tablet,
    Widget? desktop,
  }) {
    return ResponsiveLayout(
      mobile: (_) => this,
      tablet: tablet != null ? (_) => tablet : null,
      desktop: desktop != null ? (_) => desktop : null,
    );
  }
}
