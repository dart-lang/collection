// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection' show IterableBase;

import 'wrappers.dart';

export "dart:collection" show UnmodifiableListView, UnmodifiableMapView;

/// A fixed-length list.
///
/// A `NonGrowableListView` contains a [List] object and ensures that
/// its length does not change.
/// Methods that would change the length of the list,
/// such as [add] and [remove], throw an [UnsupportedError].
/// All other methods work directly on the underlying list.
///
/// This class _does_ allow changes to the contents of the wrapped list.
/// You can, for example, [sort] the list.
/// Permitted operations defer to the wrapped list.
class NonGrowableListView<E> extends DelegatingList<E>
                             with NonGrowableListMixin<E> {
  NonGrowableListView(List<E> listBase) : super(listBase);
}

/// Mixin class that implements a throwing version of all list operations that
/// change the List's length.
abstract class NonGrowableListMixin<E> implements List<E> {
  static /*=T*/ _throw/*<T>*/() {
    throw new UnsupportedError(
        "Cannot change the length of a fixed-length list");
  }

  /// Throws an [UnsupportedError];
  /// operations that change the length of the list are disallowed.
  void set length(int newLength) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the length of the list are disallowed.
  bool add(E value) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the length of the list are disallowed.
  void addAll(Iterable<E> iterable) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the length of the list are disallowed.
  void insert(int index, E element) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the length of the list are disallowed.
  void insertAll(int index, Iterable<E> iterable) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the length of the list are disallowed.
  bool remove(Object value) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the length of the list are disallowed.
  E removeAt(int index) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the length of the list are disallowed.
  E removeLast() => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the length of the list are disallowed.
  void removeWhere(bool test(E element)) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the length of the list are disallowed.
  void retainWhere(bool test(E element)) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the length of the list are disallowed.
  void removeRange(int start, int end) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the length of the list are disallowed.
  void replaceRange(int start, int end, Iterable<E> iterable) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the length of the list are disallowed.
  void clear() => _throw();
}

/// An unmodifiable set.
///
/// An UnmodifiableSetView contains a [Set] object and ensures
/// that it does not change.
/// Methods that would change the set,
/// such as [add] and [remove], throw an [UnsupportedError].
/// Permitted operations defer to the wrapped set.
class UnmodifiableSetView<E> extends DelegatingSet<E>
    with UnmodifiableSetMixin<E> {
  UnmodifiableSetView(Set<E> setBase) : super(setBase);

  /// Returns an unmodifiable empty set.
  const factory UnmodifiableSetView.empty() = _EmptyUnmodifiableSet<E>;
}

/// An unmodifiable empty set that doesn't allow adding-operations.
/// Removing-operations are ok, because the don't modify the contents of an
/// empty set.
// A super class with const constructor is needed, so IterableBase<E> fits.
class _EmptyUnmodifiableSet<E> extends IterableBase<E>
    implements UnmodifiableSetView<E> {
  static /*=T*/ _throw/*<T>*/() {
    throw new UnsupportedError(
        "Cannot call modifying operations on an unmodifiable Set");
  }

  /// Returns an empty Iterator.
  // new Iterabel.generate(0).iterator reduces to
  // new EmptyIterable().iterator so this should be efficient.
  Iterator<E> get _emptyIterator => new Iterable<E>.generate(0).iterator;

  /// Returns always an empty Iterator;
  @override
  Iterator<E> get iterator => _emptyIterator;

  /// Returns always 0;
  /// The length of en empty Set fixed to 0.
  @override
  int get length => 0;

  const _EmptyUnmodifiableSet();

  /// Throws an [UnsupportedError];
  /// modifying operations are disallowed on unmodifiable sets.
  @override
  bool add(E value) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that add to the set are disallowed.
  @override
  void addAll(Iterable<E> elements) => _throw();

  /// Throws an [UnsupportedError];
  /// modifying operations are disallowed on unmodifiable sets.
  @override
  void clear() => _throw();

  /// Returns always false;
  /// The empty set doesn't contain any elements.
  @override
  bool contains(Object element) => false;

  /// Returns true if other is empty, else false:
  @override
  bool containsAll(Iterable<Object> other) => other.isEmpty;

  /// Returns always null;
  /// The empty set doesn't contain any elements and therefore returns null.
  @override
  E lookup(Object element) => null;

  /// Throws an [UnsupportedError];
  /// modifying operations are disallowed on unmodifiable sets.
  @override
  bool remove(Object element) => _throw();

  /// Throws an [UnsupportedError];
  /// modifying operations are disallowed on unmodifiable sets.
  @override
  void removeAll(Iterable<Object> elements) => _throw();

  /// Throws an [UnsupportedError];
  /// modifying operations are disallowed on unmodifiable sets.
  @override
  void removeWhere(bool test(E element)) => _throw();

  /// Throws an [UnsupportedError];
  /// modifying operations are disallowed on unmodifiable sets.
  @override
  void retainWhere(bool test(E element)) => _throw();

  /// Throws an [UnsupportedError];
  /// modifying operations are disallowed on unmodifiable sets.
  @override
  void retainAll(Iterable<Object> elements) => _throw();

  /// Returns itself because the behaviour (in regards to add(), remove())
  /// of the returning Set<E> should be the same.
  @override
  Set<E> toSet() => this;

  /// Returns a copy of other;
  /// union with an empty set leads to a copy.
  @override
  Set<E> union(Set<E> other) => new Set.from(other);

  /// Returns an empty set;
  /// there are no elements in this (empty) set that are also in other.
  @override
  Set<E> intersection(Set<Object> other) => new Set();

  /// Returns an empty set;
  /// there are no elements in this (empty) set that aren't in other.
  @override
  Set<E> difference(Set<Object> other) => new Set();
}


/// Mixin class that implements a throwing version of all set operations that
/// change the Set.
abstract class UnmodifiableSetMixin<E> implements Set<E> {
  static /*=T*/ _throw/*<T>*/() {
    throw new UnsupportedError("Cannot modify an unmodifiable Set");
  }

  /// Throws an [UnsupportedError];
  /// operations that change the set are disallowed.
  bool add(E value) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the set are disallowed.
  void addAll(Iterable<E> elements) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the set are disallowed.
  bool remove(Object value) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the set are disallowed.
  void removeAll(Iterable elements) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the set are disallowed.
  void retainAll(Iterable elements) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the set are disallowed.
  void removeWhere(bool test(E element)) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the set are disallowed.
  void retainWhere(bool test(E element)) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the set are disallowed.
  void clear() => _throw();
}

/// Mixin class that implements a throwing version of all map operations that
/// change the Map.
abstract class UnmodifiableMapMixin<K, V> implements Map<K, V> {
  static /*=T*/ _throw/*<T>*/() {
    throw new UnsupportedError("Cannot modify an unmodifiable Map");
  }

  /// Throws an [UnsupportedError];
  /// operations that change the map are disallowed.
  void operator []=(K key, V value) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the map are disallowed.
  V putIfAbsent(K key, V ifAbsent()) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the map are disallowed.
  void addAll(Map<K, V> other) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the map are disallowed.
  V remove(Object key) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the map are disallowed.
  void clear() => _throw();
}
