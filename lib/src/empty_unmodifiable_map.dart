// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'unmodifiable_wrappers.dart';

/// An unmodifiable, empty map which can be constant.
class EmptyUnmodifiableMap<K, V>
    with UnmodifiableMapMixin<K, V>
    implements UnmodifiableMapView<K, V> {
  const EmptyUnmodifiableMap();

  @override
  V? operator [](Object? key) => null;
  @override
  Map<RK, RV> cast<RK, RV>() => EmptyUnmodifiableMap<RK, RV>();
  @override
  bool containsKey(Object? key) => false;
  @override
  bool containsValue(Object? value) => false;
  @override
  Iterable<MapEntry<K, V>> get entries => Iterable<MapEntry<K, V>>.empty();
  @override
  void forEach(void Function(K key, V value) f) {}
  @override
  bool get isEmpty => true;
  @override
  bool get isNotEmpty => false;
  @override
  Iterable<K> get keys => Iterable<K>.empty();
  @override
  int get length => 0;
  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) f) =>
      EmptyUnmodifiableMap<K2, V2>();
  @override
  Iterable<V> get values => Iterable<V>.empty();
}
