enum FlowLevel { light, medium, heavy, spotting, none }

class CycleRecord {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final FlowLevel flowLevel;
  final bool isSpotting;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isDeleted;

  CycleRecord({
    required this.id,
    required this.startDate,
    this.endDate,
    this.flowLevel = FlowLevel.medium,
    this.isSpotting = false,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.isDeleted = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get durationDays {
    if (endDate == null) return 1;
    return endDate!.difference(startDate).inDays + 1;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'flowLevel': flowLevel.name,
      'isSpotting': isSpotting ? 1 : 0,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory CycleRecord.fromMap(Map<String, dynamic> map) {
    return CycleRecord(
      id: map['id'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      flowLevel: FlowLevel.values.firstWhere(
        (e) => e.name == map['flowLevel'],
        orElse: () => FlowLevel.medium,
      ),
      isSpotting: map['isSpotting'] == 1,
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      deletedAt: map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
      isDeleted: map['isDeleted'] == 1,
    );
  }
}
