// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection' show ListMixin;
import 'dart:typed_data' show Uint32List;

import 'unmodifiable_wrappers.dart' show NonGrowableListMixin;

/// A BoolList implementation for Dart to store boolean values.
///
/// Uses list of integers as internal storage to reduce memory usage.
///
/// Internal storage of the growable [BoolList] is dynamically changed in the
/// following cases:
/// * when required length greater than preallocated space, storage expands its
///   space to `2 * length` for further length expandings;
/// * when required length less than the half of the current [length], storage
///   shrinks availiable space.
abstract class BoolList with ListMixin<bool> {
  static const int _entryShift = 5;

  static const int _bitsPerEntry = 32;

  static const int _entrySignBitIndex = 31;

  int _length;

  Uint32List _data;

  BoolList._(this._data, this._length);

  factory BoolList._selectType(int length, bool growable) {
    if (growable) {
      return _GrowableBoolList(length);
    } else {
      return _NonGrowableBoolList(length);
    }
  }

  /// Creates a [BoolList] with given length.
  ///
  /// The created list is fixed-length if [length] is provided.
  /// Al initial values are `false`.
  factory BoolList([int length]) {
    length ??= 0;
    RangeError.checkNotNegative(length, 'length');

    return BoolList._selectType(length, length == 0);
  }

  /// Creates [BoolList] of the given length with [fill] at each position.
  ///
  /// The created list is fixed-length if [growable] is false (the default)
  /// and growable if [growable] is true.
  factory BoolList.filled(int length, bool fill, {bool growable = false}) {
    RangeError.checkNotNegative(length, 'length');

    var instance = BoolList._selectType(length, growable);
    if (fill) {
      instance.fillRange(0, length, true);
    }
    return instance;
  }

  /// Generates a [BoolList] of values.
  ///
  /// Creates a [BoolList] with [length] positions and fills it with values created by
  /// calling [generator] for each index in the range `0` .. `length - 1` in increasing order.
  ///
  /// The created list is fixed-length unless [growable] is true.
  factory BoolList.generate(
    int length,
    bool Function(int) generator, {
    bool growable = true,
  }) {
    RangeError.checkNotNegative(length, 'length');

    var instance = BoolList._selectType(length, growable);
    for (var i = 0; i < length; i++) {
      instance._setBit(i, generator(i));
    }
    return instance;
  }

  /// Creates a list containing all [elements].
  ///
  /// The [Iterator] of [elements] provides the order of the elements.
  ///
  /// This constructor creates a growable [BoolList] when [growable] is true;
  /// otherwise, it returns a fixed-length list.
  factory BoolList.from(Iterable<bool> elements, {bool growable = false}) {
    return BoolList._selectType(elements.length, growable)..setAll(0, elements);
  }

  @override
  int get length => _length;

  @override
  bool operator [](int index) {
    RangeError.checkValidIndex(index, this, 'index', _length);
    return (_data[index >> _entryShift] &
            (1 << (index & _entrySignBitIndex))) !=
        0;
  }

  @override
  void operator []=(int index, bool val) {
    RangeError.checkValidIndex(index, this, 'index', _length);
    _setBit(index, val);
  }

  @override
  void fillRange(int start, int end, [bool fill]) {
    RangeError.checkValidRange(start, end, _length);
    fill ??= false;

    var startWord = start >> _entryShift;
    var endWord = (end - 1) >> _entryShift;

    var startBit = start & _entrySignBitIndex;
    var endBit = (end - 1) & _entrySignBitIndex;

    if (startWord < endWord) {
      if (fill) {
        _data[startWord] |= -1 << startBit;
        _data.fillRange(startWord + 1, endWord, -1);
        _data[endWord] |= (1 << (endBit + 1)) - 1;
      } else {
        _data[startWord] &= (1 << startBit) - 1;
        _data.fillRange(startWord + 1, endWord, 0);
        _data[endWord] &= -1 << (endBit + 1);
      }
    } else {
      if (fill) {
        _data[startWord] |= ((1 << (endBit - startBit + 1)) - 1) << startBit;
      } else {
        _data[startWord] &= ((1 << startBit) - 1) | (-1 << (endBit + 1));
      }
    }
  }

  /// Returns custom iterator for [BoolList].
  ///
  /// To provide null safety [Iterator.current] getter of returned iterator
  /// returns `false` before and after iteration process.
  @override
  Iterator<bool> get iterator => _BoolListIterator(this);

  void _setBit(int index, bool val) {
    if (val) {
      _data[index >> _entryShift] |= 1 << (index & _entrySignBitIndex);
    } else {
      _data[index >> _entryShift] &= ~(1 << (index & _entrySignBitIndex));
    }
  }

  static int _lengthInWords(int bitsLength) {
    return (bitsLength + (_bitsPerEntry - 1)) >> _entryShift;
  }
}

class _GrowableBoolList extends BoolList {
  static const int _growthFactor = 2;

  _GrowableBoolList(int length)
      : super._(
          Uint32List(BoolList._lengthInWords(length * _growthFactor)),
          length,
        );

  @override
  set length(int length) {
    RangeError.checkNotNegative(length, 'length');
    if (length > _length) {
      _expand(length);
    } else if (length < _length) {
      _shrink(length);
    }
  }

  void _expand(int length) {
    if (length > _data.length * BoolList._bitsPerEntry) {
      _data = Uint32List(
        BoolList._lengthInWords(length * _growthFactor),
      )..setAll(0, _data);
    }
    _length = length;
  }

  void _shrink(int length) {
    if (length < _length ~/ _growthFactor) {
      var newDataLength = BoolList._lengthInWords(length);
      _data = Uint32List(newDataLength)..setRange(0, newDataLength, _data);
    }

    for (var i = length; i < _data.length * BoolList._bitsPerEntry; i++) {
      _setBit(i, false);
    }

    _length = length;
  }
}

class _NonGrowableBoolList extends BoolList with NonGrowableListMixin<bool> {
  _NonGrowableBoolList(int length)
      : super._(
          Uint32List(BoolList._lengthInWords(length)),
          length,
        );
}

class _BoolListIterator implements Iterator<bool> {
  bool _current = false;
  int _pos = 0;
  final int _length;
  int _wordIndex = -1;
  int _bitIndex = BoolList._entrySignBitIndex;

  int _mask;

  final BoolList _boolList;

  _BoolListIterator(this._boolList) : _length = _boolList._length;

  @override
  bool get current => _current;

  @override
  bool moveNext() {
    if (_boolList._length != _length) {
      throw ConcurrentModificationError(_boolList);
    }

    if (_pos == _boolList.length) {
      _current = false;
      return false;
    }

    if (++_bitIndex == BoolList._bitsPerEntry) {
      _wordIndex++;
      _bitIndex = 0;
      _mask = 1;
    } else {
      _mask <<= 1;
    }

    _current = _boolList._data[_wordIndex] & _mask != 0;
    _pos++;
    return true;
  }
}
