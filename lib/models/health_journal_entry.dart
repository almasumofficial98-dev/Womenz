class HealthJournalEntry {
  final String id;
  final DateTime date;
  final String title;
  final String bodyText;
  final bool includeInDoctorReport;
  final DateTime createdAt;

  HealthJournalEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.bodyText,
    this.includeInDoctorReport = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'bodyText': bodyText,
      'includeInDoctorReport': includeInDoctorReport ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HealthJournalEntry.fromMap(Map<String, dynamic> map) {
    return HealthJournalEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      title: map['title'] ?? '',
      bodyText: map['bodyText'] ?? '',
      includeInDoctorReport: map['includeInDoctorReport'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
