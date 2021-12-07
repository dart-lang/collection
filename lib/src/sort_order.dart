// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Sorts a list ascending. For example:
///
/// 1, 3, 2, 4  =>  1, 2, 3, 4
///
/// a, c, b, d  =>  a, b, c, d
int sortAsc<T>(Comparable<T> a, T b) => _sortAscInternal(a, b);

int _sortAscInternal<T>(Comparable<T> a, T b) => a.compareTo(b);

/// Sorts a list descending. For example:
///
/// 1, 3, 2, 4  =>  4, 3, 2, 1
///
/// a, c, b, d  =>  d, c, b, a
int sortDesc<T>(T a, Comparable<T> b) => _sortDescInternal(a, b);

int _sortDescInternal<T>(T a, Comparable<T> b) => b.compareTo(a);

/// Sorts a list ascending. For example:
extension ListSort<T> on List<Comparable<T>> {
  /// Sorts a list ascending. For example:
  ///
  /// 1, 3, 2, 4  =>  1, 2, 3, 4
  ///
  /// a, c, b, d  =>  a, b, c, d
  void sortAsc() {
    sort(_sortAscInternal);
  }

  /// Sorts a list descending. For example:
  ///
  /// 1, 3, 2, 4  =>  4, 3, 2, 1
  ///
  /// a, c, b, d  =>  d, c, b, a
  void sortDesc() {
    sort(_sortDescInternal);
  }
}
