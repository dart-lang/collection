// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Tests priority queue implementations utilities.

import 'package:test/test.dart';

import 'package:collection/src/priority_queue.dart';

void main() {
  testDefault();
  testInt(() => HeapPriorityQueue<int>());
  testCustom((comparator) => HeapPriorityQueue<C>(comparator));
}

void testDefault() {
  test('PriorityQueue() returns a HeapPriorityQueue', () {
    expect(PriorityQueue<int>(), TypeMatcher<HeapPriorityQueue<int>>());
  });
  testInt(() => PriorityQueue<int>());
  testCustom((comparator) => PriorityQueue<C>(comparator));
}

void testInt(PriorityQueue<int> Function() create) {
  for (var count in [1, 5, 127, 128]) {
    testQueue('int:$count', create, List<int>.generate(count, (x) => x), count);
  }
}

void testCustom(
    PriorityQueue<C> Function(int Function(C, C) comparator) create) {
  for (var count in [1, 5, 127, 128]) {
    testQueue('Custom:$count/null', () => create(null),
        List<C>.generate(count, (x) => C(x)), C(count));
    testQueue('Custom:$count/compare', () => create(compare),
        List<C>.generate(count, (x) => C(x)), C(count));
    testQueue('Custom:$count/compareNeg', () => create(compareNeg),
        List<C>.generate(count, (x) => C(count - x)), C(0));
  }
}

/// Test that a queue behaves correctly.
///
/// The elements must be in priority order, from highest to lowest.
void testQueue(
    String name, PriorityQueue Function() create, List elements, notElement) {
  test(name, () => testQueueBody(create, elements, notElement));
}

void testQueueBody(PriorityQueue Function() create, List elements, notElement) {
  var q = create();
  expect(q.isEmpty, isTrue);
  expect(q, hasLength(0));
  expect(() {
    q.first;
  }, throwsStateError);
  expect(() {
    q.removeFirst();
  }, throwsStateError);

  // Tests removeFirst, first, contains, toList and toSet.
  void testElements() {
    expect(q.isNotEmpty, isTrue);
    expect(q, hasLength(elements.length));

    expect(q.toList(), equals(elements));
    expect(q.toSet().toList(), equals(elements));

    for (var i = 0; i < elements.length; i++) {
      expect(q.contains(elements[i]), isTrue);
    }
    expect(q.contains(notElement), isFalse);

    var all = [];
    while (q.isNotEmpty) {
      var expected = q.first;
      var actual = q.removeFirst();
      expect(actual, same(expected));
      all.add(actual);
    }

    expect(all.length, elements.length);
    for (var i = 0; i < all.length; i++) {
      expect(all[i], same(elements[i]));
    }

    expect(q.isEmpty, isTrue);
  }

  q.addAll(elements);
  testElements();

  q.addAll(elements.reversed);
  testElements();

  // Add elements in a non-linear order (gray order).
  for (var i = 0, j = 0; i < elements.length; i++) {
    int gray;
    do {
      gray = j ^ (j >> 1);
      j++;
    } while (gray >= elements.length);
    q.add(elements[gray]);
  }
  testElements();

  // Add elements by picking the middle element first, and then recursing
  // on each side.
  void addRec(int min, int max) {
    var mid = min + ((max - min) >> 1);
    q.add(elements[mid]);
    if (mid + 1 < max) addRec(mid + 1, max);
    if (mid > min) addRec(min, mid);
  }

  addRec(0, elements.length);
  testElements();

  // Test removeAll.
  q.addAll(elements);
  expect(q, hasLength(elements.length));
  var all = q.removeAll();
  expect(q.isEmpty, isTrue);
  expect(all, hasLength(elements.length));
  for (var i = 0; i < elements.length; i++) {
    expect(all, contains(elements[i]));
  }

  // Test the same element more than once in queue.
  q.addAll(elements);
  q.addAll(elements.reversed);
  expect(q, hasLength(elements.length * 2));
  for (var i = 0; i < elements.length; i++) {
    var element = elements[i];
    expect(q.contains(element), isTrue);
    expect(q.removeFirst(), element);
    expect(q.removeFirst(), element);
  }

  // Test queue with all same element.
  var a = elements[0];
  for (var i = 0; i < elements.length; i++) {
    q.add(a);
  }
  expect(q, hasLength(elements.length));
  expect(q.contains(a), isTrue);
  expect(q.contains(notElement), isFalse);
  q.removeAll().forEach((x) => expect(x, same(a)));

  // Test remove.
  q.addAll(elements);
  for (var element in elements.reversed) {
    expect(q.remove(element), isTrue);
  }
  expect(q.isEmpty, isTrue);
}

// Custom class.
// Class is comparable, comparators match normal and inverse order.
int compare(C c1, C c2) => c1.value - c2.value;
int compareNeg(C c1, C c2) => c2.value - c1.value;

class C implements Comparable<C> {
  final int value;
  const C(this.value);
  @override
  int get hashCode => value;
  @override
  bool operator ==(Object other) => other is C && value == other.value;
  @override
  int compareTo(C other) => value - other.value;
  @override
  String toString() => 'C($value)';
}
