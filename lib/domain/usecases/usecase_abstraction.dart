/// Generic interface for all Usecases.
/// input : P
/// return: T
// ignore: one_member_abstracts
abstract class Usecase<T, P> {
  Future<T> call([P? params]);
}
