import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../firebase_kit_runtime.dart';
import '../models/firebase_user_model.dart';

/// Persists user profile docs in Firestore. Path comes from
/// [FirebaseKitRuntime.collections] so host apps can rename the collection.
class UserFirestoreDataSource {
  final FirebaseFirestore _firestore;

  UserFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirebaseKitRuntime.collections.usersCollection);

  Future<void> saveUser(FirebaseUserModel user) async {
    await _users.doc(user.uid).set(user.toFirestore(), SetOptions(merge: true));
  }

  Future<FirebaseUserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return FirebaseUserModel.fromFirestore(doc);
  }

  Future<void> updateUser(FirebaseUserModel user) async {
    await _users.doc(user.uid).update(user.toFirestore());
  }

  Future<void> deleteUser(String uid) async {
    await _users.doc(uid).delete();
  }

  Stream<FirebaseUserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return FirebaseUserModel.fromFirestore(doc);
    });
  }
}
