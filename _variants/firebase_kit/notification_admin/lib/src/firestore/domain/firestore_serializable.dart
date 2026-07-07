/// Converters from/to Firestore for any domain type.
///
/// Implement these once per entity and the generic [FirestoreRepository]
/// becomes fully type-safe — no per-collection repository class needed.
///
/// ```dart
/// class TodoConverter implements FirestoreConverter<Todo> {
///   const TodoConverter();
///
///   @override
///   Todo fromFirestore(String id, Map<String, dynamic> data) => Todo(
///         id: id,
///         title: data['title'] as String,
///         done: data['done'] as bool? ?? false,
///       );
///
///   @override
///   Map<String, dynamic> toFirestore(Todo entity) => {
///         'title': entity.title,
///         'done': entity.done,
///       };
///
///   @override
///   String idOf(Todo entity) => entity.id;
/// }
/// ```
abstract class FirestoreConverter<T> {
  const FirestoreConverter();

  T fromFirestore(String id, Map<String, dynamic> data);
  Map<String, dynamic> toFirestore(T entity);

  /// Returns the document id for the entity, or an empty string if the entity
  /// hasn't been persisted yet (in which case Firestore auto-generates one).
  String idOf(T entity);
}
