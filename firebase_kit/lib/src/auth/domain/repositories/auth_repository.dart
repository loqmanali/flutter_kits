import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;

import '../entities/firebase_user_entity.dart';
import '../entities/phone_verification.dart';
import '../failures/auth_failure.dart';

/// Result alias: success returns [R], failure carries an [AuthFailure].
typedef AuthResult<R> = Either<AuthFailure, R>;

/// All Firebase Auth methods, abstracted behind a single repository so the
/// presentation layer never touches the SDK directly.
abstract class AuthRepository {
  // ----- email / password ---------------------------------------------------

  Future<AuthResult<FirebaseUserEntity>> registerWithEmail({
    required String email,
    required String password,
    String? name,
    String? phoneNumber,
    Map<String, dynamic>? extraProfile,
  });

  Future<AuthResult<FirebaseUserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthResult<void>> sendPasswordResetEmail(String email);

  Future<AuthResult<void>> confirmPasswordReset({
    required String code,
    required String newPassword,
  });

  Future<AuthResult<void>> updatePassword(String newPassword);

  // ----- email verification -------------------------------------------------

  Future<AuthResult<void>> sendEmailVerification();

  Future<AuthResult<void>> reloadUser();

  // ----- phone --------------------------------------------------------------

  /// Sends an SMS code. On Android the device may auto-resolve the code, in
  /// which case the returned session has `autoVerified = true` and the user
  /// is already signed in.
  Future<AuthResult<PhoneVerificationSession>> startPhoneVerification({
    required String phoneNumber,
    Duration timeout = const Duration(seconds: 60),
    int? forceResendingToken,
  });

  Future<AuthResult<FirebaseUserEntity>> confirmPhoneCode({
    required String verificationId,
    required String smsCode,
  });

  // ----- OAuth (Google / Apple / Facebook / GitHub / Microsoft / Yahoo / Twitter) ---

  /// Generic OAuth entry point. The [providerId] (e.g. `google.com`) must
  /// match an [OAuthProviderAdapter] registered via [FirebaseKitRuntime.use].
  Future<AuthResult<FirebaseUserEntity>> signInWithOAuth(String providerId);

  // ----- anonymous & custom -------------------------------------------------

  Future<AuthResult<FirebaseUserEntity>> signInAnonymously();

  Future<AuthResult<FirebaseUserEntity>> signInWithCustomToken(String token);

  // ----- account linking ----------------------------------------------------

  /// Links an OAuth provider to the currently-signed-in user.
  Future<AuthResult<FirebaseUserEntity>> linkOAuthProvider(String providerId);

  Future<AuthResult<FirebaseUserEntity>> linkEmailPassword({
    required String email,
    required String password,
  });

  Future<AuthResult<void>> unlinkProvider(String providerId);

  // ----- re-auth ------------------------------------------------------------

  Future<AuthResult<void>> reauthenticateWithPassword(String password);

  Future<AuthResult<void>> reauthenticateWithOAuth(String providerId);

  // ----- session ------------------------------------------------------------

  Future<AuthResult<void>> signOut();

  Future<AuthResult<void>> deleteAccount();

  /// Current user as a domain entity (also reads the Firestore user doc).
  Future<FirebaseUserEntity?> getCurrentUser();

  /// Raw Firebase [User] — exposed for advanced callers (e.g. ID tokens).
  fa.User? getCurrentFirebaseUser();

  bool isAuthenticated();

  Stream<fa.User?> authStateChanges();

  Stream<fa.User?> idTokenChanges();

  // ----- profile ------------------------------------------------------------

  Future<AuthResult<void>> updateProfile({
    String? displayName,
    String? photoUrl,
  });
}
