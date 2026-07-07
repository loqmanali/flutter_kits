import '../exceptions/commerce_exception.dart';

/// A result type that represents either success or failure.
sealed class Result<T> {
  const Result();

  /// Returns true if this is a success.
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a failure.
  bool get isFailure => this is Failure<T>;

  /// Gets the value if success, throws if failure.
  T get value => switch (this) {
        Success(value: final v) => v,
        Failure(exception: final e) => throw e,
      };

  /// Gets the value if success, returns null if failure.
  T? get valueOrNull => switch (this) {
        Success(value: final v) => v,
        Failure() => null,
      };

  /// Gets the exception if failure, returns null if success.
  CommerceException? get exceptionOrNull => switch (this) {
        Success() => null,
        Failure(exception: final e) => e,
      };

  /// Maps the value if success.
  Result<R> map<R>(R Function(T value) mapper) => switch (this) {
        Success(value: final v) => Success(mapper(v)),
        Failure(exception: final e) => Failure(e),
      };

  /// Flat maps the value if success.
  Result<R> flatMap<R>(Result<R> Function(T value) mapper) => switch (this) {
        Success(value: final v) => mapper(v),
        Failure(exception: final e) => Failure(e),
      };

  /// Maps the exception if failure.
  Result<T> mapError(CommerceException Function(CommerceException e) mapper) =>
      switch (this) {
        Success() => this,
        Failure(exception: final e) => Failure(mapper(e)),
      };

  /// Returns the value if success, or the result of orElse if failure.
  T getOrElse(T Function() orElse) => switch (this) {
        Success(value: final v) => v,
        Failure() => orElse(),
      };

  /// Returns the value if success, or the default value if failure.
  T getOrDefault(T defaultValue) => switch (this) {
        Success(value: final v) => v,
        Failure() => defaultValue,
      };

  /// Executes onSuccess if success, onFailure if failure.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(CommerceException exception) onFailure,
  }) =>
      switch (this) {
        Success(value: final v) => onSuccess(v),
        Failure(exception: final e) => onFailure(e),
      };

  /// Executes the callback if success.
  Result<T> onSuccess(void Function(T value) callback) {
    if (this case Success(value: final v)) {
      callback(v);
    }
    return this;
  }

  /// Executes the callback if failure.
  Result<T> onFailure(void Function(CommerceException exception) callback) {
    if (this case Failure(exception: final e)) {
      callback(e);
    }
    return this;
  }
}

/// Represents a successful result.
final class Success<T> extends Result<T> {
  /// The success value.
  @override
  final T value;

  /// Creates a [Success].
  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Represents a failed result.
final class Failure<T> extends Result<T> {
  /// The exception.
  final CommerceException exception;

  /// Creates a [Failure].
  const Failure(this.exception);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          exception == other.exception;

  @override
  int get hashCode => exception.hashCode;

  @override
  String toString() => 'Failure($exception)';
}

/// Utility class for error handling.
class ErrorHandler {
  ErrorHandler._();

  /// Wraps an async operation in a Result.
  static Future<Result<T>> guard<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Success(result);
    } on CommerceException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(
        ApiException(
          message: e.toString(),
          code: 'UNKNOWN_ERROR',
          cause: e,
        ),
      );
    }
  }

  /// Wraps a sync operation in a Result.
  static Result<T> guardSync<T>(T Function() operation) {
    try {
      final result = operation();
      return Success(result);
    } on CommerceException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(
        ApiException(
          message: e.toString(),
          code: 'UNKNOWN_ERROR',
          cause: e,
        ),
      );
    }
  }

  /// Converts a dynamic error to a CommerceException.
  static CommerceException toCommerceException(Object error) {
    if (error is CommerceException) return error;

    return ApiException(
      message: error.toString(),
      code: 'UNKNOWN_ERROR',
      cause: error,
    );
  }

  /// Gets a user-friendly error message from an exception.
  static String getUserMessage(CommerceException exception) {
    // Map error codes to user-friendly messages
    final userMessages = {
      'NETWORK_ERROR': 'Please check your internet connection',
      'TIMEOUT': 'Request timed out. Please try again',
      'UNAUTHORIZED': 'Please log in to continue',
      'FORBIDDEN': 'You do not have permission to perform this action',
      'SERVER_ERROR': 'Something went wrong. Please try again later',
      'ITEM_NOT_FOUND': 'Item not found',
      'OUT_OF_STOCK': 'This item is currently out of stock',
      'INVALID_QUANTITY': 'Please enter a valid quantity',
      'MAX_QUANTITY_EXCEEDED': 'Maximum quantity exceeded',
      'EMPTY_CART': 'Your cart is empty',
      'INVALID_CODE': 'Invalid discount code',
      'DISCOUNT_EXPIRED': 'This discount code has expired',
      'MINIMUM_NOT_MET': 'Minimum order amount not met',
      'USAGE_LIMIT_REACHED': 'This discount code is no longer available',
      'INSUFFICIENT_BALANCE': 'Insufficient wallet balance',
      'INSUFFICIENT_POINTS': 'Insufficient points',
      'PAYMENT_FAILED': 'Payment failed. Please try again',
      'NO_DELIVERY_AVAILABLE': 'Delivery is not available for this address',
      'SESSION_EXPIRED': 'Your session has expired. Please try again',
    };

    if (exception.code != null && userMessages.containsKey(exception.code)) {
      return userMessages[exception.code]!;
    }

    return exception.message;
  }

  /// Determines if an error is retryable.
  static bool isRetryable(CommerceException exception) {
    final retryableCodes = {
      'NETWORK_ERROR',
      'TIMEOUT',
      'SERVER_ERROR',
      'HTTP_500',
      'HTTP_502',
      'HTTP_503',
      'HTTP_504',
    };

    return exception.code != null && retryableCodes.contains(exception.code);
  }

  /// Determines if an error requires re-authentication.
  static bool requiresAuth(CommerceException exception) {
    return exception.code == 'UNAUTHORIZED' || exception.code == 'HTTP_401';
  }
}

/// Extension for easier Result creation.
extension ResultExtension<T> on T {
  /// Wraps this value in a Success.
  Result<T> get asSuccess => Success(this);
}

/// Extension for easier Failure creation.
extension CommerceExceptionExtension on CommerceException {
  /// Wraps this exception in a Failure.
  Result<T> asFailure<T>() => Failure<T>(this);
}
