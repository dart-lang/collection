import 'package:collection/src/sort_order.dart';
import 'package:test/test.dart';

void main() {
  group('sorting order', () {
    group('extension method', () {
      test('sortAsc', () {
        final list = [1, 3, 2, 4]..sortAsc();

        expect(list.join(','), '1,2,3,4');
      });

      test('sortDesc', () {
        final list = [1, 3, 2, 4]..sortDesc();

        expect(list.join(','), '4,3,2,1');
      });
    });

    group('function', () {
      test('sortAsc', () {
        final list = [1, 3, 2, 4]..sort((a, b) => sortAsc(a, b));

        expect(list.join(','), '1,2,3,4');
      });

      test('sortDesc', () {
        final list = [1, 3, 2, 4]..sort((a, b) => sortDesc(a, b));

        expect(list.join(','), '4,3,2,1');
      });
    });
  });
}
