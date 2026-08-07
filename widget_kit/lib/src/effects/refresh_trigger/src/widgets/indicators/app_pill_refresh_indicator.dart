import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/refresh_trigger_stage.dart';
import '../../theme/refresh_trigger_theme.dart';

/// A compact pill-style refresh indicator — flat (no shadow), localised
/// strings, rotating arrow on pull, spinner on refresh, checkmark on done.
///
/// Use as: `RefreshTrigger(indicatorBuilder: AppPillRefreshIndicator.builder, ...)`
class AppPillRefreshIndicator {
  const AppPillRefreshIndicator._();

  /// Plug straight into `RefreshTrigger.indicatorBuilder` (or `footerBuilder`).
  static Widget builder(BuildContext context, RefreshTriggerStage stage) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final primary = scheme.primary;
    // The semantic token for secondary copy — unlike `onSurface` at 60% it is
    // guaranteed to clear the contrast floor in both light and dark schemes.
    final muted = scheme.onSurfaceVariant;

    // Theme copy wins when supplied; the Arabic strings are only fallbacks so
    // an app that never configures the theme keeps working unchanged.
    final triggerTheme = RefreshTriggerThemeProvider.of(context);
    final pullText = triggerTheme?.pullText ?? 'اسحب للأسفل للتحديث';
    final releaseText = triggerTheme?.releaseText ?? 'اترك للتحديث';
    final refreshingText = triggerTheme?.refreshingText ?? 'جاري التحديث…';
    final completedText = triggerTheme?.completedText ?? 'تم التحديث';
    final failedText = triggerTheme?.failedText ?? 'فشل التحديث';
    final noMoreDataText = triggerTheme?.noMoreDataText ?? 'لا يوجد المزيد';

    String label;
    Widget? trailing;
    switch (stage.stage) {
      case TriggerStage.idle:
        label = !stage.isHeader && stage.noMoreData ? noMoreDataText : pullText;
        break;
      case TriggerStage.pulling:
        label = stage.extentValue >= 1 ? releaseText : pullText;
        trailing = AnimatedBuilder(
          animation: stage.extent,
          builder: (_, __) => Transform.rotate(
            angle: -math.pi * stage.extentValue.clamp(0.0, 1.0),
            child: Icon(
              stage.isHeader ? Icons.arrow_downward : Icons.arrow_upward,
              size: 14,
              color: muted,
            ),
          ),
        );
        break;
      case TriggerStage.refreshing:
        label = refreshingText;
        trailing = SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 1.8, color: primary),
        );
        break;
      case TriggerStage.completed:
        label = completedText;
        trailing = Icon(Icons.check, size: 16, color: primary);
        break;
      case TriggerStage.failed:
        label = failedText;
        trailing = Icon(Icons.error_outline, size: 16, color: scheme.error);
        break;
    }

    return Center(
      child: Container(
        // The pill slides in from whichever edge it belongs to, so the gap
        // goes on that side.
        margin: stage.isHeader
            ? const EdgeInsets.only(top: 8)
            : const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              // A type-scale role rather than a hardcoded size, so the label
              // grows with the system text size.
              style: theme.textTheme.labelMedium?.copyWith(color: muted),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              trailing,
            ],
          ],
        ),
      ),
    );
  }
}
