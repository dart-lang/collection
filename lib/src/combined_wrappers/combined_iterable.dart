// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

/// Returns a new iterable that represents iterables accessed sequentially.
///
/// All methods and accessors treat the new iterable as-if it were a single
/// sequence, but the underlying implementation is based on lazily accessing
/// individual iterable instances.
class CombinedIterableView<T> extends IterableBase<T> {
  final Iterable<Iterable<T>> _iterables;

  const CombinedIterableView(this._iterables);

  Iterator<T> get iterator =>
      new _CombinedIterator<T>(_iterables.map((i) => i.iterator).iterator);

  // Special cased isEmpty/length since many iterables have an efficient
  // implementation instead of running through the entire iterator.

  bool get isEmpty => _iterables.every((i) => i.isEmpty);

  int get length => _iterables.fold(0, (length, i) => length + i.length);
}

class _CombinedIterator<T> implements Iterator<T> {
  final Iterator<Iterator<T>> _iterators;

  _CombinedIterator(this._iterators);

  T get current => _iterators.current?.current;

  @override
  bool moveNext() {
    var current = _iterators.current;
    if (current != null && current.moveNext()) {
      return true;
    }
    return _iterators.moveNext() && moveNext();
  }
}
