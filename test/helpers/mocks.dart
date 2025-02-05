// ignore_for_file: lines_longer_than_80_chars

import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

class StorageMock extends Mock implements Storage {}

class GetHistoryListMock extends Mock implements GetCoffeeList {}

class GetFavoritesListMock extends Mock implements GetCoffeeList {}

class FetchCoffeeFromRemoteMock extends Mock implements FetchCoffeeFromRemote {}

class FetchCoffeeFromHistoryMock extends Mock implements FetchCoffeeFromHistory {}

class SaveCoffeeToHistoryMock extends Mock implements SaveCoffeeToHistory {}

class CommentCoffeeMock extends Mock implements UpdateCoffee {}

class RateCoffeeMock extends Mock implements UpdateCoffee {}
