// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'utils.dart';

// TODO(nweiz): When sdk#26488 is fixed, use overloads to ensure that if [key]
// or [value] isn't passed, `K2`/`V2` defaults to `K1`/`V1`, respectively.
/// Creates a new map from [map] with new keys and values. 
///
/// The return values of [key] are used as the keys and the return values of
/// [value] are used as the values for the new map.
Map/*<K2, V2>*/ mapMap/*<K1, V1, K2, V2>*/(Map/*<K1, V1>*/ map,
    {/*=K2*/ key(/*=K1*/ key, /*=V1*/ value),
    /*=V2*/ value(/*=K1*/ key, /*=V1*/ value)}) {
  key ??= (mapKey, _) => mapKey as dynamic/*=K2*/;
  value ??= (_, mapValue) => mapValue as dynamic/*=V2*/;

  var result = /*<K2, V2>*/{};
  map.forEach((mapKey, mapValue) {
    result[key(mapKey, mapValue)] = value(mapKey, mapValue);
  });
  return result;
}

/// Returns a new map with all key/value pairs in both [map1] and [map2].
///
/// If there are keys that occur in both maps, the [value] function is used to
/// select the value that goes into the resulting map based on the two original
/// values. If [value] is omitted, the value from [map2] is used.
Map/*<K, V>*/ mergeMaps/*<K, V>*/(Map/*<K, V>*/ map1, Map/*<K, V>*/ map2,
    {/*=V*/ value(/*=V*/ value1, /*=V*/ value2)}) {
  var result = new Map/*<K, V>*/.from(map1);
  if (value == null) return result..addAll(map2);

  map2.forEach((key, mapValue) {
    result[key] = result.containsKey(key)
        ? value(result[key], mapValue)
        : mapValue;
  });
  return result;
}

/// Groups the elements in [values] by the value returned by [key].
///
/// Returns a map from keys computed by [key] to a list of all values for which
/// [key] returns that key. The values appear in the list in the same relative
/// order as in [values].
Map<dynamic/*=T*/, List/*<S>*/> groupBy/*<S, T>*/(Iterable/*<S>*/ values,
    /*=T*/ key(/*=S*/ element)) {
  var map = /*<T, List<S>>*/{};
  for (var element in values) {
    var list = map.putIfAbsent(key(element), () => []);
    list.add(element);
  }
  return map;
}

/// Returns the element of [values] for which [orderBy] returns the minimum
/// value.
///
/// The values returned by [orderBy] are compared using the [compare] function.
/// If [compare] is omitted, values must implement [Comparable<T>] and they are
/// compared using their [Comparable.compareTo].
/*=S*/ minBy/*<S, T>*/(Iterable/*<S>*/ values, /*=T*/ orderBy(/*=S*/ element),
    {int compare(/*=T*/ value1, /*=T*/ value2)}) {
  compare ??= defaultCompare/*<T>*/();

  var/*=S*/ minValue;
  var/*=T*/ minOrderBy;
  for (var element in values) {
    var elementOrderBy = orderBy(element);
    if (minOrderBy == null || compare(elementOrderBy, minOrderBy) < 0) {
      minValue = element;
      minOrderBy = elementOrderBy;
    }
  }
  return minValue;
}

/// Returns the element of [values] for which [orderBy] returns the maximum
/// value.
///
/// The values returned by [orderBy] are compared using the [compare] function.
/// If [compare] is omitted, values must implement [Comparable<T>] and they are
/// compared using their [Comparable.compareTo].
/*=S*/ maxBy/*<S, T>*/(Iterable/*<S>*/ values, /*=T*/ orderBy(/*=S*/ element),
    {int compare(/*=T*/ value1, /*=T*/ value2)}) {
  compare ??= defaultCompare/*<T>*/();

  var/*=S*/ maxValue;
  var/*=T*/ maxOrderBy;
  for (var element in values) {
    var elementOrderBy = orderBy(element);
    if (maxOrderBy == null || compare(elementOrderBy, maxOrderBy) > 0) {
      maxValue = element;
      maxOrderBy = elementOrderBy;
    }
  }
  return maxValue;
}

/// Returns the [transitive closure][] of [graph].
///
/// [transitive closure]: https://en.wikipedia.org/wiki/Transitive_closure
///
/// This interprets [graph] as a directed graph with a vertex for each key and
/// edges from each key to the values associated with that key.
///
/// Assumes that every vertex in the graph has a key to represent it, even if
/// that vertex has no outgoing edges. For example, `{"a": ["b"]}` is not valid,
/// but `{"a": ["b"], "b": []}` is.
Map<dynamic/*=T*/, Set/*<T>*/> transitiveClosure/*<T>*/(
    Map<dynamic/*=T*/, Iterable/*<T>*/> graph) {
  // This uses [Warshall's algorithm][], modified not to add a vertex from each
  // node to itself.
  //
  // [Warshall's algorithm]: https://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm#Applications_and_generalizations.
  var result = /*<T, Set>*/{};
  graph.forEach((vertex, edges) {
    result[vertex] = new Set/*<T>*/.from(edges);
  });

  // Lists are faster to iterate than maps, so we create a list since we're
  // iterating repeatedly.
  var keys = graph.keys.toList();
  for (var vertex1 in keys) {
    for (var vertex2 in keys) {
      for (var vertex3 in keys) {
        if (result[vertex2].contains(vertex1) &&
            result[vertex1].contains(vertex3)) {
          result[vertex2].add(vertex3);
        }
      }
    }
  }

  return result;
}
