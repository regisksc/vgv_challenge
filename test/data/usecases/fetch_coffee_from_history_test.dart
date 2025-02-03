import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late FetchCoffeeFromHistory fetchCoffeeFromHistory;
  late MockStorage mockStorage;

  setUp(() {
    mockStorage = MockStorage();
    fetchCoffeeFromHistory = FetchCoffeeFromHistory(storage: mockStorage);
  });

  tearDown(() {
    reset(mockStorage);
  });

  group('FetchCoffeeFromHistory', () {
    // ignore: lines_longer_than_80_chars
    test('returns the last coffee from history when history is not empty', () async {
      // Arrange
      final seenAt = DateTime.now();
      final coffeeJson = {
        'id': '1',
        'file': 'path/to/coffee.jpg',
        'seenAt': seenAt.toIso8601String(),
        'isFavorite': false,
        'comment': 'Great coffee!',
        'rating': 5,
      };
      final jsonString = jsonEncode([coffeeJson]);

      when(
        () => mockStorage.read(key: 'history'),
      ).thenAnswer((_) async => jsonString);

      // Act
      final result = await fetchCoffeeFromHistory.call();

      // Assert
      expect(result.isSuccess, isTrue);
      final coffee = result.successValue!;
      expect(coffee.id, '1');
      expect(coffee.imagePath, 'path/to/coffee.jpg');
      expect(coffee.seenAt, isA<DateTime>());
      expect(coffee.seenAt.isAtSameMomentAs(seenAt), isTrue);
      expect(coffee.isFavorite, isFalse);
      expect(coffee.comment, 'Great coffee!');
      expect(coffee.rating, CoffeeRating.fiveStars);

      verify(() => mockStorage.read(key: 'history')).called(1);
    });

    test('returns ReadingFromEmptyFailure when history is empty', () async {
      // Arrange
      when(
        () => mockStorage.read(key: 'history'),
      ).thenAnswer((_) async => null);

      // Act
      final result = await fetchCoffeeFromHistory.call();

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.failure, isA<ReadingFromEmptyFailure>());
      verify(() => mockStorage.read(key: 'history')).called(1);
    });

    test('handles JSON decoding errors gracefully', () async {
      // Arrange
      when(
        () => mockStorage.read(key: 'history'),
      ).thenAnswer((_) async => 'invalid_json');

      // Act
      final result = await fetchCoffeeFromHistory.call();

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.failure, isA<ReadingFailure>());
      verify(() => mockStorage.read(key: 'history')).called(1);
    });

    test('handles storage read errors gracefully', () async {
      // Arrange
      when(
        () => mockStorage.read(key: 'history'),
      ).thenThrow(Exception('Storage read error'));

      // Act
      final result = await fetchCoffeeFromHistory.call();

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.failure, isA<ReadingFailure>());
      verify(() => mockStorage.read(key: 'history')).called(1);
    });

    test('returns the last coffee from a non-empty history list', () async {
      // Arrange
      final seenAt1 = DateTime.now().subtract(const Duration(days: 1));
      final seenAt2 = DateTime.now();
      final coffeeJson1 = {
        'id': '1',
        'file': 'path/to/coffee1.jpg',
        'seenAt': seenAt1.toIso8601String(),
        'isFavorite': false,
        'comment': 'Coffee 1',
        'rating': 3,
      };
      final coffeeJson2 = {
        'id': '2',
        'file': 'path/to/coffee2.jpg',
        'seenAt': seenAt2.toIso8601String(),
        'isFavorite': true,
        'comment': 'Coffee 2',
        'rating': 4,
      };
      final jsonString = jsonEncode([coffeeJson1, coffeeJson2]);

      when(
        () => mockStorage.read(key: 'history'),
      ).thenAnswer((_) async => jsonString);

      // Act
      final result = await fetchCoffeeFromHistory.call();

      // Assert
      expect(result.isSuccess, isTrue);
      final coffee = result.successValue!;
      expect(coffee.id, '2');
      expect(coffee.imagePath, 'path/to/coffee2.jpg');
      expect(coffee.seenAt.isAtSameMomentAs(seenAt2), isTrue);
      expect(coffee.isFavorite, isTrue);
      expect(coffee.comment, 'Coffee 2');
      expect(coffee.rating, CoffeeRating.fourStars);

      verify(() => mockStorage.read(key: 'history')).called(1);
    });
  });
}
