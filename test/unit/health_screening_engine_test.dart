import 'package:flutter_test/flutter_test.dart';
import 'package:womenz/models/screening_result.dart';
import 'package:womenz/models/ultrasound_info.dart';
import 'package:womenz/services/health_screening_engine.dart';

void main() {
  group('HealthScreeningEngine Tests', () {
    test('Pregnancy possibility triggers pregnancy follow up outcome', () {
      final input = PcosScreeningInput(
        longestPeriodGapDays: 120,
        hasIrregularPeriods: true,
        hasAcne: true,
        hasHirsutism: true,
        hasHairThinning: false,
        hasWeightFluctuations: true,
        hasFamilyPCOS: true,
        hasFamilyDiabetes: false,
        pregnancyStatus: 'possible',
        ultrasoundSource: UltrasoundSource.notAvailable,
      );

      final result = HealthScreeningEngine.evaluate(input);
      expect(result.outcome, equals(ScreeningOutcome.pregnancyFollowUpNeeded));
      expect(result.hasPregnancyPossibility, isTrue);
    });

    test('Domain indicators are categorized into separate domains without numerical score', () {
      final input = PcosScreeningInput(
        longestPeriodGapDays: 90,
        hasIrregularPeriods: true,
        hasAcne: true,
        hasHirsutism: true,
        hasHairThinning: false,
        hasWeightFluctuations: false,
        hasFamilyPCOS: false,
        hasFamilyDiabetes: false,
        pregnancyStatus: 'notPossible',
        ultrasoundSource: UltrasoundSource.notAvailable,
      );

      final result = HealthScreeningEngine.evaluate(input);
      expect(result.outcome, equals(ScreeningOutcome.indicatorsInMultipleAreas));
      expect(result.domainsWithIndicators.length, equals(2));
      expect(result.domainsWithIndicators, contains('Menstrual Irregularity'));
      expect(result.domainsWithIndicators, contains('Symptoms Associated with Higher Androgen Activity'));
    });

    test('Insufficient information logged produces insufficientInformation outcome', () {
      final input = PcosScreeningInput(
        longestPeriodGapDays: 28,
        hasIrregularPeriods: false,
        hasAcne: false,
        hasHirsutism: false,
        hasHairThinning: false,
        hasWeightFluctuations: false,
        hasFamilyPCOS: false,
        hasFamilyDiabetes: false,
        pregnancyStatus: 'notPossible',
        ultrasoundSource: UltrasoundSource.notAvailable,
      );

      final result = HealthScreeningEngine.evaluate(input);
      expect(result.outcome, equals(ScreeningOutcome.insufficientInformation));
    });
  });
}
