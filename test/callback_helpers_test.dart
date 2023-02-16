import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_week_view/flutter_week_view.dart';

void main() {
  group('roundTimeToFitGrid', () {
    test('Rounds to grid', () {
      expect(roundTimeToFitGrid(DateTime(2020, 1, 1, 9, 59)), DateTime(2020, 1, 1, 10, 0));
      expect(roundTimeToFitGrid(DateTime(2020, 1, 1, 10, 0)), DateTime(2020, 1, 1, 10, 0));
      expect(roundTimeToFitGrid(DateTime(2020, 1, 1, 10, 1)), DateTime(2020, 1, 1, 10, 0));
    });

    test('Works with times close to the rounding edge', () {
      expect(roundTimeToFitGrid(DateTime(2020, 1, 1, 10, 14)), DateTime(2020, 1, 1, 10, 0));
      expect(roundTimeToFitGrid(DateTime(2020, 1, 1, 10, 15)), DateTime(2020, 1, 1, 10, 30));
      expect(roundTimeToFitGrid(DateTime(2020, 1, 1, 10, 16)), DateTime(2020, 1, 1, 10, 30));
    });

    test('Works with different granularity', () {
      DateTime withGranularityOneHour(DateTime dt) =>
          roundTimeToFitGrid(dt, gridGranularity: const Duration(hours: 1));

      expect(withGranularityOneHour(DateTime(2020, 1, 1, 10, 29)), DateTime(2020, 1, 1, 10, 0));
      expect(withGranularityOneHour(DateTime(2020, 1, 1, 10, 30)), DateTime(2020, 1, 1, 11, 0));
      expect(withGranularityOneHour(DateTime(2020, 1, 1, 10, 31)), DateTime(2020, 1, 1, 11, 0));
    });
  });
}
