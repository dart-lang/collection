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
/// The resulting list has an index operator (`[]`) and `length` property that
/// are both `O(lists)`, rather than `O(1)`, and the list is unmodifiable - but
/// underlying changes to these lists are still accessible from the resulting
/// list.
List/*<T>*/ combineLists/*<T>*/(List<List/*<T>*/> lists) {
  // Small optimization when there are no lists to avoid allocation.
  if (lists.isEmpty) {
    return const [];
  }
  // If there is only a single list then just return wrapped as unmodifiable.
  if (lists.length == 1) {
    return new UnmodifiableListView/*<T>*/(lists.first);
  }
  return new _CombinedList/*<T>*/(lists);
}

class _CombinedList<T> extends ListBase<T> implements UnmodifiableListView<T> {
  static void _throw() {
    throw new UnsupportedError('Cannot modify an unmodifiable List');
  }

  final List<List<T>> _lists;

  _CombinedList(this._lists);

  set length(int length) {
    _throw();
  }

  int get length => _lists.fold(0, (length, list) => length + list.length);

  T operator [](int index) {
    var initialIndex = index;
    for (var i = 0; i < _lists.length; i++) {
      var list = _lists[i];
      if (index < list.length) {
        return list[index];
      }
      index -= list.length;
    }
    throw new RangeError.index(initialIndex, this, 'index', null, length);
  }

  void operator []=(int index, T value) {
    _throw();
  }

  void clear() {
    _throw();
  }

  bool remove(Object element) {
    _throw();
    return null;
  }

  void removeWhere(bool filter(T element)) {
    _throw();
  }

  void retainWhere(bool filter(T element)) {
    _throw();
  }
}
