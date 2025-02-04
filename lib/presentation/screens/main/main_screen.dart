import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MainScreenBloc(
        historyListBloc: context.read<HistoryListBloc>(),
        apiFetchCoffee: sl.get<FetchCoffeeFromRemote>(),
        localFetchCoffee: sl.get<FetchCoffeeFromHistory>(),
        saveCoffeeToHistory: sl.get<SaveCoffeeToHistory>(),
      )..add(FetchRandomCoffee()),
      child: const MainScreenContentWidget(),
    );
  }
}
