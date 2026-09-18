enum PregnancyStatus {
  unknown,
  notPossible,
  possible,
  confirmed,
  postpartum,
}

enum WeightUnit { kg, lb }
enum HeightUnit { cm, ftIn }
enum WaterUnit { ml, l, oz }

class UserProfile {
  String userName;
  int? birthYear;
  PregnancyStatus pregnancyStatus;
  bool isBreastfeeding;
  bool isIrregularCycle;
  WeightUnit preferredWeightUnit;
  HeightUnit preferredHeightUnit;
  WaterUnit preferredWaterUnit;
  bool isPinEnabled;
  String? hashedPin;
  List<String> enabledDashboardWidgets;
  DateTime createdAt;
  DateTime updatedAt;

  UserProfile({
    this.userName = 'User',
    this.birthYear,
    this.pregnancyStatus = PregnancyStatus.unknown,
    this.isBreastfeeding = false,
    this.isIrregularCycle = false,
    this.preferredWeightUnit = WeightUnit.kg,
    this.preferredHeightUnit = HeightUnit.cm,
    this.preferredWaterUnit = WaterUnit.ml,
    this.isPinEnabled = false,
    this.hashedPin,
    List<String>? enabledDashboardWidgets,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : enabledDashboardWidgets = enabledDashboardWidgets ?? [
          'period',
          'gap_timeline',
          'body',
          'water',
          'symptoms',
          'pcos',
          'doctor_prep',
          'urgent_care',
        ],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'birthYear': birthYear,
      'pregnancyStatus': pregnancyStatus.name,
      'isBreastfeeding': isBreastfeeding ? 1 : 0,
      'isIrregularCycle': isIrregularCycle ? 1 : 0,
      'preferredWeightUnit': preferredWeightUnit.name,
      'preferredHeightUnit': preferredHeightUnit.name,
      'preferredWaterUnit': preferredWaterUnit.name,
      'isPinEnabled': isPinEnabled ? 1 : 0,
      'hashedPin': hashedPin,
      'enabledDashboardWidgets': enabledDashboardWidgets.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userName: map['userName'] ?? 'User',
      birthYear: map['birthYear'],
      pregnancyStatus: PregnancyStatus.values.firstWhere(
        (e) => e.name == map['pregnancyStatus'],
        orElse: () => PregnancyStatus.unknown,
      ),
      isBreastfeeding: map['isBreastfeeding'] == 1,
      isIrregularCycle: map['isIrregularCycle'] == 1,
      preferredWeightUnit: WeightUnit.values.firstWhere(
        (e) => e.name == map['preferredWeightUnit'],
        orElse: () => WeightUnit.kg,
      ),
      preferredHeightUnit: HeightUnit.values.firstWhere(
        (e) => e.name == map['preferredHeightUnit'],
        orElse: () => HeightUnit.cm,
      ),
      preferredWaterUnit: WaterUnit.values.firstWhere(
        (e) => e.name == map['preferredWaterUnit'],
        orElse: () => WaterUnit.ml,
      ),
      isPinEnabled: map['isPinEnabled'] == 1,
      hashedPin: map['hashedPin'],
      enabledDashboardWidgets: (map['enabledDashboardWidgets'] as String?)?.split(',') ?? [],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
    );
  }
}
