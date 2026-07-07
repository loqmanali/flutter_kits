import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import 'actions.dart';
import 'config.dart';
import 'labels.dart';
import 'policy.dart';

/// Cupertino-styled force-update screen.
///
/// Wire it up via `ForceUpdateGate.screenBuilder`:
///
/// ```dart
/// ForceUpdateGate(
///   screenBuilder: (context, policy, actions) =>
///       CupertinoForceUpdateScreen(policy: policy, actions: actions),
///   child: child!,
/// )
/// ```
class CupertinoForceUpdateScreen extends StatelessWidget {
  const CupertinoForceUpdateScreen({
    required this.policy,
    required this.actions,
    this.labels = const ForceUpdateLabels(),
    this.skipMode = ForceUpdateSkipMode.session,
    this.showReleaseNotes = false,
    this.logo,
    this.icon,
    super.key,
  });

  final ForceUpdatePolicy policy;
  final ForceUpdateActions actions;
  final ForceUpdateLabels labels;
  final ForceUpdateSkipMode skipMode;
  final bool showReleaseNotes;
  final Widget? logo;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
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
      child: CupertinoPageScaffold(
        child: SafeArea(
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
                      child: Icon(
                        icon ?? CupertinoIcons.cloud_download,
                        size: 56,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      labels.title,
                      style: theme.textTheme.navLargeTitleTextStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      labels.message,
                      style: theme.textTheme.textStyle,
                      textAlign: TextAlign.center,
                    ),
                    if (versionText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        versionText,
                        style: theme.textTheme.tabLabelTextStyle,
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
                          style: theme.textTheme.navTitleTextStyle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        releaseNotes,
                        style: theme.textTheme.textStyle,
                      ),
                    ],
                    const SizedBox(height: 32),
                    CupertinoButton.filled(
                      onPressed: () => actions.openStore(),
                      child: Text(labels.updateButton),
                    ),
                    if (canDismiss) ...[
                      const SizedBox(height: 8),
                      CupertinoButton(
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

/// Sentinel so consumers don't need to import `cupertino.dart`.
const IconData defaultCupertinoUpdateIcon = CupertinoIcons.cloud_download;

/// Re-export of Material's `Icons.system_update` for parity.
const IconData defaultMaterialUpdateIcon = Icons.system_update;
