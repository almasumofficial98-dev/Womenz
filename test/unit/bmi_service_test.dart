import 'package:flutter_test/flutter_test.dart';
import 'package:womenz/models/user_profile.dart';
import 'package:womenz/services/bmi_service.dart';

void main() {
  group('BmiService Tests', () {
    test('calculateBmi returns correct value for 60kg / 160cm', () {
      final bmi = BmiService.calculateBmi(60.0, 160.0);
      expect(bmi, equals(23.4));
    });

    test('getBmiClassification returns neutral text', () {
      expect(BmiService.getBmiClassification(17.5), equals('Classification: Underweight'));
      expect(BmiService.getBmiClassification(22.0), equals('Classification: Normal Weight'));
      expect(BmiService.getBmiClassification(27.0), equals('Classification: Overweight'));
      expect(BmiService.getBmiClassification(32.0), equals('Classification: Obesity'));
    });

    test('convertWeight handles kg to lb conversion accurately', () {
      final lb = BmiService.convertWeight(50.0, WeightUnit.lb);
      expect(lb, equals(110.2));
    });

    test('formatHeight handles cm to ft-in conversion accurately', () {
      final ftIn = BmiService.formatHeight(165.0, HeightUnit.ftIn);
      expect(ftIn, equals("5'5\""));
    });
  });
}
