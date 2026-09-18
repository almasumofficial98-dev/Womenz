class InputValidator {
  /// Validates weight input within 30kg - 150kg range
  static String? validateWeight(double? weightKg) {
    if (weightKg == null) return 'Please enter weight';
    if (weightKg < 30.0 || weightKg > 150.0) {
      return 'Please enter a weight between 30 and 150 kg';
    }
    return null;
  }

  /// Validates height input within 100cm - 220cm range
  static String? validateHeight(double? heightCm) {
    if (heightCm == null) return 'Please enter height';
    if (heightCm < 100.0 || heightCm > 220.0) {
      return 'Please enter a height between 100 and 220 cm';
    }
    return null;
  }

  /// Prevents future dates for historical logs
  static String? validateHistoricalDate(DateTime date) {
    final now = DateTime.now();
    if (date.isAfter(now)) {
      return 'Date cannot be in the future';
    }
    return null;
  }

  /// Validates water volume
  static String? validateWater(int? waterMl) {
    if (waterMl == null || waterMl < 0) {
      return 'Please enter a valid positive water volume';
    }
    if (waterMl > 10000) {
      return 'Water volume exceeds 10L daily limit';
    }
    return null;
  }
}
