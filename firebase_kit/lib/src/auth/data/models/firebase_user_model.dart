import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;

import '../../domain/entities/firebase_user_entity.dart';

/// Firestore-backed user model. Decoupled from the entity so the domain layer
/// stays Firebase-free.
class FirebaseUserModel extends FirebaseUserEntity {
  const FirebaseUserModel({
    required super.uid,
    super.email,
    super.name,
    super.phoneNumber,
    super.photoUrl,
    super.emailVerified,
    super.isAnonymous,
    super.providerIds,
    super.createdAt,
    super.updatedAt,
    super.metadata,
  });

  factory FirebaseUserModel.fromAuthUser(fa.User user) {
    return FirebaseUserModel(
      uid: user.uid,
      email: user.email,
      name: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
      isAnonymous: user.isAnonymous,
      providerIds: user.providerData.map((p) => p.providerId).toList(),
      createdAt: user.metadata.creationTime,
      updatedAt: user.metadata.lastSignInTime,
    );
  }

  factory FirebaseUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FirebaseUserModel(
      uid: doc.id,
      email: data['email'] as String?,
      name: data['name'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      photoUrl: data['photoUrl'] as String?,
      emailVerified: data['emailVerified'] as bool? ?? false,
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      providerIds:
          (data['providerIds'] as List?)?.cast<String>() ?? const <String>[],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'isAnonymous': isAnonymous,
      'providerIds': providerIds,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Merges the authoritative Firebase Auth user with optional Firestore fields.
  FirebaseUserModel mergedWithAuth(fa.User user) {
    return FirebaseUserModel(
      uid: user.uid,
      email: user.email ?? email,
      name: user.displayName ?? name,
      phoneNumber: user.phoneNumber ?? phoneNumber,
      photoUrl: user.photoURL ?? photoUrl,
      emailVerified: user.emailVerified,
      isAnonymous: user.isAnonymous,
      providerIds: user.providerData.map((p) => p.providerId).toList(),
      createdAt: createdAt ?? user.metadata.creationTime,
      updatedAt: DateTime.now(),
      metadata: metadata,
    );
  }
}
