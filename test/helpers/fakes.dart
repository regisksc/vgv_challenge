import 'package:mocktail/mocktail.dart';
import 'package:vgv_challenge/domain/domain.dart';

Coffee get dummyCoffee => Coffee(
      id: 'id1',
      imagePath: 'dummy.jpg',
      seenAt: DateTime.now(),
      comment: 'Old comment',
    );

class FakeFailure extends Fake implements Failure {}
