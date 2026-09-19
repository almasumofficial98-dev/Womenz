import 'package:flutter_test/flutter_test.dart';
import 'package:womenz/models/cycle_models.dart';
import 'package:womenz/services/cycle_calculator.dart';

void main() {
  group('CycleCalculator Tests', () {
    test('Nil state returns unknown phase and 0 cycle day', () {
      final profile = UserProfile();
      final logs = <CycleLog>[];

      final result = CycleCalculator.calculate(profile: profile, cycleLogs: logs);

      expect(result.currentCycleDay, equals(0));
      expect(result.phase, equals(CyclePhase.unknown));
      expect(result.daysUntilNextPeriod, equals(0));
      expect(result.cycleProgressRatio, equals(0.0));
    });

    test('Regular 28 day cycle phase calculation', () {
      final lastStart = DateTime.now().subtract(const Duration(days: 13)); // Day 14
      final profile = UserProfile(
        healthCondition: HealthCondition.regular,
        avgCycleLength: 28,
        avgPeriodLength: 5,
        lastPeriodStart: lastStart,
      );
      final logs = [
        CycleLog(id: '1', startDate: lastStart, flow: FlowIntensity.medium),
      ];

      final result = CycleCalculator.calculate(profile: profile, cycleLogs: logs);

      expect(result.currentCycleDay, equals(14));
      expect(result.phase, equals(CyclePhase.ovulation));
      expect(result.isOvulationDay, isTrue);
    });

    test('PCOD / PCOS Adaptive range calculation', () {
      final lastStart = DateTime.now().subtract(const Duration(days: 10));
      final profile = UserProfile(
        healthCondition: HealthCondition.pcodPcos,
        avgCycleLength: 35,
        avgPeriodLength: 6,
        cycleVariance: 7,
        lastPeriodStart: lastStart,
      );
      final logs = [
        CycleLog(id: '1', startDate: lastStart, flow: FlowIntensity.medium),
      ];

      final result = CycleCalculator.calculate(profile: profile, cycleLogs: logs);

      expect(result.nextPeriodStartDate, isNotNull);
      expect(result.nextPeriodEndDate, isNotNull);
      expect(result.conditionBanner, contains('PCOD / PCOS'));
    });
  });
}
