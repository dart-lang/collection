//import 'dart:collection';
import 'package:test/test.dart';
import '../lib/src/multi_map.dart';


void main() {
  test('default constructor', () {
    MultiMap<String, String> map = new MultiMap<String, String>();
    expect(map is MultiMap, equals(true));
    expect(map is Map, equals(true));
  });

  /**
   * Todo: Only needed if MultiMap can be instantiated from literal.
   */
  /*
  test('literal constructor', () {
    MultiMap<String, String> map = {'foo':'bar'};
    expect(map['foo'],equals('bar'));
  });
  */

  test('identity constructor', () {
    MultiMap<String, String> map = new MultiMap<String, String>.identity();
    expect(map is MultiMap, equals(true));
  });

  test('from constructor', () {
    Map<String, Object> other = {'foo': 'bar', 'fi':['fo','fum']};
    MultiMap<String, String> map = new MultiMap<String, String>.from(other);
    expect(map is MultiMap, equals(true));
    expect(map['foo'],equals('bar'));
    expect(map['fi'],equals('fum'));
    expect(map.multiple('fi'),equals(['fo','fum']));
  });

  test('fromIterable constructor', () {
    List<int> list = [1, 2, 3];
    Map<String, int> map = new MultiMap.fromIterable(list,
        key: (item) => item.toString(),
        value: (item) => item * item);

    expect(map is MultiMap, equals(true));
    expect(map['1'],equals(1));
    expect(map['2'],equals(4));
    expect(map['3'],equals(9));
  });

  test('fromIterables constructor', () {
    Map<String, Object> other = {'foo': 'bar', 'fi':['fo','fum']};
    MultiMap<String, String> map = new MultiMap<String, String>.fromIterables(other.keys, other.values);
    expect(map is MultiMap, equals(true));
    expect(map['foo'],equals('bar'));
    expect(map['fi'],equals('fum'));
    expect(map.multiple('fi'),equals(['fo','fum']));
  });

  test('containsValue', () {
    MultiMap<String, String> map = new MultiMap<String,
        String>();
    expect(map.containsValue('b'), equals(false));
    map['a'] = 'b';
    expect(map.containsValue('b'), equals(true));
    List<String> cd = ['c', 'd'];
    map['b'] = cd;
    expect(map.containsValue('b'), equals(true));
    expect(map.containsValue('c'), equals(false));
    expect(map.containsValue('d'), equals(true));
    map['b'] = 'e';
    expect(map.containsValue('b'), equals(true));
    expect(map.containsValue('c'), equals(false));
    expect(map.containsValue('d'), equals(false));
    expect(map.containsValue('e'), equals(true));
  });

  test('containsKey', () {
    MultiMap<String, String> map = new MultiMap<String,
        String>();
    expect(map.containsKey('a'), equals(false));
    map['a'] = 'b';
    expect(map.containsKey('a'), equals(true));
    List<String> cd = ['c', 'd'];
    map['b'] = cd;
    expect(map.containsKey('a'), equals(true));
    expect(map.containsKey('b'), equals(true));
    map['c'] = 'e';
    expect(map.containsKey('a'), equals(true));
    expect(map.containsKey('b'), equals(true));
    expect(map.containsKey('c'), equals(true));
  });

  test('[]=', () {
    MultiMap<String, String> map = new MultiMap<String,
        String>();
    expect(map['a'], equals(null));
    map['a'] = 'b';
    expect(map['a'], equals('b'));
    List<String> bc = ['b', 'c'];
    map['a'] = bc;
    expect(map['a'], equals('c'));
    map['a'] = 'd';
    expect(map['a'], equals('d'));
  });

  test('putIfAbsent', () {
    MultiMap<int, int> map = new MultiMap<int, int>();
    map.putIfAbsent(4, () {
      map[5] = 5;
      map[4] = -1;
      return 4;
    });
    expect(map[4], equals(4));
    map.putIfAbsent(4, (){return 25;});
    expect(map[4], equals(4));
    map.putIfAbsent(3, (){return 25;});
    expect(map[3], equals(25));
  });

  test('addAll', () {
    Map<String, Object> other = {'foo': 'bar', 'fi':['fo','fum']};
    MultiMap<String, String> map = new MultiMap<String, String>();
    map.addAll(other);
    expect(map['foo'],equals('bar'));
    expect(map['fi'],equals('fum'));
    expect(map.multiple('fi'),equals(['fo','fum']));
  });

  test('remove', () {
    Map<String, Object> other = {'foo': 'bar', 'fi':['fo','fum']};
    MultiMap<String, String> map = new MultiMap<String, String>();
    map.addAll(other);
    expect(map.remove('foo'),equals('bar'));
    expect(map['foo'],equals(null));
    expect(map.containsKey('foo'),equals(false));

    expect(map.remove('fi'),equals('fum'));
    expect(map['fi'],equals(null));
    expect(map.containsKey('fi'),equals(false));
    expect(map.multiple('fi'),equals(null));
  });

  test('clear', () {
    Map<String, Object> other = {'foo': 'bar', 'fi':['fo','fum']};
    MultiMap<String, String> map = new MultiMap<String, String>();
    map.addAll(other);
    map.clear();
    expect(map.length,equals(0));
    expect(map.keys,equals([]));
  });

  test('forEach', () {
    Map<String, Object> other = {'foo': 'bar', 'fi':['fo','fum']};
    MultiMap<String, String> map = new MultiMap<String, String>();
    map.addAll(other);

    int i = 0;
    map.forEach((String key, String value){
      if (key == 'foo') {
        expect(i,equals(0));
        expect(value, equals('bar'));
      }
      if (key == 'fi') {
        expect(i,equals(1));
        expect(value, equals('fum'));
      }
      i++;
    });
  });

  test('forEachMultiple', () {
    Map<String, Object> other = {'foo': 'bar', 'fi':['fo','fum']};
    MultiMap<String, String> map = new MultiMap<String, String>();
    map.addAll(other);

    int i = 0;
    map.forEachMultiple((String key, List<String> value){
      if (key == 'foo') {
        expect(i,equals(0));
        expect(value, equals(['bar']));
      }
      if (key == 'fi') {
        expect(i,equals(1));
        expect(value, equals(['fo','fum']));
      }
      i++;
    });
  });

  test('get keys', () {
    MultiMap<String, String> map = new MultiMap<String,
        String>();
    expect(map['a'], equals(null));
    map['a'] = 'b';
    List<String> cd = ['c', 'd'];
    map['b'] = cd;
    Iterable<String> keys = map.keys;
    int i = 0;
    for (String key in keys) {
      if (i == 0) expect(key, equals('a'));
      if (i == 1) expect(key, equals('b'));
      i++;
    }
  });

  test('get values', () {
    MultiMap<String, String> map = new MultiMap<String,
        String>();
    expect(map['a'], equals(null));
    map['a'] = 'b';
    List<String> cd = ['c', 'd'];
    map['b'] = cd;
    Iterable<String> values = map.values;
    int i = 0;
    for (String value in values) {
      if (i == 0) expect(value, equals('b'));
      if (i == 1) expect(value, equals('d'));
      i++;
    }
  });

  test('length', () {
    MultiMap<String, String> map = new MultiMap<String,
        String>();
    expect(map.length, equals(0));
    map['a'] = 'b';
    expect(map.length, equals(1));
  });

  test('isEmpty', () {
    MultiMap<String, String> map = new MultiMap<String,
        String>();
    expect(map.isEmpty, equals(true));
    map['a'] = 'b';
    expect(map.isEmpty, equals(false));
  });

  test('isNotEmpty', () {
    MultiMap<String, String> map = new MultiMap<String,
        String>();
    expect(map.isNotEmpty, equals(false));
    map['a'] = 'b';
    expect(map.isNotEmpty, equals(true));
  });


  test('multiple', () {
    MultiMap<String, String> map = new MultiMap<String,
        String>();
    expect(map.multiple('a'), equals(null));
    map['a'] = 'b';
    List<String> cd = ['c', 'd'];
    map['b'] = cd;
    map['b'] = 'e';

    expect(map.multiple('a'), equals(['b']));
    expect(map.multiple('b'), equals(['c', 'd', 'e']));

    List<String> cdprime = ['c', 'd'];
    map['b'] = cdprime;

    expect(map.multiple('b'), equals(['c', 'd']));

  });
}