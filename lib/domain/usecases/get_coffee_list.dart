import 'package:vgv_challenge/domain/domain.dart';

typedef Coffees = List<Coffee>;

abstract class GetCoffeeList extends Usecase<Result<Coffees, Failure>, void> {}
