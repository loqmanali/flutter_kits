import 'package:cloud_firestore/cloud_firestore.dart';

import '../../firebase_kit_runtime.dart';
import '../domain/firestore_repository.dart';
import '../domain/firestore_serializable.dart';
import '../query/firestore_query.dart';

/// Concrete generic repository. Construct it with a path and a converter; it
/// handles everything else.
///
/// ```dart
/// final todosRepo = FirestoreRepositoryImpl<Todo>(
///   path: 'todos',
///   converter: const TodoConverter(),
/// );
/// ```
class FirestoreRepositoryImpl<T> implements FirestoreRepository<T> {
  final FirebaseFirestore _firestore;
  final String _path;
  final FirestoreConverter<T> _converter;

  FirestoreRepositoryImpl({
    required String path,
    required FirestoreConverter<T> converter,
    FirebaseFirestore? firestore,
  })  : _path = path,
        _converter = converter,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  String get path => _path;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_path);

  void _log(String msg) =>
      FirebaseKitRuntime.logger.debug('[$_path] $msg');

  @override
  Future<T> create(T entity) async {
    final data = _converter.toFirestore(entity);
    final id = _converter.idOf(entity);
    if (id.isEmpty) {
      final ref = await _col.add(data);
      _log('Created ${ref.id}');
      final doc = await ref.get();
      return _converter.fromFirestore(doc.id, doc.data() ?? {});
    } else {
      await _col.doc(id).set(data);
      _log('Created $id');
      return entity;
    }
  }

  @override
  Future<void> set(T entity, {bool merge = true}) async {
    final id = _converter.idOf(entity);
    if (id.isEmpty) {
      throw ArgumentError(
        'Cannot set an entity without an id. Use create() to auto-generate one.',
      );
    }
    await _col.doc(id).set(_converter.toFirestore(entity),
        SetOptions(merge: merge));
    _log('Set $id (merge=$merge)');
  }

  @override
  Future<T?> get(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return _converter.fromFirestore(doc.id, doc.data() ?? {});
  }

  @override
  Future<void> update(String id, Map<String, Object?> fields) async {
    await _col.doc(id).update(fields);
    _log('Updated $id');
  }

  @override
  Future<void> delete(String id) async {
    await _col.doc(id).delete();
    _log('Deleted $id');
  }

  @override
  Future<List<T>> list() async {
    final snap = await _col.get();
    return snap.docs
        .map((d) => _converter.fromFirestore(d.id, d.data()))
        .toList();
  }

  @override
  FirestoreQueryBuilder query() => const FirestoreQueryBuilder();

  @override
  Future<List<T>> find(FirestoreQueryBuilder builder) async {
    final snap = await builder.apply(_col).get();
    return snap.docs
        .map((d) => _converter.fromFirestore(d.id, d.data()))
        .toList();
  }

  @override
  Stream<T?> watch(String id) {
    return _col.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _converter.fromFirestore(doc.id, doc.data() ?? {});
    });
  }

  @override
  Stream<List<T>> watchQuery(FirestoreQueryBuilder builder) {
    return builder.apply(_col).snapshots().map((snap) {
      return snap.docs
          .map((d) => _converter.fromFirestore(d.id, d.data()))
          .toList();
    });
  }

  @override
  CollectionReference<Map<String, dynamic>> rawCollection() => _col;
}
