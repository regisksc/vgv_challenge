import 'package:flutter/foundation.dart';
import 'package:vgv_challenge/domain/domain.dart';

abstract class StorageFailure extends Failure {
  StorageFailure({super.message}) {
    debugPrint(message);
  }
}

class ReadingFailure extends StorageFailure {
  ReadingFailure({
    this.key,
  }) : super(message: 'Storage: No value was found for key $key');

  final String? key;

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => false;
}

class ReadingFromEmptyFailure extends ReadingFailure {
  ReadingFromEmptyFailure({super.key});
}

class LookedUpItemNotInListFailure extends ReadingFailure {
  LookedUpItemNotInListFailure({super.key});
}

class ItemNeverStoredFailure extends ReadingFailure {
  ItemNeverStoredFailure({super.key});
}

class ReadingOrWritingFailure extends StorageFailure {
  ReadingOrWritingFailure({
    required String key,
  }) : super(message: 'Storage: Could not operate on key $key');

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => false;
}

class WritingFailure extends StorageFailure {
  WritingFailure({
    required String key,
  }) : super(message: 'Storage: Could not save value for key $key');

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => false;
}
