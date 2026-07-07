import 'package:equatable/equatable.dart';

/// Domain user — combines Firebase Auth identity with optional Firestore-side
/// profile fields. Stays plain Dart so the domain layer has no Firebase deps.
class FirebaseUserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? name;
  final String? phoneNumber;
  final String? photoUrl;
  final bool emailVerified;
  final bool isAnonymous;

  /// Provider ids the user has signed in with (e.g. `password`, `google.com`).
  final List<String> providerIds;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Arbitrary app-specific fields persisted alongside the user document.
  final Map<String, dynamic>? metadata;

  const FirebaseUserEntity({
    required this.uid,
    this.email,
    this.name,
    this.phoneNumber,
    this.photoUrl,
    this.emailVerified = false,
    this.isAnonymous = false,
    this.providerIds = const [],
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  FirebaseUserEntity copyWith({
    String? uid,
    String? email,
    String? name,
    String? phoneNumber,
    String? photoUrl,
    bool? emailVerified,
    bool? isAnonymous,
    List<String>? providerIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return FirebaseUserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      providerIds: providerIds ?? this.providerIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        name,
        phoneNumber,
        photoUrl,
        emailVerified,
        isAnonymous,
        providerIds,
        createdAt,
        updatedAt,
        metadata,
      ];
}
