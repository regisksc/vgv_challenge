import 'package:flutter/foundation.dart';
import 'package:vgv_challenge/domain/domain.dart';

abstract class StorageFailure extends Failure {
  StorageFailure({super.message, this.originalException}) {
    debugPrint(message);
    debugPrint(originalException ?? '');
  }
  final String? originalException;
}

class ReadingFailure extends StorageFailure {
  ReadingFailure({
    this.key,
    super.originalException,
  }) : super(
          message: 'Storage: No value was found for key $key',
        );

  final String? key;

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => false;
}

class ReadingFromEmptyFailure extends ReadingFailure {
  ReadingFromEmptyFailure({super.key, super.originalException});
}

class LookedUpItemNotInListFailure extends ReadingFailure {
  LookedUpItemNotInListFailure({super.key, super.originalException});
}

class ItemNeverStoredFailure extends ReadingFailure {
  ItemNeverStoredFailure({super.key, super.originalException});
}

class ReadingOrWritingFailure extends StorageFailure {
  ReadingOrWritingFailure({
    required String key,
    super.originalException,
  }) : super(message: 'Storage: Could not operate on key $key');

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => false;
}

class WritingFailure extends StorageFailure {
  WritingFailure({
    required String key,
    super.originalException,
  }) : super(message: 'Storage: Could not save value for key $key');

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => false;
}
