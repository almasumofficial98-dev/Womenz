class WaterLog {
  final String id;
  final DateTime date;
  final int waterMl;
  final int goalMl;
  final DateTime createdAt;
  final DateTime updatedAt;

  WaterLog({
    required this.id,
    required this.date,
    required this.waterMl,
    this.goalMl = 2500,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get progressPercentage {
    if (goalMl <= 0) return 0.0;
    return (waterMl / goalMl).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'waterMl': waterMl,
      'goalMl': goalMl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      waterMl: map['waterMl'],
      goalMl: map['goalMl'] ?? 2500,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
