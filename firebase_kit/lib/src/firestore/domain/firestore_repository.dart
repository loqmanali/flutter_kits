import 'package:cloud_firestore/cloud_firestore.dart';

import '../query/firestore_query.dart';

/// Generic Firestore repository contract.
///
/// One instance == one collection (or one subcollection). Construct via the
/// data-layer factory and reuse from your providers; no per-entity repository
/// subclass needed.
abstract class FirestoreRepository<T> {
  /// Path of the collection this repository points at.
  String get path;

  /// Creates a new document. If [idOf(entity)] is empty, Firestore generates
  /// the id; the saved entity (with its assigned id) is returned.
  Future<T> create(T entity);

  /// Upserts a document. Pass [merge] = false to replace the document wholesale.
  Future<void> set(T entity, {bool merge = true});

  /// Returns the document with [id], or null if it doesn't exist.
  Future<T?> get(String id);

  /// Updates a subset of fields. Use for partial writes (the entity converter
  /// is bypassed — callers control the exact field-set).
  Future<void> update(String id, Map<String, Object?> fields);

  /// Deletes the document.
  Future<void> delete(String id);

  /// Lists all documents (no query). Avoid on large collections.
  Future<List<T>> list();

  /// Builder for queries. Pass to [find] / [watch].
  FirestoreQueryBuilder query();

  /// Runs [builder] and returns the matching documents.
  Future<List<T>> find(FirestoreQueryBuilder builder);

  /// Real-time stream of a single document (null while it doesn't exist).
  Stream<T?> watch(String id);

  /// Real-time stream of a query.
  Stream<List<T>> watchQuery(FirestoreQueryBuilder builder);

  /// Escape hatch for advanced callers (batched writes, transactions, etc.).
  CollectionReference<Map<String, dynamic>> rawCollection();
}
