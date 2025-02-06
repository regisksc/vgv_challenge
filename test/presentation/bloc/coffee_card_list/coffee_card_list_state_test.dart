import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vgv_challenge/data/data.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('CoffeeCardListState', () {
    group('CoffeeCardListLoading', () {
      test('supports value equality', () {
        expect(const CoffeeCardListLoading(), const CoffeeCardListLoading());
      });
    });

    group('CoffeeCardListLoaded', () {
      test('supports value equality', () {
        expect(
          CoffeeCardListLoaded(list: dummyCoffeeList),
          CoffeeCardListLoaded(list: dummyCoffeeList),
        );
      });

      test('props are correct', () {
        expect(
          CoffeeCardListLoaded(list: dummyCoffeeList).props,
          [dummyCoffeeList],
        );
      });

      test('supports value inequality for different lists', () {
        final differentList = dummyCoffeeList
            .map(
              (e) => CoffeeModel.fromEntity(e).copyWith(
                id: faker.guid.guid(),
              ),
            )
            .toList()
            .asEntities;
        expect(
          CoffeeCardListLoaded(list: dummyCoffeeList),
          isNot(CoffeeCardListLoaded(list: differentList)),
        );
      });
    });

    group('CoffeeCardListFailedLoading', () {
      test('supports value equality with the same failure', () {
        final localFailure = failure;

        expect(
          CoffeeCardListFailedLoading(localFailure),
          CoffeeCardListFailedLoading(localFailure),
        );
      });

      test('props are correct', () {
        final localFailure = failure;
        expect(
          CoffeeCardListFailedLoading(localFailure).props,
          [localFailure],
        );
      });

      test('supports value inequality for different failures', () {
        expect(
          CoffeeCardListFailedLoading(failure),
          isNot(CoffeeCardListFailedLoading(unexpectedInputFailure)),
        );
      });

      test('supports value inequality for different custom failures', () {
        expect(
          CoffeeCardListFailedLoading(unexpectedInputFailure),
          isNot(CoffeeCardListFailedLoading(failure)),
        );
      });
    });
  });
}
