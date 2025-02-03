import 'package:vgv_challenge/domain/domain.dart';

/// Saves a [Coffee] to either Favorites or History
abstract class SaveCoffee extends Usecase<Result<void, Failure>, Coffee> {}
