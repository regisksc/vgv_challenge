import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';

Coffee get dummyCoffee => Coffee(
      id: 'id1',
      imagePath: 'dummy.jpg',
      seenAt: DateTime.now(),
      comment: 'Old comment',
    );

Coffees get dummyCoffeeList => [
      CoffeeModel.fromEntity(dummyCoffee).copyWith(id: '1'),
      CoffeeModel.fromEntity(dummyCoffee).copyWith(id: '2'),
    ].asEntities;

Failure get failure => FakeFailure();
Failure get unexpectedInputFailure => UnexpectedInputFailure();

class FakeFailure extends Fake implements Failure {}
