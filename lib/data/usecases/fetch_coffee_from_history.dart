import 'dart:convert';

import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';


class FetchCoffeeFromHistory implements GetCoffee {
  FetchCoffeeFromHistory({required this.storage});

  final Storage storage;

  @override
  Future<Result<Coffee, Failure>> call([void _]) async {
    try {
      final history = await _getHistory();
      if (history.isEmpty) return Result.failure(ReadingFromEmptyFailure());
      return Result.success(history.last.asEntity);
    } catch (e) {
      return Result.failure(ReadingFailure());
    }
  }

  Future<List<CoffeeModel>> _getHistory() async {
    final json = await storage.read(key: 'history');
    if (json == null) return [];
    return (jsonDecode(json) as List? ?? []).map(_mapFromJson).toList();
  }

  CoffeeModel _mapFromJson(dynamic e) {
    return CoffeeModel.fromJson(e as Map<String, dynamic>);
  }
}
