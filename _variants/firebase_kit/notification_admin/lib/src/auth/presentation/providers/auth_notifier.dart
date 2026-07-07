import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/firebase_user_entity.dart';
import '../../domain/entities/phone_verification.dart';
import '../../domain/failures/auth_failure.dart';
import 'auth_providers.dart';

class AuthState {
  final bool isLoading;
  final FirebaseUserEntity? user;
  final AuthFailure? error;
  final PhoneVerificationSession? phoneSession;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.phoneSession,
  });

  AuthState copyWith({
    bool? isLoading,
    FirebaseUserEntity? user,
    AuthFailure? error,
    PhoneVerificationSession? phoneSession,
    bool clearError = false,
    bool clearUser = false,
    bool clearPhoneSession = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
      phoneSession: clearPhoneSession
          ? null
          : (phoneSession ?? this.phoneSession),
    );
  }
}

/// Imperative facade over [AuthRepository] — wraps each method, manages
/// loading/error state, and updates [AuthState] for the UI.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> _run<R>(
    Future<dynamic> Function() action, {
    void Function(R value)? onSuccess,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await action();
    result.fold(
      (AuthFailure failure) =>
          state = state.copyWith(isLoading: false, error: failure),
      (value) {
        if (onSuccess != null) onSuccess(value as R);
        state = state.copyWith(isLoading: false);
      },
    );
  }

  // ----- email / password ---------------------------------------------------

  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? name,
    String? phoneNumber,
    Map<String, dynamic>? extraProfile,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    await _run<FirebaseUserEntity>(
      () => repo.registerWithEmail(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        extraProfile: extraProfile,
      ),
      onSuccess: (user) => state = state.copyWith(user: user),
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    await _run<FirebaseUserEntity>(
      () => repo.signInWithEmail(email: email, password: password),
      onSuccess: (user) => state = state.copyWith(user: user),
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final repo = ref.read(authRepositoryProvider);
    await _run<void>(() => repo.sendPasswordResetEmail(email));
  }

  Future<void> updatePassword(String newPassword) async {
    final repo = ref.read(authRepositoryProvider);
    await _run<void>(() => repo.updatePassword(newPassword));
  }

  Future<void> sendEmailVerification() async {
    final repo = ref.read(authRepositoryProvider);
    await _run<void>(() => repo.sendEmailVerification());
  }

  // ----- phone --------------------------------------------------------------

  Future<void> startPhoneVerification({
    required String phoneNumber,
    Duration timeout = const Duration(seconds: 60),
    int? forceResendingToken,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    await _run<PhoneVerificationSession>(
      () => repo.startPhoneVerification(
        phoneNumber: phoneNumber,
        timeout: timeout,
        forceResendingToken: forceResendingToken,
      ),
      onSuccess: (session) =>
          state = state.copyWith(phoneSession: session),
    );
  }

  Future<void> confirmPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    await _run<FirebaseUserEntity>(
      () => repo.confirmPhoneCode(
        verificationId: verificationId,
        smsCode: smsCode,
      ),
      onSuccess: (user) => state = state.copyWith(
        user: user,
        clearPhoneSession: true,
      ),
    );
  }

  // ----- OAuth / anonymous / custom -----------------------------------------

  Future<void> signInWithOAuth(String providerId) async {
    final repo = ref.read(authRepositoryProvider);
    await _run<FirebaseUserEntity>(
      () => repo.signInWithOAuth(providerId),
      onSuccess: (user) => state = state.copyWith(user: user),
    );
  }

  Future<void> signInAnonymously() async {
    final repo = ref.read(authRepositoryProvider);
    await _run<FirebaseUserEntity>(
      () => repo.signInAnonymously(),
      onSuccess: (user) => state = state.copyWith(user: user),
    );
  }

  Future<void> signInWithCustomToken(String token) async {
    final repo = ref.read(authRepositoryProvider);
    await _run<FirebaseUserEntity>(
      () => repo.signInWithCustomToken(token),
      onSuccess: (user) => state = state.copyWith(user: user),
    );
  }

  // ----- linking ------------------------------------------------------------

  Future<void> linkOAuthProvider(String providerId) async {
    final repo = ref.read(authRepositoryProvider);
    await _run<FirebaseUserEntity>(
      () => repo.linkOAuthProvider(providerId),
      onSuccess: (user) => state = state.copyWith(user: user),
    );
  }

  Future<void> unlinkProvider(String providerId) async {
    final repo = ref.read(authRepositoryProvider);
    await _run<void>(() => repo.unlinkProvider(providerId));
  }

  // ----- session ------------------------------------------------------------

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await repo.signOut();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (_) => state = const AuthState(),
    );
  }

  Future<void> deleteAccount() async {
    final repo = ref.read(authRepositoryProvider);
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await repo.deleteAccount();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (_) => state = const AuthState(),
    );
  }

  Future<void> loadCurrentUser() async {
    final repo = ref.read(authRepositoryProvider);
    state = state.copyWith(isLoading: true);
    final user = await repo.getCurrentUser();
    state = state.copyWith(isLoading: false, user: user);
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    await _run<void>(
      () => repo.updateProfile(displayName: displayName, photoUrl: photoUrl),
    );
    await loadCurrentUser();
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
