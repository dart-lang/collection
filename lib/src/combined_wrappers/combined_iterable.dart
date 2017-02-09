// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

class CombinedIterable<T> extends IterableBase<T> {
  final Iterable<Iterable<T>> _iterables;

  const CombinedIterable(this._iterables);

  // TODO: implement iterator
  @override
  Iterator<T> get iterator => null;
}
