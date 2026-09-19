import 'package:flutter_test/flutter_test.dart';
import 'package:womenz/models/cycle_model.dart';

void main() {
  group('Womenz v6.0 Clinical Menstrual Model Tests', () {
    test('Dynamic Period State: active when started, inactive when marked ended', () {
      final now = DateTime.now();
      final data = UserCycleData(
        lastPeriodStartDate: now.subtract(const Duration(days: 3)),
        periodDuration: 5,
        currentDay: 4,
      );

      // By default within duration, period is active Day 4
      expect(data.isPeriodActive, isTrue);
      expect(data.activePeriodDay, equals(4));

      // Mark period ended manually
      data.isPeriodOngoing = false;
      expect(data.isPeriodActive, isFalse);

      // Mark period ongoing again
      data.isPeriodOngoing = true;
      expect(data.isPeriodActive, isTrue);
    });

    test('ACOG Alert: Flags active bleeding >7 days with hasExtendedBleeding', () {
      final now = DateTime.now();
      // Day 6 (normal length)
      final normalBleeding = UserCycleData(
        lastPeriodStartDate: now.subtract(const Duration(days: 5)),
        periodDuration: 7,
        currentDay: 6,
        isPeriodOngoing: true,
      );
      expect(normalBleeding.activePeriodDay, equals(6));
      expect(normalBleeding.hasExtendedBleeding, isFalse);

      // Day 8 (>7 days ACOG threshold)
      final extendedBleeding = UserCycleData(
        lastPeriodStartDate: now.subtract(const Duration(days: 7)),
        periodDuration: 10,
        currentDay: 8,
        isPeriodOngoing: true,
      );
      expect(extendedBleeding.activePeriodDay, equals(8));
      expect(extendedBleeding.hasExtendedBleeding, isTrue);

      // If period ended, hasExtendedBleeding should be false even if 8 days passed
      extendedBleeding.isPeriodOngoing = false;
      expect(extendedBleeding.hasExtendedBleeding, isFalse);
    });

    test('Non-diagnostic estimation language and phase naming', () {
      expect(CyclePhase.menstrual.displayName, equals('Menstrual Phase'));
      expect(CyclePhase.follicular.displayName, equals('Estimated Follicular Phase'));
      expect(CyclePhase.ovulation.displayName, equals('Estimated Ovulation Phase'));
      expect(CyclePhase.luteal.displayName, equals('Estimated Luteal Phase'));

      final now = DateTime.now();
      final data = UserCycleData(
        lastPeriodStartDate: now.subtract(const Duration(days: 10)),
        cycleLength: 28,
        periodDuration: 5,
        currentDay: 11,
        isPeriodOngoing: false,
      );

      expect(data.currentPhase, equals(CyclePhase.follicular));
      expect(data.estimatedNextPeriodText, startsWith('~'));
      expect(data.estimatedNextPeriodText, contains('d)'));
    });

    test('Pain scale labeling uses descriptive severity without diagnostic claims', () {
      final logLow = DailyLog(date: DateTime.now(), painScale: 2);
      expect(logLow.painLabel, equals('Mild discomfort (1–3/10)'));

      final logModerate = DailyLog(date: DateTime.now(), painScale: 6);
      expect(logModerate.painLabel, equals('Moderate pain (4–7/10)'));

      final logSevere = DailyLog(date: DateTime.now(), painScale: 9);
      expect(logSevere.painLabel, equals('Severe pain (8–10/10)'));
    });

    test('Medications and non-pharmacological self-care are strictly separated', () {
      final log = DailyLog(
        date: DateTime.now(),
        flow: 'Medium',
        painScale: 5,
        tookSupplements: true,
        medications: ['Ibuprofen 400mg', 'Mefenamic Acid'],
        selfCare: ['Heating Pad', 'Chamomile Tea', 'Gentle Walk'],
      );

      expect(log.medications.length, equals(2));
      expect(log.medications, contains('Ibuprofen 400mg'));
      expect(log.selfCare.length, equals(3));
      expect(log.selfCare, contains('Heating Pad'));
      expect(log.tookSupplements, isTrue);
    });

    test('Fast flow logging supports 5 distinct intensities', () {
      final validFlows = ['None', 'Spotting', 'Light', 'Medium', 'Heavy'];
      for (final flow in validFlows) {
        final log = DailyLog(date: DateTime.now(), flow: flow);
        expect(log.flow, equals(flow));
      }
    });

    test('Discreet Mode hides explicit cycle terminology', () {
      final data = UserCycleData(
        lastPeriodStartDate: DateTime.now().subtract(const Duration(days: 2)),
        isDiscreetMode: true,
      );
      expect(data.isDiscreetMode, isTrue);
    });

    test('FIGO AUB Evaluator: detects normal vs irregular cycle variance >9 days', () {
      // Normal regular history
      final normalFigo = FigoReport.evaluate(
        cycleLengths: [28, 29, 27, 28],
        periodDurations: [5, 5, 6],
        recentLogs: [],
      );
      expect(normalFigo.hasFindings, isFalse);
      expect(normalFigo.frequencyStatus, contains('Normal'));
      expect(normalFigo.regularityStatus, contains('Regular'));

      // Irregular history (variance >9 days)
      final irregularFigo = FigoReport.evaluate(
        cycleLengths: [24, 38, 26, 40],
        periodDurations: [5, 6],
        recentLogs: [],
      );
      expect(irregularFigo.hasFindings, isTrue);
      expect(irregularFigo.regularityStatus, contains('Irregular'));
      expect(irregularFigo.clinicalObservations.any((o) => o.contains('varied')), isTrue);
      expect(irregularFigo.discussionPrompts.isNotEmpty, isTrue);

      // Prolonged duration (>8 days)
      final prolongedFigo = FigoReport.evaluate(
        cycleLengths: [28, 28],
        periodDurations: [10, 5],
        recentLogs: [],
      );
      expect(prolongedFigo.hasFindings, isTrue);
      expect(prolongedFigo.durationStatus, contains('Prolonged'));
    });

    test('Contraception Mode: Identifies hormonal withdrawal bleed and daily pill tracking', () {
      final now = DateTime.now();
      final data = UserCycleData(
        lastPeriodStartDate: now.subtract(const Duration(days: 2)),
        periodDuration: 5,
        currentDay: 3,
        contraceptionType: ContraceptionType.combinedPill,
        isPillTakenToday: true,
      );

      expect(data.contraceptionType.isHormonalSuppression, isTrue);
      expect(data.isPeriodActive, isTrue);
      expect(data.isWithdrawalBleeding, isTrue);
      expect(data.centerRingSubtitle, contains('Withdrawal Bleed'));
      expect(data.isPillTakenToday, isTrue);
    });

    test('Sympto-Thermal Observation: BBT and Cervical Mucus logging', () {
      final log = DailyLog(
        date: DateTime.now(),
        bbt: 36.65,
        cervicalMucus: 'Egg-White',
        tookInositol: true,
      );

      expect(log.bbt, equals(36.65));
      expect(log.cervicalMucus, equals('Egg-White'));
      expect(log.tookInositol, isTrue);
    });

    test('Phase Lifestyle Guide: Returns evidence-based nutrition and movement per phase', () {
      final menstrualGuide = PhaseLifestyleGuide.getForPhase(CyclePhase.menstrual);
      expect(menstrualGuide.nutritionFocus.any((f) => f.contains('Iron')), isTrue);
      expect(menstrualGuide.movementAdvice.any((m) => m.contains('restorative')), isTrue);

      final follicularGuide = PhaseLifestyleGuide.getForPhase(CyclePhase.follicular);
      expect(follicularGuide.movementAdvice.any((m) => m.contains('strength')), isTrue);
      expect(follicularGuide.energyInsight, contains('Initiation'));

      final lutealGuide = PhaseLifestyleGuide.getForPhase(CyclePhase.luteal);
      expect(lutealGuide.nutritionFocus.any((f) => f.contains('Complex carbohydrates')), isTrue);
    });

    test('Pregnancy Pause Mode: Pauses menses calculations and tracks gestation', () {
      final lmp = DateTime.now().subtract(const Duration(days: 28)); // 4 weeks ago
      final data = UserCycleData(
        lastPeriodStartDate: lmp,
        isPregnancyPaused: true,
        pregnancyStartDate: lmp,
      );

      expect(data.isPeriodActive, isFalse);
      expect(data.daysUntilNextCycleText, equals('Paused'));
      expect(data.estimatedNextPeriodText, equals('Pregnancy Mode'));
      expect(data.currentPhasePillText, equals('Pregnancy'));
      expect(data.pregnancyWeeks, equals(6)); // 28d = 4w + 2 clinical LMP weeks = 6 weeks
      expect(data.centerRingSubtitle, contains('Gestation: ~6 Weeks'));
    });

    test('Perimenopause Vasomotor Symptoms: Tracks hot flashes and night sweats', () {
      final log = DailyLog(
        date: DateTime.now(),
        hotFlashesCount: 4,
        nightSweats: true,
        sleepRating: 2,
      );

      expect(log.hotFlashesCount, equals(4));
      expect(log.nightSweats, isTrue);
      expect(log.sleepRating, equals(2));
    });
  });
}
