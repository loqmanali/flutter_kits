import 'package:flutter/widgets.dart';

import '../utils/widget_kit_localization.dart';

/// App-level, non-styling configuration for `widget_kit`.
///
/// Styling lives in [WidgetKitTheme] (a `ThemeExtension`). Everything else the
/// three other customization axes cover — default behavior, whole-widget
/// injection ("interface"), and strings — lives here and is carried down the
/// tree by [WidgetKitScope].
///
/// Every field is optional; an absent [WidgetKitScope] resolves to
/// `const WidgetKitConfig()`, which reproduces widget_kit's built-in behavior
/// exactly. Read the resolution order in the package README.
class WidgetKitConfig {
  const WidgetKitConfig({
    this.behavior = const WidgetKitBehavior(),
    this.builders = const WidgetKitBuilders(),
    this.strings = WidgetKitStrings.fallback,
  });

  /// Default behavior overrides (safe-area, navigator, durations…).
  final WidgetKitBehavior behavior;

  /// Whole-widget injection points ("interface"): loading, empty, error…
  final WidgetKitBuilders builders;

  /// App-wide string overrides (falls back to English defaults).
  final WidgetKitStrings strings;
}

/// Behavioral defaults applied when a widget/call-site leaves a param unset.
///
/// Fields are nullable — `null` means "unset, use widget_kit's built-in
/// default". Resolve as `param ?? behavior.field ?? builtInDefault`.
class WidgetKitBehavior {
  const WidgetKitBehavior({
    this.bottomSheetUseSafeArea,
    this.bottomSheetIsDismissible,
    this.useRootNavigator,
    this.dialogBarrierDismissible,
  });

  /// Default for `UIHelper.showBottomSheet(useSafeArea:)`. Built-in: `false`.
  final bool? bottomSheetUseSafeArea;

  /// Default for `UIHelper.showBottomSheet(isDismissible:)`. Built-in: `true`.
  final bool? bottomSheetIsDismissible;

  /// Default for sheet/dialog `useRootNavigator`. Built-in: `true` for sheets.
  final bool? useRootNavigator;

  /// Default for dialog `barrierDismissible`. Built-in: `true`.
  final bool? dialogBarrierDismissible;
}

/// Data passed to a consumer-supplied [WidgetKitBuilders.emptyStateBuilder].
///
/// Mirrors `EmptyStateWidget`'s inputs so a custom builder has everything the
/// built-in widget would.
class EmptyStateData {
  const EmptyStateData({
    required this.title,
    required this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.height,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double? height;
}

/// Data passed to a consumer-supplied [WidgetKitBuilders.errorStateBuilder].
///
/// Mirrors `ErrorStateWidget`'s inputs.
class ErrorStateData {
  const ErrorStateData({
    required this.message,
    required this.onRetry,
    this.title,
    this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String? title;
  final String? retryLabel;
}

/// Whole-widget injection points — the "interface" a consuming app implements
/// to swap out a built-in widget for its own, app-wide.
///
/// A `null` builder means "use widget_kit's built-in widget". Add a new slot by
/// declaring another nullable builder here and resolving it at the widget's
/// build site (see EXTENDING.md).
class WidgetKitBuilders {
  const WidgetKitBuilders({
    this.loadingBuilder,
    this.emptyStateBuilder,
    this.errorStateBuilder,
  });

  /// Replaces `LoadingIndicator`'s content when set.
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Replaces `EmptyStateWidget` when set.
  final Widget Function(BuildContext context, EmptyStateData data)?
      emptyStateBuilder;

  /// Replaces `ErrorStateWidget` when set.
  final Widget Function(BuildContext context, ErrorStateData data)?
      errorStateBuilder;
}

/// Carries a [WidgetKitConfig] down the tree.
///
/// Mount once near the app root (e.g. in `MaterialApp.builder`). Widgets read
/// it via [WidgetKitScope.of]; when it is absent they get a const fallback
/// equal to widget_kit's built-in behavior, so it is always safe to omit.
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => WidgetKitScope(
///     config: WidgetKitConfig(
///       behavior: const WidgetKitBehavior(bottomSheetUseSafeArea: true),
///       builders: WidgetKitBuilders(loadingBuilder: (ctx) => MySpinner()),
///     ),
///     child: child!,
///   ),
/// );
/// ```
class WidgetKitScope extends InheritedWidget {
  const WidgetKitScope({
    required this.config,
    required super.child,
    super.key,
  });

  final WidgetKitConfig config;

  /// The nearest config, or a built-in-defaults fallback when no scope is
  /// mounted — so callers never have to null-check.
  static WidgetKitConfig of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<WidgetKitScope>();
    return scope?.config ?? const WidgetKitConfig();
  }

  // ponytail: identity compare. The scope is meant to sit at the app root with
  // a stable (const/hoisted) config, so a new instance == a real change. If you
  // rebuild it every frame with a fresh config, dependents rebuild — hoist it.
  @override
  bool updateShouldNotify(WidgetKitScope oldWidget) =>
      !identical(config, oldWidget.config);
}
