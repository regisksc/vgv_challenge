import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

void main() {
  // ignore: lines_longer_than_80_chars
  testWidgets('NavigationListenerWidget pushes route on NavigationRequested event', (tester) async {
    // Arrange
    final navigationBloc = NavigationBloc();
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/test': (context) => const Scaffold(body: Text('Test Page')),
        },
        home: MultiBlocProvider(
          providers: [
            BlocProvider<NavigationBloc>.value(value: navigationBloc),
          ],
          child: const NavigationListenerWidget(child: Text('Home')),
        ),
      ),
    );
    // Act
    navigationBloc.add(NavigateTo(routeName: '/test', arguments: 'testArg'));
    await tester.pumpAndSettle();
    // Assert
    expect(find.text('Test Page'), findsOneWidget);
  });
}
