import 'package:cloud_firestore/cloud_firestore.dart';

/// Fluent query builder. Each method returns a new builder, so chains stay
/// declarative:
///
/// ```dart
/// repo.query()
///   .where('ownerId', isEqualTo: uid)
///   .orderBy('createdAt', descending: true)
///   .limit(20)
///   .get();
/// ```
class FirestoreQueryBuilder {
  final List<_WhereClause> _wheres;
  final List<_OrderClause> _orderBys;
  final int? _limit;
  final int? _limitToLast;
  final Object? _startAfter;

  const FirestoreQueryBuilder() : this._();

  const FirestoreQueryBuilder._({
    List<_WhereClause> wheres = const [],
    List<_OrderClause> orderBys = const [],
    int? limit,
    int? limitToLast,
    Object? startAfter,
  })  : _wheres = wheres,
        _orderBys = orderBys,
        _limit = limit,
        _limitToLast = limitToLast,
        _startAfter = startAfter;

  FirestoreQueryBuilder where(
    String field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
  }) {
    return FirestoreQueryBuilder._(
      wheres: [
        ..._wheres,
        _WhereClause(
          field: field,
          isEqualTo: isEqualTo,
          isNotEqualTo: isNotEqualTo,
          isLessThan: isLessThan,
          isLessThanOrEqualTo: isLessThanOrEqualTo,
          isGreaterThan: isGreaterThan,
          isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
          arrayContains: arrayContains,
          arrayContainsAny: arrayContainsAny,
          whereIn: whereIn,
          whereNotIn: whereNotIn,
          isNull: isNull,
        )
      ],
      orderBys: _orderBys,
      limit: _limit,
      limitToLast: _limitToLast,
      startAfter: _startAfter,
    );
  }

  FirestoreQueryBuilder orderBy(String field, {bool descending = false}) {
    return FirestoreQueryBuilder._(
      wheres: _wheres,
      orderBys: [..._orderBys, _OrderClause(field, descending)],
      limit: _limit,
      limitToLast: _limitToLast,
      startAfter: _startAfter,
    );
  }

  FirestoreQueryBuilder limit(int n) => FirestoreQueryBuilder._(
        wheres: _wheres,
        orderBys: _orderBys,
        limit: n,
        limitToLast: _limitToLast,
        startAfter: _startAfter,
      );

  FirestoreQueryBuilder limitToLast(int n) => FirestoreQueryBuilder._(
        wheres: _wheres,
        orderBys: _orderBys,
        limit: _limit,
        limitToLast: n,
        startAfter: _startAfter,
      );

  FirestoreQueryBuilder startAfterDocument(DocumentSnapshot doc) =>
      FirestoreQueryBuilder._(
        wheres: _wheres,
        orderBys: _orderBys,
        limit: _limit,
        limitToLast: _limitToLast,
        startAfter: doc,
      );

  /// Applies this builder onto a Firestore [Query] reference.
  Query<Map<String, dynamic>> apply(Query<Map<String, dynamic>> base) {
    Query<Map<String, dynamic>> q = base;
    for (final w in _wheres) {
      q = q.where(
        w.field,
        isEqualTo: w.isEqualTo,
        isNotEqualTo: w.isNotEqualTo,
        isLessThan: w.isLessThan,
        isLessThanOrEqualTo: w.isLessThanOrEqualTo,
        isGreaterThan: w.isGreaterThan,
        isGreaterThanOrEqualTo: w.isGreaterThanOrEqualTo,
        arrayContains: w.arrayContains,
        arrayContainsAny: w.arrayContainsAny,
        whereIn: w.whereIn,
        whereNotIn: w.whereNotIn,
        isNull: w.isNull,
      );
    }
    for (final o in _orderBys) {
      q = q.orderBy(o.field, descending: o.descending);
    }
    final after = _startAfter;
    if (after is DocumentSnapshot) {
      q = q.startAfterDocument(after);
    }
    final lim = _limit;
    if (lim != null) q = q.limit(lim);
    final limLast = _limitToLast;
    if (limLast != null) q = q.limitToLast(limLast);
    return q;
  }
}

class _WhereClause {
  final String field;
  final Object? isEqualTo;
  final Object? isNotEqualTo;
  final Object? isLessThan;
  final Object? isLessThanOrEqualTo;
  final Object? isGreaterThan;
  final Object? isGreaterThanOrEqualTo;
  final Object? arrayContains;
  final List<Object?>? arrayContainsAny;
  final List<Object?>? whereIn;
  final List<Object?>? whereNotIn;
  final bool? isNull;

  const _WhereClause({
    required this.field,
    this.isEqualTo,
    this.isNotEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
    this.isNull,
  });
}

class _OrderClause {
  final String field;
  final bool descending;
  const _OrderClause(this.field, this.descending);
}
