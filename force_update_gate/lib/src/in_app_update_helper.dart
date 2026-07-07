import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

import 'config.dart';

/// Result returned by [InAppUpdateHelper.start].
enum InAppUpdateResult {
  /// Either we're not on Android, no update was advertised by Play, or
  /// the package is not configured. The caller should fall back to
  /// launching the store URL.
  notHandled,

  /// Play accepted the request; the user is now in Google's update
  /// flow.
  started,

  /// We tried to start the flow but Play rejected it.
  failed,
}

/// Thin wrapper around the [in_app_update] package. Hides the Android-
/// only-ness and the various failure modes from the gate widget.
class InAppUpdateHelper {
  const InAppUpdateHelper();

  Future<InAppUpdateResult> start({
    required AndroidInAppUpdateMode? mode,
    bool debugLogging = false,
  }) async {
    if (mode == null || !Platform.isAndroid) {
      return InAppUpdateResult.notHandled;
    }

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return InAppUpdateResult.notHandled;
      }

      switch (mode) {
        case AndroidInAppUpdateMode.immediate:
          if (info.immediateUpdateAllowed) {
            await InAppUpdate.performImmediateUpdate();
            return InAppUpdateResult.started;
          }
          break;
        case AndroidInAppUpdateMode.flexible:
          if (info.flexibleUpdateAllowed) {
            await InAppUpdate.startFlexibleUpdate();
            return InAppUpdateResult.started;
          }
          break;
      }
      return InAppUpdateResult.notHandled;
    } catch (error, stackTrace) {
      if (debugLogging) {
        debugPrint(
          '[ForceUpdateGate] in-app update failed: $error\n$stackTrace',
        );
      }
      return InAppUpdateResult.failed;
    }
  }

  Future<bool> completeFlexible({bool debugLogging = false}) async {
    if (!Platform.isAndroid) return false;
    try {
      await InAppUpdate.completeFlexibleUpdate();
      return true;
    } catch (error, stackTrace) {
      if (debugLogging) {
        debugPrint(
          '[ForceUpdateGate] completeFlexibleUpdate failed: $error\n$stackTrace',
        );
      }
      return false;
    }
  }
}
