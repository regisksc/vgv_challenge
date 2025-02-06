import 'package:equatable/equatable.dart';
import 'package:vgv_challenge/domain/domain.dart';

abstract class MainScreenEvent extends Equatable {
  const MainScreenEvent();
  @override
  List<Object?> get props => [];
}

class FetchRandomCoffee extends MainScreenEvent {}

class RefreshRandomCoffee extends MainScreenEvent {}

class TapCoffee extends MainScreenEvent {
  const TapCoffee({this.coffee});

  final Coffee? coffee;
}

class ReloadLoadedImage extends MainScreenEvent {}
