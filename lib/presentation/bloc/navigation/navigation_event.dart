abstract class NavigationEvent {}

class NavigateTo extends NavigationEvent {
  NavigateTo({
    required this.routeName,
    this.arguments,
    this.onComplete,
  });

  final String routeName;
  final Object? arguments;
  final Function? onComplete;
}
