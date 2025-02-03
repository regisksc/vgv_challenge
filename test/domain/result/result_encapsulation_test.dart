import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/domain/domain.dart';

class TestFailure extends Mock implements Failure {}

class MockSuccessCallback extends Mock {
  String call(int value);
}

class MockFailureCallback extends Mock {
  String call(TestFailure failure);
}

void main() {
  setUpAll(() {
    registerFallbackValue(TestFailure());
    registerFallbackValue(MockSuccessCallback());
    registerFallbackValue(MockFailureCallback());
  });

  group('Result', () {
    late MockSuccessCallback mockSuccess;
    late MockFailureCallback mockFailure;

    setUp(() {
      mockSuccess = MockSuccessCallback();
      mockFailure = MockFailureCallback();
    });

    test('returns success values correctly', () {
      // Arrange
      const expectedValue = 42;
      const result = Result<int, TestFailure>.success(expectedValue);

      expect(result.isSuccess, isTrue);
      expect(result.successValue, expectedValue);
      expect(result.failure, isNull);

      when(
        () => mockSuccess(expectedValue),
      ).thenReturn('Success: $expectedValue');

      // Act
      final output = result.when(mockSuccess.call, mockFailure.call);

      // Assert
      expect(output, 'Success: $expectedValue');
      verify(() => mockSuccess(expectedValue)).called(1);
      verifyNever(() => mockFailure(any()));
    });

    test('returns failure values correctly', () {
      // Arrange
      final testFailure = TestFailure();
      final result = Result<int, TestFailure>.failure(testFailure);

      expect(result.isSuccess, isFalse);
      expect(result.successValue, isNull);
      expect(result.failure, testFailure);

      when(
        () => mockFailure(testFailure),
      ).thenReturn('Failure: ${testFailure.message}');

      // Act
      final output = result.when(mockSuccess.call, mockFailure.call);

      // Assert
      expect(output, 'Failure: ${testFailure.message}');
      verify(() => mockFailure(testFailure)).called(1);
      verifyNever(() => mockSuccess(any()));
    });

    test('toString returns correct representation for success', () {
      // Arrange
      const value = 100;
      const result = Result<int, TestFailure>.success(value);

      // Act & Assert
      expect(result.toString(), 'Result.success($value)');
    });

    test('toString returns correct representation for failure', () {
      // Arrange
      final testFailure = TestFailure();
      final result = Result<int, TestFailure>.failure(testFailure);

      // Act & Assert
      expect(result.toString(), 'Result.failure($testFailure)');
    });
  });
}
