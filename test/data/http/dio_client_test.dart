// File: test/data/http/dio_http_client_test.dart

// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late DioHttpClient dioHttpClient;

  setUp(() {
    mockDio = MockDio();
    dioHttpClient = DioHttpClient(dio: mockDio);
  });

  Response<dynamic> makeResponse({
    required int statusCode,
    required Map<String, dynamic>? data,
  }) {
    return Response<Map<String, dynamic>>(
      data: data,
      statusCode: statusCode,
      requestOptions: RequestOptions(path: 'test'),
    );
  }

  group('DioHttpClient.request', () {
    test('returns response.data when status code is 200', () async {
      // Arrange
      final fakeData = {'key': 'value'};
      final response = makeResponse(statusCode: 200, data: fakeData);

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => response);

      // Act
      final result = await dioHttpClient.request(url: 'http://example.com');

      // Assert
      expect(result, equals(fakeData));
    });

    test('returns null when status code is 204', () async {
      // Arrange
      final response = makeResponse(statusCode: 204, data: null);

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => response);

      // Act
      final result = await dioHttpClient.request(url: 'http://example.com');

      // Assert
      expect(result, isNull);
    });

    test('throws BadRequestFailure when status code is 400', () async {
      // Arrange
      final response = makeResponse(statusCode: 400, data: {});

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => response);

      // Act & Assert
      expect(
        () async => dioHttpClient.request(url: 'http://example.com'),
        throwsA(isA<BadRequestFailure>()),
      );
    });

    test('throws UnauthorizedFailure when status code is 401', () async {
      // Arrange
      final response = makeResponse(statusCode: 401, data: {});

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => response);

      // Act & Assert
      expect(
        () async => dioHttpClient.request(url: 'http://example.com'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('throws UnauthorizedFailure when status code is 403', () async {
      // Arrange
      final response = makeResponse(statusCode: 403, data: {});

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => response);

      // Act & Assert
      expect(
        () async => dioHttpClient.request(url: 'http://example.com'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('throws NotFoundFailure when status code is 404', () async {
      // Arrange
      final response = makeResponse(statusCode: 404, data: {});

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => response);

      // Act & Assert
      expect(
        () async => dioHttpClient.request(url: 'http://example.com'),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('throws ServerFailure for any other status code', () async {
      // Arrange
      final response = makeResponse(statusCode: 500, data: {});

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => response);

      // Act & Assert
      expect(
        () async => dioHttpClient.request(url: 'http://example.com'),
        throwsA(isA<ServerFailure>()),
      );
    });

    // Now test the DioException mapping:
    test('maps DioException with connectionTimeout to TimeoutException', () async {
      // Arrange
      final requestOptions = RequestOptions(path: 'http://example.com');
      final dioEx = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
        message: 'timeout error',
      );

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(dioEx);

      // Act & Assert
      expect(
        () async => dioHttpClient.request(url: 'http://example.com'),
        throwsA(predicate((e) => e is TimeoutException && e.message == 'timeout error')),
      );
    });

    test('maps DioException with receiveTimeout to TimeoutException', () async {
      // Arrange
      final requestOptions = RequestOptions(path: 'http://example.com');
      final dioEx = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.receiveTimeout,
        message: 'receive timeout',
      );

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(dioEx);

      // Act & Assert
      expect(
        () async => dioHttpClient.request(url: 'http://example.com'),
        throwsA(predicate((e) => e is TimeoutException && e.message == 'receive timeout')),
      );
    });

    test('maps DioException with badResponse and status 400 to BadRequestFailure', () async {
      // Arrange
      final requestOptions = RequestOptions(path: 'http://example.com');
      final response = Response<dynamic>(
        statusCode: 400,
        requestOptions: requestOptions,
      );
      final dioEx = DioException(
        requestOptions: requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'bad response',
      );

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(dioEx);

      // Act & Assert
      expect(
        () async => dioHttpClient.request(url: 'http://example.com'),
        throwsA(isA<BadRequestFailure>()),
      );
    });

    test('maps DioException with badResponse and status 401 to UnauthorizedFailure', () async {
      // Arrange
      final requestOptions = RequestOptions(path: 'http://example.com');
      final response = Response<dynamic>(
        statusCode: 401,
        requestOptions: requestOptions,
      );
      final dioEx = DioException(
        requestOptions: requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'unauthorized',
      );

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(dioEx);

      // Act & Assert
      expect(
        () async => dioHttpClient.request(url: 'http://example.com'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('maps DioException with badResponse and status 403 to UnauthorizedFailure', () async {
      // Arrange
      final requestOptions = RequestOptions(path: 'http://example.com');
      final response = Response<dynamic>(
        statusCode: 403,
        requestOptions: requestOptions,
      );
      final dioEx = DioException(
        requestOptions: requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'forbidden',
      );

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(dioEx);

      // Act & Assert
      expect(
        () async => dioHttpClient.request(url: 'http://example.com'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('maps DioException with badResponse and status 404 to NotFoundFailure', () async {
      // Arrange
      final requestOptions = RequestOptions(path: 'http://example.com');
      final response = Response<dynamic>(
        statusCode: 404,
        requestOptions: requestOptions,
      );
      final dioEx = DioException(
        requestOptions: requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'not found',
      );

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(dioEx);

      // Act & Assert
      expect(
        () async => dioHttpClient.request(url: 'http://example.com'),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('maps DioException with badResponse and unknown status to ServerFailure', () async {
      // Arrange
      final requestOptions = RequestOptions(path: 'http://example.com');
      final response = Response<dynamic>(
        statusCode: 500,
        requestOptions: requestOptions,
      );
      final dioEx = DioException(
        requestOptions: requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'server error',
      );

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(dioEx);

      // Act & Assert
      expect(
        () async => dioHttpClient.request(url: 'http://example.com'),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('maps DioException with non-badResponse type to ServerFailure', () async {
      // Arrange
      final requestOptions = RequestOptions(path: 'http://example.com');
      final dioEx = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
        message: 'some error',
      );

      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(dioEx);

      // Act & Assert
      expect(
        () async => dioHttpClient.request(url: 'http://example.com'),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('throws ServerFailure when a non-DioException is thrown', () async {
      // Arrange
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(Exception('Unexpected error'));

      // Act & Assert
      expect(
        () async => dioHttpClient.request(url: 'http://example.com'),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
