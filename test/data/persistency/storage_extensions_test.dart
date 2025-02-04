import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late MockStorage mockStorage;

  setUp(() {
    mockStorage = MockStorage();
  });

  // ignore: lines_longer_than_80_chars
  test('getCoffeeList returns null when not found', () async {
    // Arrange
    const testKey = 'testKey';
    when(() => mockStorage.read(key: testKey)).thenAnswer((_) async => null);

    // Act
    final result = await mockStorage.getCoffeeList(testKey);

    // Act & Assert
    expect(result, isNull);
  });
}
