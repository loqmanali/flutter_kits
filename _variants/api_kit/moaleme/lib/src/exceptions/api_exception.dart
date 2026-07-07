import 'package:equatable/equatable.dart';

/// Base exception class for API and application errors
class ApiException extends Equatable implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    final code = statusCode;
    if (code == null) {
      return message;
    }
    return '$message (Code: $code)';
  }

  @override
  List<Object?> get props => [message, statusCode];
}

/// Authentication related exception
class AuthException extends ApiException {
  const AuthException([String? message])
      : super(message ?? 'Authentication error occurred');
}

/// Server related exception.
///
/// Used for "other 5xx" responses (502, 504, 505, 507, 508, 511, …) that have
/// no dedicated subclass. Forwards [statusCode] to the base so the real code is
/// never lost (e.g. a 504 is reported as 504, not collapsed to null).
class ServerException extends ApiException {
  const ServerException([String? message, int? statusCode])
      : super(message ?? 'Server error occurred', statusCode: statusCode);
}

/// Unauthorized access exception
class UnauthorizedException extends ApiException {
  const UnauthorizedException([String? message])
      : super(message ?? 'Unauthorized access', statusCode: 401);
}

/// Resource not found exception
class NotFoundException extends ApiException {
  const NotFoundException([String? message])
      : super(message ?? 'Resource not found', statusCode: 404);
}

/// Conflict exception for duplicate resources
class ConflictException extends ApiException {
  const ConflictException([String? message])
      : super(message ?? 'Conflict occurred', statusCode: 409);
}

/// Internal server error exception
class InternalServerErrorException extends ApiException {
  const InternalServerErrorException([String? message])
      : super(message ?? 'Internal server error occurred', statusCode: 500);
}

/// No internet connection exception
class NoInternetConnectionException extends ApiException {
  const NoInternetConnectionException([String? message])
      : super(message ?? 'No internet connection');
}

/// Cache related exception
class CacheException extends ApiException {
  const CacheException([String? message])
      : super(message ?? 'Cache error occurred');
}

/// Format exception for data parsing errors
class FormatErrorException extends ApiException {
  const FormatErrorException([String? message])
      : super(message ?? 'Format error occurred');
}

/// Validation exception for input validation errors (422).
///
/// Carries [statusCode] 422 by default so the code survives the throw — the old
/// constructor omitted it, silently dropping the 422. [fieldErrors] holds the
/// per-field messages parsed from the response body when present.
class ValidationException extends ApiException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    String? message,
    this.fieldErrors,
    int? statusCode = 422,
  }) : super(message ?? 'Validation error occurred', statusCode: statusCode);

  @override
  List<Object?> get props => [message, statusCode, fieldErrors];
}

/// Timeout exception for request timeouts
class TimeoutException extends ApiException {
  const TimeoutException([String? message])
      : super(message ?? 'Request timeout');
}

/// Cancellation exception for cancelled requests
class CancellationException extends ApiException {
  const CancellationException([String? message])
      : super(message ?? 'Request cancelled');
}

/// Bad request exception (400)
class BadRequestException extends ApiException {
  const BadRequestException([String? message])
      : super(message ?? 'Bad request', statusCode: 400);
}

/// Forbidden request exception (403)
class ForbiddenException extends ApiException {
  const ForbiddenException([String? message])
      : super(message ?? 'Forbidden', statusCode: 403);
}

/// Method not allowed exception (405)
class MethodNotAllowedException extends ApiException {
  const MethodNotAllowedException([String? message])
      : super(message ?? 'Method not allowed', statusCode: 405);
}

/// Not acceptable exception (406)
class NotAcceptableException extends ApiException {
  const NotAcceptableException([String? message])
      : super(message ?? 'The request is not acceptable', statusCode: 406);
}

/// Not implemented exception (501)
class NotImplementedException extends ApiException {
  const NotImplementedException([String? message])
      : super(message ?? 'Not implemented', statusCode: 501);
}

/// Service unavailable exception (503)
class ServiceUnavailableException extends ApiException {
  const ServiceUnavailableException([String? message])
      : super(message ?? 'Service unavailable', statusCode: 503);
}

/// Unexpected error exception
class UnexpectedException extends ApiException {
  const UnexpectedException([String? message])
      : super(message ?? 'An unexpected error occurred');
}

/// Bad certificate exception
class BadCertificateException extends ApiException {
  const BadCertificateException([String? message])
      : super(message ?? 'Bad certificate');
}
