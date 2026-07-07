import 'package:dartz/dartz.dart';

import '../entities/notification_payload.dart';
import '../failures/notification_failures.dart';

class ProcessDeepLinkUseCase {
  Future<Either<NotificationFailure, String>> call(
    NotificationPayload payload,
  ) async {
    try {
      if (payload.route != null) {
        return Right(payload.route!);
      }

      switch (payload.type) {
        case DeepLinkType.product:
          if (payload.targetId != null) {
            return Right('/product/${payload.targetId}');
          }
          break;
        case DeepLinkType.category:
          if (payload.targetId != null) {
            return Right('/category/${payload.targetId}');
          }
          break;
        case DeepLinkType.order:
          if (payload.targetId != null) {
            return Right('/order/${payload.targetId}');
          }
          break;
        case DeepLinkType.promotion:
          if (payload.targetId != null) {
            return Right('/promotion/${payload.targetId}');
          }
          break;
        case DeepLinkType.profile:
          return const Right('/profile');
        case DeepLinkType.cart:
          return const Right('/cart');
        case DeepLinkType.checkout:
          return const Right('/checkout');
        case DeepLinkType.external:
          if (payload.externalUrl != null) {
            return Right(payload.externalUrl!);
          }
          break;
        case DeepLinkType.custom:
          break;
      }

      return const Right('/');
    } catch (e) {
      return Left(
        PayloadParsingFailure(message: e.toString(), originalError: e),
      );
    }
  }
}
