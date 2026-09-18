enum UltrasoundSource {
  notAvailable,
  userReportedHistory,
  clinicianConfirmedReport,
}

extension UltrasoundSourceExtension on UltrasoundSource {
  String get displayName {
    switch (this) {
      case UltrasoundSource.notAvailable:
        return 'No Ultrasound Available';
      case UltrasoundSource.userReportedHistory:
        return 'User-Reported Previous Finding';
      case UltrasoundSource.clinicianConfirmedReport:
        return 'Clinician-Confirmed Medical Report';
    }
  }
}

class UltrasoundInformation {
  final String id;
  final DateTime date;
  final UltrasoundSource source;
  final String reportSummary;
  final String? notes;
  final DateTime createdAt;

  UltrasoundInformation({
    required this.id,
    required this.date,
    required this.source,
    required this.reportSummary,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'source': source.name,
      'reportSummary': reportSummary,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UltrasoundInformation.fromMap(Map<String, dynamic> map) {
    return UltrasoundInformation(
      id: map['id'],
      date: DateTime.parse(map['date']),
      source: UltrasoundSource.values.firstWhere(
        (e) => e.name == map['source'],
        orElse: () => UltrasoundSource.notAvailable,
      ),
      reportSummary: map['reportSummary'] ?? '',
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
