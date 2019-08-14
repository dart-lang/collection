// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'combined_iterable.dart';

/// Returns a new map that represents maps flattened into a single map.
///
/// All methods and accessors treat the new map as-if it were a single
/// concatenated map, but the underlying implementation is based on lazily
/// accessing individual map instances. In the occasion where a key occurs in
/// multiple maps the first value is returned.
///
/// The resulting map has an index operator (`[]`) and `length` property that
/// are both `O(maps)`, rather than `O(1)`, and the map is unmodifiable - but
/// underlying changes to these maps are still accessible from the resulting
/// map.
class CombinedMapView<K, V> extends UnmodifiableMapBase<K, V> {
  final Iterable<Map<K, V>> _maps;

  /// Create a new combined view into multiple maps.
  ///
  /// The iterable is accessed lazily so it should be collection type like
  /// [List] or [Set] rather than a lazy iterable produced by `map()` et al.
  CombinedMapView(this._maps);

  V operator [](Object key) {
    for (var map in _maps) {
      // Avoid two hash lookups on a positive hit.
      var value = map[key];
      if (value != null || map.containsKey(value)) {
        return value;
      }
    }
    return null;
  }

  /// The keys of [this].
  ///
  /// The returned iterable has efficient `length` and `contains` operations,
  /// based on [length] and [containsKey] of the individual maps.
  ///
  /// The order of iteration is defined by the individual `Map` implementations,
  /// but must be consistent between changes to the maps.
  ///
  /// Unlike most [Map] implementations, modifying an individual map while
  /// iterating the keys will _sometimes_ throw. This behavior may change in
  /// the future.
  Iterable<K> get keys => _LazyDeduplicatingIterableView(
      CombinedIterableView(_maps.map((m) => m.keys)));
}

/// A view of an iterable that lazily skips any duplicate entries.
class _LazyDeduplicatingIterableView<T> extends IterableBase<T> {
  final Iterable<T> _iterable;

  const _LazyDeduplicatingIterableView(this._iterable);

  Iterator<T> get iterator => _LazyDeduplicatingIterator(_iterable.iterator);
}

/// An iterator that wraps another iterator and lazily skips duplicate values.
class _LazyDeduplicatingIterator<T> implements Iterator<T> {
  final Iterator<T> _iterator;

  final _emitted = Set<T>();

  _LazyDeduplicatingIterator(this._iterator);

  T get current => _iterator.current;

  bool moveNext() {
    while (_iterator.moveNext()) {
      if (_emitted.add(current)) {
        return true;
      }
    }
    _emitted.clear();
    return false;
  }
}
