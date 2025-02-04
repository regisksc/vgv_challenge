// File: test/data/usecases/coffee_update_helper_test.dart

import 'dart:convert';

import 'package:faker/faker.dart';
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

class MockGetCoffee extends Mock implements GetCoffee {}

class MockSaveCoffee extends Mock implements SaveCoffee {}

void main() {
  final faker = Faker();
  late MockStorage mockStorage;
  late TestCoffeeUpdater testUpdater;
  late RateCoffee rateCoffee;
  late CommentCoffee commentCoffee;

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

  CoffeeModel generateCoffeeModel(Coffee coffee) {
    return CoffeeModel.fromEntity(coffee);
  }

  String generateJsonFromList(List<CoffeeModel> models) {
    return jsonEncode(
      models
          .map(
            (m) => m.toJson(),
          )
          .toList(),
    );
  }

  setUp(() {
    mockStorage = MockStorage();
    testUpdater = TestCoffeeUpdater(mockStorage);
    rateCoffee = RateCoffee(storage: mockStorage);
    commentCoffee = CommentCoffee(storage: mockStorage);
  });

  group('updateCoffeeIfPresent', () {
    final testCoffeeModel = CoffeeModel(
      id: '1',
      file: 'test.jpg',
      seenAt: DateTime(2025),
      comment: 'Original comment',
      rating: 3,
    );

    test('successfully updates both comment and rating', () async {
      // Arrange
      const key = StorageConstants.favoritesKey;
      final initialJson = jsonEncode([testCoffeeModel.toJson()]);
      when(
        () => mockStorage.read(key: key),
      ).thenAnswer((_) async => initialJson);
      when(
        () => mockStorage.write(
          key: key,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      // Act
      final result = await testUpdater.updateCoffeeIfPresent(
        key: key,
        coffeeId: '1',
        newComment: 'Updated comment',
        newRating: CoffeeRating.fourStars,
      );

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(
        () => mockStorage.write(
          key: key,
          value: captureAny(named: 'value'),
        ),
      ).captured.single as String;
      final updatedList = (jsonDecode(captured) as List)
          .map(
            (m) => CoffeeModel.fromJson(m as Map<String, dynamic>),
          )
          .toList();
      expect(updatedList.first.comment, 'Updated comment');
      expect(updatedList.first.rating, 4);
    });

    test('updates only comment when rating is not provided', () async {
      // Arrange
      const key = StorageConstants.favoritesKey;
      final initialJson = jsonEncode([testCoffeeModel.toJson()]);
      when(
        () => mockStorage.read(key: key),
      ).thenAnswer((_) async => initialJson);
      when(
        () => mockStorage.write(
          key: key,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      // Act
      final result = await testUpdater.updateCoffeeIfPresent(
        key: key,
        coffeeId: '1',
        newComment: 'Updated comment',
      );

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(
        () => mockStorage.write(
          key: key,
          value: captureAny(named: 'value'),
        ),
      ).captured.single as String;
      final updatedList = (jsonDecode(captured) as List)
          .map(
            (m) => CoffeeModel.fromJson(m as Map<String, dynamic>),
          )
          .toList();
      expect(updatedList.first.comment, 'Updated comment');
      expect(updatedList.first.rating, testCoffeeModel.rating);
    });

    test('updates only rating when comment is not provided', () async {
      // Arrange
      const key = StorageConstants.favoritesKey;
      final initialJson = jsonEncode([testCoffeeModel.toJson()]);
      when(
        () => mockStorage.read(key: key),
      ).thenAnswer((_) async => initialJson);
      when(
        () => mockStorage.write(
          key: key,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      // Act
      final result = await testUpdater.updateCoffeeIfPresent(
        key: key,
        coffeeId: '1',
        newRating: CoffeeRating.fiveStars,
      );

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(
        () => mockStorage.write(
          key: key,
          value: captureAny(named: 'value'),
        ),
      ).captured.single as String;
      final updatedList = (jsonDecode(captured) as List)
          .map(
            (m) => CoffeeModel.fromJson(m as Map<String, dynamic>),
          )
          .toList();
      expect(updatedList.first.comment, testCoffeeModel.comment);
      expect(updatedList.first.rating, 5);
    });

    test('LookedUpItemNotInListFailure when coffee not found', () async {
      // Arrange
      const key = StorageConstants.favoritesKey;
      final initialJson = jsonEncode([testCoffeeModel.toJson()]);
      when(
        () => mockStorage.read(key: key),
      ).thenAnswer((_) async => initialJson);

      // Act
      final result = await testUpdater.updateCoffeeIfPresent(
        key: key,
        coffeeId: '2',
        newComment: 'Updated comment',
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<LookedUpItemNotInListFailure>(),
      );
    });

    test('returns ReadingFailure on storage read error', () async {
      // Arrange
      const key = StorageConstants.favoritesKey;
      when(
        () => mockStorage.read(key: key),
      ).thenThrow(
        Exception('Read error'),
      );

      // Act
      final result = await testUpdater.updateCoffeeIfPresent(
        key: key,
        coffeeId: '1',
        newComment: 'Updated comment',
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<ReadingFailure>(),
      );
    });

    test('returns ReadingFailure on storage write error', () async {
      // Arrange
      const key = StorageConstants.favoritesKey;
      final initialJson = jsonEncode([testCoffeeModel.toJson()]);
      when(
        () => mockStorage.read(key: key),
      ).thenAnswer((_) async => initialJson);
      when(
        () => mockStorage.write(
          key: key,
          value: any(named: 'value'),
        ),
      ).thenThrow(
        Exception('Write error'),
      );

      // Act
      final result = await testUpdater.updateCoffeeIfPresent(
        key: key,
        coffeeId: '1',
        newComment: 'Updated comment',
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<ReadingFailure>(),
      );
    });
  });

  group('RateCoffee', () {
    // ignore: lines_longer_than_80_chars
    test('returns failure(UnexpectedInputFailure) when params is null', () async {
      // Arrange
      // Act
      final result = await rateCoffee.call();

      // Assert
      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<UnexpectedInputFailure>(),
      );
    });

    // ignore: lines_longer_than_80_chars
    test('returns failure(UnexpectedInputFailure) when newRating is null', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final params = UpdateCoffeeParams(coffee: coffee);

      // Act
      final result = await rateCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<UnexpectedInputFailure>(),
      );
    });

    // ignore: lines_longer_than_80_chars
    test('returns failure if update fails in favorites with non-tolerated failures', () async {
      // Arrange
      when(
        () => mockStorage.read(key: StorageConstants.favoritesKey),
      ).thenThrow(
        Exception('Favorites read error'),
      );
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer(
        (_) async => jsonEncode([]),
      );

      final coffee = generateFakeCoffee();
      final params = UpdateCoffeeParams(
        coffee: coffee,
        newRating: CoffeeRating.fiveStars,
      );

      // Act
      final result = await rateCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ReadingFailure>());
    });

    // ignore: lines_longer_than_80_chars
    test('returns failure if update fails in history with non-LookedUpItemNotInListFailure', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(
        () => mockStorage.read(key: StorageConstants.favoritesKey),
      ).thenAnswer(
        (_) async => generateJsonFromList([coffeeModel]),
      );
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenThrow(
        Exception('History read error'),
      );
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final params = UpdateCoffeeParams(
        coffee: coffee,
        newRating: CoffeeRating.fourStars,
      );

      // Act
      final result = await rateCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<ReadingFailure>(),
      );
    });

    // ignore: lines_longer_than_80_chars
    test('ItemNeverStoredFailure when coffee not found in both lists', () async {
      // Arrange
      when(
        () => mockStorage.read(key: StorageConstants.favoritesKey),
      ).thenAnswer(
        (_) async => jsonEncode([]),
      );
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer(
        (_) async => jsonEncode([]),
      );

      final coffee = generateFakeCoffee();
      final params = UpdateCoffeeParams(
        coffee: coffee,
        newRating: CoffeeRating.threeStars,
      );

      // Act
      final result = await rateCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<ItemNeverStoredFailure>(),
      );
    });

    test('updates coffee from favorites if available', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(
        () => mockStorage.read(key: StorageConstants.favoritesKey),
      ).thenAnswer(
        (_) async => generateJsonFromList([coffeeModel]),
      );
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer(
        (_) async => jsonEncode([]),
      );
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final params = UpdateCoffeeParams(
        coffee: coffee,
        newRating: CoffeeRating.fiveStars,
      );

      // Act
      final result = await rateCoffee.call(params);

      // Assert
      expect(result.isSuccess, isTrue);

      final captured = verify(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: captureAny(named: 'value'),
        ),
      ).captured.last as String;
      final updatedList = (jsonDecode(captured) as List)
          .map(
            (m) => CoffeeModel.fromJson(m as Map<String, dynamic>),
          )
          .toList();
      expect(updatedList.first.rating, 5);
    });

    test('updates coffee from history if favorites not updated', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(
        () => mockStorage.read(key: StorageConstants.favoritesKey),
      ).thenAnswer(
        (_) async => jsonEncode([]),
      );
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer(
        (_) async => generateJsonFromList([coffeeModel]),
      );
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final params = UpdateCoffeeParams(
        coffee: coffee,
        newRating: CoffeeRating.threeStars,
      );

      // Act
      final result = await rateCoffee.call(params);

      // Assert
      expect(result.isSuccess, isTrue);

      final captured = verify(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: captureAny(named: 'value'),
        ),
      ).captured.last as String;
      final updatedList = (jsonDecode(captured) as List)
          .map(
            (m) => CoffeeModel.fromJson(m as Map<String, dynamic>),
          )
          .toList();
      expect(updatedList.first.rating, 3);
    });

    test('ReadingFailure when an unexpected exception is thrown', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(
        () => mockStorage.read(key: StorageConstants.favoritesKey),
      ).thenAnswer(
        (_) async => generateJsonFromList([coffeeModel]),
      );
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer(
        (_) async => generateJsonFromList([coffeeModel]),
      );
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(
        Exception('Write error'),
      );

      final params = UpdateCoffeeParams(
        coffee: coffee,
        newRating: CoffeeRating.fiveStars,
      );

      // Act
      final result = await rateCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<ReadingFailure>(),
      );
    });
  });

  group('CommentCoffee', () {
    // ignore: lines_longer_than_80_chars
    test('returns failure(UnexpectedInputFailure) when params is null', () async {
      // Arrange
      // Act
      final result = await commentCoffee.call();

      // Assert
      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<UnexpectedInputFailure>(),
      );
    });

    // ignore: lines_longer_than_80_chars
    test('returns failure(UnexpectedInputFailure) when newComment is null', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final params = UpdateCoffeeParams(coffee: coffee);

      // Act
      final result = await commentCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<UnexpectedInputFailure>(),
      );
    });

    // ignore: lines_longer_than_80_chars
    test('failure if update fails in favorites with non-LookedUpItemNotInListFailure', () async {
      // Arrange
      when(
        () => mockStorage.read(key: StorageConstants.favoritesKey),
      ).thenThrow(
        Exception('Favorites read error'),
      );
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer(
        (_) async => jsonEncode([]),
      );

      final coffee = generateFakeCoffee();
      final params = UpdateCoffeeParams(
        coffee: coffee,
        newComment: faker.lorem.sentence(),
      );

      // Act
      final result = await commentCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<ReadingFailure>(),
      );
    });

    // ignore: lines_longer_than_80_chars
    test('failure if update fails in history with non-LookedUpItemNotInListFailure', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(
        () => mockStorage.read(key: StorageConstants.favoritesKey),
      ).thenAnswer(
        (_) async => generateJsonFromList([coffeeModel]),
      );
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenThrow(
        Exception('History read error'),
      );
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final params = UpdateCoffeeParams(
        coffee: coffee,
        newComment: faker.lorem.sentence(),
      );

      // Act
      final result = await commentCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<ReadingFailure>(),
      );
    });

    // ignore: lines_longer_than_80_chars
    test('ItemNeverStoredFailure when coffee not found in both lists', () async {
      // Arrange
      when(
        () => mockStorage.read(key: StorageConstants.favoritesKey),
      ).thenAnswer(
        (_) async => jsonEncode([]),
      );
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer(
        (_) async => jsonEncode([]),
      );

      final coffee = generateFakeCoffee();
      final params = UpdateCoffeeParams(
        coffee: coffee,
        newComment: faker.lorem.sentence(),
      );

      // Act
      final result = await commentCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<ItemNeverStoredFailure>(),
      );
    });

    test('updates coffee from favorites if available', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(
        () => mockStorage.read(key: StorageConstants.favoritesKey),
      ).thenAnswer(
        (_) async => generateJsonFromList([coffeeModel]),
      );
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer(
        (_) async => jsonEncode([]),
      );
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final newComment = faker.lorem.sentence();
      final params = UpdateCoffeeParams(coffee: coffee, newComment: newComment);

      // Act
      final result = await commentCoffee.call(params);

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: captureAny(named: 'value'),
        ),
      ).captured.last as String;
      final updatedList = (jsonDecode(captured) as List)
          .map(
            (m) => CoffeeModel.fromJson(m as Map<String, dynamic>),
          )
          .toList();
      expect(
        updatedList.first.comment,
        equals(newComment),
      );
    });

    test('updates coffee from history if favorites not updated', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(
        () => mockStorage.read(key: StorageConstants.favoritesKey),
      ).thenAnswer(
        (_) async => jsonEncode([]),
      );
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer(
        (_) async => generateJsonFromList([coffeeModel]),
      );
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final newComment = faker.lorem.sentence();
      final params = UpdateCoffeeParams(coffee: coffee, newComment: newComment);

      // Act
      final result = await commentCoffee.call(params);

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: captureAny(named: 'value'),
        ),
      ).captured.last as String;
      final updatedList = (jsonDecode(captured) as List)
          .map(
            (m) => CoffeeModel.fromJson(m as Map<String, dynamic>),
          )
          .toList();
      expect(
        updatedList.first.comment,
        equals(newComment),
      );
    });

    test('ReadingFailure when an unexpected exception is thrown', () async {
      // Arrange
      final coffee = generateFakeCoffee();
      final coffeeModel = generateCoffeeModel(coffee);

      when(
        () => mockStorage.read(key: StorageConstants.favoritesKey),
      ).thenAnswer(
        (_) async => generateJsonFromList([coffeeModel]),
      );
      when(
        () => mockStorage.read(key: StorageConstants.historyKey),
      ).thenAnswer(
        (_) async => generateJsonFromList([coffeeModel]),
      );
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(
        Exception('Write error'),
      );

      final params = UpdateCoffeeParams(
        coffee: coffee,
        newComment: faker.lorem.sentence(),
      );

      // Act
      final result = await commentCoffee.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<ReadingFailure>(),
      );
    });
  });
}
