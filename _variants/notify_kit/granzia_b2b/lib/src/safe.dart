import 'package:flutter/foundation.dart';

import 'models.dart';

/// Invokes a user-supplied callback; a throwing handler must never kill
/// a stream subscription (spec §8). Errors are always logged and, when
/// [onError] is provided, forwarded to it (e.g. Crashlytics/Sentry).
void runSafely(
  String context,
  void Function() fn, {
  NotifyErrorHandler? onError,
}) {
  try {
    fn();
  } catch (error, stack) {
    debugPrint('notify_kit: $context handler threw: $error\n$stack');
    if (onError != null) {
      try {
        onError(context, error, stack);
      } catch (handlerError) {
        debugPrint('notify_kit: onError handler itself threw: $handlerError');
      }
    }
  }
}
