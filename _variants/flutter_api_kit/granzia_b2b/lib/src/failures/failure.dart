import 'package:equatable/equatable.dart';

/// Simple quota information for rate-limit failures.
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

/// Base failure type for domain/use-case layers that prefer the Either /
/// Result pattern over exceptions.
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors,
  });

  @override
  List<Object> get props => [message, if (fieldErrors != null) fieldErrors!];
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}

class InputFailure extends Failure {
  const InputFailure({required super.message});
}

class RateLimitFailure extends Failure {
  final int? retryAfterMs;
  final Object? quotaInfo;

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

class AppUpdateRequiredFailure extends Failure {
  final String? minVersion;
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
