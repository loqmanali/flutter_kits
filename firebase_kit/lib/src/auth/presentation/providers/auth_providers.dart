import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_data_source.dart';
import '../../data/datasources/user_firestore_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/firebase_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// ----- data sources ---------------------------------------------------------

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSource();
});

final userFirestoreDataSourceProvider =
    Provider<UserFirestoreDataSource>((ref) {
  return UserFirestoreDataSource();
});

// ----- repository -----------------------------------------------------------

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authDataSource: ref.watch(authDataSourceProvider),
    userDataSource: ref.watch(userFirestoreDataSourceProvider),
  );
});

// ----- state streams --------------------------------------------------------

/// Stream of raw Firebase Auth state changes. Most consumers should prefer
/// [currentAuthUserProvider] which yields a [FirebaseUserEntity].
final authStateChangesProvider = StreamProvider<fa.User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Stream of ID-token changes — useful for backend token-refresh flows.
final idTokenChangesProvider = StreamProvider<fa.User?>((ref) {
  return ref.watch(authRepositoryProvider).idTokenChanges();
});

/// Domain user, refreshed whenever auth state changes. Returns null when
/// signed out.
final currentAuthUserProvider =
    FutureProvider<FirebaseUserEntity?>((ref) async {
  // Re-evaluate whenever the auth stream emits.
  ref.watch(authStateChangesProvider);
  return ref.watch(authRepositoryProvider).getCurrentUser();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authRepositoryProvider).isAuthenticated();
});
