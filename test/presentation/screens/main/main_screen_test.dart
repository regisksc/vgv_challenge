// ignore_for_file: lines_longer_than_80_chars

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

import '../../../helpers/helpers.dart';

class MockCoffeeCardListBloc extends MockBloc<CoffeeCardListEvent, CoffeeCardListState> implements CoffeeCardListBloc {}

class MockMainScreenBloc extends MockBloc<MainScreenEvent, MainScreenState> implements MainScreenBloc {}

void main() {
  late MockCoffeeCardListBloc mockCoffeeCardListBloc;
  late MockMainScreenBloc mockMainScreenBloc;

  setUp(() {
    mockCoffeeCardListBloc = MockCoffeeCardListBloc();
    mockMainScreenBloc = MockMainScreenBloc();
  });

  setUpAll(() {
    registerFallbackValue(LoadCoffeeCardList());
    registerFallbackValue(ReloadLoadedImage());
  });

  tearDown(() {
    mockCoffeeCardListBloc.close();
    mockMainScreenBloc.close();
  });

  Widget buildApp({
    required CoffeeCardListBloc coffeeCardListBloc,
    required MainScreenBloc mainScreenBloc,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CoffeeCardListBloc>.value(value: coffeeCardListBloc),
        BlocProvider<MainScreenBloc>.value(value: mainScreenBloc),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.details) {
            return MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: const Text('Details'),
                  ),
                  body: Container(),
                );
              },
            );
          }
          return MaterialPageRoute(builder: (context) => const MainScreen());
        },
      ),
    );
  }

  group('MainScreen Tests', () {
    testWidgets('renders correctly', (tester) async {
      // Arrange
      when(() => mockCoffeeCardListBloc.state).thenReturn(
        const CoffeeCardListLoading(),
      );
      when(() => mockMainScreenBloc.state).thenReturn(
        MainScreenLoading(),
      );

      // Act
      await tester.pumpWidget(
        buildApp(
          coffeeCardListBloc: mockCoffeeCardListBloc,
          mainScreenBloc: mockMainScreenBloc,
        ),
      );

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(CoffeeCardListWidget), findsOneWidget);
    });

    testWidgets('shows down arrow when scroll offset is less than 30', (tester) async {
      // Arrange
      when(() => mockCoffeeCardListBloc.state).thenReturn(
        const CoffeeCardListLoaded(list: []),
      );
      when(() => mockMainScreenBloc.state).thenReturn(
        MainScreenLoaded(coffee: dummyCoffee),
      );

      await tester.pumpWidget(
        buildApp(
          coffeeCardListBloc: mockCoffeeCardListBloc,
          mainScreenBloc: mockMainScreenBloc,
        ),
      );

      // Act
      final scrollController = find.byType(Scrollable).evaluate().first.widget as Scrollable;
      scrollController.controller?.jumpTo(20);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('hides down arrow when scroll offset is greater than 30', (tester) async {
      // Arrange
      when(() => mockCoffeeCardListBloc.state).thenReturn(
        const CoffeeCardListLoaded(list: []),
      );
      when(() => mockMainScreenBloc.state).thenReturn(
        MainScreenLoaded(coffee: dummyCoffee),
      );

      await tester.pumpWidget(
        buildApp(
          coffeeCardListBloc: mockCoffeeCardListBloc,
          mainScreenBloc: mockMainScreenBloc,
        ),
      );

      // Act
      final scrollController = find.byType(Scrollable).evaluate().first.widget as Scrollable;
      scrollController.controller?.jumpTo(60);
      await tester.pumpAndSettle();

      final icon = find.byIcon(Icons.keyboard_arrow_down);

      // Assert
      expect(icon, findsOneWidget);

      final animatedOpacityFinder = find.ancestor(
        of: icon,
        matching: find.byType(AnimatedOpacity),
      );
      final animatedOpacityWidget = tester.widget<AnimatedOpacity>(animatedOpacityFinder);
      expect(animatedOpacityWidget.opacity, 0.0);
    });

    testWidgets('handles empty coffee card list state', (tester) async {
      // Arrange
      when(() => mockCoffeeCardListBloc.state).thenReturn(
        const CoffeeCardListLoaded(list: []),
      );
      when(() => mockMainScreenBloc.state).thenReturn(
        MainScreenLoaded(coffee: dummyCoffee),
      );

      await tester.pumpWidget(
        buildApp(
          coffeeCardListBloc: mockCoffeeCardListBloc,
          mainScreenBloc: mockMainScreenBloc,
        ),
      );

      // Assert
      expect(find.text('Last seen'), findsNothing); // shoul;d be ''
    });
  });
}
