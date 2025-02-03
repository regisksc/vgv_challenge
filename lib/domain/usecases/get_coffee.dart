import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/domain/usecases/usecase_abstraction.dart';

abstract class GetCoffee extends Usecase<Result<Coffee, Failure>, void> {}
