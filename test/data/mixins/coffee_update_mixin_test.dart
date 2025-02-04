// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class MockStorage extends Mock implements Storage {}

class TestCoffeeUpdater extends UpdateCoffee with CoffeeUpdateHelper {
  TestCoffeeUpdater(this.storage);
  @override
  final Storage storage;
  @override
  Future<Result<void, Failure>> call([UpdateCoffeeParams? params]) async {
    throw UnimplementedError();
  }
}

void main() {
  late MockStorage mockStorage;
  late TestCoffeeUpdater updater;
  final testCoffee = Coffee(
    id: '1',
    imagePath: 'test.jpg',
    seenAt: DateTime(2025),
    comment: 'Original comment',
  );
  final testCoffeeModel = CoffeeModel.fromEntity(testCoffee);

  String generateJsonFromList(List<CoffeeModel> models) {
    return jsonEncode(models.map((m) => m.toJson()).toList());
  }

  setUp(() {
    mockStorage = MockStorage();
    updater = TestCoffeeUpdater(mockStorage);
    when(() => mockStorage.read(key: any(named: 'key'))).thenAnswer((_) async => '[]');
  });

  group('update method', () {
    test('updates coffee from favorites when updateValue is CoffeeRating', () async {
      // Arrange
      const keyFav = StorageConstants.favoritesKey;
      const keyHist = StorageConstants.historyKey;
      final validJson = generateJsonFromList([testCoffeeModel]);
      when(() => mockStorage.read(key: keyFav)).thenAnswer((_) async => validJson);
      when(() => mockStorage.write(key: keyFav, value: any(named: 'value'))).thenAnswer((_) => Future.value());
      when(() => mockStorage.read(key: keyHist)).thenAnswer((_) async => '[]');
      // Act
      final result = await updater.update(testCoffee.id, CoffeeRating.fiveStars);
      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(
        () => mockStorage.write(
          key: keyFav,
          value: captureAny(named: 'value'),
        ),
      ).captured.last as String;
      final updatedList =
          (jsonDecode(captured) as List).map((m) => CoffeeModel.fromJson(m as Map<String, dynamic>)).toList();
      expect(updatedList.first.rating, 5);
    });

    test('updates coffee from history when favorites returns recoverable and updateValue is String', () async {
      // Arrange
      const keyFav = StorageConstants.favoritesKey;
      const keyHist = StorageConstants.historyKey;
      final validJson = generateJsonFromList([testCoffeeModel]);
      when(() => mockStorage.read(key: keyFav)).thenAnswer((_) async => '[]');
      when(() => mockStorage.read(key: keyHist)).thenAnswer((_) async => validJson);
      when(() => mockStorage.write(key: keyHist, value: any(named: 'value'))).thenAnswer((_) => Future.value());
      // Act
      final result = await updater.update(testCoffee.id, 'New Comment');
      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(
        () => mockStorage.write(
          key: keyHist,
          value: captureAny(named: 'value'),
        ),
      ).captured.last as String;
      final updatedList =
          (jsonDecode(captured) as List).map((m) => CoffeeModel.fromJson(m as Map<String, dynamic>)).toList();
      expect(updatedList.first.comment, 'New Comment');
    });

    test('returns ItemNeverStoredFailure if not found in both lists', () async {
      // Arrange
      const keyFav = StorageConstants.favoritesKey;
      const keyHist = StorageConstants.historyKey;
      when(() => mockStorage.read(key: keyFav)).thenAnswer((_) async => '[]');
      when(() => mockStorage.read(key: keyHist)).thenAnswer((_) async => '[]');
      // Act
      final result = await updater.update('unknownId', 'whatever');
      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ItemNeverStoredFailure>());
    });

    test('returns ReadingFailure if favorites fails critically', () async {
      // Arrange
      const keyFav = StorageConstants.favoritesKey;
      when(() => mockStorage.read(key: keyFav)).thenAnswer((_) async => throw Exception('Favorites critical'));
      // Act
      final result = await updater.update('coffeeId', CoffeeRating.fourStars);
      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ReadingFailure>());
      verifyNever(() => mockStorage.read(key: StorageConstants.historyKey));
    });

    test('returns ReadingFailure if favorites recoverable and history fails critically', () async {
      // Arrange
      const keyFav = StorageConstants.favoritesKey;
      const keyHist = StorageConstants.historyKey;
      when(() => mockStorage.read(key: keyFav)).thenAnswer((_) async => '[]');
      when(() => mockStorage.read(key: keyHist)).thenAnswer((_) async => throw Exception('History error'));
      // Act
      final result = await updater.update('coffeeId', 'any');
      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ReadingFailure>());
    });
  });

  group('Utility methods indirectly via update', () {
    test('returns success when updateValue is String and one list updates', () async {
      // Arrange
      const keyFav = StorageConstants.favoritesKey;
      const keyHist = StorageConstants.historyKey;
      final validJson = generateJsonFromList([testCoffeeModel]);
      when(() => mockStorage.read(key: keyFav)).thenAnswer((_) async => '[]');
      when(() => mockStorage.read(key: keyHist)).thenAnswer((_) async => validJson);
      when(() => mockStorage.write(key: keyHist, value: any(named: 'value'))).thenAnswer((_) => Future.value());
      // Act
      final result = await updater.update(testCoffee.id, 'Changed Comment');
      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(
        () => mockStorage.write(
          key: keyHist,
          value: captureAny(named: 'value'),
        ),
      ).captured.last as String;
      final updatedList =
          (jsonDecode(captured) as List).map((m) => CoffeeModel.fromJson(m as Map<String, dynamic>)).toList();
      expect(updatedList.first.comment, 'Changed Comment');
    });

    test('returns success when updateValue is CoffeeRating and one list updates', () async {
      // Arrange
      const keyFav = StorageConstants.favoritesKey;
      const keyHist = StorageConstants.historyKey;
      final validJson = generateJsonFromList([testCoffeeModel]);
      when(() => mockStorage.read(key: keyFav)).thenAnswer((_) async => validJson);
      when(() => mockStorage.write(key: keyFav, value: any(named: 'value'))).thenAnswer((_) => Future.value());
      when(() => mockStorage.read(key: keyHist)).thenAnswer((_) async => '[]');
      // Act
      final result = await updater.update(testCoffee.id, CoffeeRating.fiveStars);
      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(
        () => mockStorage.write(
          key: keyFav,
          value: captureAny(named: 'value'),
        ),
      ).captured.last as String;
      final updatedList =
          (jsonDecode(captured) as List).map((m) => CoffeeModel.fromJson(m as Map<String, dynamic>)).toList();
      expect(updatedList.first.rating, 5);
    });

    test('returns ReadingFailure when an unexpected exception is thrown', () async {
      // Arrange
      const keyFav = StorageConstants.favoritesKey;
      const keyHist = StorageConstants.historyKey;
      final validJson = generateJsonFromList([testCoffeeModel]);
      when(() => mockStorage.read(key: keyFav)).thenAnswer((_) async => validJson);
      when(() => mockStorage.read(key: keyHist)).thenAnswer((_) async => validJson);
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => throw Exception('Write error'));
      // Act
      final result = await updater.update(testCoffee.id, 'Some Comment');
      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ReadingFailure>());
    });
  });
}
