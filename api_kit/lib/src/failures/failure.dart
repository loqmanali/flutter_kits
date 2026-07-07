import 'package:equatable/equatable.dart';

/// Simple quota information for core failures.
class CoreQuotaInfo extends Equatable {
  const CoreQuotaInfo({
    this.currentUsage = 0,
    this.limit = 20,
    this.isExceeded = false,
    this.retryAfterSeconds,
  });

  final int currentUsage;
  final int limit;
  final bool isExceeded;
  final int? retryAfterSeconds;

  int get remaining => (limit - currentUsage).clamp(0, limit);
  double get usagePercentage => limit > 0 ? currentUsage / limit : 0.0;

  @override
  List<Object?> get props =>
      [currentUsage, limit, isExceeded, retryAfterSeconds];
}

/// Base failure class for the domain layer.
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

/// Server-related failure
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Cache-related failure
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Network-related failure
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Validation-related failure
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors,
  });

  @override
  List<Object> get props => [message, if (fieldErrors != null) fieldErrors!];
}

/// Authentication-related failure
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Resource not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

/// Permission-related failure
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

/// Timeout-related failure
class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message});
}

/// Unexpected error failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}

/// Input data-related failure
class InputFailure extends Failure {
  const InputFailure({required super.message});
}

/// Rate limit exceeded failure.
class RateLimitFailure extends Failure {
  /// Suggested retry delay in milliseconds (optional).
  final int? retryAfterMs;

  /// Quota information when available. Accepts both [CoreQuotaInfo] and any
  /// domain-specific QuotaInfo value object to avoid coupling api_kit to a
  /// particular feature's types.
  final dynamic quotaInfo;

  const RateLimitFailure({
    required super.message,
    this.retryAfterMs,
    this.quotaInfo,
  });

  @override
  List<Object> get props => [
        message,
        if (retryAfterMs != null) retryAfterMs!,
        if (quotaInfo != null) quotaInfo!,
      ];
}

/// App update required failure (426).
class AppUpdateRequiredFailure extends Failure {
  /// The minimum required version.
  final String? minVersion;

  /// The store URL to update the app.
  final String? storeUrl;

  const AppUpdateRequiredFailure({
    required super.message,
    this.minVersion,
    this.storeUrl,
  });

  @override
  List<Object> get props => [
        message,
        if (minVersion != null) minVersion!,
        if (storeUrl != null) storeUrl!,
      ];
}
