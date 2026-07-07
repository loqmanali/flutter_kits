import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../adapters/notification_kit_runtime.dart';
import '../domain/entities/notification_payload.dart';
import '../domain/usecases/process_deep_link_usecase.dart';

class DeepLinkNotificationService {
  final ProcessDeepLinkUseCase _processDeepLinkUseCase;

  DeepLinkNotificationService(this._processDeepLinkUseCase);

  Future<void> handleDeepLink(BuildContext context, NotificationPayload payload) async {
    final result = await _processDeepLinkUseCase(payload);

    result.fold(
      (failure) {
        NotificationKitRuntime.logger.warning(
          '[DeepLinkNotificationService] Failed to process deep link: ${failure.message}',
        );
      },
      (route) {
        if (route.isNotEmpty) {
          try {
            GoRouter.of(context).push(route);
          } catch (e, stackTrace) {
            NotificationKitRuntime.logger.error(
              '[DeepLinkNotificationService] Failed to navigate to route: $route',
              e,
              stackTrace,
            );
          }
        }
      },
    );
  }
}
