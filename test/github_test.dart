import 'package:test/test.dart';

void main() {
  test('good', () {
    expect(true, isTrue);
  });

  test('bad', () {
    expect(false, isTrue);
  });

  test('error', () {
    throw UnimplementedError();
  });
}
