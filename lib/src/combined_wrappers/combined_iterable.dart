// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

class CombinedIterable<T> extends IterableBase<T> {
  final Iterable<Iterable<T>> _iterables;

  const CombinedIterable(this._iterables);

  @override
  Iterator<T> get iterator =>
      new _CombinedIterator<T>(_iterables.map((i) => i.iterator).iterator);
}

class _CombinedIterator<T> implements Iterator<T> {
  final Iterator<Iterator<T>> _iterators;

  _CombinedIterator(this._iterators);

  @override
  T get current => _iterators.current?.current;

  @override
  bool moveNext() =>
      _iterators.current?.moveNext() == true ||
      _iterators.moveNext();
}