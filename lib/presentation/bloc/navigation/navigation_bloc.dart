import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationInitial()) {
    on<NavigateTo>((event, emit) {
      emit(
        NavigationRequested(
          routeName: event.routeName,
          arguments: event.arguments,
          onComplete: event.onComplete,
        ),
      );
    });
  }
}
