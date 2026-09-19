
enum HealthCondition {
  regular,
  irregular,
  pcodPcos,
  endometriosis,
  perimenopause,
}

extension HealthConditionExt on HealthCondition {
  String get displayName {
    switch (this) {
      case HealthCondition.regular:
        return 'Regular Cycle';
      case HealthCondition.irregular:
        return 'Irregular Cycle';
      case HealthCondition.pcodPcos:
        return 'PCOD / PCOS Care';
      case HealthCondition.endometriosis:
        return 'Endometriosis Care';
      case HealthCondition.perimenopause:
        return 'Perimenopause Care';
    }
  }

  String get dbCode {
    switch (this) {
      case HealthCondition.regular:
        return 'regular';
      case HealthCondition.irregular:
        return 'irregular';
      case HealthCondition.pcodPcos:
        return 'pcod_pcos';
      case HealthCondition.endometriosis:
        return 'endometriosis';
      case HealthCondition.perimenopause:
        return 'perimenopause';
    }
  }

  static HealthCondition fromDbCode(String code) {
    switch (code) {
      case 'irregular':
        return HealthCondition.irregular;
      case 'pcod_pcos':
        return HealthCondition.pcodPcos;
      case 'endometriosis':
        return HealthCondition.endometriosis;
      case 'perimenopause':
        return HealthCondition.perimenopause;
      default:
        return HealthCondition.regular;
    }
  }
}

enum FlowIntensity { spotting, light, medium, heavy, clots }

extension FlowIntensityExt on FlowIntensity {
  String get displayName {
    switch (this) {
      case FlowIntensity.spotting:
        return 'Spotting';
      case FlowIntensity.light:
        return 'Light';
      case FlowIntensity.medium:
        return 'Medium';
      case FlowIntensity.heavy:
        return 'Heavy';
      case FlowIntensity.clots:
        return 'Clots / Very Heavy';
    }
  }
}

class UserProfile {
  final HealthCondition healthCondition;
  final int avgCycleLength;
  final int avgPeriodLength;
  final int cycleVariance; // +/- variance days for irregular / PCOD
  final DateTime? lastPeriodStart;
  final bool isOnboarded;
  final String? privacyPin;

  UserProfile({
    this.healthCondition = HealthCondition.regular,
    this.avgCycleLength = 28,
    this.avgPeriodLength = 5,
    this.cycleVariance = 3,
    this.lastPeriodStart,
    this.isOnboarded = false,
    this.privacyPin,
  });

  UserProfile copyWith({
    HealthCondition? healthCondition,
    int? avgCycleLength,
    int? avgPeriodLength,
    int? cycleVariance,
    DateTime? lastPeriodStart,
    bool? isOnboarded,
    String? privacyPin,
  }) {
    return UserProfile(
      healthCondition: healthCondition ?? this.healthCondition,
      avgCycleLength: avgCycleLength ?? this.avgCycleLength,
      avgPeriodLength: avgPeriodLength ?? this.avgPeriodLength,
      cycleVariance: cycleVariance ?? this.cycleVariance,
      lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      privacyPin: privacyPin ?? this.privacyPin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'healthCondition': healthCondition.dbCode,
      'avgCycleLength': avgCycleLength,
      'avgPeriodLength': avgPeriodLength,
      'cycleVariance': cycleVariance,
      'lastPeriodStart': lastPeriodStart?.toIso8601String(),
      'isOnboarded': isOnboarded,
      'privacyPin': privacyPin,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      healthCondition: HealthConditionExt.fromDbCode(json['healthCondition'] ?? 'regular'),
      avgCycleLength: json['avgCycleLength'] ?? 28,
      avgPeriodLength: json['avgPeriodLength'] ?? 5,
      cycleVariance: json['cycleVariance'] ?? 3,
      lastPeriodStart: json['lastPeriodStart'] != null
          ? DateTime.parse(json['lastPeriodStart'])
          : null,
      isOnboarded: json['isOnboarded'] ?? false,
      privacyPin: json['privacyPin'],
    );
  }
}

class CycleLog {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final FlowIntensity flow;
  final String? notes;

  CycleLog({
    required this.id,
    required this.startDate,
    this.endDate,
    this.flow = FlowIntensity.medium,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'flow': flow.name,
      'notes': notes,
    };
  }

  factory CycleLog.fromJson(Map<String, dynamic> json) {
    return CycleLog(
      id: json['id'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      flow: FlowIntensity.values.firstWhere(
        (e) => e.name == json['flow'],
        orElse: () => FlowIntensity.medium,
      ),
      notes: json['notes'],
    );
  }
}

class SymptomLog {
  final String id;
  final DateTime date;
  final List<String> symptoms;
  final List<String> moods;
  final int waterGlasses;
  final double sleepHours;
  final String? notes;

  SymptomLog({
    required this.id,
    required this.date,
    required this.symptoms,
    required this.moods,
    this.waterGlasses = 0,
    this.sleepHours = 0.0,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'symptoms': symptoms,
      'moods': moods,
      'waterGlasses': waterGlasses,
      'sleepHours': sleepHours,
      'notes': notes,
    };
  }

  factory SymptomLog.fromJson(Map<String, dynamic> json) {
    return SymptomLog(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      moods: List<String>.from(json['moods'] ?? []),
      waterGlasses: json['waterGlasses'] ?? 0,
      sleepHours: (json['sleepHours'] ?? 0.0).toDouble(),
      notes: json['notes'],
    );
  }
}
