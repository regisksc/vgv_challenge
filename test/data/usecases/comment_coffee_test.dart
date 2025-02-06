import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mocks.dart';

void main() {
  late StorageMock fakeStorage;
  late CommentCoffee commentCoffee;
  late UpdateCoffeeParams paramsWithComment;

  setUp(() {
    fakeStorage = StorageMock();
    commentCoffee = CommentCoffee(storage: fakeStorage);

    paramsWithComment = UpdateCoffeeParams(
      coffee: dummyCoffee,
      newComment: 'New comment',
    );
  });

  test('returns failure when params is null', () async {
    // Arrange
    // Act
    final result = await commentCoffee.call();
    // Assert
    expect(result.isFailure, isTrue);
    expect(result.failure, isA<UnexpectedInputFailure>());
  });

  test('returns failure when newComment is null', () async {
    // Arrange
    final params = UpdateCoffeeParams(coffee: dummyCoffee);
    // Act
    final result = await commentCoffee.call(params);
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
    final result = await commentCoffee.call(paramsWithComment);
    // Assert
    expect(result.isSuccess, isTrue);
    verify(() => commentCoffee.update(dummyCoffee.id, 'New comment')).called(1);
  });
}
