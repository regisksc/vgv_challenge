import 'dart:async';

import 'package:dio/dio.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

// is an adapter
class DioHttpClient implements HttpClient {
  DioHttpClient({required this.dio});

  final Dio dio;

  @override
  Future<dynamic> request({
    required String url,
    HttpMethod method = HttpMethod.get,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool isData = false,
  }) async {
    try {
      final response = await dio.request<dynamic>(
        url,
        data: body,
        options: Options(
          method: method.value,
          headers: headers,
          responseType: isData ? ResponseType.bytes : ResponseType.json,
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is! Failure && e is Exception) throw ServerFailure();
      rethrow;
    }
  }

  dynamic _handleResponse(Response<dynamic> response) {
    return switch (response.statusCode) {
      200 => response.data,
      204 => null,
      400 => throw BadRequestFailure(),
      401 || 403 => throw UnauthorizedFailure(),
      404 => throw NotFoundFailure(),
      _ => throw ServerFailure(),
    };
  }

  Exception _mapException(DioException e) {
    return switch (e.type) {
      // ignore: lines_longer_than_80_chars
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout =>
        TimeoutException(e.message),
      DioExceptionType.badResponse => switch (e.response?.statusCode) {
          400 => BadRequestFailure(),
          401 || 403 => UnauthorizedFailure(),
          404 => NotFoundFailure(),
          _ => ServerFailure(),
        },
      _ => ServerFailure(),
    };
  }
}
