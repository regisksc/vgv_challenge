import 'package:flutter/foundation.dart';

abstract class NavigationEvent {}

class NavigateTo extends NavigationEvent {
  NavigateTo({
    required this.routeName,
    this.arguments,
    this.onComplete,
  });

  final String routeName;
  final Object? arguments;
  final VoidCallback? onComplete;
}
