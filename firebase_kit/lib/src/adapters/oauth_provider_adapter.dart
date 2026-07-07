import 'package:firebase_auth/firebase_auth.dart';

/// Contract for an external OAuth provider (Google, Apple, Facebook, GitHub,
/// Microsoft, Yahoo, Twitter/X, …).
///
/// firebase_kit does NOT bundle the native sign-in SDKs (google_sign_in,
/// sign_in_with_apple, flutter_facebook_auth, …) so consumers only pull the
/// deps they need. Instead, the host app implements this adapter and registers
/// it with [FirebaseKitRuntime.use] keyed by provider id.
///
/// Each adapter is responsible for running the provider's native UI flow
/// and returning a Firebase [AuthCredential] that the kit then exchanges
/// for a Firebase session via `signInWithCredential`.
///
/// Example for Google (consumer side):
/// ```dart
/// class GoogleAdapter implements OAuthProviderAdapter {
///   @override
///   String get id => 'google.com';
///
///   @override
///   Future<AuthCredential?> obtainCredential() async {
///     final account = await GoogleSignIn().signIn();
///     if (account == null) return null;
///     final auth = await account.authentication;
///     return GoogleAuthProvider.credential(
///       idToken: auth.idToken,
///       accessToken: auth.accessToken,
///     );
///   }
///
///   @override
///   Future<void> signOut() => GoogleSignIn().signOut();
/// }
/// ```
abstract class OAuthProviderAdapter {
  /// Firebase provider id (e.g. `google.com`, `apple.com`, `facebook.com`,
  /// `github.com`, `microsoft.com`, `yahoo.com`, `twitter.com`).
  String get id;

  /// Runs the native sign-in flow and returns a Firebase [AuthCredential].
  /// Returns `null` if the user cancelled.
  Future<AuthCredential?> obtainCredential();

  /// Signs the user out of the underlying provider. Optional — defaults to no-op.
  Future<void> signOut() async {}
}
