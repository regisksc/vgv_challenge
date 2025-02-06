import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/domain/domain.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

void main() {
  final sl = GetIt.instance;

  setUp(() async {
    // Arrange
    PathProviderPlatform.instance = FakePathProvider();
    await setupServiceLocator();
  });

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await setUpTestHive();
    await Hive.openBox<String>('coffee_box');
  });

  tearDownAll(() async {
    await tearDownTestHive();
  });

  tearDown(() async {
    await sl<Box<String>>().close();
    await sl.reset();
  });

  test('dependencies are registered in GetIt', () {
    // Assert
    expect(sl.isRegistered<Dio>(), isTrue);
    expect(sl.isRegistered<HttpClient>(), isTrue);
    expect(sl.isRegistered<Box<String>>(), isTrue);
    expect(sl.isRegistered<Storage>(), isTrue);
    expect(sl.isRegistered<FetchCoffeeFromRemote>(), isTrue);
    expect(sl.isRegistered<FetchCoffeeFromHistory>(), isTrue);
    expect(sl.isRegistered<GetCoffeeList>(instanceName: 'history'), isTrue);
    expect(
      sl.isRegistered<GetCoffeeList>(
        instanceName: StorageConstants.favoritesKey,
      ),
      isTrue,
    );
    expect(sl.isRegistered<SaveCoffee>(instanceName: 'saveFavorite'), isTrue);
    expect(sl.isRegistered<SaveCoffee>(instanceName: 'saveHistory'), isTrue);
    expect(sl.isRegistered<Unfavorite>(), isTrue);
    expect(
      sl.isRegistered<UpdateCoffee>(instanceName: 'commentCoffee'),
      isTrue,
    );
    expect(sl.isRegistered<UpdateCoffee>(instanceName: 'rateCoffee'), isTrue);
  });
}

class FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '.';
}
