import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'actions.dart';
import 'config.dart';
import 'default_screen.dart';
import 'dismissal_store.dart';
import 'in_app_update_helper.dart';
import 'policy.dart';
import 'service.dart';

/// Signature for building a custom force-update screen.
typedef ForceUpdateScreenBuilder =
    Widget Function(
      BuildContext context,
      ForceUpdatePolicy policy,
      ForceUpdateActions actions,
    );

/// Wraps any widget subtree and replaces it with a force-update screen
/// when a newer version is detected on the store.
///
/// Place at the root of your app, typically inside `MaterialApp.builder`:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => ForceUpdateGate(child: child!),
/// );
/// ```
///
/// While the version check is running, the [child] keeps rendering — the
/// gate never blocks initial paint. Once the policy resolves, if an
/// update is required the screen takes over.
class ForceUpdateGate extends StatefulWidget {
  const ForceUpdateGate({
    required this.child,
    this.config = const ForceUpdateConfig(),
    this.screenBuilder,
    this.service,
    this.dismissalStore,
    this.inAppUpdateHelper,
    super.key,
  });

  final Widget child;
  final ForceUpdateConfig config;
  final ForceUpdateScreenBuilder? screenBuilder;

  /// Optional override for the version-check service. Defaults to
  /// [ForceUpdateService] using the gate's [config]. Useful for tests.
  final ForceUpdateService? service;

  /// Optional override for the dismissal persistence layer. Defaults to
  /// a [DismissalStore] backed by `shared_preferences`.
  final DismissalStore? dismissalStore;

  /// Optional override for the Android in-app update helper. Defaults to
  /// the real implementation.
  final InAppUpdateHelper? inAppUpdateHelper;

  @override
  State<ForceUpdateGate> createState() => _ForceUpdateGateState();
}

class _ForceUpdateGateState extends State<ForceUpdateGate>
    with WidgetsBindingObserver {
  ForceUpdatePolicy? _policy;
  bool _sessionDismissed = false;
  bool _persistedDismissed = false;
  bool _notifiedRequired = false;
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
    _evaluatePolicy();
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
      _evaluatePolicy();
    }
  }

  Future<void> _evaluatePolicy() async {
    final policy = await _service.resolvePolicy();
    if (!mounted) return;

    final dismissedByStore = await _store.isDismissed(
      mode: widget.config.skipMode,
      storeVersion: policy.latestVersion,
    );

    if (!mounted) return;
    setState(() {
      _policy = policy;
      _persistedDismissed = dismissedByStore;
    });

    if (policy.updateRequired && !_notifiedRequired) {
      _notifiedRequired = true;
      widget.config.onUpdateRequired?.call(policy);
    }
  }

  Future<void> _openStore() async {
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

  Future<bool> _completeFlexible() async {
    return _inAppUpdate.completeFlexible(
      debugLogging: widget.config.debugLogging,
    );
  }

  Future<void> _dismiss() async {
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
    final isDismissed = _sessionDismissed || _persistedDismissed;
    final shouldShow =
        !isDismissed && policy != null && policy.updateRequired;

    if (!shouldShow) {
      return widget.child;
    }

    final actions = ForceUpdateActions(
      openStore: _openStore,
      dismiss: widget.config.allowLater ? _dismiss : null,
      completeFlexibleUpdate: _completeFlexible,
    );

    final builder = widget.screenBuilder;
    if (builder != null) {
      return builder(context, policy, actions);
    }

    return DefaultForceUpdateScreen(
      policy: policy,
      actions: actions,
      labels: widget.config.labels,
      skipMode: widget.config.skipMode,
      showReleaseNotes: widget.config.includeReleaseNotes,
    );
  }
}
