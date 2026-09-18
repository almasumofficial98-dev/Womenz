import 'package:flutter_test/flutter_test.dart';
import 'package:womenz/core/validation/input_validator.dart';
import 'package:womenz/models/user_profile.dart';
import 'package:womenz/services/hydration_service.dart';

void main() {
  group('Unit Conversion & Validation Tests', () {
    test('InputValidator flags out-of-range weight', () {
      expect(InputValidator.validateWeight(25.0), isNotNull);
      expect(InputValidator.validateWeight(160.0), isNotNull);
      expect(InputValidator.validateWeight(65.0), isNull);
    });

    test('InputValidator flags out-of-range height', () {
      expect(InputValidator.validateHeight(80.0), isNotNull);
      expect(InputValidator.validateHeight(230.0), isNotNull);
      expect(InputValidator.validateHeight(165.0), isNull);
    });

    test('HydrationService formats ml, L, oz correctly', () {
      expect(HydrationService.formatWater(2500, WaterUnit.ml), equals('2500 ml'));
      expect(HydrationService.formatWater(2500, WaterUnit.l), equals('2.5 L'));
      expect(HydrationService.formatWater(2500, WaterUnit.oz), equals('85 oz'));
    });
  });
}
