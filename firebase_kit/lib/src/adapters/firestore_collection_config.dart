/// Lets host apps rename the collection paths used by the kit's built-in user
/// repository. Custom collections used with the generic [FirestoreRepository]
/// can be named per-instance.
class FirestoreCollectionConfig {
  final String usersCollection;

  const FirestoreCollectionConfig({
    this.usersCollection = 'users',
  });
}
