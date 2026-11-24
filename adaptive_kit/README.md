# adaptive_kit

Unified phone/tablet/desktop layout kit. Depends only on Flutter, so it can be
reused across apps. It ships **two complementary APIs** on one kit — use
whichever reads better at each call site.

## API 1 — Singleton + widgets (context-free reads)

```dart
// 1. Feed the singleton once, at the app root:
MaterialApp(builder: (context, child) => AdaptiveBuilder(child: child!))

// 2. Read anywhere (no BuildContext needed):
Adaptive.i.isTablet / isPhone / isDesktop / shouldUseTabletLayout
final cols = Adaptive.i.value(mobile: 2, tablet: 4, desktop: 6);

// 3. Branch bodies with widgets:
AdaptiveLayout(mobile: HomeMobile(), tablet: HomeTablet())
```

Breakpoints (shortest side): phone `< 600`, tablet `< 900`, else desktop.
Override with `Adaptive.i.configure(phoneBreakpoint: …, tabletBreakpoint: …)`.

## API 2 — Context-based (no root wiring)

```dart
context.isMobile / isTablet / isDesktop
context.displaySize                       // DisplaySize.mobile | .tablet | .desktop
context.responsivePadding                 // 16 → 24 → 32
context.responsiveColumns()               // 1 → 2 → 3
context.responsiveValue(mobile: a, tablet: b, desktop: c);

// Builder-based body picker (tablet→mobile, desktop→tablet fallback):
ResponsiveLayout(
  mobile: (context) => const HomeMobile(),
  tablet: (context) => const HomeTablet(),
)

ResponsiveBuilder(builder: (context, size, constraints) => ...)
ResponsiveContent(child: form)            // constrains wide content
ResponsiveGrid(children: cards)           // auto column counts
ResponsiveVisibility(visibleOnMobile: false, child: sidebar)
```

Breakpoints (width): mobile `< 600`, tablet `600–1024`, desktop `≥ 1024`
(`ResponsiveBreakpoints`).

## Which one?

Both express the same idea (branch once, keep shared logic in one place, let
bodies be layout-only). `Adaptive.i` reads outside the widget tree
(notifiers, helpers); the `context.*` helpers avoid root wiring. `AdaptiveLayout`
takes ready widgets; `ResponsiveLayout` takes builder callbacks. Pick per call
site — they never fight.
