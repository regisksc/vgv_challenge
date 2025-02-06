import 'package:equatable/equatable.dart';

class Result<T, F extends Failure> {
  const Result.success(this._successValue)
      : _isSuccess = true,
        _isFailure = false,
        _failure = null;

  const Result.failure(this._failure)
      : _isSuccess = false,
        _isFailure = true,
        _successValue = null;

  final bool _isSuccess;
  final bool _isFailure;
  final T? _successValue;
  final F? _failure;

  bool get isSuccess => _isSuccess;
  bool get isFailure => _isFailure;
  T? get successValue => _successValue;
  F? get failure => _failure;

  R when<R>(
    R Function(T value) success,
    R Function(F failure) failure,
  ) {
    if (_isSuccess) {
      return success(_successValue as T);
    } else {
      return failure(_failure!);
    }
  }

  @override
  String toString() {
    if (_isSuccess) {
      return 'Result.success($successValue)';
    } else {
      return 'Result.failure($failure)';
    }
  }
}

abstract class Failure extends Error implements Equatable {
  Failure({this.message});
  final String? message;

  @override
  List<Object?> get props => [];
}

class UnexpectedInputFailure extends Failure {
  @override
  bool? get stringify => false;
}
