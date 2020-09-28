// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Returns a [Comparator] that asserts that its first argument is comparable.
Comparator<T> defaultCompare<T>() =>
    (value1, value2) => (value1 as Comparable).compareTo(value2);
