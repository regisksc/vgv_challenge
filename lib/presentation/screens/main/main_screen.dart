import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      
      providers: [
        BlocProvider(
          create: (_) => CoffeeCardListBloc(
            getList: sl.get<GetCoffeeList>(instanceName: 'history'),
          )..add(LoadCoffeeCardList()),
        ),
        BlocProvider(
          
          create: (context) => MainScreenBloc(
            historyListBloc: context.read<CoffeeCardListBloc>(),
            apiFetchCoffee: sl.get<FetchCoffeeFromRemote>(),
            localFetchCoffee: sl.get<FetchCoffeeFromHistory>(),
            saveCoffeeToHistory: sl.get<SaveCoffeeToHistory>(),
          )..add(FetchRandomCoffee()),
        ),
        
      ],
      child: BlocListener<MainScreenBloc, MainScreenState>(
        listener: (context, state) {
          if (state is IsNavigating) {
            Navigator.pushNamed(
              context,
              state.destination,
              arguments: (
                coffee: state.coffee,
                historyBloc: context.read<CoffeeCardListBloc>(),
                favoritesBloc: context.read<CoffeeCardListBloc>(),
              ),
            );
          }
        },
        child: const MainScreenContentWidget(),
      ),
    );
  }
}
