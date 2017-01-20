// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

/// Returns a new list that represents [lists] flattened into a single list.
///
/// All methods and accessors treat the new list as-if it were a single
/// concatenated list, but the underlying implementation is based on lazily
/// accessing individual list instances.
///
/// The returned list is unmodifiable.
List/*<T>*/ combineLists/*<T>*/(List<List/*<T>*/> lists) {
  return new _CombinedList/*<T>*/(lists);
}

class _CombinedList<T> extends ListBase<T> implements UnmodifiableListView<T> {
  static void _throw() {
    throw new UnsupportedError('Cannot modify an unmodifiable List');
  }

  final List<List<T>> _lists;

  _CombinedList(this._lists);

  @override
  set length(int length) {
    _throw();
  }

  @override
  int get length => _lists.fold(0, (length, list) => length + list.length);

  @override
  T operator [](int index) {
    final initialIndex = index;
    for (var i = 0; i < _lists.length; i++) {
      var list = _lists[i];
      if (index < list.length) {
        return list[index];
      }
      index -= list.length;
    }
    throw new RangeError.value(initialIndex, 'index', 'Length of $length');
  }

  @override
  void operator []=(int index, T value) {
    _throw();
  }

  @override
  void clear() {
    _throw();
  }

  @override
  bool remove(Object element) {
    _throw();
    return null;
  }

  @override
  void removeWhere(bool filter(T element)) {
    _throw();
  }

  @override
  void retainWhere(bool filter(T element)) {
    _throw();
  }
}
