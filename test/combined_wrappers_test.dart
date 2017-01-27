// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:test/test.dart';

import 'unmodifiable_collection_test.dart' as common;

void main() {
  final list1 = const [1, 2, 3];
  final list2 = const [4, 5, 6];
  final list3 = const [7, 8, 9];
  final concat = []..addAll(list1)..addAll(list2)..addAll(list3);
  final combine = combineLists([list1, list2, list3]);

  // In every way possible this should test the same as an UnmodifiableListView.
  common.testUnmodifiableList(concat, combine, 'combineLists');

  test('should function as an empty list when no lists are passed', () {
    var empty = combineLists([]);
    expect(empty, isEmpty);
    expect(empty.length, 0);
    expect(() => empty[0], throwsRangeError);
  });

  test('should function as an empty list when only empty lists are passed', () {
    var empty = combineLists([[], [], []]);
    expect(empty, isEmpty);
    expect(empty.length, 0);
    expect(() => empty[0], throwsRangeError);
  });
}
