// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Tests for BitArray.

import 'package:collection/collection.dart';
import 'package:test/test.dart';

void main() {
  var generator = (int index) {
    if (index < 500) {
      return index.isEven;
    }
    return false;
  };

  group('BitArray()', () {
    test('initial false values', () {
      var ba = BitArray(1000);
      for (var pos = 0; pos < 1000; ++pos) {
        expect(ba[pos], false, reason: 'at pos $pos');
      }
    });

    test('initial true values', () {
      var ba = BitArray(1000, true);
      for (var pos = 0; pos < 1000; ++pos) {
        expect(ba[pos], true, reason: 'at pos $pos');
      }
    });
  });

  test('BitArray.generate()', () {
    var ba = BitArray.generate(1000, generator);

    for (var pos = 0; pos < 1000; ++pos) {
      expect(ba[pos], generator(pos), reason: 'at pos $pos');
    }
  });

  group('[], []=', () {
    test('RangeError', () {
      var ba = BitArray(1000);

      expect(() {
        ba[-1];
      }, throwsRangeError);

      expect(() {
        ba[1000];
      }, throwsRangeError);
    });

    test('[], []=', () {
      var ba = BitArray(1000);

      bool posVal;
      for (var pos = 0; pos < 1000; ++pos) {
        posVal = generator(pos);
        ba[pos] = posVal;
        expect(ba[pos], posVal, reason: 'at pos $pos');
      }
    });
  });

  test('BitArrayIterator', () {
    var ba = BitArray.generate(1000, generator);
    var iter = BitArrayIterator(ba);

    var pos = 0;
    while (iter.moveNext()) {
      expect(iter.current, ba[pos], reason: 'at pos $pos');
      ++pos;
    }
    expect(pos, ba.length);
  });

  group('logical operations', () {
    BitArray ba1;
    BitArray ba2;

    var negated = List.generate(300, (int index) => index <= 100);
    var ored = List.filled(300, true);
    var anded = List.generate(300, (int index) => index > 100 && index < 200);
    var xored = List.generate(300, (int index) => index <= 100 || index >= 200);

    setUp(() {
      ba1 = BitArray.generate(300, (int index) => index > 100);
      ba2 = BitArray.generate(300, (int index) => index < 200);
    });

    test('BitArray.not()', () {
      ba1.not();
      expect(ba1, containsAll(negated));
    });

    test('BitArray.or()', () {
      ba1.or(ba2);
      expect(ba1, containsAll(ored));
    });

    test('BitArray.and()', () {
      ba1.and(ba2);
      expect(ba1, containsAll(anded));
    });

    test('BitArray.xor()', () {
      ba1.xor(ba2);
      expect(ba1, containsAll(xored));
    });

    test('BitArray.notGate()', () {
      expect(BitArray.notGate(ba1), containsAll(negated));
    });

    test('BitArray.orGate()', () {
      expect(BitArray.orGate(ba1, ba2), containsAll(ored));
    });

    test('BitArray.andGate()', () {
      expect(BitArray.andGate(ba1, ba2), containsAll(anded));
    });

    test('BitArray.xorGate()', () {
      expect(BitArray.xorGate(ba1, ba2), containsAll(xored));
    });
  });

  test('BitArray.cardinality', () {
    var ba = BitArray.generate(300, (int index) {
      return index > 100 && index < 200;
    });

    expect(ba.cardinality, 99);
  });

  test('BitArray.flip', () {
    var ba = BitArray(100, true);

    ba.flip(50);
    expect(ba[50], false);

    ba.flip(50);
    expect(ba[50], true);
  });

  test('BitArray.flipRange', () {
    var ba = BitArray(100, true);

    ba.flipRange(25, 63);
    for (var pos = 25; pos < 63; ++pos) {
      expect(ba[pos], false, reason: 'at pos $pos');
    }

    ba.flipRange(25, 63);
    for (var pos = 25; pos < 63; ++pos) {
      expect(ba[pos], true, reason: 'at pos $pos');
    }
  });

  test('BitArray.equal()', () {
    var ba1 = BitArray.generate(300, (int index) => index > 100);

    var ba2 = BitArray.generate(300, (int index) => index > 100);
    expect(ba1.equal(ba2), true);

    var ba3 = BitArray.generate(300, (int index) => index < 100);
    expect(ba1.equal(ba3), false);
  });
}
