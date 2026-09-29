import 'package:flutter/material.dart';

import '../domain/toast_tone.dart';
import 'toast_kit_theme.dart';
import 'toast_layout.dart';

/// The shared paint job every built-in [ToastLayout] assembles from: an
/// icon, title/message, an optional action and close button, and an
/// optional progress line driven by [ToastView.progress].
///
/// Each layout passes its own [backgroundColor]/[foregroundColor]/
/// [iconColor]/[borderSide] — `flat`'s light tint, `filled`'s solid accent,
/// `outlined`'s bare border, and so on — so this widget stays the one place
/// that lays the pieces out.
class ToastCard extends StatelessWidget {
  const ToastCard({
    super.key,
    required this.view,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.iconColor,
    this.borderSide = BorderSide.none,
    this.elevation,
    this.showProgressBar = true,
    this.fullWidth = false,
  });

  final ToastView view;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color iconColor;
  final BorderSide borderSide;
  final double? elevation;
  final bool showProgressBar;

  /// `true` for [BannerToastLayout]: no `maxWidth` cap, square corners.
  final bool fullWidth;

  static IconData _iconFor(ToastTone tone) => switch (tone) {
        ToastTone.success => Icons.check_circle,
        ToastTone.error => Icons.error,
        ToastTone.warning => Icons.warning_amber_rounded,
        ToastTone.info => Icons.info,
        ToastTone.neutral => Icons.notifications,
      };

  @override
  Widget build(BuildContext context) {
    final theme = ToastKitTheme.of(context);
    final radius = fullWidth ? 0.0 : (theme.borderRadius ?? 12);
    final request = view.request;

    final semanticsLabel = view.request.semanticsLabel ??
        '${request.title}${request.message != null ? '. ${request.message}' : ''}';

    Widget card = Material(
      type: MaterialType.card,
      color: backgroundColor,
      elevation: elevation ?? theme.elevation ?? 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: borderSide,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: theme.padding ?? const EdgeInsetsDirectional.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconFor(view.tone), color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    request.title,
                    maxLines: view.maxTitleLines,
                    overflow: TextOverflow.ellipsis,
                    style: view.titleStyle.copyWith(color: foregroundColor),
                  ),
                  if (request.message != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      request.message!,
                      maxLines: view.maxMessageLines,
                      overflow: TextOverflow.ellipsis,
                      style: view.messageStyle.copyWith(
                        color: foregroundColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                  if (view.action != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: view.onAction,
                        style: TextButton.styleFrom(
                            foregroundColor: foregroundColor),
                        child: Text(view.action!.label),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (view.showCloseButton)
              IconButton(
                icon: Icon(Icons.close, color: foregroundColor, size: 18),
                onPressed: view.onClose,
                tooltip: view.strings.closeButtonSemanticLabel,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
      ),
    );

    if (showProgressBar) {
      card = Stack(
        children: [
          card,
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: view.progress,
              builder: (context, _) => ClipRRect(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(radius)),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: view.progress.value.clamp(0.0, 1.0),
                  child: Container(height: 3, color: iconColor),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      liveRegion: true,
      label: '${view.strings.liveRegionPrefix}: $semanticsLabel',
      child: fullWidth
          ? card
          : ConstrainedBox(
              constraints: BoxConstraints(maxWidth: theme.maxWidth ?? 480),
              child: card,
            ),
    );
  }
}
