import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/l10n/l10n.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainScreenBloc(
        historyListBloc: context.read<CoffeeCardListBloc>(),
        apiFetchCoffee: sl.get<FetchCoffeeFromRemote>(),
        localFetchCoffee: sl.get<FetchCoffeeFromHistory>(),
        saveCoffeeToHistory: sl.get<SaveCoffee>(
          instanceName: 'saveHistory',
        ),
      )..add(FetchRandomCoffee()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Lobster',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.brown,
            primary: Colors.brown,
            onPrimary: Colors.brown[900],
            secondary: Colors.brown[900],
            onSecondary: Colors.brown,
            onSurface: Colors.brown[900],
            surface: Colors.brown[50],
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.brown[500],
            foregroundColor: Colors.brown[900],
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.brown[900],
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.brown[900],
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.brown[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintStyle: TextStyle(color: Colors.brown[900]),
          ),
        ),
        onGenerateRoute: AppRoutes.onGenerateRoute,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => CoffeeCardListBloc(
                getList: sl.get<GetCoffeeList>(instanceName: 'history'),
              )..add(LoadCoffeeCardList()),
            ),
            BlocProvider<CoffeeInteractionBloc>(
              create: (_) => CoffeeInteractionBloc(
                commentCoffee: sl.get<UpdateCoffee>(
                  instanceName: 'comment',
                ),
                rateCoffee: sl.get<UpdateCoffee>(
                  instanceName: 'rating',
                ),
              ),
            ),
          ],
          child: const NavigationListenerWidget(
            child: MainScreen(),
          ),
        ),
      ),
    );
  }
}
