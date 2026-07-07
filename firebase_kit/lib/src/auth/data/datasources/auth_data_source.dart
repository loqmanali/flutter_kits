import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../firebase_kit_runtime.dart';
import '../../domain/entities/phone_verification.dart';

/// Thin wrapper over FirebaseAuth — the only layer that touches the SDK
/// directly. Everything else routes through here so behavior can be mocked.
class AuthDataSource {
  final FirebaseAuth _auth;

  AuthDataSource({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  void _log(String message) => FirebaseKitRuntime.logger.debug(message);

  // ----- email / password ---------------------------------------------------

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    _log('Register w/ email: $email');
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _log('Sign in w/ email: $email');
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _log('Send password reset: $email');
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    _log('Confirm password reset');
    await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
  }

  Future<void> updatePassword(String newPassword) async {
    _requireUser().updatePassword(newPassword);
    _log('Password updated');
  }

  // ----- email verification -------------------------------------------------

  Future<void> sendEmailVerification() async {
    _log('Send email verification');
    await _requireUser().sendEmailVerification();
  }

  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.reload();
  }

  // ----- phone --------------------------------------------------------------

  Future<PhoneVerificationSession> startPhoneVerification({
    required String phoneNumber,
    Duration timeout = const Duration(seconds: 60),
    int? forceResendingToken,
  }) async {
    _log('Start phone verification: $phoneNumber');
    final completer = Completer<PhoneVerificationSession>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: timeout,
      forceResendingToken: forceResendingToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android auto-retrieval — sign the user in immediately.
        try {
          await _auth.signInWithCredential(credential);
          if (!completer.isCompleted) {
            completer.complete(const PhoneVerificationSession(
              verificationId: '',
              autoVerified: true,
            ));
          }
        } catch (e) {
          if (!completer.isCompleted) completer.completeError(e);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) {
          completer.complete(PhoneVerificationSession(
            verificationId: verificationId,
            resendToken: resendToken,
          ));
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // No-op — codeSent has already resolved the completer.
      },
    );

    return completer.future;
  }

  Future<UserCredential> confirmPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  // ----- OAuth --------------------------------------------------------------

  Future<UserCredential> signInWithOAuthCredential(AuthCredential credential) {
    return _auth.signInWithCredential(credential);
  }

  // ----- anonymous / custom -------------------------------------------------

  Future<UserCredential> signInAnonymously() => _auth.signInAnonymously();

  Future<UserCredential> signInWithCustomToken(String token) =>
      _auth.signInWithCustomToken(token);

  // ----- linking ------------------------------------------------------------

  Future<UserCredential> linkCredential(AuthCredential credential) =>
      _requireUser().linkWithCredential(credential);

  Future<UserCredential> linkEmailPassword({
    required String email,
    required String password,
  }) {
    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    return _requireUser().linkWithCredential(credential);
  }

  Future<User> unlinkProvider(String providerId) =>
      _requireUser().unlink(providerId);

  // ----- re-auth ------------------------------------------------------------

  Future<UserCredential> reauthenticateWithPassword(String password) {
    final user = _requireUser();
    final credential = EmailAuthProvider.credential(
      email: user.email ?? '',
      password: password,
    );
    return user.reauthenticateWithCredential(credential);
  }

  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential credential,
  ) {
    return _requireUser().reauthenticateWithCredential(credential);
  }

  // ----- session ------------------------------------------------------------

  Future<void> signOut() async {
    _log('Sign out');
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    _log('Delete account');
    await _requireUser().delete();
  }

  User? get currentUser => _auth.currentUser;

  bool get isAuthenticated => _auth.currentUser != null;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Stream<User?> idTokenChanges() => _auth.idTokenChanges();

  // ----- profile ------------------------------------------------------------

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    final user = _requireUser();
    if (displayName != null) await user.updateDisplayName(displayName);
    if (photoUrl != null) await user.updatePhotoURL(photoUrl);
    await user.reload();
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user-signed-in',
        message: 'No user is currently signed in.',
      );
    }
    return user;
  }
}
