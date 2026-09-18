class LabResult {
  final String id;
  final DateTime date;
  final String testName; // e.g. TSH, Total Testosterone, LH, FSH, HbA1c, DHEAS, Fasting Glucose, Prolactin
  final String value;
  final String unit;
  final String? referenceRange;
  final String? labName;
  final DateTime? reportDate;
  final String? notes;
  final String? attachmentPath; // PDF or Image file path
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  LabResult({
    required this.id,
    required this.date,
    required this.testName,
    required this.value,
    required this.unit,
    this.referenceRange,
    this.labName,
    this.reportDate,
    this.notes,
    this.attachmentPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isDeleted = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'testName': testName,
      'value': value,
      'unit': unit,
      'referenceRange': referenceRange,
      'labName': labName,
      'reportDate': reportDate?.toIso8601String(),
      'notes': notes,
      'attachmentPath': attachmentPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory LabResult.fromMap(Map<String, dynamic> map) {
    return LabResult(
      id: map['id'],
      date: DateTime.parse(map['date']),
      testName: map['testName'],
      value: map['value'],
      unit: map['unit'],
      referenceRange: map['referenceRange'],
      labName: map['labName'],
      reportDate: map['reportDate'] != null ? DateTime.parse(map['reportDate']) : null,
      notes: map['notes'],
      attachmentPath: map['attachmentPath'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isDeleted: map['isDeleted'] == 1,
    );
  }
}
