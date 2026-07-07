import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart';
import 'in_app_update_helper.dart';
import 'service.dart';

/// Imperative API: runs the version check and shows a Material
/// `AlertDialog` if an update is required. Returns `true` when the
/// dialog was shown.
///
/// Suitable for apps that want to gate at a specific point (e.g. after
/// login) instead of wrapping the whole subtree.
///
/// ```dart
/// ElevatedButton(
///   onPressed: () => showForceUpdateDialog(context: context),
///   child: const Text('Check for updates'),
/// )
/// ```
Future<bool> showForceUpdateDialog({
  required BuildContext context,
  ForceUpdateConfig config = const ForceUpdateConfig(),
  ForceUpdateService? service,
  InAppUpdateHelper? inAppUpdateHelper,
  bool barrierDismissible = false,
}) async {
  final resolved = service ?? ForceUpdateService(config: config);
  final inApp = inAppUpdateHelper ?? const InAppUpdateHelper();
  final policy = await resolved.resolvePolicy();

  if (!policy.updateRequired) return false;
  if (!context.mounted) return false;

  config.onUpdateRequired?.call(policy);

  final labels = config.labels;
  final latest = policy.latestVersion?.trim();
  final versionText =
      (latest != null && latest.isNotEmpty)
          ? (labels.versionPrefix != null
              ? '${labels.versionPrefix} $latest'
              : 'v$latest')
          : null;
  final dismissLabel =
      config.skipMode == ForceUpdateSkipMode.version
          ? labels.skipVersionButton
          : labels.laterButton;

  await showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible && config.allowLater,
    builder: (context) {
      return AlertDialog(
        title: Text(labels.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(labels.message),
            if (versionText != null) ...[
              const SizedBox(height: 12),
              Text(
                versionText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (config.includeReleaseNotes &&
                policy.releaseNotes != null &&
                policy.releaseNotes!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                labels.releaseNotesTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                policy.releaseNotes!.trim(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          if (config.allowLater)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                config.onUpdateDismissed?.call(policy);
              },
              child: Text(dismissLabel),
            ),
          FilledButton(
            onPressed: () async {
              config.onStoreOpened?.call(policy);
              final result = await inApp.start(
                mode: config.androidInAppUpdateMode,
                debugLogging: config.debugLogging,
              );
              if (result != InAppUpdateResult.started &&
                  policy.storeUrl.isNotEmpty) {
                final uri = Uri.tryParse(policy.storeUrl);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(labels.updateButton),
          ),
        ],
      );
    },
  );

  return true;
}
