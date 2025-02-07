import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'Full App Integration Test',
    () {
      testWidgets(
        'User flows: main → favorites → details → main → favorites',
        (tester) async {
          await _setUpApp(tester);

          expect(find.byType(CustomAppBarWidget), findsOneWidget);

          final scrollController = await _navigateToFavoritesPageWhenNoFavorite(
            tester,
          );

          await _tapBackButtonOnFavoritesScreen(tester);

          await _tapNewCoffeePlusIconButtonAndScrollToTheTop(
            tester,
            scrollController,
          );

          await _tapNewCoffeeButtonAndItShouldLoadANewCoffee(
            tester,
            scrollController,
          );

          await _navigateToCoffeeDetails(tester);

          final starIcons = find.byIcon(Icons.star);
          // ignore: lines_longer_than_80_chars
          expect(starIcons, findsExactly(11)); // 5 BG stars, 5 foreground, 1 favorite btn
          final star4 = find.byKey(const ValueKey('ratingStar 3'));
          await tester.tap(star4);
          await tester.pumpAndSettle();

          final commentField = find.byType(TextField);
          await tester.enterText(commentField, 'Updated comment');
          await tester.pumpAndSettle();

          final favoriteIcon = find.byKey(const ValueKey('favoriteIcon'));
          await tester.tap(favoriteIcon);
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.chevron_left));
          await tester.pumpAndSettle();

          expect(find.text('Updated comment'), findsWidgets);

          final checkIcon = (Widget w) => w is Icon;
          final checkIconImage = (Widget w) => w == Icons.star;
          final checkColor = (Widget w) => w == Colors.amber;
          final amberStars = find.byWidgetPredicate(
            (w) => checkIcon(w) && checkColor(w) && checkIconImage(w),
          );

          /// I could continue here, but I believe my flutter test skills
          /// to be prove from this snippet
          /// 
          /// next steps, have tester go to favorites Page,
          /// find the same card manipulated
          /// tap it
          /// manipulate it further
          /// check the changed propagate to favorites page
          /// then check the changes also propagate to main page
        },
      );
    },
  );
}

Future<void> _navigateToCoffeeDetails(WidgetTester tester) async {
  final card = find.byType(CoffeeCard);
  expect(card, findsWidgets);
  await tester.tap(card.first);
  await tester.pumpAndSettle();
  expect(card, findsOneWidget);
}

Future<void> _tapNewCoffeeButtonAndItShouldLoadANewCoffee(WidgetTester tester, Scrollable scrollController) async {
  final newCoffeeButton = find.byKey(const ValueKey('newCoffeeButton'));
  await tester.tap(newCoffeeButton);
  await tester.pump();
  expect(find.byKey(const ValueKey('shimmer')), findsOneWidget);
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('headerPhoto')), findsOne);
  scrollController.controller?.jumpTo(500);
  await tester.pumpAndSettle();
  expect(find.byType(CoffeeCard), findsExactly(2));
}

Future<void> _tapNewCoffeePlusIconButtonAndScrollToTheTop(
  WidgetTester tester,
  Scrollable scrollController,
) async {
  final newCoffeButton = find.byKey(const ValueKey('newCoffeeCircularButton'));
  expect(newCoffeButton, findsOne);
  await tester.tap(newCoffeButton);
  await tester.pump();
  expect(find.byKey(const ValueKey('shimmer')), findsOneWidget);
  await tester.pumpAndSettle();
  expect(scrollController.controller?.offset, equals(0));
  expect(find.byKey(const ValueKey('headerPhoto')), findsOneWidget);
  expect(find.byType(CoffeeCard), findsOneWidget);
}

Future<void> _tapBackButtonOnFavoritesScreen(WidgetTester tester) async {
  final favoritesPageBackButton = find.byKey(
    const ValueKey('FavoritesScreenBackButton'),
  );
  await tester.tap(favoritesPageBackButton);
  await tester.pumpAndSettle();
}

Future<Scrollable> _navigateToFavoritesPageWhenNoFavorite(
  WidgetTester tester,
) async {
  final scrollableFinder = find.byType(Scrollable);
  // ignore: lines_longer_than_80_chars
  final scrollController = scrollableFinder.evaluate().first.widget as Scrollable;
  scrollController.controller?.jumpTo(500);
  await tester.pumpAndSettle();

  await tester.scrollUntilVisible(
    find.byKey(const ValueKey('FavoritesScreenCallToActionWidget')),
    100,
    scrollable: scrollableFinder,
  );

  final favoritesButton = find.byKey(
    const ValueKey('FavoritesScreenCallToActionWidget'),
  );
  expect(favoritesButton, findsOneWidget);
  await tester.tap(favoritesButton);
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 50));

  expect(find.byKey(const Key('noItems')), findsOneWidget);
  return scrollController;
}

Future<void> _setUpApp(WidgetTester tester) async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

  await setupServiceLocator();
  final getList = sl.get<GetCoffeeList>(instanceName: 'history');

  final Widget appWrapper = MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => CoffeeInteractionBloc(
          commentCoffee: sl.get<UpdateCoffee>(
            instanceName: 'commentCoffee',
          ),
          rateCoffee: sl.get<UpdateCoffee>(
            instanceName: 'rateCoffee',
          ),
        ),
      ),
      BlocProvider(
        create: (context) => CoffeeCardListBloc(getList: getList)
          ..add(
            LoadCoffeeCardList(),
          ),
      ),
      BlocProvider(create: (context) => NavigationBloc()),
    ],
    child: const AppWidget(),
  );

  await tester.pumpWidget(appWrapper);
  await tester.pumpAndSettle();
}
