// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

extension MapExtensions<K, V> on Map<K, V> {
  /// Like [Map.entries], but returns each entry as a record.
  Iterable<(K, V)> get pairs => entries.map((e) => (e.key, e.value));

  /// Like [Map.addEntries], but takes each entry as a record.
  void addPairs(Iterable<(K, V)> newPairs) {
    for (var (key, value) in newPairs) {
      this[key] = value;
    }
  }
}
