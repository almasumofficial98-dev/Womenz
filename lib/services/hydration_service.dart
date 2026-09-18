import '../models/user_profile.dart';

class HydrationService {
  /// Converts water volume from internal ML to target display unit
  static String formatWater(int waterMl, WaterUnit unit) {
    if (unit == WaterUnit.l) {
      return '${(waterMl / 1000.0).toStringAsFixed(1)} L';
    } else if (unit == WaterUnit.oz) {
      return '${(waterMl / 29.5735).round()} oz';
    }
    return '$waterMl ml';
  }

  /// Calculates progress ratio between 0.0 and 1.0
  static double calculateProgress(int waterMl, int goalMl) {
    if (goalMl <= 0) return 0.0;
    return (waterMl / goalMl).clamp(0.0, 1.0);
  }

  static const String disclaimer =
      'Hydration goals vary based on factors such as climate, activity, diet, and medical conditions.';
}
