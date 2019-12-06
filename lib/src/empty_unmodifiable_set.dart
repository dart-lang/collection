// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'unmodifiable_wrappers.dart';

// Unfortunately, we can't use UnmodifiableSetMixin here, since const classes
// can't use mixins.
/// An unmodifiable, empty set that can have a const constructor.
class EmptyUnmodifiableSet<E> extends IterableBase<E>
    implements UnmodifiableSetView<E> {
  static T _throw<T>() {
    throw UnsupportedError('Cannot modify an unmodifiable Set');
  }

  @override
  Iterator<E> get iterator => Iterable<E>.empty().iterator;
  @override
  int get length => 0;

  const EmptyUnmodifiableSet();

  @override
  EmptyUnmodifiableSet<T> cast<T>() => EmptyUnmodifiableSet<T>();
  @override
  bool contains(Object element) => false;
  @override
  bool containsAll(Iterable<Object> other) => other.isEmpty;
  @override
  Iterable<E> followedBy(Iterable<E> other) => Set.from(other);
  @override
  E lookup(Object element) => null;
  @deprecated
  @override
  EmptyUnmodifiableSet<T> retype<T>() => EmptyUnmodifiableSet<T>();
  @override
  E singleWhere(bool Function(E) test, {E Function() orElse}) =>
      super.singleWhere(test);
  @override
  Iterable<T> whereType<T>() => EmptyUnmodifiableSet<T>();
  @override
  Set<E> toSet() => {};
  @override
  Set<E> union(Set<E> other) => Set.from(other);
  @override
  Set<E> intersection(Set<Object> other) => {};
  @override
  Set<E> difference(Set<Object> other) => {};

  @override
  bool add(E value) => _throw();
  @override
  void addAll(Iterable<E> elements) => _throw();
  @override
  void clear() => _throw();
  @override
  bool remove(Object element) => _throw();
  @override
  void removeAll(Iterable<Object> elements) => _throw();
  @override
  void removeWhere(bool Function(E) test) => _throw();
  @override
  void retainWhere(bool Function(E) test) => _throw();
  @override
  void retainAll(Iterable<Object> elements) => _throw();
}
