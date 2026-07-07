/// Side-effect handler for 426 Upgrade Required responses.
///
/// Typical implementation pops a non-dismissible dialog driving the user to
/// the store. The package does not render UI itself.
abstract class ForceUpdateHandler {
  void showForceUpdateDialog({
    String? message,
    String? minVersion,
    required String currentVersion,
    String? storeUrl,
  });
}

/// No-op handler — useful as a default when force-update is not yet wired.
class NoopForceUpdateHandler implements ForceUpdateHandler {
  const NoopForceUpdateHandler();

  @override
  void showForceUpdateDialog({
    String? message,
    String? minVersion,
    required String currentVersion,
    String? storeUrl,
  }) {}
}
