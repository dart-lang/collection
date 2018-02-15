// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

/// A lazy caching version of [Iterable].
///
/// This iterable is efficient in the following ways:
///
///  * It will not walk the given iterator more than you ask for.
///
///  * If you use it twice (e.g. you check [isNotEmpty], then
///    use [single]), it will only walk the given iterator
///    once. This caching will even work efficiently if you are
///    running two side-by-side iterators on the same iterable.
///
///  * [toList] uses its EfficientLength variant to create its
///    list quickly.
///
/// It is inefficient in the following ways:
///
///  * The first iteration through has caching overhead.
///
///  * It requires more memory than a non-caching iterator.
///
///  * the [length] and [toList] properties immediately precache the
///    entire list. Using these fields therefore loses the laziness of
///    the iterable. However, it still gets cached.
///
/// The caching behavior is propagated to the iterators that are
/// created by [map], [where], [expand], [take], [takeWhile], [skip],
/// and [skipWhile], and is used by the built-in methods that use an
/// iterator like [isNotEmpty] and [single].
///
/// Because a CachingIterable only walks the underlying data once, it
/// cannot be used multiple times with the underlying data changing
/// between each use. You must create a new iterable each time. This
/// also applies to any iterables derived from this one, e.g. as
/// returned by `where`.
class CachingIterable<E> extends IterableBase<E> {
  /// Creates a CachingIterable using the given [Iterator] as the
  /// source of data. The iterator must be non-null and must not throw
  /// exceptions.
  ///
  /// Since the argument is an [Iterator], not an [Iterable], it is
  /// guaranteed that the underlying data set will only be walked
  /// once. If you have an [Iterable], you can pass its [iterator]
  /// field as the argument to this constructor.
  ///
  /// You can use a `sync*` function with this as follows:
  ///
  /// ```dart
  /// Iterable<int> range(int start, int end) sync* {
  ///   for (int index = start; index <= end; index += 1)
  ///     yield index;
  ///  }
  ///
  /// Iterable<int> i = new CachingIterable<int>(range(1, 5).iterator);
  /// print(i.length); // walks the list
  /// print(i.length); // efficient
  /// ```
  CachingIterable(this._prefillIterator);

  final Iterator<E> _prefillIterator;
  final List<E> _results = <E>[];

  @override
  Iterator<E> get iterator {
    return new _LazyListIterator<E>(this);
  }

  @override
  Iterable<T> map<T>(T f(E e)) {
    return new CachingIterable<T>(super.map<T>(f).iterator);
  }

  @override
  Iterable<E> where(bool f(E element)) {
    return new CachingIterable<E>(super.where(f).iterator);
  }

  @override
  Iterable<T> expand<T>(Iterable<T> f(E element)) {
    return new CachingIterable<T>(super.expand<T>(f).iterator);
  }

  @override
  Iterable<E> take(int count) {
    return new CachingIterable<E>(super.take(count).iterator);
  }

  @override
  Iterable<E> takeWhile(bool test(E value)) {
    return new CachingIterable<E>(super.takeWhile(test).iterator);
  }

  @override
  Iterable<E> skip(int count) {
    return new CachingIterable<E>(super.skip(count).iterator);
  }

  @override
  Iterable<E> skipWhile(bool test(E value)) {
    return new CachingIterable<E>(super.skipWhile(test).iterator);
  }

  @override
  int get length {
    _precacheEntireList();
    return _results.length;
  }

  @override
  List<E> toList({bool growable: true}) {
    _precacheEntireList();
    return new List<E>.from(_results, growable: growable);
  }

  void _precacheEntireList() {
    while (_fillNext()) {}
  }

  bool _fillNext() {
    if (!_prefillIterator.moveNext()) return false;
    _results.add(_prefillIterator.current);
    return true;
  }
}

class _LazyListIterator<E> implements Iterator<E> {
  _LazyListIterator(this._owner) : _index = -1;

  final CachingIterable<E> _owner;
  int _index;

  @override
  E get current {
    assert(_index >= 0); // called "current" before "moveNext()"
    if (_index < 0 || _index == _owner._results.length) return null;
    return _owner._results[_index];
  }

  @override
  bool moveNext() {
    if (_index >= _owner._results.length) return false;
    _index += 1;
    if (_index == _owner._results.length) return _owner._fillNext();
    return true;
  }
}
