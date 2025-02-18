import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

  await setupServiceLocator();
  final getList = sl.get<GetCoffeeList>(instanceName: 'history');
  runApp(
    MultiBlocProvider(
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
      child: await builder(),
    ),
  );
}
