class FamilyHistory {
  final bool hasPCOS;
  final bool hasType2Diabetes;
  final bool hasThyroidCondition;
  final bool hasCardiovascularDisease;
  final String? notes;

  FamilyHistory({
    this.hasPCOS = false,
    this.hasType2Diabetes = false,
    this.hasThyroidCondition = false,
    this.hasCardiovascularDisease = false,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'hasPCOS': hasPCOS ? 1 : 0,
      'hasType2Diabetes': hasType2Diabetes ? 1 : 0,
      'hasThyroidCondition': hasThyroidCondition ? 1 : 0,
      'hasCardiovascularDisease': hasCardiovascularDisease ? 1 : 0,
      'notes': notes,
    };
  }

  factory FamilyHistory.fromMap(Map<String, dynamic> map) {
    return FamilyHistory(
      hasPCOS: map['hasPCOS'] == 1,
      hasType2Diabetes: map['hasType2Diabetes'] == 1,
      hasThyroidCondition: map['hasThyroidCondition'] == 1,
      hasCardiovascularDisease: map['hasCardiovascularDisease'] == 1,
      notes: map['notes'],
    );
  }
}
