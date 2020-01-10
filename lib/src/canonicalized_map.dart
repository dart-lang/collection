// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'utils.dart';

/// A map whose keys are converted to canonical values of type `C`.
///
/// This is useful for using case-insensitive String keys, for example. It's
/// more efficient than a [LinkedHashMap] with a custom equality operator
/// because it only canonicalizes each key once, rather than doing so for each
/// comparison.
///
/// By default, `null` is allowed as a key. It can be forbidden via the
/// `isValidKey` parameter.
class CanonicalizedMap<C, K, V> implements Map<K, V> {
  final C Function(K) _canonicalize;

  final bool Function(Object) _isValidKeyFn;

  final _base = <C, Pair<K, V>>{};

  /// Creates an empty canonicalized map.
  ///
  /// The [canonicalize] function should return the canonical value for the
  /// given key. Keys with the same canonical value are considered equivalent.
  ///
  /// The [isValidKey] function is called before calling [canonicalize] for
  /// methods that take arbitrary objects. It can be used to filter out keys
  /// that can't be canonicalized.
  CanonicalizedMap(C Function(K key) canonicalize,
      {bool Function(Object key) isValidKey})
      : _canonicalize = canonicalize,
        _isValidKeyFn = isValidKey;

  /// Creates a canonicalized map that is initialized with the key/value pairs
  /// of [other].
  ///
  /// The [canonicalize] function should return the canonical value for the
  /// given key. Keys with the same canonical value are considered equivalent.
  ///
  /// The [isValidKey] function is called before calling [canonicalize] for
  /// methods that take arbitrary objects. It can be used to filter out keys
  /// that can't be canonicalized.
  CanonicalizedMap.from(Map<K, V> other, C Function(K key) canonicalize,
      {bool Function(Object key) isValidKey})
      : _canonicalize = canonicalize,
        _isValidKeyFn = isValidKey {
    addAll(other);
  }

  @override
  V operator [](Object key) {
    if (!_isValidKey(key)) return null;
    var pair = _base[_canonicalize(key as K)];
    return pair == null ? null : pair.last;
  }

  @override
  void operator []=(K key, V value) {
    if (!_isValidKey(key)) return;
    _base[_canonicalize(key)] = Pair(key, value);
  }

  @override
  void addAll(Map<K, V> other) {
    other.forEach((key, value) => this[key] = value);
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) => _base.addEntries(
      entries.map((e) => MapEntry(_canonicalize(e.key), Pair(e.key, e.value))));

  @override
  Map<K2, V2> cast<K2, V2>() => _base.cast<K2, V2>();

  @override
  void clear() {
    _base.clear();
  }

  @override
  bool containsKey(Object key) {
    if (!_isValidKey(key)) return false;
    return _base.containsKey(_canonicalize(key as K));
  }

  @override
  bool containsValue(Object value) =>
      _base.values.any((pair) => pair.last == value);

  @override
  Iterable<MapEntry<K, V>> get entries =>
      _base.entries.map((e) => MapEntry(e.value.first, e.value.last));

  @override
  void forEach(void Function(K, V) f) {
    _base.forEach((key, pair) => f(pair.first, pair.last));
  }

  @override
  bool get isEmpty => _base.isEmpty;

  @override
  bool get isNotEmpty => _base.isNotEmpty;

  @override
  Iterable<K> get keys => _base.values.map((pair) => pair.first);

  @override
  int get length => _base.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K, V) transform) =>
      _base.map((_, pair) => transform(pair.first, pair.last));

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    return _base
        .putIfAbsent(_canonicalize(key), () => Pair(key, ifAbsent()))
        .last;
  }

  @override
  V remove(Object key) {
    if (!_isValidKey(key)) return null;
    var pair = _base.remove(_canonicalize(key as K));
    return pair == null ? null : pair.last;
  }

  @override
  void removeWhere(bool Function(K key, V value) test) =>
      _base.removeWhere((_, pair) => test(pair.first, pair.last));

  @deprecated
  Map<K2, V2> retype<K2, V2>() => cast<K2, V2>();

  @override
  V update(K key, V Function(V) update, {V Function() ifAbsent}) => _base
      .update(_canonicalize(key), (pair) => Pair(key, update(pair.last)),
          ifAbsent: ifAbsent == null ? null : () => Pair(key, ifAbsent()))
      .last;

  @override
  void updateAll(V Function(K key, V value) update) => _base
      .updateAll((_, pair) => Pair(pair.first, update(pair.first, pair.last)));

  @override
  Iterable<V> get values => _base.values.map((pair) => pair.last);

  @override
  String toString() {
    // Detect toString() cycles.
    if (_isToStringVisiting(this)) {
      return '{...}';
    }

    var result = StringBuffer();
    try {
      _toStringVisiting.add(this);
      result.write('{');
      var first = true;
      forEach((k, v) {
        if (!first) {
          result.write(', ');
        }
        first = false;
        result.write('$k: $v');
      });
      result.write('}');
    } finally {
      assert(identical(_toStringVisiting.last, this));
      _toStringVisiting.removeLast();
    }

    return result.toString();
  }

  bool _isValidKey(Object key) =>
      (key == null || key is K) &&
      (_isValidKeyFn == null || _isValidKeyFn(key));
}

/// A collection used to identify cyclic maps during toString() calls.
final List _toStringVisiting = [];

/// Check if we are currently visiting `o` in a toString() call.
bool _isToStringVisiting(o) => _toStringVisiting.any((e) => identical(o, e));
