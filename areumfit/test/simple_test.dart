import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Simple arithmetic test', () {
    expect(1 + 1, equals(2));
  });
  
  test('String concatenation test', () {
    expect('Hello' + ' World', equals('Hello World'));
  });
  
  test('List operations test', () {
    final list = <String>['apple', 'banana'];
    list.add('cherry');
    expect(list.length, equals(3));
    expect(list.contains('banana'), isTrue);
  });
}