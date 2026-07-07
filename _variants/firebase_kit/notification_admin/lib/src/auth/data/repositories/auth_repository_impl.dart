import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;

import '../../../firebase_kit_runtime.dart';
import '../../domain/entities/firebase_user_entity.dart';
import '../../domain/entities/phone_verification.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';
import '../datasources/user_firestore_data_source.dart';
import '../models/firebase_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDs;
  final UserFirestoreDataSource _userDs;

  AuthRepositoryImpl({
    required AuthDataSource authDataSource,
    required UserFirestoreDataSource userDataSource,
  })  : _authDs = authDataSource,
        _userDs = userDataSource;

  // ----- helpers ------------------------------------------------------------

  Future<AuthResult<R>> _guard<R>(Future<R> Function() body) async {
    try {
      return Right(await body());
    } on fa.FirebaseAuthException catch (e) {
      FirebaseKitRuntime.logger.warning('FirebaseAuthException: ${e.code}', e);
      return Left(AuthFailure.fromFirebase(e));
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e, st) {
      FirebaseKitRuntime.logger.error('Unexpected auth error', e, st);
      return Left(AuthFailure.unexpected(e, st));
    }
  }

  Future<FirebaseUserModel> _syncUserDoc(
    fa.User authUser, {
    String? displayName,
    String? phoneNumber,
    Map<String, dynamic>? extraProfile,
  }) async {
    final existing = await _userDs.getUser(authUser.uid);
    final base = existing?.mergedWithAuth(authUser) ??
        FirebaseUserModel.fromAuthUser(authUser);

    final merged = FirebaseUserModel(
      uid: base.uid,
      email: base.email,
      name: displayName ?? base.name,
      phoneNumber: phoneNumber ?? base.phoneNumber,
      photoUrl: base.photoUrl,
      emailVerified: base.emailVerified,
      isAnonymous: base.isAnonymous,
      providerIds: base.providerIds,
      createdAt: base.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: extraProfile != null
          ? {...?base.metadata, ...extraProfile}
          : base.metadata,
    );

    if (FirebaseKitRuntime.config.autoCreateUserDocument || existing != null) {
      await _userDs.saveUser(merged);
    }
    return merged;
  }

  // ----- email / password ---------------------------------------------------

  @override
  Future<AuthResult<FirebaseUserEntity>> registerWithEmail({
    required String email,
    required String password,
    String? name,
    String? phoneNumber,
    Map<String, dynamic>? extraProfile,
  }) {
    return _guard(() async {
      final cred =
          await _authDs.registerWithEmail(email: email, password: password);
      final user = cred.user!;
      if (name != null) await _authDs.updateProfile(displayName: name);
      await user.reload();
      final refreshed = _authDs.currentUser ?? user;
      final model = await _syncUserDoc(
        refreshed,
        displayName: name,
        phoneNumber: phoneNumber,
        extraProfile: extraProfile,
      );
      return model as FirebaseUserEntity;
    });
  }

  @override
  Future<AuthResult<FirebaseUserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final cred =
          await _authDs.signInWithEmail(email: email, password: password);
      final model = await _syncUserDoc(cred.user!);
      return model as FirebaseUserEntity;
    });
  }

  @override
  Future<AuthResult<void>> sendPasswordResetEmail(String email) {
    return _guard(() => _authDs.sendPasswordResetEmail(email));
  }

  @override
  Future<AuthResult<void>> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) {
    return _guard(() =>
        _authDs.confirmPasswordReset(code: code, newPassword: newPassword));
  }

  @override
  Future<AuthResult<void>> updatePassword(String newPassword) {
    return _guard(() => _authDs.updatePassword(newPassword));
  }

  // ----- email verification -------------------------------------------------

  @override
  Future<AuthResult<void>> sendEmailVerification() {
    return _guard(() => _authDs.sendEmailVerification());
  }

  @override
  Future<AuthResult<void>> reloadUser() {
    return _guard(() => _authDs.reloadUser());
  }

  // ----- phone --------------------------------------------------------------

  @override
  Future<AuthResult<PhoneVerificationSession>> startPhoneVerification({
    required String phoneNumber,
    Duration timeout = const Duration(seconds: 60),
    int? forceResendingToken,
  }) {
    return _guard(() => _authDs.startPhoneVerification(
          phoneNumber: phoneNumber,
          timeout: timeout,
          forceResendingToken: forceResendingToken,
        ));
  }

  @override
  Future<AuthResult<FirebaseUserEntity>> confirmPhoneCode({
    required String verificationId,
    required String smsCode,
  }) {
    return _guard(() async {
      final cred = await _authDs.confirmPhoneCode(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final model = await _syncUserDoc(cred.user!);
      return model as FirebaseUserEntity;
    });
  }

  // ----- OAuth --------------------------------------------------------------

  @override
  Future<AuthResult<FirebaseUserEntity>> signInWithOAuth(String providerId) {
    return _guard(() async {
      final adapter = FirebaseKitRuntime.tryOAuthAdapter(providerId);
      if (adapter == null) {
        throw AuthFailure(
          code: AuthFailureCode.oauthAdapterMissing,
          message:
              'No OAuth adapter registered for "$providerId". Register one '
              'via FirebaseKitRuntime.use(oauthAdapters: [...]).',
        );
      }
      final credential = await adapter.obtainCredential();
      if (credential == null) {
        throw const AuthFailure(
          code: AuthFailureCode.oauthCancelled,
          message: 'OAuth sign-in was cancelled.',
        );
      }
      final cred = await _authDs.signInWithOAuthCredential(credential);
      final model = await _syncUserDoc(cred.user!);
      return model as FirebaseUserEntity;
    });
  }

  // ----- anonymous / custom -------------------------------------------------

  @override
  Future<AuthResult<FirebaseUserEntity>> signInAnonymously() {
    return _guard(() async {
      final cred = await _authDs.signInAnonymously();
      final model = await _syncUserDoc(cred.user!);
      return model as FirebaseUserEntity;
    });
  }

  @override
  Future<AuthResult<FirebaseUserEntity>> signInWithCustomToken(String token) {
    return _guard(() async {
      final cred = await _authDs.signInWithCustomToken(token);
      final model = await _syncUserDoc(cred.user!);
      return model as FirebaseUserEntity;
    });
  }

  // ----- linking ------------------------------------------------------------

  @override
  Future<AuthResult<FirebaseUserEntity>> linkOAuthProvider(String providerId) {
    return _guard(() async {
      final adapter = FirebaseKitRuntime.requireOAuthAdapter(providerId);
      final credential = await adapter.obtainCredential();
      if (credential == null) {
        throw const AuthFailure(
          code: AuthFailureCode.oauthCancelled,
          message: 'OAuth link was cancelled.',
        );
      }
      final cred = await _authDs.linkCredential(credential);
      final model = await _syncUserDoc(cred.user!);
      return model as FirebaseUserEntity;
    });
  }

  @override
  Future<AuthResult<FirebaseUserEntity>> linkEmailPassword({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final cred =
          await _authDs.linkEmailPassword(email: email, password: password);
      final model = await _syncUserDoc(cred.user!);
      return model as FirebaseUserEntity;
    });
  }

  @override
  Future<AuthResult<void>> unlinkProvider(String providerId) {
    return _guard(() => _authDs.unlinkProvider(providerId));
  }

  // ----- re-auth ------------------------------------------------------------

  @override
  Future<AuthResult<void>> reauthenticateWithPassword(String password) {
    return _guard(() => _authDs.reauthenticateWithPassword(password));
  }

  @override
  Future<AuthResult<void>> reauthenticateWithOAuth(String providerId) {
    return _guard(() async {
      final adapter = FirebaseKitRuntime.requireOAuthAdapter(providerId);
      final credential = await adapter.obtainCredential();
      if (credential == null) {
        throw const AuthFailure(
          code: AuthFailureCode.oauthCancelled,
          message: 'OAuth re-auth was cancelled.',
        );
      }
      await _authDs.reauthenticateWithCredential(credential);
    });
  }

  // ----- session ------------------------------------------------------------

  @override
  Future<AuthResult<void>> signOut() {
    return _guard(() async {
      // Best-effort sign out from each registered OAuth adapter.
      for (final providerId in FirebaseKitRuntime.registeredOAuthProviders) {
        try {
          await FirebaseKitRuntime.requireOAuthAdapter(providerId).signOut();
        } catch (e) {
          FirebaseKitRuntime.logger
              .warning('OAuth adapter signOut failed: $providerId', e);
        }
      }
      await _authDs.signOut();
    });
  }

  @override
  Future<AuthResult<void>> deleteAccount() {
    return _guard(() async {
      final user = _authDs.currentUser;
      if (user == null) {
        throw const AuthFailure(
          code: AuthFailureCode.noUserSignedIn,
          message: 'No user is currently signed in.',
        );
      }
      final uid = user.uid;
      await _userDs.deleteUser(uid);
      await _authDs.deleteAccount();
    });
  }

  @override
  Future<FirebaseUserEntity?> getCurrentUser() async {
    final user = _authDs.currentUser;
    if (user == null) return null;
    final doc = await _userDs.getUser(user.uid);
    return (doc?.mergedWithAuth(user) ?? FirebaseUserModel.fromAuthUser(user))
        as FirebaseUserEntity;
  }

  @override
  fa.User? getCurrentFirebaseUser() => _authDs.currentUser;

  @override
  bool isAuthenticated() => _authDs.isAuthenticated;

  @override
  Stream<fa.User?> authStateChanges() => _authDs.authStateChanges();

  @override
  Stream<fa.User?> idTokenChanges() => _authDs.idTokenChanges();

  // ----- profile ------------------------------------------------------------

  @override
  Future<AuthResult<void>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) {
    return _guard(() async {
      await _authDs.updateProfile(displayName: displayName, photoUrl: photoUrl);
      final user = _authDs.currentUser;
      if (user != null) {
        await _syncUserDoc(user, displayName: displayName);
      }
    });
  }
}
