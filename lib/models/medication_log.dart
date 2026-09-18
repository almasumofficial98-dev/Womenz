class MedicationLog {
  final String id;
  final String name;
  final String? dose;
  final String? frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? contraceptionMethod; // e.g. Pill, IUD, Patch, Injection, None
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationLog({
    required this.id,
    required this.name,
    this.dose,
    this.frequency,
    required this.startDate,
    this.endDate,
    this.contraceptionMethod,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dose': dose,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'contraceptionMethod': contraceptionMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MedicationLog.fromMap(Map<String, dynamic> map) {
    return MedicationLog(
      id: map['id'],
      name: map['name'],
      dose: map['dose'],
      frequency: map['frequency'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      contraceptionMethod: map['contraceptionMethod'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
