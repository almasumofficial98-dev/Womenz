class LifestyleRecord {
  final String id;
  final DateTime date;
  final double? sleepDurationHours;
  final int? exerciseMinutes;
  final int? stressLevel; // 1 to 5 scale
  final String? notes;

  LifestyleRecord({
    required this.id,
    required this.date,
    this.sleepDurationHours,
    this.exerciseMinutes,
    this.stressLevel,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'sleepDurationHours': sleepDurationHours,
      'exerciseMinutes': exerciseMinutes,
      'stressLevel': stressLevel,
      'notes': notes,
    };
  }

  factory LifestyleRecord.fromMap(Map<String, dynamic> map) {
    return LifestyleRecord(
      id: map['id'],
      date: DateTime.parse(map['date']),
      sleepDurationHours: (map['sleepDurationHours'] as num?)?.toDouble(),
      exerciseMinutes: map['exerciseMinutes'],
      stressLevel: map['stressLevel'],
      notes: map['notes'],
    );
  }
}
