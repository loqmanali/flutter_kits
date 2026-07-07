import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Strongly-typed auth failure. Replaces raw `String` errors with something
/// callers can pattern-match on for UI logic (e.g. "show resend verification
/// button when code == emailNotVerified").
class AuthFailure extends Equatable implements Exception {
  final AuthFailureCode code;
  final String message;
  final Object? cause;

  const AuthFailure({
    required this.code,
    required this.message,
    this.cause,
  });

  factory AuthFailure.fromFirebase(FirebaseAuthException e) {
    return AuthFailure(
      code: _mapCode(e.code),
      message: _humanMessage(e.code, e.message),
      cause: e,
    );
  }

  factory AuthFailure.unexpected(Object e, [StackTrace? st]) {
    return AuthFailure(
      code: AuthFailureCode.unknown,
      message: 'Unexpected authentication error: $e',
      cause: e,
    );
  }

  static AuthFailureCode _mapCode(String code) {
    switch (code) {
      case 'weak-password':
        return AuthFailureCode.weakPassword;
      case 'email-already-in-use':
        return AuthFailureCode.emailAlreadyInUse;
      case 'invalid-email':
        return AuthFailureCode.invalidEmail;
      case 'invalid-credential':
      case 'wrong-password':
        return AuthFailureCode.invalidCredential;
      case 'user-disabled':
        return AuthFailureCode.userDisabled;
      case 'user-not-found':
        return AuthFailureCode.userNotFound;
      case 'too-many-requests':
        return AuthFailureCode.tooManyRequests;
      case 'operation-not-allowed':
        return AuthFailureCode.operationNotAllowed;
      case 'requires-recent-login':
        return AuthFailureCode.requiresRecentLogin;
      case 'account-exists-with-different-credential':
        return AuthFailureCode.accountExistsWithDifferentCredential;
      case 'invalid-verification-code':
        return AuthFailureCode.invalidVerificationCode;
      case 'invalid-verification-id':
        return AuthFailureCode.invalidVerificationId;
      case 'session-expired':
        return AuthFailureCode.sessionExpired;
      case 'network-request-failed':
        return AuthFailureCode.networkError;
      case 'credential-already-in-use':
        return AuthFailureCode.credentialAlreadyInUse;
      default:
        return AuthFailureCode.unknown;
    }
  }

  static String _humanMessage(String code, String? fallback) {
    switch (code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'invalid-credential':
      case 'wrong-password':
        return 'Invalid credentials.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with these credentials.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'Please re-authenticate to perform this action.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification session is invalid. Please request a new code.';
      case 'session-expired':
        return 'The verification session expired. Please request a new code.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'credential-already-in-use':
        return 'This credential is already linked to another account.';
      default:
        return fallback ?? 'Authentication error.';
    }
  }

  @override
  List<Object?> get props => [code, message];

  @override
  String toString() => 'AuthFailure(${code.name}): $message';
}

enum AuthFailureCode {
  weakPassword,
  emailAlreadyInUse,
  invalidEmail,
  invalidCredential,
  userDisabled,
  userNotFound,
  tooManyRequests,
  operationNotAllowed,
  requiresRecentLogin,
  accountExistsWithDifferentCredential,
  credentialAlreadyInUse,
  invalidVerificationCode,
  invalidVerificationId,
  sessionExpired,
  networkError,
  emailNotVerified,
  noUserSignedIn,
  oauthCancelled,
  oauthAdapterMissing,
  unknown,
}
