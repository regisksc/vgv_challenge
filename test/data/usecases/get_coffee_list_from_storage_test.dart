import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  final faker = Faker();

  Coffee generateFakeCoffee() {
    return Coffee(
      id: faker.guid.guid(),
      imagePath: faker.internet.httpsUrl(),
      seenAt: DateTime.now(),
      isFavorite: faker.randomGenerator.boolean(),
      comment: faker.lorem.sentence(),
      rating: CoffeeRating.values[faker.randomGenerator.integer(
        CoffeeRating.values.length,
      )],
    );
  }

  group('GetCoffeeListFromStorage', () {
    late MockStorage mockStorage;

    setUp(() {
      mockStorage = MockStorage();
    });

    group('GetFavoriteCoffeeList', () {
      late GetFavoriteCoffeeList getFavoriteCoffeeList;

      setUp(() {
        getFavoriteCoffeeList = GetFavoriteCoffeeList(storage: mockStorage);
      });

      test('returns failure when storage returns null', () async {
        // Arrange
        when(
          () => mockStorage.read(key: StorageConstants.favoritesKey),
        ).thenAnswer((_) async => null);

        // Act
        final result = await getFavoriteCoffeeList.call();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ReadingFromEmptyFailure>());
        verify(
          () => mockStorage.read(key: StorageConstants.favoritesKey),
        ).called(1);
      });

      // ignore: lines_longer_than_80_chars
      test('returns success with a list of Coffee when valid JSON is returned', () async {
        // Arrange
        final coffees = List.generate(3, (_) => generateFakeCoffee());
        final coffeeJsonList = coffees
            .map(
              (coffee) => CoffeeModel.fromEntity(coffee).toJson(),
            )
            .toList();
        final jsonString = jsonEncode(coffeeJsonList);

        when(
          () => mockStorage.read(key: StorageConstants.favoritesKey),
        ).thenAnswer((_) async => jsonString);

        // Act
        final result = await getFavoriteCoffeeList.call();

        // Assert
        expect(result.isSuccess, isTrue);
        final returnedList = result.successValue!.reversed.toList();
        expect(returnedList.length, equals(coffees.length));
        for (var i = 0; i < coffees.length; i++) {
          expect(returnedList[i].id, equals(coffees[i].id));
        }
        verify(
          () => mockStorage.read(key: StorageConstants.favoritesKey),
        ).called(1);
      });

      // ignore: lines_longer_than_80_chars
      test('returns failure with ReadingFailure when storage.read throws', () async {
        // Arrange
        when(
          () => mockStorage.read(key: StorageConstants.favoritesKey),
        ).thenThrow(Exception('Read error'));

        // Act
        final result = await getFavoriteCoffeeList.call();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ReadingFailure>());
        verify(
          () => mockStorage.read(key: StorageConstants.favoritesKey),
        ).called(1);
      });
    });

    group('GetCoffeeHistoryList', () {
      late GetCoffeeHistoryList getCoffeeHistoryList;

      setUp(() {
        getCoffeeHistoryList = GetCoffeeHistoryList(storage: mockStorage);
      });

      test('returns failure when storage returns null', () async {
        // Arrange
        when(
          () => mockStorage.read(key: StorageConstants.historyKey),
        ).thenAnswer((_) async => null);

        // Act
        final result = await getCoffeeHistoryList.call();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ReadingFromEmptyFailure>());
        verify(
          () => mockStorage.read(key: StorageConstants.historyKey),
        ).called(1);
      });

      // ignore: lines_longer_than_80_chars
      test('returns success with a list of Coffee when valid JSON is returned', () async {
        // Arrange
        final coffees = List.generate(2, (_) => generateFakeCoffee());
        final coffeeJsonList = coffees
            .map(
              (coffee) => CoffeeModel.fromEntity(coffee).toJson(),
            )
            .toList();
        final jsonString = jsonEncode(coffeeJsonList);

        when(
          () => mockStorage.read(key: StorageConstants.historyKey),
        ).thenAnswer((_) async => jsonString);

        // Act
        final result = await getCoffeeHistoryList.call();

        // Assert
        expect(result.isSuccess, isTrue);
        final returnedList = result.successValue!.reversed.toList();
        expect(returnedList.length, equals(coffees.length));
        for (var i = 0; i < coffees.length; i++) {
          expect(returnedList[i].id, equals(coffees[i].id));
        }
        verify(
          () => mockStorage.read(key: StorageConstants.historyKey),
        ).called(1);
      });

      // ignore: lines_longer_than_80_chars
      test('returns failure with ReadingFailure when storage.read throws', () async {
        // Arrange
        when(
          () => mockStorage.read(key: StorageConstants.historyKey),
        ).thenThrow(Exception('Some error'));

        // Act
        final result = await getCoffeeHistoryList.call();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ReadingFailure>());
        verify(
          () => mockStorage.read(key: StorageConstants.historyKey),
        ).called(1);
      });
    });
  });
}
