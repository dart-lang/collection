// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

void main() {
  final list1 = <String?>['foo', 'bar', null, 'baz'];
  // ignore: unused_local_variable
  final list2 = list1.whereNotNull();
}
