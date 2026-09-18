import 'package:flutter_test/flutter_test.dart';
import 'package:womenz/models/symptom_record.dart';
import 'package:womenz/services/red_flag_service.dart';

void main() {
  group('RedFlagService Tests', () {
    test('Severe pelvic pain and fainting trigger urgent medical care symptoms', () {
      final urgent = RedFlagService.evaluateUrgentSymptoms(
        latestSymptomRecord: SymptomRecord(
          id: 's1',
          date: DateTime.now(),
          pelvicPain: SymptomSeverity.severe,
        ),
        isPregnant: false,
        hasExtremeBleeding: false,
        hasFaintingDizziness: true,
        hasSeverePelvicPain: true,
        hasNewVisionChanges: false,
      );

      expect(urgent.length, equals(2));
      expect(urgent, contains('Severe pelvic or lower abdominal pain'));
      expect(urgent, contains('Fainting, severe dizziness, or loss of consciousness'));
    });
  });
}
