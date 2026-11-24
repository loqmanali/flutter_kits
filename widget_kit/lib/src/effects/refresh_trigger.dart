/// Pull-to-refresh and pull-to-load-more for any scrollable.
///
/// Layered like the rest of the kit — models, theme, controller and widgets are
/// separate files under `refresh_trigger/src/`; this barrel is the only import
/// consumers need.
///
/// ```dart
/// RefreshTriggerThemeProvider(
///   data: const RefreshTriggerTheme(
///     minExtent: 80,
///     displayMode: RefreshTriggerDisplayMode.inset,
///   ),
///   child: RefreshTrigger(
///     controller: controller,
///     onRefresh: () async => fetchFirstPage(),
///     enableLoadMore: true,
///     onLoadMore: () async {
///       final hasMore = await fetchNextPage();
///       if (!hasMore) controller.finishLoadMore(noMoreData: true);
///     },
///     footerBuilder: (context, stage) => ClassicFooter(stage: stage),
///     child: ListView.builder(itemBuilder: ...),
///   ),
/// )
/// ```
library;

export 'refresh_trigger/src/controller/refresh_trigger_controller.dart';
export 'refresh_trigger/src/models/refresh_trigger_stage.dart';
export 'refresh_trigger/src/painters/animated_check_painter.dart';
export 'refresh_trigger/src/painters/bezier_painter.dart';
export 'refresh_trigger/src/physics/refresh_trigger_physics.dart';
export 'refresh_trigger/src/theme/refresh_trigger_theme.dart';
export 'refresh_trigger/src/widgets/indicators/app_pill_refresh_indicator.dart';
export 'refresh_trigger/src/widgets/indicators/bezier_header.dart';
export 'refresh_trigger/src/widgets/indicators/classic_footer.dart';
export 'refresh_trigger/src/widgets/indicators/classic_header.dart';
export 'refresh_trigger/src/widgets/indicators/default_refresh_indicator.dart';
export 'refresh_trigger/src/widgets/indicators/material_header.dart';
export 'refresh_trigger/src/widgets/indicators/water_drop_header.dart';
export 'refresh_trigger/src/widgets/refresh_trigger.dart';
export 'refresh_trigger/src/widgets/refresh_trigger_layout.dart';
