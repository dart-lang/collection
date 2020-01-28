// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection' show SetBase;

import 'dart:typed_data';

/// Creates an empty set of non-negative integers.
///
/// The [maxElements] it must be no larger than [maxSupportedElements].
/// Then the resulting set can only contain integers which
/// are non-negative and *less than* [maxElements].
///
/// The set is backed directly by as many bits as necessary.
/// A verly large value for [maxElements] may not be supported by the
/// underlying system.
Set<int> bitSet(int maxElements) {
  RangeError.checkNotNegative(maxElements, "maxElements");
  return _DenseBitSet(maxElements);
}

class _DenseBitSet extends SetBase<int> {
  final int _maxElements;
  final Uint8List _bits;
  int _elementCount = 0;
  _DenseBitSet(this._maxElements) : _bits = Uint8List((_maxElements + 7) ~/ 8);

  // Used by [toSet].
  _DenseBitSet._(this._maxElements, this._elementCount, this._bits);

  bool add(int value) {
    RangeError.checkValidIndex(value, this, "value", _maxElements);
    var mask = 1 << (value & 7);
    int index = value ~/ 8;
    int byte = _bits[index];
    if (byte & mask == 0) {
      _bits[index] = byte + mask;
      _elementCount++;
      return true;
    }
    return false;
  }

  bool contains(Object element) {
    if (element is int) {
      if (element < 0 || element >= _maxElements) return false;
      return _contains(element);
    }
    return false;
  }

  bool _contains(int element) =>
      _bits[element ~/ 8] & (1 << (element & 7)) != 0;

  Iterable<int> get _elements sync* {
    int index = 0;
    for (int i = 0; i < _bits.length; i++) {
      int byte = _bits[i];
      if (byte != 0) {
        for (int j = 0, bit = 1; j < 8; bit += bit, j++) {
          if (byte & bit != 0) yield index;
          index++;
        }
      } else {
        index += 8;
      }
    }
  }

  Iterator<int> get iterator => _elements.iterator;

  int get length => _elementCount;

  @override
  int/*?*/ lookup(Object element) {
    if (element is int) {
      if (element < 0 || element >= _maxElements) return null;
      if (_contains(element)) return element;
    }
    return null;
  }

  @override
  bool remove(Object value) {
    if (value is int) {
      if (value < 0 || value >= _maxElements) return false;
      var mask = 1 << (value & 7);
      int index = value ~/ 8;
      int byte = _bits[index];
      if (byte & mask == 1) {
        _bits[index] = byte - mask;
        _elementCount--;
        return true;
      }
    }
    return false;
  }

  Set<int> toSet() =>
      _DenseBitSet._(_maxElements, _elementCount, Uint8List.fromList(_bits));
}
