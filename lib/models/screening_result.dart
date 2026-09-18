import 'ultrasound_info.dart';

enum ScreeningOutcome {
  insufficientInformation,
  indicatorsInOneArea,
  indicatorsInMultipleAreas,
  pregnancyFollowUpNeeded,
  urgentSymptomsDetected,
}

extension ScreeningOutcomeExtension on ScreeningOutcome {
  String get title {
    switch (this) {
      case ScreeningOutcome.insufficientInformation:
        return 'Not Enough Information Logged';
      case ScreeningOutcome.indicatorsInOneArea:
        return 'Indicators Recorded in 1 Area';
      case ScreeningOutcome.indicatorsInMultipleAreas:
        return 'Indicators Recorded in 2 or More Areas';
      case ScreeningOutcome.pregnancyFollowUpNeeded:
        return 'Pregnancy Evaluation Recommended';
      case ScreeningOutcome.urgentSymptomsDetected:
        return 'Urgent Medical Symptoms Noted';
    }
  }

  String get summaryText {
    switch (this) {
      case ScreeningOutcome.insufficientInformation:
        return 'Log more period history or symptoms to evaluate health patterns.';
      case ScreeningOutcome.indicatorsInOneArea:
        return 'Your records show indicators in 1 health area. Discuss these findings with a clinician.';
      case ScreeningOutcome.indicatorsInMultipleAreas:
        return 'Indicators were recorded in multiple areas that clinicians may consider when evaluating PCOS or hormonal health.';
      case ScreeningOutcome.pregnancyFollowUpNeeded:
        return 'Because a period gap was logged with a possibility of pregnancy, prioritize a pregnancy test or medical evaluation.';
      case ScreeningOutcome.urgentSymptomsDetected:
        return 'Severe symptoms detected. Please consult a healthcare professional immediately.';
    }
  }
}

class PcosScreeningInput {
  final int? birthYear;
  final int longestPeriodGapDays;
  final bool hasIrregularPeriods;
  final bool hasAcne;
  final bool hasHirsutism;
  final bool hasHairThinning;
  final bool hasWeightFluctuations;
  final bool hasFamilyPCOS;
  final bool hasFamilyDiabetes;
  final String pregnancyStatus; // 'unknown', 'possible', etc.
  final UltrasoundSource ultrasoundSource;

  PcosScreeningInput({
    this.birthYear,
    required this.longestPeriodGapDays,
    required this.hasIrregularPeriods,
    required this.hasAcne,
    required this.hasHirsutism,
    required this.hasHairThinning,
    required this.hasWeightFluctuations,
    required this.hasFamilyPCOS,
    required this.hasFamilyDiabetes,
    required this.pregnancyStatus,
    required this.ultrasoundSource,
  });
}

class PcosScreeningResult {
  final String id;
  final String screeningVersion;
  final DateTime screeningDate;
  final ScreeningOutcome outcome;
  final List<String> domainsWithIndicators;
  final List<String> flaggedSymptoms;
  final bool hasPregnancyPossibility;
  final String clinicalGuidance;

  PcosScreeningResult({
    required this.id,
    this.screeningVersion = '1.0',
    required this.screeningDate,
    required this.outcome,
    required this.domainsWithIndicators,
    required this.flaggedSymptoms,
    required this.hasPregnancyPossibility,
    required this.clinicalGuidance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'screeningVersion': screeningVersion,
      'screeningDate': screeningDate.toIso8601String(),
      'outcome': outcome.name,
      'domainsWithIndicators': domainsWithIndicators.join(','),
      'flaggedSymptoms': flaggedSymptoms.join(','),
      'hasPregnancyPossibility': hasPregnancyPossibility ? 1 : 0,
      'clinicalGuidance': clinicalGuidance,
    };
  }

  factory PcosScreeningResult.fromMap(Map<String, dynamic> map) {
    return PcosScreeningResult(
      id: map['id'],
      screeningVersion: map['screeningVersion'] ?? '1.0',
      screeningDate: DateTime.parse(map['screeningDate']),
      outcome: ScreeningOutcome.values.firstWhere(
        (e) => e.name == map['outcome'],
        orElse: () => ScreeningOutcome.insufficientInformation,
      ),
      domainsWithIndicators: (map['domainsWithIndicators'] as String?)?.split(',') ?? [],
      flaggedSymptoms: (map['flaggedSymptoms'] as String?)?.split(',') ?? [],
      hasPregnancyPossibility: map['hasPregnancyPossibility'] == 1,
      clinicalGuidance: map['clinicalGuidance'] ?? '',
    );
  }
}
