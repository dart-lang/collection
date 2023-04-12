// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'comparators.dart';

const int _hashMask = 0x7fffffff;

/// A generic equality relation on objects.
abstract class Equality<E> {
  const factory Equality() = DefaultEquality<E>;

  /// Compare two elements for being equal.
  ///
  /// This should be a proper equality relation, meaning that it is:
  /// * Reflexive. For all applicable values `v`, `eq.equals(v, v)` must
  ///   be true.
  /// * Symmetric. For all applicable values `v1` and `v2`,
  ///   `eq.equals(v1, v2)` must give the same result as `eq.equals(v2, v1)`.
  /// * Transitive. For all applicable values `v1`, `v2` and `v3`,
  ///   if `eq.equals(v1, v2)` and `eq.equals(v2, v3)` are both true,
  ///   then `eq.equals(v1, v3)` must also be true.
  bool equals(E e1, E e2);

  /// Get a hashcode of an element.
  ///
  /// The hashcode should be compatible with [equals], so that if
  /// `eq.equals(a, b)` then `eq.hash(a) == eq.hash(b)`.
  int hash(E e);

  /// Test whether an object is a valid argument to [equals] and [hash].
  ///
  /// Some implementations may be restricted to only work on specific kinds
  /// of objects.
  bool isValidKey(Object? o);
}

/// Equality of objects based on derived values.
///
/// For example, given the class:
/// ```dart
/// abstract class Employee {
///   int get employmentId;
/// }
/// ```
///
/// The following [Equality] considers employees with the same IDs to be equal:
/// ```dart
/// EqualityBy((Employee e) => e.employmentId);
/// ```
///
/// It's also possible to pass an additional equality instance that should be
/// used to compare the value itself.
class EqualityBy<E, F> implements Equality<E> {
  final F Function(E) _comparisonKey;

  final Equality<F> _inner;

  /// Creates equality which compares objects by [comparisonKey].
  ///
  /// The values extraced from objects by [comparisonKey]
  /// are compared and hashed using the [inner] equality,
  /// which defaults to [Object.==] and [Object.hashCode].
  EqualityBy(F Function(E) comparisonKey,
      [Equality<F> inner = const DefaultEquality<Never>()])
      : _comparisonKey = comparisonKey,
        _inner = inner;

  @override
  bool equals(E e1, E e2) =>
      _inner.equals(_comparisonKey(e1), _comparisonKey(e2));

  @override
  int hash(E e) => _inner.hash(_comparisonKey(e));

  @override
  bool isValidKey(Object? o) => o is E && _inner.isValidKey(_comparisonKey(o));
}

/// Equality of objects that compares only the natural equality of the objects.
///
/// This equality uses the objects' own [Object.==] and [Object.hashCode] for
/// the equality.
///
/// Works on any object, no matter which type argument is provided.
class DefaultEquality<E> implements Equality<E> {
  const DefaultEquality._();
  const factory DefaultEquality() = DefaultEquality<Never>._;
  @override
  bool equals(Object? e1, Object? e2) => e1 == e2;
  @override
  int hash(Object? e) => e.hashCode;
  @override
  bool isValidKey(Object? o) => true;
}

/// Equality of objects that compares only the identity of the objects.
///
/// Uses [identical] for [equals] and [identityHashCode] for [hash].
///
/// Works on any object, no matter which type argument is provided.
class IdentityEquality<E> implements Equality<E> {
  const IdentityEquality._();
  const factory IdentityEquality() = IdentityEquality<Never>._;
  @override
  bool equals(Object? e1, Object? e2) => identical(e1, e2);
  @override
  int hash(Object? e) => identityHashCode(e);
  @override
  bool isValidKey(Object? o) => true;
}

/// Equality on iterables.
///
/// Two iterables are equal if they have the same elements in the same order.
///
/// The [equals] and [hash] methods accepts `null` values,
/// even if the [isValidKey] returns `false` for `null`.
/// The [hash] of `null` is always `null.hashCode`.
class IterableEquality<E> implements Equality<Iterable<E>> {
  final Equality<E?> _elementEquality;
  const IterableEquality(
      [Equality<E> elementEquality = const DefaultEquality<Never>()])
      : _elementEquality = elementEquality;

  @override
  bool equals(Iterable<E>? elements1, Iterable<E>? elements2) {
    if (identical(elements1, elements2)) return true;
    if (elements1 == null || elements2 == null) return false;
    var it1 = elements1.iterator;
    var it2 = elements2.iterator;
    bool more1;
    bool more2;
    while ((more1 = it1.moveNext()) & (more2 = it2.moveNext())) {
      if (!_elementEquality.equals(it1.current, it2.current)) return false;
    }
    return more1 == more2;
  }

  @override
  int hash(Iterable<E>? elements) {
    if (elements == null) return null.hashCode;
    // Jenkins's one-at-a-time hash function.
    var hash = 0;
    for (var element in elements) {
      var c = _elementEquality.hash(element);
      hash = (hash + c) & _hashMask;
      hash = (hash + (hash << 10)) & _hashMask;
      hash ^= (hash >> 6);
    }
    hash = (hash + (hash << 3)) & _hashMask;
    hash ^= (hash >> 11);
    hash = (hash + (hash << 15)) & _hashMask;
    return hash;
  }

  @override
  bool isValidKey(Object? o) => o is Iterable<E>;
}

/// Equality on lists.
///
/// Two lists are equal if they have the same length and their elements
/// at each index are equal.
///
/// This is effectively the same as [IterableEquality] except that it
/// accesses elements by index instead of through iteration.
///
/// The [equals] and [hash] methods accepts `null` values,
/// even if the [isValidKey] returns `false` for `null`.
/// The [hash] of `null` is `null.hashCode`.
class ListEquality<E> implements Equality<List<E>> {
  final Equality<E> _elementEquality;
  const ListEquality(
      [Equality<E> elementEquality = const DefaultEquality<Never>()])
      : _elementEquality = elementEquality;

  @override
  bool equals(List<E>? list1, List<E>? list2) {
    if (identical(list1, list2)) return true;
    if (list1 == null || list2 == null) return false;
    var length = list1.length;
    if (length != list2.length) return false;
    for (var i = 0; i < length; i++) {
      if (!_elementEquality.equals(list1[i], list2[i])) return false;
    }
    return true;
  }

  @override
  int hash(List<E>? list) {
    if (list == null) return null.hashCode;
    // Jenkins's one-at-a-time hash function.
    // This code is almost identical to the one in IterableEquality, except
    // that it uses indexing instead of iterating to get the elements.
    var hash = 0;
    for (var i = 0; i < list.length; i++) {
      var c = _elementEquality.hash(list[i]);
      hash = (hash + c) & _hashMask;
      hash = (hash + (hash << 10)) & _hashMask;
      hash ^= (hash >> 6);
    }
    hash = (hash + (hash << 3)) & _hashMask;
    hash ^= (hash >> 11);
    hash = (hash + (hash << 15)) & _hashMask;
    return hash;
  }

  @override
  bool isValidKey(Object? o) => o is List<E>;
}

abstract class _UnorderedEquality<E, T extends Iterable<E>>
    implements Equality<T> {
  final Equality<E> _elementEquality;

  const _UnorderedEquality(this._elementEquality);

  @override
  bool equals(T? elements1, T? elements2) {
    if (identical(elements1, elements2)) return true;
    if (elements1 == null || elements2 == null) return false;
    var counts = HashMap<E, int>(
        equals: _elementEquality.equals,
        hashCode: _elementEquality.hash,
        isValidKey: _elementEquality.isValidKey);
    var length = 0;
    for (var e in elements1) {
      var count = counts[e] ?? 0;
      counts[e] = count + 1;
      length++;
    }
    for (var e in elements2) {
      var count = counts[e];
      if (count == null || count == 0) return false;
      counts[e] = count - 1;
      length--;
    }
    return length == 0;
  }

  @override
  int hash(T? elements) {
    if (elements == null) return null.hashCode;
    var hash = 0;
    for (E element in elements) {
      var c = _elementEquality.hash(element);
      hash = (hash + c) & _hashMask;
    }
    hash = (hash + (hash << 3)) & _hashMask;
    hash ^= (hash >> 11);
    hash = (hash + (hash << 15)) & _hashMask;
    return hash;
  }
}

/// Equality of the elements of two iterables without considering order.
///
/// Two iterables are considered equal if they have the same number of elements,
/// and the elements of one set can be paired with the elements
/// of the other iterable, so that each pair are equal.
class UnorderedIterableEquality<E> extends _UnorderedEquality<E, Iterable<E>> {
  const UnorderedIterableEquality(
      [super.elementEquality = const DefaultEquality<Never>()]);

  @override
  bool isValidKey(Object? o) => o is Iterable<E>;
}

/// Equality of sets.
///
/// Two sets are considered equal if they have the same number of elements,
/// and the elements of one set are also elements of the other,
/// according to the other set, and the actual elements are equal
/// according to the element equality.
///
/// Sets have an inherent notion of equality (and sometimes hash code)
/// of elements. Thesets being compared should have compatiable notions
/// of equality, and the element equality provided in the constructor should
/// agree with the sets as well.
/// If not, the equality and hash reported by this class may disagree with
/// the sets' behavior, and the equality may not be symmetric.
///
/// This equality differs from [UnorderedIterableEquality] in that
/// it uses [Set.contains] to match elements of one set to elements
/// of the other, instead of matching up elements itself.
/// This assumes that the equality of the second set is compatible
/// with the element equality.
///
/// The [equals] and [hash] methods accepts `null` values,
/// even if the [isValidKey] returns `false` for `null`.
/// The [hash] of `null` is `null.hashCode`.
class SetEquality<E> extends _UnorderedEquality<E, Set<E>> {
  const SetEquality([super.elementEquality = const DefaultEquality<Never>()]);

  @override
  bool equals(Set<E>? elements1, Set<E>? elements2) {
    if (identical(elements1, elements2)) return true;
    if (elements1 == null || elements2 == null) return false;
    var length = elements1.length;
    if (length != elements2.length) return false;
    for (var element1 in elements1) {
      var element2 = elements2.lookup(element1);
      // Type promotion cannot join `E` and `E & Object` into `E`.
      E nonNullableElement2;
      if (element2 == null) {
        if (element2 is! E || !elements2.contains(element1)) return false;
        nonNullableElement2 = element2; // type `E`
      } else {
        nonNullableElement2 = element2; // type `E & Object`
      }
      if (!_elementEquality.equals(element1, nonNullableElement2)) return false;
    }
    return true;
  }

  @override
  bool isValidKey(Object? o) => o is Set<E>;
}

/// Equality on maps.
///
/// Two maps are equal if they have the same number of entries, and if the
/// keys of one map are also keys of the other map,
/// and they have equal values.
///
/// Maps have an inherent notion of equality (and sometimes hash code)
/// of keys. The maps being compared should have compatiable notions
/// of equality, and the key equality provided in the constructor should
/// agree with the maps as well.
/// If not, the equality and hash reported by this class may disagree with
/// the maps' behavior, and the equality may not be symmetric.
///
/// The [equals] and [hash] methods accepts `null` values,
/// even if the [isValidKey] returns `false` for `null`.
/// The [hash] of `null` is `null.hashCode`.
///
/// The `keys` equality is only used for computing [hash].
/// The [equals] method only uses keys from one map to
/// look up in the other map.
class MapEquality<K, V> implements Equality<Map<K, V>> {
  final Equality<K> _keyEquality;
  final Equality<V> _valueEquality;
  const MapEquality(
      {Equality<K> keys = const DefaultEquality<Never>(),
      Equality<V> values = const DefaultEquality<Never>()})
      : _keyEquality = keys,
        _valueEquality = values;

  @override
  bool equals(Map<K, V>? map1, Map<K, V>? map2) {
    if (identical(map1, map2)) return true;
    if (map1 == null || map2 == null) return false;
    var length = map1.length;
    if (length != map2.length) return false;
    for (var entry in map1.entries) {
      var key = entry.key;
      var value1 = entry.value;
      var value2 = map2[key];
      // Type inference cannot join `V` and `V & Object` below.
      V nonNullableValue2;
      if (value2 == null) {
        // Either `V` accepts `null`, `map2` does not contain `key`, or both.
        if (value2 is! V || !map2.containsKey(key)) {
          return false;
        }
        nonNullableValue2 = value2;
      } else {
        nonNullableValue2 = value2;
      }
      if (!_valueEquality.equals(value1, nonNullableValue2)) {
        return false;
      }
    }
    return true;
  }

  @override
  int hash(Map<K, V>? map) {
    if (map == null) return null.hashCode;
    var hash = 0;
    // Unordered hash code.
    for (var entry in map.entries) {
      var keyHash = _keyEquality.hash(entry.key);
      var valueHash = _valueEquality.hash(entry.value);
      hash = (hash + 3 * keyHash + 7 * valueHash) & _hashMask;
    }
    hash = (hash + (hash << 3)) & _hashMask;
    hash ^= (hash >> 11);
    hash = (hash + (hash << 15)) & _hashMask;
    return hash;
  }

  @override
  bool isValidKey(Object? o) => o is Map<K, V>;
}

/// Combines several equalities into a single equality.
///
/// Tries each equality in order, using [Equality.isValidKey], and returns
/// the result of the first equality that applies to the argument or arguments.
///
/// For `equals`, the first equality that matches the first argument is used,
/// and if the second argument of `equals` is not valid for that equality,
/// it returns false.
///
/// Because the equalities are tried in order, they should generally work on
/// disjoint types. Otherwise the multi-equality may give inconsistent results
/// for `equals(e1, e2)` and `equals(e2, e1)`. This can happen if one equality
/// considers only `e1` a valid key, and not `e2`, but an equality which is
/// checked later, allows both.
class MultiEquality<E> implements Equality<E> {
  final Iterable<Equality<E>> _equalities;

  const MultiEquality(Iterable<Equality<E>> equalities)
      : _equalities = equalities;

  @override
  bool equals(E e1, E e2) {
    for (var eq in _equalities) {
      if (eq.isValidKey(e1)) return eq.isValidKey(e2) && eq.equals(e1, e2);
    }
    return false;
  }

  @override
  int hash(E e) {
    for (var eq in _equalities) {
      if (eq.isValidKey(e)) return eq.hash(e);
    }
    return 0;
  }

  @override
  bool isValidKey(Object? o) {
    for (var eq in _equalities) {
      if (eq.isValidKey(o)) return true;
    }
    return false;
  }
}

/// Deep equality on collections.
///
/// Recognizes lists, sets, iterables and maps and compares their elements using
/// deep equality as well.
///
/// Non-iterable/map objects are compared using a configurable base equality.
///
/// Works in one of two modes: ordered or unordered.
///
/// In ordered mode, lists and iterables are required to have equal elements
/// in the same order. In unordered mode, the order of elements in iterables
/// and lists are not important.
///
/// A list is only equal to another list, likewise for sets and maps. All other
/// iterables are compared as iterables only.
class DeepCollectionEquality implements Equality<Object?> {
  final Equality _base;
  final bool _unordered;
  const DeepCollectionEquality(
      [Equality<Object?> base = const DefaultEquality<Never>()])
      : _base = base,
        _unordered = false;

  /// Creates a deep equality on collections where the order of lists and
  /// iterables are not considered important. That is, lists and iterables are
  /// treated as unordered iterables.
  const factory DeepCollectionEquality.unordered([Equality base]) =
      _UnorderedDeepCollectionEquality;

  const DeepCollectionEquality._(this._base, this._unordered);

  @override
  bool equals(Object? e1, Object? e2) {
    if (identical(e1, e2)) return true;
    if (e1 == null || e2 == null) return false;
    return _equals(e1, e2);
  }

  bool _equals(Object? e1, Object? e2) {
    if (e1 is Set) {
      return e2 is Set && SetEquality(this).equals(e1, e2);
    }
    if (e1 is Map) {
      return e2 is Map && MapEquality(keys: this, values: this).equals(e1, e2);
    }
    if (!_unordered) {
      if (e1 is List) {
        return e2 is List && ListEquality(this).equals(e1, e2);
      }
      if (e1 is Iterable) {
        return e2 is Iterable && IterableEquality(this).equals(e1, e2);
      }
    } else if (e1 is Iterable) {
      if (e1 is List != e2 is List) return false;
      return e2 is Iterable && UnorderedIterableEquality(this).equals(e1, e2);
    }
    return _base.equals(e1, e2);
  }

  @override
  int hash(Object? o) {
    if (o == null) return o.hashCode;
    if (o is Set) return SetEquality(this).hash(o);
    if (o is Map) return MapEquality(keys: this, values: this).hash(o);
    if (!_unordered) {
      if (o is List) return ListEquality(this).hash(o);
      if (o is Iterable) return IterableEquality(this).hash(o);
    } else if (o is Iterable) {
      return UnorderedIterableEquality(this).hash(o);
    }
    return _base.hash(o);
  }

  @override
  bool isValidKey(Object? o) =>
      o is Iterable || o is Map || _base.isValidKey(o);
}

/// Entry used to cache hash code and equality of an object in an
/// unordered deep collection equality.
class _EqualityCache {
  final Map<Object?, bool> cachedEquals = Map.identity();
  int? hash;
  bool? operator [](Object? second) => cachedEquals[second];
  void operator []=(Object? second, bool value) {
    cachedEquals[second] = value;
  }
}

class _UnorderedDeepCollectionEquality extends DeepCollectionEquality {
  /// Cache used when doing deep unordered equality.
  ///
  /// Avoids recomputing hash and equality of sub-expressions that
  /// have already been checked.
  /// Needed because unordered comparison stores values in
  /// hash tables, and therefore performes repeated hashing and
  /// equality, and for nested collections, that can have exponential
  /// time complexity in the depth of the structure.
  static Map<Object?, _EqualityCache>? _deepEqualityCache;

  const _UnorderedDeepCollectionEquality(
      [Equality<Object?> base = const DefaultEquality<Never>()])
      : super._(base, true);

  @override
  bool equals(Object? e1, Object? e2) {
    if (identical(e1, e2)) return true;
    if (e1 == null || e2 == null) return false;
    var equalityCache = _deepEqualityCache;
    if (equalityCache != null) {
      return (equalityCache[e1] ??= _EqualityCache())[e2] ??=
          super._equals(e1, e2);
    }
    return _equalsNewCache(e1, e2);
  }

  bool _equalsNewCache(e1, e2) {
    var equalityCache = _deepEqualityCache = Map.identity();
    try {
      return (equalityCache[e1] = _EqualityCache())[e2] = super._equals(e1, e2);
    } finally {
      _deepEqualityCache = null;
    }
  }

  @override
  int hash(Object? o) {
    var equalityCache = _deepEqualityCache;
    if (equalityCache == null) return super.hash(o);
    return (equalityCache[o] ??= _EqualityCache()).hash ??= super.hash(o);
  }

  @override
  bool isValidKey(Object? o) =>
      o is Iterable || o is Map || _base.isValidKey(o);
}

/// String equality that's insensitive to differences in ASCII case.
///
/// Non-ASCII characters are compared as-is, with no conversion.
class CaseInsensitiveEquality implements Equality<String> {
  const CaseInsensitiveEquality();

  @override
  bool equals(String string1, String string2) =>
      equalsIgnoreAsciiCase(string1, string2);

  @override
  int hash(String string) => hashIgnoreAsciiCase(string);

  @override
  bool isValidKey(Object? object) => object is String;
}

/// Deep equality on JSON-like object structures.
///
/// JSON-like objects can be:
/// * Lists of JSON-like objects.
/// * Maps with `String` keys and JSON-like objects as values.
/// * Other objects compared by normal `==`.
///
/// Lists are considered equal if they have the same length
/// and the elements at each index are equal.
/// Maps are considered equal if they have the same string keys
/// and their values for each key are equal.
/// Such maps are assumed to be normal maps using `==` as key equality.
///
/// This equality treat any value which is not
/// a `List<Object?>` or `Map<Object?, Object?>`
/// as a plain value to be compared using `==`.
///
/// Normal JSON structures only contain
/// strings, numbers, booleans and `null` as such values,
/// and only strings as map keys.
/// This equality accepts any other value too, and uses `==` equality
/// on those as well.
class JsonEquality implements Equality<Object?> {
  const JsonEquality();

  @override
  bool equals(Object? e1, Object? e2) {
    if (e1 == e2) return true;
    if (e1 is List) {
      if (e2 is! List) return false;
      return const ListEquality(JsonEquality()).equals(e1, e2);
    }
    if (e1 is Map<Object?, Object?>) {
      if (e2 is! Map<Object?, Object?>) return false;
      // Uses `DefaultEquality` for keys.
      return const MapEquality<Object?, Object?>(values: JsonEquality())
          .equals(e1, e2);
    }
    return false;
  }

  @override
  int hash(Object? e) {
    if (e is List) return const ListEquality(JsonEquality()).hash(e);
    if (e is Map<String, Object?>) {
      return const MapEquality<Object?, Object?>(values: JsonEquality())
          .hash(e);
    }
    return e.hashCode;
  }

  @override
  bool isValidKey(Object? o) => true;
}
