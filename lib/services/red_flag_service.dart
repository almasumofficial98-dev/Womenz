import '../models/symptom_record.dart';

class RedFlagService {
  /// Evaluates urgent medical symptoms that require immediate healthcare evaluation
  static List<String> evaluateUrgentSymptoms({
    required SymptomRecord? latestSymptomRecord,
    required bool isPregnant,
    required bool hasExtremeBleeding,
    required bool hasFaintingDizziness,
    required bool hasSeverePelvicPain,
    required bool hasNewVisionChanges,
  }) {
    final urgentList = <String>[];

    if (hasSeverePelvicPain ||
        (latestSymptomRecord != null && latestSymptomRecord.pelvicPain == SymptomSeverity.severe)) {
      urgentList.add('Severe pelvic or lower abdominal pain');
    }

    if (hasFaintingDizziness) {
      urgentList.add('Fainting, severe dizziness, or loss of consciousness');
    }

    if (hasExtremeBleeding) {
      urgentList.add('Extremely heavy menstrual bleeding (soaking multiple pads per hour)');
    }

    if (hasNewVisionChanges) {
      urgentList.add('New severe headaches accompanied by vision changes');
    }

    if (isPregnant && (hasSeverePelvicPain || hasExtremeBleeding)) {
      urgentList.add('Abdominal pain or bleeding during suspected/confirmed pregnancy');
    }

    return urgentList;
  }

  static const String urgentCareAdvice =
      'If you are experiencing any of these urgent symptoms, please seek emergency or prompt medical evaluation from a qualified healthcare provider or hospital immediately.';
}
