import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

import '../../helpers/mocks.dart';

void main() {
  late StorageMock fakeStorage;
  late RateCoffee rateCoffee;
  late Coffee dummyCoffee;
  late UpdateCoffeeParams paramsWithRating;

  setUp(() {
    fakeStorage = StorageMock();
    rateCoffee = RateCoffee(storage: fakeStorage);
    dummyCoffee = Coffee(
      id: 'id1',
      imagePath: 'dummy.jpg',
      seenAt: DateTime.now(),
      comment: 'Old comment',
      rating: CoffeeRating.oneStar,
    );

    paramsWithRating = UpdateCoffeeParams(
      coffee: dummyCoffee,
      newRating: CoffeeRating.fiveStars,
    );
  });

  test('returns failure when params is null', () async {
    // Arrange
    // Act
    final result = await rateCoffee.call();
    // Assert
    expect(result.isFailure, isTrue);
    expect(result.failure, isA<UnexpectedInputFailure>());
  });

  test('returns failure when newRating is null', () async {
    // Arrange
    final params = UpdateCoffeeParams(coffee: dummyCoffee);
    // Act
    final result = await rateCoffee.call(params);
    // Assert
    expect(result.isFailure, isTrue);
    expect(result.failure, isA<UnexpectedInputFailure>());
  });

  test('calls update and returns its result when valid', () async {
    // Arrange
    final mockedJson = jsonEncode([
      CoffeeModel.fromEntity(dummyCoffee).toJson(),
    ]);
    when(
      () => fakeStorage.read(key: any(named: 'key')),
    ).thenAnswer(
      (_) async => mockedJson,
    );
    when(
      () => fakeStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer(
      (_) async => Future.value(),
    );
    // Act
    final result = await rateCoffee.call(paramsWithRating);
    // Assert
    expect(result.isSuccess, isTrue);
  });
}
