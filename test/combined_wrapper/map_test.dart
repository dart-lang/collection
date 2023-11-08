// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:test/test.dart';

void main() {
  var map1 = const {1: 1, 2: 2, 3: 3};
  var map2 = const {4: 4, 5: 5, 6: 6};
  var map3 = const {7: 7, 8: 8, 9: 9};
  var map4 = const {1: -1, 2: -2, 3: -3};
  var concat = SplayTreeMap<int, int>()
    // The duplicates map appears first here but last in the CombinedMapView
    // which has the opposite semantics of `concat`. Keys/values should be
    // returned from the first map that contains them.
    ..addAll(map4)
    ..addAll(map1)
    ..addAll(map2)
    ..addAll(map3);

  // In every way possible this should test the same as an UnmodifiableMapView.
  _testReadMap(
      concat, CombinedMapView([map1, map2, map3, map4]), 'CombinedMapView');

  _testReadMap(
      concat,
      CombinedMapView([map1, {}, map2, {}, map3, {}, map4, {}]),
      'CombinedMapView (some empty)');

  test('should function as an empty map when no maps are passed', () {
    var empty = CombinedMapView([]);
    expect(empty, isEmpty);
    expect(empty.length, 0);
  });

  test('should function as an empty map when only empty maps are passed', () {
    var empty = CombinedMapView([{}, {}, {}]);
    expect(empty, isEmpty);
    expect(empty.length, 0);
  });

  test('should reflect underlying changes back to the combined map', () {
    var backing1 = <int, int>{};
    var backing2 = <int, int>{};
    var combined = CombinedMapView([backing1, backing2]);
    expect(combined, isEmpty);
    backing1.addAll(map1);
    expect(combined, map1);
    backing2.addAll(map2);
    expect(combined, Map.from(backing1)..addAll(backing2));
  });

  test('should reflect underlying changes with a single map', () {
    var backing1 = <int, int>{};
    var combined = CombinedMapView([backing1]);
    expect(combined, isEmpty);
    backing1.addAll(map1);
    expect(combined, map1);
  });

  test('re-iterating keys produces same result', () {
    var combined = CombinedMapView([map1, map2, map3, map4]);
    var keys = combined.keys;
    expect(keys.toList(), keys.toList());
  });
}

void _testReadMap(Map<int, int> original, Map<int, int> wrapped, String name) {
  test('$name length', () {
    expect(wrapped.length, equals(original.length));
  });

  test('$name isEmpty', () {
    expect(wrapped.isEmpty, equals(original.isEmpty));
  });

  test('$name isNotEmpty', () {
    expect(wrapped.isNotEmpty, equals(original.isNotEmpty));
  });

  test('$name operator[]', () {
    expect(wrapped[0], equals(original[0]));
    expect(wrapped[999], equals(original[999]));
  });

  test('$name containsKey', () {
    expect(wrapped.containsKey(0), equals(original.containsKey(0)));
    expect(wrapped.containsKey(999), equals(original.containsKey(999)));
  });

  test('$name containsValue', () {
    expect(wrapped.containsValue(0), equals(original.containsValue(0)));
    expect(wrapped.containsValue(999), equals(original.containsValue(999)));
  });

  test('$name forEach', () {
    var origCnt = 0;
    var wrapCnt = 0;
    wrapped.forEach((k, v) {
      wrapCnt += 1 << k + 3 * v;
    });
    original.forEach((k, v) {
      origCnt += 1 << k + 3 * v;
    });
    expect(wrapCnt, equals(origCnt));
  });

  test('$name keys', () {
    expect(wrapped.keys, orderedEquals(original.keys));
  });

  test('$name values', () {
    expect(wrapped.values, orderedEquals(original.values));
  });
}
