import 'package:equatable/equatable.dart';

/// Base exception class for API and application errors.
class ApiException extends Equatable implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    final code = statusCode;
    if (code == null) return message;
    return '$message (Code: $code)';
  }

  @override
  List<Object?> get props => [message, statusCode];
}

class AuthException extends ApiException {
  const AuthException([String? message])
      : super(message ?? 'Authentication error occurred');
}

class ServerException extends ApiException {
  const ServerException([String? message])
      : super(message ?? 'Server error occurred');
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([String? message])
      : super(message ?? 'Unauthorized access', statusCode: 401);
}

class NotFoundException extends ApiException {
  const NotFoundException([String? message])
      : super(message ?? 'Resource not found', statusCode: 404);
}

class ConflictException extends ApiException {
  const ConflictException([String? message])
      : super(message ?? 'Conflict occurred', statusCode: 409);
}

class InternalServerErrorException extends ApiException {
  const InternalServerErrorException([String? message])
      : super(message ?? 'Internal server error occurred', statusCode: 500);
}

class NoInternetConnectionException extends ApiException {
  const NoInternetConnectionException([String? message])
      : super(message ?? 'No internet connection');
}

class CacheException extends ApiException {
  const CacheException([String? message])
      : super(message ?? 'Cache error occurred');
}

class FormatErrorException extends ApiException {
  const FormatErrorException([String? message])
      : super(message ?? 'Format error occurred');
}

class ValidationException extends ApiException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    String? message,
    this.fieldErrors,
  }) : super(message ?? 'Validation error occurred');

  @override
  List<Object?> get props => [message, statusCode, fieldErrors];
}

class TimeoutException extends ApiException {
  const TimeoutException([String? message])
      : super(message ?? 'Request timeout');
}

class CancellationException extends ApiException {
  const CancellationException([String? message])
      : super(message ?? 'Request cancelled');
}

class BadRequestException extends ApiException {
  const BadRequestException([String? message])
      : super(message ?? 'Bad request', statusCode: 400);
}

class ForbiddenException extends ApiException {
  const ForbiddenException([String? message])
      : super(message ?? 'Forbidden', statusCode: 403);
}

class MethodNotAllowedException extends ApiException {
  const MethodNotAllowedException([String? message])
      : super(message ?? 'Method not allowed', statusCode: 405);
}

class NotAcceptableException extends ApiException {
  const NotAcceptableException([String? message])
      : super(message ?? 'The request is not acceptable', statusCode: 406);
}

class NotImplementedException extends ApiException {
  const NotImplementedException([String? message])
      : super(message ?? 'Not implemented', statusCode: 501);
}

class ServiceUnavailableException extends ApiException {
  const ServiceUnavailableException([String? message])
      : super(message ?? 'Service unavailable', statusCode: 503);
}

class UnexpectedException extends ApiException {
  const UnexpectedException([String? message])
      : super(message ?? 'An unexpected error occurred');
}

class BadCertificateException extends ApiException {
  const BadCertificateException([String? message])
      : super(message ?? 'Bad certificate');
}

/// Thrown for 426 Upgrade Required — app version is below the server's
/// minimum supported version.
class AppUpdateRequiredException extends ApiException {
  final String? minVersion;
  final String? storeUrl;

  const AppUpdateRequiredException({
    String? message,
    this.minVersion,
    this.storeUrl,
  }) : super(
          message ?? 'Please update your app to the latest version.',
          statusCode: 426,
        );

  @override
  List<Object?> get props => [message, statusCode, minVersion, storeUrl];
}
