abstract class NavigationState {}

class NavigationInitial extends NavigationState {}

class NavigationRequested extends NavigationState {
  NavigationRequested({
    required this.routeName,
    this.arguments,
    this.onComplete,
  });

  final String routeName;
  final Object? arguments;
  final Function? onComplete;
}
