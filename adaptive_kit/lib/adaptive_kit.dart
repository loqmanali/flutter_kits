/// Unified phone/tablet/desktop layout kit — two complementary APIs.
///
/// **Singleton / widget-based** (context-free reads):
///  1. Wrap the app root once: `AdaptiveBuilder(child: ...)`.
///  2. Read anywhere: `Adaptive.i.isTablet`, `Adaptive.i.value(mobile: …)`.
///  3. Branch bodies: `AdaptiveLayout(mobile: Widget, tablet: Widget)`.
///
/// **Context-based** (no root wiring needed):
///  - Helpers on `BuildContext`: `context.isTablet`, `context.responsivePadding`…
///  - Layout widgets: `ResponsiveLayout(mobile: (ctx) => …)`, `ResponsiveGrid`,
///    `ResponsiveContent`, `ResponsiveBuilder`, `ResponsiveVisibility`.
///
/// Pick whichever reads better at each call site — both share this one kit.
library;

export 'src/adaptive.dart';
export 'src/adaptive_builder.dart';
export 'src/adaptive_layout.dart';
export 'src/responsive_breakpoints.dart';
export 'src/responsive_layout.dart';
