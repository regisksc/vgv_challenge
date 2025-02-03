import 'package:vgv_challenge/domain/domain.dart';

class HttpFailure extends Failure implements Exception {
  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => false;
}

class BadRequestFailure extends HttpFailure {}

class UnauthorizedFailure extends HttpFailure {}

class NotFoundFailure extends HttpFailure {}

class ServerFailure extends HttpFailure {}

class ClientFailure extends HttpFailure {}

class ConnectionFailure extends HttpFailure {}
