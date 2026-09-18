import 'dart:math';
import '../models/screening_result.dart';
import '../models/ultrasound_info.dart';

class HealthScreeningEngine {
  static const String version = '1.0';

  /// Pure domain screening evaluator
  static PcosScreeningResult evaluate(PcosScreeningInput input) {
    final now = DateTime.now();
    final String id = 'scr_${now.millisecondsSinceEpoch}_${Random().nextInt(9999)}';

    // 1. Pregnancy Possibility Gate
    if (input.pregnancyStatus == 'possible' || input.pregnancyStatus == 'confirmed') {
      return PcosScreeningResult(
        id: id,
        screeningVersion: version,
        screeningDate: now,
        outcome: ScreeningOutcome.pregnancyFollowUpNeeded,
        domainsWithIndicators: [],
        flaggedSymptoms: [],
        hasPregnancyPossibility: true,
        clinicalGuidance:
            'Because a period gap was logged with a possibility of pregnancy, prioritize a pregnancy test or professional medical evaluation before evaluating PCOS or hormonal patterns.',
      );
    }

    final domainsWithIndicators = <String>[];
    final flaggedSymptoms = <String>[];

    // 2. Domain 1: Menstrual Irregularity / Ovulatory Dysfunction
    bool hasOvulatoryDomain = false;
    if (input.hasIrregularPeriods || input.longestPeriodGapDays >= 35) {
      hasOvulatoryDomain = true;
      domainsWithIndicators.add('Menstrual Irregularity');
      if (input.longestPeriodGapDays >= 180) {
        flaggedSymptoms.add('Prolonged Period Gap (6+ months)');
      } else if (input.longestPeriodGapDays >= 90) {
        flaggedSymptoms.add('Period Gap (3+ months)');
      } else if (input.longestPeriodGapDays >= 35) {
        flaggedSymptoms.add('Cycle Length > 35 days');
      }
    }

    // 3. Domain 2: Clinical Hyperandrogenism Indicators
    bool hasAndrogenDomain = false;
    int androgenCount = 0;

    if (input.hasAcne) {
      flaggedSymptoms.add('Persistent Acne');
      androgenCount++;
    }
    if (input.hasHirsutism) {
      flaggedSymptoms.add('Excess Facial/Body Hair (Hirsutism)');
      androgenCount++;
    }
    if (input.hasHairThinning) {
      flaggedSymptoms.add('Scalp Hair Thinning');
      androgenCount++;
    }

    if (androgenCount >= 1) {
      hasAndrogenDomain = true;
      domainsWithIndicators.add('Symptoms Associated with Higher Androgen Activity');
    }

    // 4. Domain 3: Ultrasound Information
    bool hasUltrasoundDomain = false;
    if (input.ultrasoundSource == UltrasoundSource.clinicianConfirmedReport ||
        input.ultrasoundSource == UltrasoundSource.userReportedHistory) {
      hasUltrasoundDomain = true;
      domainsWithIndicators.add('Ultrasound Information');
    }

    // 5. Outcome Determination
    ScreeningOutcome outcome;
    if (domainsWithIndicators.isEmpty) {
      outcome = ScreeningOutcome.insufficientInformation;
    } else if (domainsWithIndicators.length == 1) {
      outcome = ScreeningOutcome.indicatorsInOneArea;
    } else {
      outcome = ScreeningOutcome.indicatorsInMultipleAreas;
    }

    // 6. Clinical Guidance Text Formulation
    String guidance = '';
    if (outcome == ScreeningOutcome.insufficientInformation) {
      guidance =
          'Few or no indicators recorded. Continue tracking your cycle and symptoms over time to view health patterns.';
    } else if (outcome == ScreeningOutcome.indicatorsInOneArea) {
      guidance =
          'Indicators were recorded in 1 health area (${domainsWithIndicators.first}). A healthcare professional can help evaluate if these patterns require blood panels or clinical review.';
    } else {
      guidance =
          'Indicators were recorded in ${domainsWithIndicators.length} areas (${domainsWithIndicators.join(", ")}). Clinicians consider your medical history, physical examination, blood tests (e.g. TSH, Testosterone, LH/FSH), and pelvic ultrasound when evaluating PCOS. This screening does not diagnose PCOS.';
    }

    return PcosScreeningResult(
      id: id,
      screeningVersion: version,
      screeningDate: now,
      outcome: outcome,
      domainsWithIndicators: domainsWithIndicators,
      flaggedSymptoms: flaggedSymptoms,
      hasPregnancyPossibility: false,
      clinicalGuidance: guidance,
    );
  }
}
