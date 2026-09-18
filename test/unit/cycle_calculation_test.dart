import 'package:flutter_test/flutter_test.dart';
import 'package:womenz/models/cycle_record.dart';
import 'package:womenz/services/cycle_calculation_service.dart';

void main() {
  group('CycleCalculationService Tests', () {
    test('calculateCurrentGap handles 28 day cycle correctly', () {
      final now = DateTime(2026, 9, 18);
      final records = [
        CycleRecord(
          id: 'c1',
          startDate: DateTime(2026, 8, 21),
          endDate: DateTime(2026, 8, 26),
        )
      ];

      final gap = CycleCalculationService.calculateCurrentGap(records, targetDate: now);
      expect(gap, equals(28));
    });

    test('calculateCurrentGap handles 180 day gap correctly', () {
      final now = DateTime(2026, 9, 18);
      final records = [
        CycleRecord(
          id: 'c1',
          startDate: DateTime(2026, 3, 22),
          endDate: DateTime(2026, 3, 27),
        )
      ];

      final gap = CycleCalculationService.calculateCurrentGap(records, targetDate: now);
      expect(gap, equals(180));
    });

    test('calculateLongestGap evaluates maximum period gap', () {
      final now = DateTime(2026, 9, 18);
      final records = [
        CycleRecord(id: 'c1', startDate: DateTime(2026, 1, 1)),
        CycleRecord(id: 'c2', startDate: DateTime(2026, 2, 1)), // 31 days
        CycleRecord(id: 'c3', startDate: DateTime(2026, 6, 1)), // 120 days
      ];

      final longest = CycleCalculationService.calculateLongestGap(records, targetDate: now);
      expect(longest, greaterThanOrEqualTo(120));
    });

    test('calculatePeriodsLast12Months counts periods within 365 days', () {
      final now = DateTime(2026, 9, 18);
      final records = [
        CycleRecord(id: 'c1', startDate: DateTime(2025, 10, 1)),
        CycleRecord(id: 'c2', startDate: DateTime(2026, 1, 1)),
        CycleRecord(id: 'c3', startDate: DateTime(2026, 5, 1)),
        CycleRecord(id: 'c4', startDate: DateTime(2024, 1, 1)), // Out of range
      ];

      final count = CycleCalculationService.calculatePeriodsLast12Months(records, targetDate: now);
      expect(count, equals(3));
    });
  });
}
