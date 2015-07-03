// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Tests equality utilities.

import "dart:collection";
import "package:collection/collection.dart";
import "package:test/test.dart";

main() {
  o(id) => new Element(id);

  // Lists that are point-wise equal, but not identical.
  var list1 = [o(1), o(2), o(3), o(4), o(5)];
  var list2 = [o(1), o(2), o(3), o(4), o(5)];
  // Similar length list with equal elements in different order.
  var list3 = [o(1), o(3), o(5), o(4), o(2)];

  test("IterableEquality - List", () {
    expect(const IterableEquality().equals(list1, list2), isTrue);
    Equality iterId = const IterableEquality(const IdentityEquality());
    expect(iterId.equals(list1, list2), isFalse);
  });

  test("IterableEquality - LinkedSet", () {
    var l1 = new LinkedHashSet.from(list1);
    var l2 = new LinkedHashSet.from(list2);
    expect(const IterableEquality().equals(l1, l2), isTrue);
    Equality iterId = const IterableEquality(const IdentityEquality());
    expect(iterId.equals(l1, l2), isFalse);
  });

  test("ListEquality", () {
    expect(const ListEquality().equals(list1, list2),
           isTrue);
    Equality listId = const ListEquality(const IdentityEquality());
    expect(listId.equals(list1, list2), isFalse);
  });

  test("ListInequality length", () {
    var list4 = [o(1), o(2), o(3), o(4), o(5), o(6)];
    expect(const ListEquality().equals(list1, list4),
           isFalse);
    expect(const ListEquality(const IdentityEquality()).equals(list1, list4),
           isFalse);
  });

  test("ListInequality value", () {
    var list5 = [o(1), o(2), o(3), o(4), o(6)];
    expect(const ListEquality().equals(list1, list5),
           isFalse);
    expect(const ListEquality(const IdentityEquality()).equals(list1, list5),
           isFalse);
  });

  test("UnorderedIterableEquality", () {
    expect(const UnorderedIterableEquality().equals(list1, list3),
           isTrue);
    Equality uniterId =
        const UnorderedIterableEquality(const IdentityEquality());
    expect(uniterId.equals(list1, list3), isFalse);
  });

  test("UnorderedIterableInequality length", () {
    var list6 = [o(1), o(3), o(5), o(4), o(2), o(1)];
    expect(const UnorderedIterableEquality().equals(list1, list6),
           isFalse);
    expect(const UnorderedIterableEquality(const IdentityEquality())
               .equals(list1, list6),
           isFalse);
  });

  test("UnorderedIterableInequality values", () {
    var list7 = [o(1), o(3), o(5), o(4), o(6)];
    expect(const UnorderedIterableEquality().equals(list1, list7),
           isFalse);
    expect(const UnorderedIterableEquality(const IdentityEquality())
               .equals(list1, list7),
           isFalse);
  });

  test("SetEquality", () {
    var set1 = new HashSet.from(list1);
    var set2 = new LinkedHashSet.from(list3);
    expect(const SetEquality().equals(set1, set2), isTrue);
    Equality setId = const SetEquality(const IdentityEquality());
    expect(setId.equals(set1, set2), isFalse);
  });

  test("SetInequality length", () {
    var list8 = [o(1), o(3), o(5), o(4), o(2), o(6)];
    var set1 = new HashSet.from(list1);
    var set2 = new LinkedHashSet.from(list8);
    expect(const SetEquality().equals(set1, set2),
           isFalse);
    expect(const SetEquality(const IdentityEquality()).equals(set1, set2),
           isFalse);
  });

  test("SetInequality value", () {
    var list7 = [o(1), o(3), o(5), o(4), o(6)];
    var set1 = new HashSet.from(list1);
    var set2 = new LinkedHashSet.from(list7);
    expect(const SetEquality().equals(set1, set2),
           isFalse);
    expect(const SetEquality(const IdentityEquality()).equals(set1, set2),
           isFalse);
  });

  var map1a = {"x": [o(1), o(2), o(3)], "y": [true, false, null]};
  var map1b = {"x": [o(4), o(5), o(6)], "y": [false, true, null]};
  var map2a = {"x": [o(3), o(2), o(1)], "y": [false, true, null]};
  var map2b = {"x": [o(6), o(5), o(4)], "y": [null, false, true]};
  var l1 = [map1a, map1b];
  var l2 = [map2a, map2b];
  var s1 = new Set.from(l1);
  var s2 = new Set.from([map2b, map2a]);

  test("RecursiveEquality", () {
    const unordered = const UnorderedIterableEquality();
    expect(unordered.equals(map1a["x"], map2a["x"]),
        isTrue);
    expect(unordered.equals(map1a["y"], map2a["y"]),
        isTrue);
    expect(unordered.equals(map1b["x"], map2b["x"]),
        isTrue);
    expect(unordered.equals(map1b["y"], map2b["y"]),
        isTrue);
    const mapval = const MapEquality(values: unordered);
    expect(
        mapval.equals(map1a, map2a),
        isTrue);
    expect(mapval.equals(map1b, map2b),
        isTrue);
    const listmapval = const ListEquality(mapval);
    expect(listmapval.equals(l1, l2),
        isTrue);
    const setmapval = const SetEquality(mapval);
    expect(setmapval.equals(s1, s2),
        isTrue);
  });

  test("DeepEquality", () {
    var colleq = const DeepCollectionEquality.unordered();
    expect(colleq.equals(map1a["x"], map2a["x"]),
        isTrue);
    expect(colleq.equals(map1a["y"], map2a["y"]),
        isTrue);
    expect(colleq.equals(map1b["x"], map2b["x"]),
        isTrue);
    expect(colleq.equals(map1b["y"], map2b["y"]),
        isTrue);
    expect(colleq.equals(map1a, map2a),
        isTrue);
    expect(colleq.equals(map1b, map2b),
        isTrue);
    expect(colleq.equals(l1, l2),
        isTrue);
    expect(colleq.equals(s1, s2),
        isTrue);
  });
}

/// Wrapper objects for an `id` value.
///
/// Compares the `id` value by equality and for comparison.
/// Allows creating simple objects that are equal without being identical.
class Element implements Comparable<Element> {
  final Comparable id;
  const Element(this.id);
  int get hashCode => id.hashCode;
  bool operator==(Object other) => other is Element && id == other.id;
  int compareTo(other) => id.compareTo(other.id);
}
