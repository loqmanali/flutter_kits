import '../exceptions/api_exception.dart';
import '../failures/failure.dart';

/// Maps exceptions to failures for repositories / use-cases.
class ErrorMapper {
  static Failure mapExceptionToFailure(Exception exception) {
    if (exception is ApiException) {
      return _mapApiExceptionToFailure(exception);
    }
    return UnexpectedFailure(message: exception.toString());
  }

  static Failure _mapApiExceptionToFailure(ApiException exception) {
    final message = exception.message;

    if (exception is ServerException ||
        exception is InternalServerErrorException) {
      return ServerFailure(message: message);
    } else if (exception is CacheException) {
      return CacheFailure(message: message);
    } else if (exception is NoInternetConnectionException) {
      return NetworkFailure(message: message);
    } else if (exception is AuthException ||
        exception is UnauthorizedException) {
      return AuthFailure(message: message);
    } else if (exception is ValidationException) {
      return ValidationFailure(
        message: message,
        fieldErrors: exception.fieldErrors,
      );
    } else if (exception is NotFoundException) {
      return NotFoundFailure(message: message);
    } else if (exception is TimeoutException) {
      return TimeoutFailure(message: message);
    } else if (exception is AppUpdateRequiredException) {
      return AppUpdateRequiredFailure(
        message: message,
        minVersion: exception.minVersion,
        storeUrl: exception.storeUrl,
      );
    }

    return UnexpectedFailure(message: message);
  }

  static String getErrorMessage(Failure failure) => failure.message;
}
