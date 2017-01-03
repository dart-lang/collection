// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "dart:collection";
import 'dart:convert';


/**
 * An implementation of [Map]. That allows for multiple inserts of a key retaining
 * all inserted values and always returning the last inserted value through
 * standard Map API.  Additional method [multiple] allows access to all inserted
 * values for a given key.
 *
 * Default behavior is identical to [Map] with the exception that an unmodifiable
 * Multimap cannot be constructed.
 */
class MultiMap<K, V> implements Map<K, V> {

  LinkedHashMap<K, List<V>> _map;

  /**
   * Default constructor see [Map]
   */
  MultiMap({bool equals(K key1, K key2),
  int hashCode(K key),
  bool isValidKey(potentialKey)}) {
    _map = new LinkedHashMap<K, List<V>>(equals:equals,hashCode:hashCode,isValidKey:isValidKey);
  }

  /**
   * Factory constructing a Map from a parser generated Map literal.
   * [elements] contains n key-value pairs.
   * Todo: rwrozelle - How do we construct a multimap from a literal?
   */
  /*
  factory MultiMap._fromLiteral(List elements) {
    var map = new MultiMap<K, V>();
    var len = elements.length;
    for (int i = 1; i < len; i += 2) {
      map[elements[i - 1]] = elements[i];
    }
    return map;
  }
  */

  /**
   * Unmodifiable constructor is not implemented due to class hierarchy mismatch.
   * Todo:  rwrozelle - Is it important enough to figure out an unmodifiable implmentation?
   */
  /*
  factory MultiMap.unmodifiable(Map other) {
  }
  */

  /**
   * Creates an identity-based map. See [Map]
   */
   factory MultiMap.identity() {
     return new MultiMap<K, V>(equals:identical,hashCode:identityHashCode);
   }

  /**
   * Creates a MultiMap that contains all key value pairs of [other].
   */
  factory MultiMap.from(Map other) {
    MultiMap<K, V> result = new MultiMap<K, V>();
    other.forEach((k, v)
    {
      result[k] = v;
    });
    return result;
  }

  /**
   * Creates a MultiMap where the keys and values are computed from the
   * [iterable].  See [Map]
   */
  factory MultiMap.fromIterable(Iterable iterable,
      {K key(element), V value(element)}) {
    MultiMap<K, V> map = new MultiMap<K, V>();
    MultiMapHelper._fillMapWithMappedIterable(map, iterable, key, value);
    return map;
  }

  /**
   * Creates a MultiMap associating the given [keys] to [values].  See [Map]
   */
  factory MultiMap.fromIterables(Iterable<K> keys, Iterable<Object> values) {
    MultiMap<K, V> map = new MultiMap<K, V>();
    MultiMapHelper._fillMapWithIterables(map, keys, values);
    return map;
  }

  /**
   * Returns true if this map contains the given [value].
   *
   * Returns true if any of the last values inserted in the map are equal to
   * `value` according to the `==` operator.
   */
  bool containsValue(Object value) {
    for (K key in keys) {
      if (this[key] == value) return true;
    }
    return false;
  }

  /**
   * Returns true if this map contains the given [key].
   *
   * Returns true if any of the keys in the map are equal to `key`
   * according to the equality used by the map.
   */
  bool containsKey(Object key) => _map.containsKey(key);

  /**
   * Returns the last inserted value for the given [key] or null if [key]
   * is not in the map.  See [Map] for what a return of 'null' means
   */
  V operator [](Object key) {
    Object listValue = _map[key];
    if (listValue == null || (listValue as List<V>).isEmpty) return null;
    return (listValue as List<V>).last;
  }

  /**
   * Associates the [key] with the given [value].
   *
   * If the key was already in the map, its associated value is inserted.
   * Otherwise the key-value pair is added to the map.
   * if the [value] provided is a List<V>, then it overwrites any prior inserted
   * values with the new list of values and the last value in this list
   * is considered the "last inserted value" for the key.
   */
  void operator []=(K key, Object value) {
    if (value is List<V>) {
      _map[key] = value;
    }
    else if (value is V) {
      List<V> listValue = _map[key];
      if (listValue != null) listValue.add(value);
      else _map[key] = [value];
    }
  }

  /**
   * Look up the value of [key], or add a new value if it isn't there.
   * see [Map].
   */
  V putIfAbsent(key, ifAbsent()) {
    if (containsKey(key)) return this[key];
    var value = ifAbsent();
    this[key] = value;
    return value;
  }

  /**
   * Adds all key-value pairs of [other] to this map.
   *
   * If a key of [other] is already in this map, its value is inserted.
   *
   * The operation is equivalent to doing `this[key] = value` for each key
   * and associated value in other. It iterates over [other], which must
   * therefore not change during the iteration.
   */
  void addAll(Map<K, V> other) {
    for (K key in other.keys) {
      this[key] = other[key];
    }
  }

  /**
   * Removes [key] and its associated value(s), if present, from the map.
   *
   * Returns the last inserted value associated with `key` before it was removed.
   * Returns `null` if `key` was not in the map.
   *
   * Note that values can be `null` and a returned `null` value doesn't
   * always mean that the key was absent.
   */
  V remove(Object key) {
    List<V> result = _map.remove(key);
    if (result == null || result.isEmpty) return null;
    return result.last;
  }

  /**
   * Removes all pairs from the map.
   *
   * After this, the map is empty.
   */
  void clear() => _map.clear();

  /**
   * Applies [f] to each key-value pair of the map.  Value used by [f] is the
   * last inserted value associated with the key
   *
   * Calling `f` must not add or remove keys from the map.
   */
  void forEach(void f(K key, V value)) {
    for (K key in keys) {
      f(key, this[key]);
    }
  }

  /**
   * Applies [f] to each key-value pair of the map.  Value used by [f] is the
   * last inserted value associated with the key
   *
   * Calling `f` must not add or remove keys from the map.
   */
  void forEachMultiple(void f(K key, List<V> value)) {
    for (K key in keys) {
      f(key, this.multiple(key));
    }
  }

  /**
   * The keys of [this].
   *
   * The returned iterable has efficient `length` and `contains` operations,
   * based on [length] and [containsKey] of the map.
   *
   * The order of iteration is defined by the individual `Map` implementation,
   * but must be consistent between changes to the map.
   *
   * Modifying the map while iterating the keys
   * may break the iteration.
   */
  Iterable<K> get keys => _map.keys;

  /**
   * The last inserted values of [this].
   *
   * The values are iterated in the order of their corresponding keys.
   * This means that iterating [keys] and [values] in parallel will
   * provided matching pairs of keys and values.
   *
   * The returned iterable has an efficient `length` method based on the
   * [length] of the map. Its [Iterable.contains] method is based on
   * `==` comparison.
   *
   * Modifying the map while iterating the
   * values may break the iteration.
   */
  Iterable<V> get values {
    Iterable<V> result = new List<V>();
    for (K key in this.keys) {
      (result as List<V>).add(this[key]);
    }
    return result;
  }

  /**
   * The number of key-value pairs in the map.
   */
  int get length => _map.length;

  /**
   * Returns true if there is no key-value pair in the map.
   */
  bool get isEmpty => _map.isEmpty;

  /**
   * Returns true if there is at least one key-value pair in the map.
   */
  bool get isNotEmpty => _map.isNotEmpty;

  /**
   * Returns the values of the key as a list
   */
  List<V> multiple(K key) {
    return _map[key];
  }

  /**
   * Returns the [query] split into a map according to the rules
   * specified for FORM post in the [HTML 4.01 specification section
   * 17.13.4](http://www.w3.org/TR/REC-html40/interact/forms.html#h-17.13.4 "HTML 4.01 section 17.13.4").
   * Each key and value in the returned map has been decoded. If the [query]
   * is the empty string an empty map is returned.
   *
   * Keys in the query string that have no value are mapped to the
   * empty string.
   *
   * Each query component will be decoded using [encoding]. The default encoding
   * is UTF-8.
   * This is a copy of dart-sdk core Uri.splitQueryString modified to return
   * List<Strings> when parameter is duplicated, for example:
   * "foo=bar&baz=bang&fi=fo&fi=fum" returns {"foo": "bar", "baz": "bang", "fi":["fo","fum"]}
   */
  static MultiMap<String, String> splitQueryString(String query, {Encoding encoding: UTF8}) {
    MultiMap<String, String> mmap = new MultiMap<String, String>();
    query.split("&").fold({}, (map, element) {
      int index = element.indexOf("=");
      if (index == -1) {
        if (element != "") {
          mmap[Uri.decodeQueryComponent(element, encoding: encoding)] = "";
        }
      } else if (index != 0) {
        var key = element.substring(0, index);
        var value = element.substring(index + 1);
        print(key.toString() + ": " + value.toString());
        mmap[Uri.decodeQueryComponent(key, encoding: encoding)] =
            Uri.decodeQueryComponent(value, encoding: encoding);
      }
    });
    return mmap;
  }
}

/**
 * Helper class which implements complex [Map] operations
 * in term of basic ones ([Map.keys], [Map.operator []],
 * [Map.operator []=] and [Map.remove].)  Not all methods are
 * necessary to implement each particular operation.
 * This was copied from /dart/lib/collection/maps.dart because of privacy in
 * original location.
 */
class MultiMapHelper {

  static _id(x) => x;

  /**
   * Fills a map with key/value pairs computed from [iterable].
   *
   * This method is used by Map classes in the named constructor fromIterable.
   */
  static void _fillMapWithMappedIterable(Map map, Iterable iterable,
      key(element), value(element)) {
    if (key == null) key = _id;
    if (value == null) value = _id;

    for (var element in iterable) {
      map[key(element)] = value(element);
    }
  }

  /**
   * Fills a map by associating the [keys] to [values].
   *
   * This method is used by Map classes in the named constructor fromIterables.
   */
  static void _fillMapWithIterables(Map map, Iterable keys,
      Iterable values) {
    Iterator keyIterator = keys.iterator;
    Iterator valueIterator = values.iterator;

    bool hasNextKey = keyIterator.moveNext();
    bool hasNextValue = valueIterator.moveNext();

    while (hasNextKey && hasNextValue) {
      map[keyIterator.current] = valueIterator.current;
      hasNextKey = keyIterator.moveNext();
      hasNextValue = valueIterator.moveNext();
    }

    if (hasNextKey || hasNextValue) {
      throw new ArgumentError("Iterables do not have same length.");
    }
  }
}