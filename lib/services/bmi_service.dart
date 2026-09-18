import '../models/user_profile.dart';

class BmiService {
  /// Calculates BMI value given weight in KG and height in CM
  static double calculateBmi(double weightKg, double heightCm) {
    if (heightCm <= 0 || weightKg <= 0) return 0.0;
    final heightMeters = heightCm / 100.0;
    return double.parse((weightKg / (heightMeters * heightMeters)).toStringAsFixed(1));
  }

  /// Returns neutral classification text
  static String getBmiClassification(double bmi) {
    if (bmi <= 0) return 'Classification: Unknown';
    if (bmi < 18.5) return 'Classification: Underweight';
    if (bmi < 25.0) return 'Classification: Normal Weight';
    if (bmi < 30.0) return 'Classification: Overweight';
    return 'Classification: Obesity';
  }

  /// Converts weight to preferred display unit (kg or lb)
  static double convertWeight(double weightKg, WeightUnit unit) {
    if (unit == WeightUnit.lb) {
      return double.parse((weightKg * 2.20462).toStringAsFixed(1));
    }
    return weightKg;
  }

  /// Converts height to preferred display unit (cm or ft-in formatted string)
  static String formatHeight(double heightCm, HeightUnit unit) {
    if (unit == HeightUnit.ftIn) {
      final totalInches = heightCm / 2.54;
      final feet = (totalInches / 12).floor();
      final inches = (totalInches % 12).round();
      return "$feet'$inches\"";
    }
    return '${heightCm.round()} cm';
  }

  static const String disclaimer =
      'BMI is a general physical screening measure and does not directly diagnose health conditions. It does not account for muscle mass, body composition, or all aspects of health.';
}
