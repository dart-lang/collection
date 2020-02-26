// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection' show ListMixin;
import 'dart:typed_data' show Uint32List;
import 'package:collection/collection.dart' show NonGrowableListMixin;

/// A BitArray implementation for Dart to store boolean values.
///
/// Uses list of integers as internal storage to reduce memory usage.
/// Implemented as fixed-length [List] of [bool].
/// Throws error when calling any operation with length modifying.
///
/// Support several ways to perform logical operations (NOT, OR, AND, XOR):
/// * instance methods (mutate [this]): [BitArray.not], [BitArray.or], [BitArray.and], [BitArray.xor];
/// * producing new instance of [BitArray]:
///     * logical operators: [BitArray.~], [BitArray.|], [BitArray.&], [BitArray.^].
///     * logical gates (as static methods): [BitArray.notGate], [BitArray.orGate], [BitArray.andGate], [BitArray.xorGate].
/// All arguments for not-unary logical operations must have the same [length] or [ArgumentError] will be thrown.
class BitArray with ListMixin<bool>, NonGrowableListMixin<bool> {
  int _length;

  Uint32List _data;

  /// Mask to set tail bits to zero.
  int _tailMask;

  static const List<int> _numOfBitsLookup = [
    0, 1, 1, 2, 1, 2, 2, 3, //
    1, 2, 2, 3, 2, 3, 3, 4, //
    1, 2, 2, 3, 2, 3, 3, 4, //
    2, 3, 3, 4, 3, 4, 4, 5, //
    1, 2, 2, 3, 2, 3, 3, 4, //
    2, 3, 3, 4, 3, 4, 4, 5, //
    2, 3, 3, 4, 3, 4, 4, 5, //
    3, 4, 4, 5, 4, 5, 5, 6, //
    1, 2, 2, 3, 2, 3, 3, 4, //
    2, 3, 3, 4, 3, 4, 4, 5, //
    2, 3, 3, 4, 3, 4, 4, 5, //
    3, 4, 4, 5, 4, 5, 5, 6, //
    2, 3, 3, 4, 3, 4, 4, 5, //
    3, 4, 4, 5, 4, 5, 5, 6, //
    3, 4, 4, 5, 4, 5, 5, 6, //
    4, 5, 5, 6, 5, 6, 6, 7, //
    1, 2, 2, 3, 2, 3, 3, 4, //
    2, 3, 3, 4, 3, 4, 4, 5, //
    2, 3, 3, 4, 3, 4, 4, 5, //
    3, 4, 4, 5, 4, 5, 5, 6, //
    2, 3, 3, 4, 3, 4, 4, 5, //
    3, 4, 4, 5, 4, 5, 5, 6, //
    3, 4, 4, 5, 4, 5, 5, 6, //
    4, 5, 5, 6, 5, 6, 6, 7, //
    2, 3, 3, 4, 3, 4, 4, 5, //
    3, 4, 4, 5, 4, 5, 5, 6, //
    3, 4, 4, 5, 4, 5, 5, 6, //
    4, 5, 5, 6, 5, 6, 6, 7, //
    3, 4, 4, 5, 4, 5, 5, 6, //
    4, 5, 5, 6, 5, 6, 6, 7, //
    4, 5, 5, 6, 5, 6, 6, 7, //
    5, 6, 6, 7, 6, 7, 7, 8
  ];

  /// Creates a [BitArray] with [length].
  ///
  /// All initial values are [false], set [filled] to [true] to make them [true].
  BitArray(int length, [bool filled = false]) {
    ArgumentError.checkNotNull(length);
    RangeError.checkNotNegative(length, 'length');

    _length = length;
    _data = Uint32List((length >> 5) + 1);

    _tailMask = 0xFFFFFFFF >> (_data.length * 32 - _length);

    if (filled) {
      _setDataWords((_) => -1);
    }
  }

  /// Generates a [BitArray] filled with values by [generator].
  factory BitArray.generate(int length, bool Function(int index) generator) {
    ArgumentError.checkNotNull(length);
    RangeError.checkNotNegative(length, 'length');

    ArgumentError.checkNotNull(generator);

    var result = BitArray(length);
    for (var pos = 0; pos < length; ++pos) {
      result[pos] = generator(pos);
    }
    return result;
  }

  /// Replaces integer values in [_data] by applying [func] to each word.
  void _transformDataWords(int Function(int word, int wordIndex) func) {
    for (var wordIndex = 0; wordIndex < _data.length; ++wordIndex) {
      _data[wordIndex] = func(_data[wordIndex], wordIndex);
    }
    _clearTailBits();
  }

  /// Sets all words in [_data] to values retuned from [func].
  void _setDataWords(int Function(int wordIndex) func) {
    for (var wordIndex = 0; wordIndex < _data.length; ++wordIndex) {
      _data[wordIndex] = func(wordIndex);
    }
    _clearTailBits();
  }

  /// Sets tail bits in the last word of [_data] to zero.
  ///
  /// Needs to clear last bits after logical operations over [this].
  void _clearTailBits() {
    _data.last &= _tailMask;
  }

  /// Performs logical negation to [this].
  void not() {
    _transformDataWords((int word, _) => ~word);
  }

  /// Performs logical AND operation to [this] with given [BitArray].
  void and(BitArray ba) {
    _checkLengthsEqual(this, ba);
    _transformDataWords(
        (int word, int wordIndex) => word & ba._data[wordIndex]);
  }

  /// Performs logical OR operation to [this] with given [BitArray].
  void or(BitArray ba) {
    _checkLengthsEqual(this, ba);
    _transformDataWords(
        (int word, int wordIndex) => word | ba._data[wordIndex]);
  }

  /// Performs logical XOR operation to [this] with given [BitArray].
  void xor(BitArray ba) {
    _checkLengthsEqual(this, ba);
    _transformDataWords(
        (int word, int wordIndex) => word ^ ba._data[wordIndex]);
  }

  /// Creates a new instance of [BitArray] with the same values as in [this].
  BitArray clone() {
    var result = BitArray(_length);
    result._setDataWords((int wordIndex) => _data[wordIndex]);
    return result;
  }

  /// Returns a [BitArray] result of negated [ba].
  static BitArray notGate(BitArray ba) {
    var result = BitArray(ba.length);
    result._setDataWords((int wordIndex) => ~ba._data[wordIndex]);
    return result;
  }

  /// Returns a result of logical OR operation for passed [BitArray]s.
  static BitArray orGate(BitArray ba1, BitArray ba2) {
    _checkLengthsEqual(ba1, ba2);
    var result = BitArray(ba1.length);
    result._setDataWords((int wordIndex) {
      return ba1._data[wordIndex] | ba2._data[wordIndex];
    });
    return result;
  }

  /// Returns a result of logical AND operation for passed [BitArray]s.
  static BitArray andGate(BitArray ba1, BitArray ba2) {
    _checkLengthsEqual(ba1, ba2);
    var result = BitArray(ba1.length);
    result._setDataWords((int wordIndex) {
      return ba1._data[wordIndex] & ba2._data[wordIndex];
    });
    return result;
  }

  /// Returns a result of logical XOR operation for passed [BitArray]s.
  static BitArray xorGate(BitArray ba1, BitArray ba2) {
    _checkLengthsEqual(ba1, ba2);
    var result = BitArray(ba1.length);
    result._setDataWords((int wordIndex) {
      return ba1._data[wordIndex] ^ ba2._data[wordIndex];
    });
    return result;
  }

  /// Returns [true] if bitarrays have the same length and the same values.
  bool equal(BitArray ba) {
    if (identical(this, ba)) return true;
    if (_length != ba._length) return false;
    for (var wordIndex = 0; wordIndex < _data.length; ++wordIndex) {
      if (_data[wordIndex] != ba._data[wordIndex]) return false;
    }
    return true;
  }

  @override
  bool operator [](int index) {
    RangeError.checkValidIndex(index, this);
    return (_data[index >> 5] & (1 << (index & 31))) != 0;
  }

  @override
  int get length => _length;

  @override
  void operator []=(int index, bool val) {
    RangeError.checkValidIndex(index, this);
    if (val) {
      _data[index >> 5] |= 1 << (index & 31);
    } else {
      _data[index >> 5] &= ~(1 << (index & 31));
    }
  }

  /// Counts number of bits in unsigned [val].
  int _countBits(int val) {
    var bits = 0;
    while (val != 0) {
      bits += _numOfBitsLookup[val & 0xFF];
      val >>= 8;
    }
    return bits;
  }

  /// Returns number [true] values in [this].
  int get cardinality {
    var card = 0;
    for (var word in _data) {
      card += _countBits(word);
    }
    return card;
  }

  /// Returns logical NOT of [this].
  BitArray operator ~() => BitArray.notGate(this);

  /// Returns result or logical AND between [this] and [ba].
  BitArray operator &(BitArray ba) => BitArray.andGate(this, ba);

  /// Returns result or logical OR between [this] and [ba].
  BitArray operator |(BitArray ba) => BitArray.orGate(this, ba);

  /// Returns result or logical XOR between [this] and [ba].
  BitArray operator ^(BitArray ba) => BitArray.xorGate(this, ba);

  /// Checks lengths equal for given [BitArray]s.
  ///
  /// Throws [ArgumentExceprion] when lengts is differ.
  static void _checkLengthsEqual(BitArray ba1, BitArray ba2) {
    if (ba1._length != ba2._length) {
      throw ArgumentError.value(
          'BitArrays should have equal lengths: ${ba1._length} != ${ba2._length}');
    }
  }

  /// Sets the bit at the [index] to the complement of its current value.
  void flip(int index) {
    RangeError.checkValidIndex(index, this);
    _data[index >> 5] ^= 1 << (index & 31);
  }

  /// Sets each bit at the range from [start] inclusive to [end] exclusive to the complement of its current value.
  void flipRange(int start, [int end]) {
    end ??= _length;
    RangeError.checkValidRange(start, end, _length);

    var startWordIndex = start >> 5;
    var endWordIndex = end >> 5;

    if (startWordIndex == endWordIndex) {
      for (var pos = start; pos < end; ++pos) {
        flip(pos);
      }
    } else {
      // First word
      _data[startWordIndex] ^= -1 << (start & 31);

      // Intermediate words
      for (var wordIndex = startWordIndex + 1;
          wordIndex < endWordIndex;
          ++wordIndex) {
        _data[wordIndex] = ~_data[wordIndex];
      }

      // Last word
      _data[endWordIndex] ^= 0xFFFFFFFF >> (32 - (end & 31));
    }
  }

  @override
  Iterator<bool> get iterator => BitArrayIterator(this);
}

/// Iterator for [BitArray].
class BitArrayIterator implements Iterator<bool> {
  bool _current;
  int _pos = 0;
  final BitArray _bitArray;

  BitArrayIterator(this._bitArray);

  @override
  bool get current => _current;

  @override
  bool moveNext() {
    if (_pos == _bitArray.length) {
      _current == null;
      return false;
    }
    _current = _bitArray[_pos];
    ++_pos;
    return true;
  }
}
