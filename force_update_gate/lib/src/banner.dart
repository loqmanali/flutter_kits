import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart';
import 'dismissal_store.dart';
import 'in_app_update_helper.dart';
import 'policy.dart';
import 'service.dart';

/// Non-modal banner version of [ForceUpdateGate].
///
/// Wraps a child and renders a Material banner at the top of the screen
/// when an update is detected. Use this for soft-upgrade nudges where
/// you don't want to block the app entirely.
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => ForceUpdateBanner(child: child!),
/// )
/// ```
class ForceUpdateBanner extends StatefulWidget {
  const ForceUpdateBanner({
    required this.child,
    this.config = const ForceUpdateConfig(allowLater: true),
    this.service,
    this.dismissalStore,
    this.inAppUpdateHelper,
    super.key,
  });

  final Widget child;
  final ForceUpdateConfig config;
  final ForceUpdateService? service;
  final DismissalStore? dismissalStore;
  final InAppUpdateHelper? inAppUpdateHelper;

  @override
  State<ForceUpdateBanner> createState() => _ForceUpdateBannerState();
}

class _ForceUpdateBannerState extends State<ForceUpdateBanner>
    with WidgetsBindingObserver {
  ForceUpdatePolicy? _policy;
  bool _sessionDismissed = false;
  bool _persistedDismissed = false;
  late final DismissalStore _store;
  late final InAppUpdateHelper _inAppUpdate;

  ForceUpdateService get _service =>
      widget.service ?? ForceUpdateService(config: widget.config);

  @override
  void initState() {
    super.initState();
    _store = widget.dismissalStore ?? DismissalStore();
    _inAppUpdate = widget.inAppUpdateHelper ?? const InAppUpdateHelper();
    if (widget.config.recheckOnForeground) {
      WidgetsBinding.instance.addObserver(this);
    }
    _evaluate();
  }

  @override
  void dispose() {
    if (widget.config.recheckOnForeground) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _evaluate();
    }
  }

  Future<void> _evaluate() async {
    final policy = await _service.resolvePolicy();
    if (!mounted) return;
    final dismissed = await _store.isDismissed(
      mode: widget.config.skipMode,
      storeVersion: policy.latestVersion,
    );
    if (!mounted) return;
    setState(() {
      _policy = policy;
      _persistedDismissed = dismissed;
    });
  }

  Future<void> _onUpdate() async {
    final policy = _policy;
    if (policy == null) return;
    widget.config.onStoreOpened?.call(policy);
    final inAppResult = await _inAppUpdate.start(
      mode: widget.config.androidInAppUpdateMode,
      debugLogging: widget.config.debugLogging,
    );
    if (inAppResult == InAppUpdateResult.started) return;
    if (policy.storeUrl.isEmpty) return;
    final uri = Uri.tryParse(policy.storeUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _onDismiss() async {
    final policy = _policy;
    if (policy == null) return;
    await _store.recordDismissal(
      mode: widget.config.skipMode,
      cooldown: widget.config.laterCooldown,
      storeVersion: policy.latestVersion,
    );
    if (!mounted) return;
    setState(() => _sessionDismissed = true);
    widget.config.onUpdateDismissed?.call(policy);
  }

  @override
  Widget build(BuildContext context) {
    final policy = _policy;
    final dismissed = _sessionDismissed || _persistedDismissed;
    final shouldShow =
        !dismissed && policy != null && policy.updateRequired;

    if (!shouldShow) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final dismissLabel =
        widget.config.skipMode == ForceUpdateSkipMode.version
            ? widget.config.labels.skipVersionButton
            : widget.config.labels.laterButton;

    return Column(
      children: [
        Material(
          color: theme.colorScheme.primaryContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.system_update,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.config.labels.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _onUpdate,
                    child: Text(widget.config.labels.updateButton),
                  ),
                  if (widget.config.allowLater)
                    IconButton(
                      tooltip: dismissLabel,
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      onPressed: _onDismiss,
                    ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
