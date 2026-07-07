import 'package:flutter/material.dart';

import 'actions.dart';
import 'config.dart';
import 'labels.dart';
import 'policy.dart';

/// Default Material screen rendered by the gate when no custom
/// `screenBuilder` is provided.
///
/// Designed to be unopinionated about branding — colors come from the
/// ambient `Theme`, and consumers can pass a `logo` widget for their
/// company mark. For deeper customisation, supply a `screenBuilder` to
/// `ForceUpdateGate` and ignore this widget entirely.
class DefaultForceUpdateScreen extends StatelessWidget {
  const DefaultForceUpdateScreen({
    required this.policy,
    required this.actions,
    this.labels = const ForceUpdateLabels(),
    this.skipMode = ForceUpdateSkipMode.session,
    this.showReleaseNotes = false,
    this.logo,
    this.icon = Icons.system_update,
    super.key,
  });

  final ForceUpdatePolicy policy;
  final ForceUpdateActions actions;
  final ForceUpdateLabels labels;
  final ForceUpdateSkipMode skipMode;
  final bool showReleaseNotes;
  final Widget? logo;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latestVersion = policy.latestVersion?.trim();
    final canDismiss = actions.dismiss != null;
    final dismissLabel =
        skipMode == ForceUpdateSkipMode.version
            ? labels.skipVersionButton
            : labels.laterButton;
    final versionText =
        (latestVersion != null && latestVersion.isNotEmpty)
            ? (labels.versionPrefix != null
                ? '${labels.versionPrefix} $latestVersion'
                : 'v$latestVersion')
            : null;
    final releaseNotes = policy.releaseNotes?.trim();

    return PopScope(
      canPop: canDismiss,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (logo != null) ...[
                      Center(child: logo!),
                      const SizedBox(height: 32),
                    ],
                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 42,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      labels.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      labels.message,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    if (versionText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        versionText,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (showReleaseNotes &&
                        releaseNotes != null &&
                        releaseNotes.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          labels.releaseNotesTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          releaseNotes,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: () => actions.openStore(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(labels.updateButton),
                      ),
                    ),
                    if (canDismiss) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: actions.dismiss,
                        child: Text(dismissLabel),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
